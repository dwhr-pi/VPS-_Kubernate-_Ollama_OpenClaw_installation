"""Local-only, bounded pre-call policy for a single LiteLLM process; no prompt/key logging."""
from collections import defaultdict
import hashlib
import ipaddress
import json
import os
import re
import threading
import time
from urllib.parse import urlsplit

from fastapi import HTTPException
from litellm.integrations.custom_logger import CustomLogger


def local_backend(model, url):
    if not isinstance(model, str) or not model.startswith('ollama/'):
        return False
    try:
        parsed = urlsplit(url)
        if (parsed.scheme not in ('http', 'https') or parsed.username or parsed.password
                or parsed.port != 11434 or parsed.path not in ('', '/') or parsed.query or parsed.fragment):
            return False
        if parsed.hostname in ('ollama', 'ollama.llmops.svc.cluster.local', 'localhost'):
            return True
        address = ipaddress.ip_address(parsed.hostname)
        return address.is_loopback or any(address in ipaddress.ip_network(network)
                 for network in ('10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16'))
    except (TypeError, ValueError):
        return False


class LocalPolicy(CustomLogger):
    def __init__(self):
        super().__init__()
        self.lock = threading.Lock()
        self.window = 0
        self.counts = defaultdict(int)
        self.total = 0

    async def async_pre_call_hook(self, user_api_key_dict, cache, data, call_type):
        if (call_type != 'completion' or not isinstance(data, dict)
                or data.get('model') not in ('local-default', 'ollama-default')
                or not local_backend(os.environ.get('LITELLM_OLLAMA_MODEL'), os.environ.get('OLLAMA_API_BASE'))):
            raise HTTPException(status_code=403, detail='Local route policy rejected request')
        if any(key in data for key in ('api_base', 'api_key', 'base_url', 'custom_llm_provider')):
            raise HTTPException(status_code=403, detail='Client route overrides forbidden')
        messages = data.get('messages')
        if not isinstance(messages, list) or not 1 <= len(messages) <= 64:
            raise HTTPException(status_code=400, detail='Invalid message envelope')
        for message in messages:
            if (not isinstance(message, dict) or message.get('role') not in ('system', 'user', 'assistant', 'tool')
                    or message.get('content') is not None and not isinstance(message.get('content'), str)):
                raise HTTPException(status_code=400, detail='Only bounded text/tool messages supported')
        try:
            body = json.dumps(messages, ensure_ascii=True)
        except (ValueError, TypeError):
            raise HTTPException(status_code=400, detail='Invalid message encoding') from None
        if len(body.encode()) > 65536 or re.search(r'-----BEGIN [A-Z ]*PRIVATE KEY-----|sk-[A-Za-z0-9_-]{24,}', body):
            raise HTTPException(status_code=400, detail='Input size or credential-pattern policy rejected request')
        for name in ('max_tokens', 'max_completion_tokens'):
            if name in data and (type(data[name]) is not int or not 1 <= data[name] <= 1024):
                raise HTTPException(status_code=400, detail='Output token limit exceeded')
        if 'max_tokens' not in data and 'max_completion_tokens' not in data:
            data['max_tokens'] = 256
        identity = (user_api_key_dict.get('api_key') if isinstance(user_api_key_dict, dict)
                    else getattr(user_api_key_dict, 'api_key', None))
        if not isinstance(identity, str) or not identity:
            raise HTTPException(status_code=403, detail='Authenticated key identity required')
        digest = hashlib.sha256(identity.encode()).hexdigest()
        window = int(time.monotonic() // 60)
        with self.lock:
            if window != self.window:
                self.window, self.total = window, 0
                self.counts.clear()
            if self.total >= 32 or self.counts.get(digest, 0) >= 8:
                raise HTTPException(status_code=429, detail='Single-process rate quota exceeded')
            self.total += 1
            self.counts[digest] += 1
        return data


policy = LocalPolicy()
