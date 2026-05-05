import { api } from '/js/api.js';
import { navigate } from '/js/router.js';

export function renderVerify(out) {
  let pending = '';
  try { pending = sessionStorage.getItem('pendingEmail') || ''; } catch (_) {}
  out.innerHTML = `
    <div class="card">
      <h2>Verify your email</h2>
      <p class="muted">Enter the code we sent to your email.</p>
      <form id="f">
        <label>Email <input name="email" type="email" required value="${pending}"></label>
        <label>Verification code <input name="code" required></label>
        <button type="submit">Verify</button>
      </form>
      <p id="msg"></p>
    </div>`;
  out.querySelector('#f').addEventListener('submit', async e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    try {
      await api.verify(fd.get('email'), fd.get('code'));
      navigate('/thank-you');
    } catch (err) {
      out.querySelector('#msg').innerHTML = `<span class="error">${err.message}</span>`;
    }
  });
}
