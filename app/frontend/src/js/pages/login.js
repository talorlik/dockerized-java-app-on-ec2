import { api, setToken } from '/js/api.js';
import { navigate } from '/js/router.js';

export function renderLogin(out) {
  out.innerHTML = `
    <div class="card">
      <h2>Login</h2>
      <form id="f">
        <label>Email <input name="email" type="email" required></label>
        <label>Password <input name="password" type="password" required></label>
        <button type="submit">Login</button>
      </form>
      <p id="msg"></p>
    </div>`;
  out.querySelector('#f').addEventListener('submit', async e => {
    e.preventDefault();
    const fd = new FormData(e.target);
    try {
      const res = await api.login(fd.get('email'), fd.get('password'));
      setToken(res.token);
      navigate('/profile');
    } catch (err) {
      out.querySelector('#msg').innerHTML = `<span class="error">${err.message}</span>`;
    }
  });
}
