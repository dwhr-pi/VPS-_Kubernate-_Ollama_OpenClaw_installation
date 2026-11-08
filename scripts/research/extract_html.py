"""Run only inside the networkless adapter sandbox; never launch Chromium or an LLM."""
import contextlib
from html.parser import HTMLParser
import io
import json
import sys


class Text(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts = []

    def handle_data(self, value):
        self.parts.append(value)


def main():
    # The parent passes only bounded HTML, never browser credentials, prompts or environment secrets.
    payload = sys.stdin.read(4 * 1024 ** 2 + 1)
    if len(payload) > 4 * 1024 ** 2:
        raise ValueError('input limit')
    data = json.loads(payload)
    if set(data) != {'url', 'html'} or not all(isinstance(v, str) for v in data.values()):
        raise ValueError('invalid input')
    # Suppress third-party logs, which could include original page contents.
    with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(io.StringIO()):
        from crawl4ai.content_scraping_strategy import LXMLWebScrapingStrategy
        result = LXMLWebScrapingStrategy().scrap(data['url'], data['html'], word_count_threshold=1)
        if not result.success:
            raise ValueError('extraction failed')
    text = Text()
    text.feed(result.cleaned_html)
    print(json.dumps(dict(text=' '.join(' '.join(text.parts).split())[:100000])))


if __name__ == '__main__':
    main()
