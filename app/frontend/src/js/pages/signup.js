import { api } from '/js/api.js';
import { navigate } from '/js/router.js';

export function renderSignup(out) {
  out.innerHTML = `
    <div class="card">
      <h2>Sign up</h2>
      <form id="f">
        <label>Email <input name="email" type="email" required></label>
        <label>Full name <input name="fullName" required></label>
        <label>Password (min 12) <input name="password" type="password" minlength="12" required></label>
        <button type="submit">Create account</button>
      </form>
      <p id="msg"></p>
    </div>`;
  out.querySelector('#f').addEventListener('submit', async e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    try {
      await api.signup(fd.get('email'), fd.get('password'), fd.get('fullName'));
      sessionStorageSafe('pendingEmail', fd.get('email'));
      navigate('/verify');
    } catch (err) {
      out.querySelector('#msg').innerHTML = `<span class="error">${err.message}</span>`;
    }
  });
}

function sessionStorageSafe(k, v) {
  try { sessionStorage.setItem(k, v); } catch (_) {}
}
