// Tiny hash-free path router (works with the Nginx SPA fallback).

const routes = [];
let outlet, navEl, getNav;

export function route(path, render, opts = {}) {
  routes.push({ path, render, ...opts });
}

export function start({ mount, nav, navBuilder }) {
  outlet = mount;
  navEl = nav;
  getNav = navBuilder;
  window.addEventListener('popstate', render);
  document.addEventListener('click', e => {
    const a = e.target.closest('a[data-link]');
    if (!a) return;
    e.preventDefault();
    navigate(a.getAttribute('href'));
  });
  render();
}

export function navigate(path) {
  history.pushState(null, '', path);
  render();
}

function paramsFor(routePath, urlPath) {
  const r = routePath.split('/').filter(Boolean);
  const u = urlPath.split('/').filter(Boolean);
  if (r.length !== u.length) return null;
  const p = {};
  for (let i = 0; i < r.length; i++) {
    if (r[i].startsWith(':')) p[r[i].slice(1)] = decodeURIComponent(u[i]);
    else if (r[i] !== u[i]) return null;
  }
  return p;
}

function render() {
  const url = new URL(window.location.href);
  let matched = null, params = null;
  for (const r of routes) {
    const p = paramsFor(r.path, url.pathname);
    if (p) { matched = r; params = p; break; }
  }
  navEl.innerHTML = getNav();
  if (!matched) {
    outlet.innerHTML = `<div class="card"><h2>Not found</h2></div>`;
    return;
  }
  outlet.innerHTML = '';
  matched.render(outlet, { params, query: Object.fromEntries(url.searchParams.entries()) });
}
