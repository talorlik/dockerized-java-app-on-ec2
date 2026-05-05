import { api, getToken } from '/js/api.js';
import { navigate } from '/js/router.js';

export async function renderAdminList(out, ctx) {
  if (!getToken()) { navigate('/login'); return; }

  const params = {
    page: ctx.query.page || 0,
    size: ctx.query.size || 20,
    sort: ctx.query.sort || 'createdAt',
    dir:  ctx.query.dir  || 'desc',
    q:    ctx.query.q    || '',
    verified: ctx.query.verified || ''
  };

  let data;
  try {
    data = await api.adminList(stripEmpty(params));
  } catch (e) {
    out.innerHTML = `<div class="card error">${escape(e.message)}</div>`;
    return;
  }

  out.innerHTML = `
    <div class="card">
      <div class="toolbar">
        <input id="q" placeholder="search" value="${escape(params.q)}">
        <select id="verified">
          <option value="">all</option>
          <option value="true"  ${params.verified==='true'  ? 'selected':''}>verified</option>
          <option value="false" ${params.verified==='false' ? 'selected':''}>unverified</option>
        </select>
        <button id="apply">Apply</button>
        <a href="${api.adminCsvUrl()}" download><button class="secondary">Export CSV</button></a>
      </div>
      <table>
        <thead>
          <tr><th>id</th><th>email</th><th>name</th><th>verified</th><th>enabled</th><th>created</th><th></th></tr>
        </thead>
        <tbody>
          ${data.items.map(rowHtml).join('')}
        </tbody>
      </table>
      <div class="pager">
        <button class="secondary" id="prev" ${data.page<=0?'disabled':''}>Prev</button>
        <span class="muted">page ${data.page+1} / ${data.totalPages}</span>
        <button class="secondary" id="next" ${data.page+1>=data.totalPages?'disabled':''}>Next</button>
      </div>
    </div>`;

  out.querySelector('#apply').onclick = () => {
    const q = out.querySelector('#q').value;
    const verified = out.querySelector('#verified').value;
    navigate(`/admin/users?q=${encodeURIComponent(q)}&verified=${verified}`);
  };
  out.querySelector('#prev').onclick = () => navigate(buildUrl(params, +params.page-1));
  out.querySelector('#next').onclick = () => navigate(buildUrl(params, +params.page+1));
}

function rowHtml(u) {
  return `<tr>
    <td>${u.id}</td>
    <td>${escape(u.email)}</td>
    <td>${escape(u.fullName)}</td>
    <td>${u.verified}</td>
    <td>${u.enabled}</td>
    <td>${escape(u.createdAt)}</td>
    <td><a href="/admin/users/${u.id}" data-link>edit</a></td>
  </tr>`;
}

function buildUrl(p, page) {
  const o = { ...p, page };
  return `/admin/users?${new URLSearchParams(stripEmpty(o)).toString()}`;
}
function stripEmpty(o) { return Object.fromEntries(Object.entries(o).filter(([,v]) => v !== '' && v !== null && v !== undefined)); }
function escape(s) {
  return String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c]);
}
