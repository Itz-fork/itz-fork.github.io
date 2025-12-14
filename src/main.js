// Navigation logic.

const buttons = document.querySelectorAll('.nav button');
const islands = document.querySelectorAll('.island');


// Detect if device is desktop
function isDesktop() {
  return window.matchMedia('only screen and (min-device-width: 800px)').matches;
}
let cachedIsDesktop = isDesktop();
window.addEventListener('resize', () => {
  cachedIsDesktop = isDesktop();
});

buttons.forEach(btn => {
  btn.addEventListener('click', () => {
    const target = document.getElementById(btn.dataset.target);
    if (!target) return;

    // Update active nav state
    buttons.forEach(b => {
      b.classList.remove('active');
      b.removeAttribute('aria-current');
    });

    btn.classList.add('active');
    btn.setAttribute('aria-current', 'page');

    // Desktop = app-style swap
    if (cachedIsDesktop) {
      islands.forEach(i => i.classList.toggle('active', i === target));
      target.focus({ preventScroll: true });
    }
    // Mobile = normal scroll
    else {
      target.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
  });
});

// Cursor behavior (desktop only)
document.addEventListener('DOMContentLoaded', () => {
  const cursor = document.querySelector('.custom-cursor');
  if (!cursor) return;

  document.addEventListener('mousemove', (e) => {
    if (!cachedIsDesktop) {
      cursor.classList.add('hide');
      return;
    }
    cursor.style.left = e.clientX + 'px';
    cursor.style.top = e.clientY + 'px';
  });

  document.body.addEventListener('mouseleave', () => cursor.classList.add('hide'));
  document.body.addEventListener('mouseenter', () => cursor.classList.remove('hide'));

  document.body.addEventListener('mouseenter', (e) => {
    const el = e.target.closest('a, button, input[type="submit"], [data-cursor-hover]');
    if (el && isDesktop()) cursor.classList.add('hover');
  }, true);

  document.body.addEventListener('mouseleave', (e) => {
    const el = e.target.closest('a, button, input[type="submit"], [data-cursor-hover]');
    if (el) cursor.classList.remove('hover');
  }, true);
});

// Fake terminal boot
const term = document.getElementById('term');
const replayBtn = document.querySelector('.term-replay');

const terminalLines = [
  'Booting runtime...',
  'Loading config... OK',
  'Connecting to database... OK',
  'Starting worker pool... OK',
  '',
  'GET /about HTTP/1.1',
  'Host: hirusha.dev',
  '',
  'HTTP/1.1 200 OK',
  'Content-Type: application/json',
  'Cache-Control: no-store',
  '',
  '{',
  '  "name": "Hirusha Himath",',
  '  "role": "Backend & Automation Engineer",',
  '  "location": "Sri Lanka",',
  '  "focus": [',
  '    "backend systems",',
  '    "automation",',
  '    "APIs",',
  '    "reliability-first design"',
  '  ],',
  '  "availability": "open_to_work"',
  '}'
];

let termBuffer;

function playTerminal() {
  if (termBuffer) clearInterval(termBuffer);
  term.textContent = '';
  lineIndex = 0;

  termBuffer = setInterval(() => {
    if (lineIndex >= terminalLines.length) {
      clearInterval(termBuffer);
      termBuffer = null;
      return;
    }
    term.textContent += terminalLines[lineIndex] + '\n';
    lineIndex++;
  }, 180);
}

// Initial run
playTerminal();

// Replay handler
replayBtn?.addEventListener('click', playTerminal);


// Auto-grow textarea in contact form.
const messageTextarea = document.querySelector('#contact textarea');

if (messageTextarea) {
  const autoResize = () => {
    messageTextarea.style.height = 'auto';
    messageTextarea.style.height = messageTextarea.scrollHeight + 'px';
  };

  messageTextarea.addEventListener('input', autoResize);
  autoResize();
}

// Contact form submission logic
const form = document.getElementById('contact-form');
const statusEl = document.getElementById('form-status');

if (form) {
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const submitBtn = form?.querySelector('button[type="submit"]');
    const email = form.email.value.trim();
    const msg = form.msg.value.trim();

    // Basic validation
    // Email empty
    if (!email) {
      setStatus('Email is required.', true);
      return;
    }

    // Email format
    if (!isValidEmail(email)) {
      setStatus('Please enter a valid email address.', true);
      return;
    }

    // Message empty
    if (!msg) {
      setStatus('Message is required.', true);
      return;
    }

    // Message length
    if (msg.length < 10) {
      setStatus('Message must be at least 10 characters.', true);
      return;
    }

    // Check for message length limit (pls dont be stupid)
    if (msg.length > 3000) {
      setStatus('Message is too long.', true);
      return;
    }

    const payload = {
      name: 'Portfolio Contact',
      email,
      subject: 'New contact from portfolio',
      msg
    };

    setStatus('Sending…');
    submitBtn.disabled = true;
    form.setAttribute('aria-busy', 'true');

    try {
      const res = await fetch('https://contact.git-itzfork.workers.dev', {
        method: 'POST',
        headers: {
          'content-type': 'application/json'
        },
        body: JSON.stringify(payload)
      });

      if (!res.ok) {
        throw new Error('Request failed');
      }

      setStatus('Message sent successfully.');
      form.reset();
      submitBtn.disabled = false;
      form.removeAttribute('aria-busy');

    } catch (err) {
      setStatus('Failed to send message. Try again later.', true);
      submitBtn.disabled = false;
      form.removeAttribute('aria-busy');

    }
  });
}

// Email validation
function isValidEmail(email) {
  const EMAIL_REGEX =
    /^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$/;

  return email.length <= 254 && EMAIL_REGEX.test(email);
}

// Status message handler
function setStatus(message, isError = false) {
  statusEl.textContent = message;
  statusEl.style.color = isError ? '#ff6b6b' : '#2dd4bf';
}
