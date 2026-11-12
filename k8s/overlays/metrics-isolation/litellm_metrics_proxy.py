"""Least-privilege scrape bridge. Default is an offline plan, never a listener."""
import argparse
import hmac
import http.client
from http.server import BaseHTTPRequestHandler, HTTPServer
import os
from pathlib import Path
import re
import socket
import stat
import sys
import threading
import time

MAX_BYTES = 4 * 1024 * 1024
TIMEOUT = 3


def read_token(path):
    # Kubernetes projected Secret symlinks are intentional; validate the opened inode.
    fd = os.open(path, os.O_RDONLY | getattr(os, "O_NONBLOCK", 0) | getattr(os, "O_BINARY", 0))
    with os.fdopen(fd, "rb") as stream:
        info = os.fstat(stream.fileno())
        if not stat.S_ISREG(info.st_mode) or info.st_size > 512:
            raise ValueError("Invalid credential file")
        if os.name == "posix" and (info.st_uid not in (0, os.getuid()) or info.st_mode & 0o026):
            raise ValueError("Unsafe credential permissions")
        value = stream.read(513)
    if value.endswith(b"\n"):
        value = value[:-1]
    if not re.fullmatch(rb"[A-Za-z0-9_+/=.-]{32,256}", value):
        raise ValueError("Invalid credential format")
    return value


def interrupt(sock):
    try:
        sock.shutdown(socket.SHUT_RDWR)
    except OSError:
        pass


def fetch_metrics(master, port=4000):
    # Fixed literal loopback target, method and path; no DNS, proxy, redirect or retry.
    connection = http.client.HTTPConnection("127.0.0.1", port, timeout=TIMEOUT)
    timer = None
    deadline = time.monotonic() + TIMEOUT
    try:
        connection.connect()
        sock = connection.sock
        timer = threading.Timer(max(0.001, deadline - time.monotonic()), interrupt, args=(sock,))
        timer.daemon = True
        timer.start()
        connection.request("GET", "/metrics", headers={"Authorization": "Bearer " + master.decode("ascii"),
                           "Accept": "text/plain", "Accept-Encoding": "identity", "Connection": "close"})
        response = connection.getresponse()
        if (response.status != 200 or response.getheader("Content-Type", "").split(";")[0].strip() != "text/plain"
                or response.getheader("Content-Encoding", "identity") != "identity"):
            raise ValueError("Metrics unavailable")
        data = bytearray()
        while True:
            remaining = deadline - time.monotonic()
            if remaining <= 0:
                raise ValueError("Metrics deadline")
            sock.settimeout(remaining)
            chunk = response.read1(min(65536, MAX_BYTES + 1 - len(data)))
            if time.monotonic() > deadline or len(data) + len(chunk) > MAX_BYTES:
                raise ValueError("Metrics limit")
            if not chunk:
                break
            data.extend(chunk)
        if not data or master in data:
            raise ValueError("Invalid metrics payload")
        return bytes(data)
    finally:
        if timer is not None:
            timer.cancel()
        connection.close()


def dispatch(method, path, headers, scrape_file, master_file, fetch=fetch_metrics):
    if method != "GET":
        return 405, b"method denied\n"
    if path not in ("/healthz", "/metrics"):
        return 404, b"not found\n"
    if headers.get_all("Transfer-Encoding") or headers.get_all("Content-Length") not in (None, ["0"]):
        return 400, b"body denied\n"
    if path == "/healthz":
        return 200, b"process alive; upstream not checked\n"
    values = headers.get_all("Authorization", [])
    if len(values) != 1 or not re.fullmatch(r"Bearer [A-Za-z0-9_+/=.-]{32,256}", values[0]):
        return 401, b"unauthorized\n"
    try:
        # Re-open projected files for every scrape so rotation does not require a restart.
        scrape = read_token(scrape_file)
        if not hmac.compare_digest(values[0][7:].encode("ascii"), scrape):
            return 401, b"unauthorized\n"
        master = read_token(master_file)
        if hmac.compare_digest(scrape, master):
            return 503, b"credential separation required\n"
        data = fetch(master)
        if not isinstance(data, bytes) or not data or len(data) > MAX_BYTES or scrape in data or master in data:
            raise ValueError("Invalid metrics payload")
        return 200, data
    except (OSError, ValueError, http.client.HTTPException):
        return 502, b"metrics unavailable\n"


def handler(scrape_file, master_file, port):
    class Handler(BaseHTTPRequestHandler):
        protocol_version = "HTTP/1.0"
        server_version = "MetricsBridge"
        sys_version = ""

        def handle_one_request(self):
            timer = threading.Timer(5, interrupt, args=(self.connection,))
            timer.daemon = True
            timer.start()
            try:
                super().handle_one_request()
            finally:
                timer.cancel()

        def reply(self):
            status, body = dispatch(self.command, self.path, self.headers, scrape_file, master_file,
                                    fetch=lambda key: fetch_metrics(key, port))
            self.send_response(status)
            self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.send_header("Cache-Control", "no-store")
            self.send_header("Connection", "close")
            self.end_headers()
            if self.command != "HEAD":
                self.wfile.write(body)

        do_GET = do_POST = do_PUT = do_DELETE = do_PATCH = do_OPTIONS = do_TRACE = do_HEAD = reply

        def log_message(self, *_):
            pass

        def send_error(self, code, message=None, explain=None):
            # Never reflect arbitrary paths, headers or exception text.
            self.send_response(code)
            self.send_header("Content-Length", "0")
            self.send_header("Connection", "close")
            self.end_headers()
    return Handler


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--serve", action="store_true")
    parser.add_argument("--listen-address", choices=("127.0.0.1", "0.0.0.0"), default="127.0.0.1")
    parser.add_argument("--port", type=int, default=9092)
    parser.add_argument("--upstream-port", type=int, default=4000)
    parser.add_argument("--scrape-token-file", type=Path, default=Path("/run/metrics-scrape/token"))
    parser.add_argument("--master-key-file", type=Path, default=Path("/run/metrics-upstream/master-key"))
    args = parser.parse_args(argv)
    if not args.serve:
        print("Offline-Plan: nur GET /metrics, eigener Scrape-Token, Upstream nur Loopback; kein Secret gelesen.")
        return 0
    if os.name != "posix" or any(not 1024 <= p <= 65535 for p in (args.port, args.upstream_port)) or args.port == args.upstream_port:
        parser.error("Native POSIX-Runtime und unterschiedliche unprivilegierte Ports erforderlich")
    if any(not path.is_absolute() for path in (args.scrape_token_file, args.master_key_file)):
        parser.error("Absolute Credential-Pfade erforderlich")
    class BoundedServer(HTTPServer):
        request_queue_size = 4

        def get_request(self):
            connection, address = super().get_request()
            connection.settimeout(5)
            return connection, address

        def handle_error(self, *_):
            pass
    with BoundedServer((args.listen_address, args.port), handler(args.scrape_token_file, args.master_key_file, args.upstream_port)) as server:
        server.serve_forever()
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except KeyboardInterrupt:
        sys.exit(0)
    except (OSError, ValueError):
        print("Metrics-Bridge konnte nicht sicher gestartet werden.", file=sys.stderr)
        sys.exit(1)
