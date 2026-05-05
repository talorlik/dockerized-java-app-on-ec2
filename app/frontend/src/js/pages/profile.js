import { api, getToken } from '/js/api.js';
import { navigate } from '/js/router.js';

export async function renderProfile(out) {
  if (!getToken()) { navigate('/login'); return; }
  let me;
  try {
    me = await api.me();
  } catch (e) {
    navigate('/login'); return;
  }
  out.innerHTML = `
    <div class="card">
      <h2>Your profile</h2>
      <p><b>Email</b>: <span class="muted">${escape(me.email)}</span> <span class="muted">(read-only)</span></p>
      <form id="f">
        <label>Full name <input name="fullName" value="${escape(me.fullName)}" required></label>
        <button type="submit">Save</button>
      </form>
      <p id="msg"></p>
    </div>`;
  out.querySelector('#f').addEventListener('submit', async e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    try {
      await api.updateMe({ fullName: fd.get('fullName') });
      out.querySelector('#msg').innerHTML = `<span class="ok">Saved.</span>`;
    } catch (err) {
      out.querySelector('#msg').innerHTML = `<span class="error">${escape(err.message)}</span>`;
    }
  });
}

function escape(s) {
  return String(s).replace(/[&<>"']/g, c => ({
    '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'
  })[c]);
}
