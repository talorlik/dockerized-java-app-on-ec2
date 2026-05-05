import { test, expect } from '@playwright/test';

test('landing page renders and security headers are present', async ({ page, request }) => {
  // 1. Container-level health (frontend Nginx)
  const healthz = await request.get('/healthz');
  expect(healthz.ok()).toBeTruthy();

  // 2. Backend health proxied via Nginx
  const beHealth = await request.get('/actuator/health');
  expect(beHealth.ok()).toBeTruthy();

  // 3. Page renders + security headers (TR-HARD-010)
  const res = await request.get('/');
  expect(res.ok()).toBeTruthy();
  const headers = res.headers();
  expect(headers['strict-transport-security']).toBeTruthy();
  expect(headers['x-content-type-options']).toBe('nosniff');
  expect(headers['x-frame-options']).toBe('DENY');
  expect(headers['referrer-policy']).toBeTruthy();
  expect(headers['content-security-policy']).toBeTruthy();

  await page.goto('/');
  await expect(page.locator('h1')).toContainText('Welcome');
});

test('signup -> verify code rejection -> login rejection', async ({ page, request }) => {
  const email = `user-${Date.now()}@example.test`;
  const signup = await request.post('/api/auth/signup', {
    data: { email, password: 'CorrectHorse_Battery_5!', fullName: 'Test User' },
  });
  expect(signup.status()).toBe(202);

  // Wrong code -> 400 generic
  const v = await request.post('/api/auth/verify', { data: { email, code: '000000' } });
  expect(v.status()).toBe(400);

  // Login before verify -> 401
  const l = await request.post('/api/auth/login', { data: { email, password: 'CorrectHorse_Battery_5!' } });
  expect(l.status()).toBe(401);
});
