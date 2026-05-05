import { route, start, navigate } from '/js/router.js';
import { getToken, clearToken } from '/js/api.js';
import { renderSignup }   from '/js/pages/signup.js';
import { renderVerify }   from '/js/pages/verify.js';
import { renderThanks }   from '/js/pages/thanks.js';
import { renderLogin }    from '/js/pages/login.js';
import { renderProfile }  from '/js/pages/profile.js';
import { renderAdminList } from '/js/pages/admin_list.js';
import { renderAdminEdit } from '/js/pages/admin_edit.js';

route('/',                renderLanding);
route('/signup',          renderSignup);
route('/verify',          renderVerify);
route('/thank-you',       renderThanks);
route('/login',           renderLogin);
route('/profile',         renderProfile,    { auth: true });
route('/admin/users',     renderAdminList);
route('/admin/users/:id', renderAdminEdit);

start({
  mount: document.getElementById('app'),
  nav:   document.getElementById('nav'),
  navBuilder: () => {
    if (getToken()) {
      return `
        <a href="/profile" data-link>Profile</a>
        <a href="/admin/users" data-link>Admin</a>
        <a href="#" id="logout">Logout</a>`;
    }
    return `
      <a href="/login"  data-link>Login</a>
      <a href="/signup" data-link>Sign up</a>`;
  },
});

document.addEventListener('click', e => {
  if (e.target?.id === 'logout') {
    e.preventDefault();
    clearToken();
    navigate('/');
  }
});

function renderLanding(out) {
  out.innerHTML = `
    <div class="card">
      <h1>Welcome</h1>
      <p>Create an account or log in.</p>
      <p>
        <a href="/signup" data-link><button>Sign up</button></a>
        <a href="/login"  data-link><button class="secondary">Login</button></a>
      </p>
    </div>`;
}
