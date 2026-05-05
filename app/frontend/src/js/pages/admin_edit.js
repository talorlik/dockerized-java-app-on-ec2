import { api, getToken } from '/js/api.js';
import { navigate } from '/js/router.js';

export async function renderAdminEdit(out, ctx) {
  if (!getToken()) { navigate('/login'); return; }
  const id = ctx.params.id;
  let u;
  try { u = await api.adminGet(id); } catch (e) {
    out.innerHTML = `<div class="card error">${escape(e.message)}</div>`; return;
  }
  out.innerHTML = `
    <div class="card">
      <h2>User #${u.id}</h2>
      <p><b>Email</b>: ${escape(u.email)}</p>
      <form id="f">
        <label>Full name <input name="fullName" value="${escape(u.fullName)}"></label>
        <label><input type="checkbox" name="enabled" ${u.enabled ? 'checked' : ''}> Enabled</label>
        <label><input type="checkbox" name="resetVerification"> Reset verification status</label>
        <button type="submit">Save</button>
        <button type="button" id="del" class="secondary">Delete</button>
      </form>
      <p id="msg"></p>
    </div>`;
  out.querySelector('#f').addEventListener('submit', async e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    try {
      await api.adminUpdate(id, {
        fullName: fd.get('fullName'),
        enabled: fd.get('enabled') === 'on',
        resetVerification: fd.get('resetVerification') === 'on',
      });
      out.querySelector('#msg').innerHTML = `<span class="ok">Saved.</span>`;
    } catch (err) {
      out.querySelector('#msg').innerHTML = `<span class="error">${escape(err.message)}</span>`;
    }
  });
  out.querySelector('#del').addEventListener('click', async () => {
    if (!confirm(`Delete user ${u.email}?`)) return;
    try { await api.adminDelete(id); navigate('/admin/users'); }
    catch (err) { out.querySelector('#msg').innerHTML = `<span class="error">${escape(err.message)}</span>`; }
  });
}

function escape(s) {
  return String(s ?? '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c]);
}
