// Thin fetch wrapper. JWT is kept in memory only (page-scoped). Reload = logout.

const TOKEN = { value: null };

export function setToken(t)  { TOKEN.value = t; }
export function getToken()   { return TOKEN.value; }
export function clearToken() { TOKEN.value = null; }

async function call(path, { method = 'GET', body, auth = false } = {}) {
  const headers = { 'Content-Type': 'application/json' };
  if (auth && TOKEN.value) headers['Authorization'] = `Bearer ${TOKEN.value}`;

  const res = await fetch(path, {
    method,
    headers,
    body: body ? JSON.stringify(body) : undefined,
    credentials: 'omit',
  });

  let data = null;
  const ct = res.headers.get('content-type') || '';
  if (ct.includes('application/json')) {
    data = await res.json().catch(() => null);
  } else if (ct.startsWith('text/')) {
    data = await res.text().catch(() => null);
  }

  if (!res.ok) {
    const msg = (data && data.message) || `Request failed (${res.status})`;
    const err = new Error(msg);
    err.status = res.status;
    throw err;
  }
  return data;
}

export const api = {
  signup: (email, password, fullName) => call('/api/auth/signup', { method: 'POST', body: { email, password, fullName } }),
  verify: (email, code)               => call('/api/auth/verify', { method: 'POST', body: { email, code } }),
  login:  (email, password)           => call('/api/auth/login',  { method: 'POST', body: { email, password } }),

  me:           ()        => call('/api/profile', { auth: true }),
  updateMe:     (payload) => call('/api/profile', { method: 'PUT', body: payload, auth: true }),

  adminList:    (params)  => call(`/api/admin/users?${new URLSearchParams(params).toString()}`, { auth: true }),
  adminGet:     (id)      => call(`/api/admin/users/${id}`, { auth: true }),
  adminUpdate:  (id, p)   => call(`/api/admin/users/${id}`, { method: 'PUT', body: p, auth: true }),
  adminDelete:  (id)      => call(`/api/admin/users/${id}`, { method: 'DELETE', auth: true }),
  adminCsvUrl:  ()        => '/api/admin/users.csv',
};
