export function renderThanks(out) {
  out.innerHTML = `
    <div class="card">
      <h2>Thanks for signing up</h2>
      <p>Your account is verified.</p>
      <p><a href="/login" data-link><button>Continue to login</button></a></p>
    </div>`;
}
