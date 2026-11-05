'use strict';
const $ = id => document.getElementById(id);
let navigation = [], currentRequest, searchRequest, timer;
function link(page) {
  const a = document.createElement('a');
  a.href = '/?doc=' + encodeURIComponent(page.path);
  if (page.anchor) a.href += '#' + encodeURIComponent(page.anchor);
  a.textContent = page.title;
  a.dataset.path = page.path;
  a.title = page.path;
  return a;
}
async function json(url, signal) {
  const response = await fetch(url, {signal, credentials: 'omit'});
  if (!response.ok) throw new Error('Dokument nicht verfügbar (' + response.status + ')');
  return response.json();
}
async function show(path, updateHistory = false, hash = '') {
  currentRequest?.abort();
  currentRequest = new AbortController();
  try {
    const page = await json('/api/page?path=' + encodeURIComponent(path), currentRequest.signal);
    // The server sanitizes Markdown and rewrites every local asset/link against its allowlist.
    $('article').innerHTML = page.html;
    $('breadcrumb').textContent = path.split('/').join(' / ');
    document.title = (navigation.find(p => p.path === path)?.title || path) + ' | OpenClaw';
    $('toc').replaceChildren();
    for (const item of page.toc) {
      const a = document.createElement('a');
      a.href = '#' + encodeURIComponent(item.id);
      a.textContent = item.title;
      a.className = item.level > 2 ? 'sub' : '';
      $('toc').append(a);
    }
    for (const block of $('article').querySelectorAll('pre')) {
      const button = document.createElement('button');
      button.className = 'copy'; button.textContent = 'Kopieren';
      button.addEventListener('click', async () => {
        try { await navigator.clipboard.writeText(block.querySelector('code')?.textContent || ''); button.textContent = 'Kopiert'; }
        catch { button.textContent = 'Bitte Text markieren'; }
      });
      block.append(button);
    }
    if (updateHistory) history.pushState(null, '', '/?doc=' + encodeURIComponent(path) + hash);
    document.querySelectorAll('[data-path]').forEach(a => a.classList.toggle('active', a.dataset.path === path));
    document.body.classList.remove('nav-open'); $('menu').setAttribute('aria-expanded', 'false');
    if (hash) {
      const target = document.getElementById(decodeURIComponent(hash.slice(1)));
      for (let parent = target?.parentElement; parent; parent = parent.parentElement) {
        if (parent.tagName === 'DETAILS') parent.open = true;
      }
      target?.scrollIntoView();
    }
    else window.scrollTo({top: 0});
  } catch (error) {
    if (error.name !== 'AbortError') $('article').textContent = error.message;
  }
}
document.addEventListener('click', event => {
  const a = event.target.closest('a');
  if (!a || event.ctrlKey || event.metaKey || event.shiftKey || event.button !== 0) return;
  const url = new URL(a.href, location.href);
  if (url.origin === location.origin && url.pathname === '/' && url.searchParams.has('doc')) {
    event.preventDefault(); show(url.searchParams.get('doc'), true, url.hash);
  }
});
function locationPage() { show(new URLSearchParams(location.search).get('doc') || 'readme.md', false, location.hash); }
window.addEventListener('popstate', locationPage);
$('menu').addEventListener('click', () => {
  const open = document.body.classList.toggle('nav-open'); $('menu').setAttribute('aria-expanded', String(open));
});
$('print').addEventListener('click', () => window.print());
document.addEventListener('keydown', event => {
  if (event.key === '/' && !['INPUT', 'TEXTAREA'].includes(document.activeElement.tagName)) { event.preventDefault(); $('search').focus(); }
  if (event.key === 'Escape') { $('search').value = ''; $('search').dispatchEvent(new Event('input')); document.body.classList.remove('nav-open'); $('menu').setAttribute('aria-expanded', 'false'); }
});
$('search').addEventListener('input', () => {
  clearTimeout(timer); searchRequest?.abort();
  const query = $('search').value.trim();
  $('results').hidden = !query; $('tree').hidden = Boolean(query); $('quick').hidden = Boolean(query);
  if (!query) { $('search-status').textContent = ''; return; }
  timer = setTimeout(async () => {
    searchRequest = new AbortController();
    try {
      const pages = await json('/api/search?q=' + encodeURIComponent(query), searchRequest.signal);
      $('results').replaceChildren(...pages.map(link));
      $('search-status').textContent = pages.length + ' Treffer (maximal 60)';
    } catch (error) { if (error.name !== 'AbortError') $('search-status').textContent = error.message; }
  }, 180);
});
json('/api/index').then(index => {
  navigation = index.pages;
  index.quick.forEach(page => $('quick').append(link(page)));
  const groups = new Map();
  for (const page of index.pages) {
    if (!groups.has(page.group)) {
      const details = document.createElement('details'), summary = document.createElement('summary');
      summary.textContent = page.group; details.append(summary); groups.set(page.group, details); $('tree').append(details);
    }
    groups.get(page.group).append(link(page));
  }
  locationPage();
}).catch(error => { $('article').textContent = error.message; });
