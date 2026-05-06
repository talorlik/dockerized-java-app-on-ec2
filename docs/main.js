// Theme management
const themeStylesheet = document.getElementById('theme-stylesheet');
const themeToggle = document.getElementById('themeToggle');
const sunIcon = document.getElementById('sunIcon');
const moonIcon = document.getElementById('moonIcon');
const currentTheme = localStorage.getItem('theme') || 'light';

function setTheme(theme) {
  if (theme === 'dark') {
    themeStylesheet.href = 'dark-theme.css';
    sunIcon.classList.remove('hidden');
    moonIcon.classList.add('hidden');
    themeToggle.setAttribute('aria-label', 'Switch to light theme');
    themeToggle.setAttribute('title', 'Switch to light theme');
    localStorage.setItem('theme', 'dark');
  } else {
    themeStylesheet.href = 'light-theme.css';
    sunIcon.classList.add('hidden');
    moonIcon.classList.remove('hidden');
    themeToggle.setAttribute('aria-label', 'Switch to dark theme');
    themeToggle.setAttribute('title', 'Switch to dark theme');
    localStorage.setItem('theme', 'light');
  }
}

setTheme(currentTheme);

themeToggle.addEventListener('click', () => {
  const newTheme = themeStylesheet.href.includes('dark-theme.css') ? 'light' : 'dark';
  setTheme(newTheme);
});

// Mobile menu toggle
const mobileMenuToggle = document.getElementById('mobileMenuToggle');
const navMenu = document.getElementById('navMenu');
mobileMenuToggle.addEventListener('click', () => {
  navMenu.classList.toggle('active');
});

// Close mobile menu when clicking on a link
const navLinks = document.querySelectorAll('.nav-menu a');
navLinks.forEach((link) => {
  link.addEventListener('click', () => {
    navMenu.classList.remove('active');
  });
});

// Active section highlighting
const sections = document.querySelectorAll('section[id]');
const navLinksArray = Array.from(navLinks);

function highlightActiveSection() {
  const scrollY = window.pageYOffset;
  sections.forEach((section) => {
    const sectionHeight = section.offsetHeight;
    const sectionTop = section.offsetTop - 150;
    const sectionId = section.getAttribute('id');
    if (scrollY > sectionTop && scrollY <= sectionTop + sectionHeight) {
      navLinksArray.forEach((link) => {
        link.classList.remove('active');
        if (link.getAttribute('href') === `#${sectionId}`) {
          link.classList.add('active');
        }
      });
    }
  });
}

window.addEventListener('scroll', highlightActiveSection);
window.addEventListener('load', highlightActiveSection);

// Scroll to top button
function initScrollToTop() {
  const scrollToTopButton = document.getElementById('scrollToTopButton');
  if (!scrollToTopButton) {
    return;
  }
  function checkScroll() {
    if (window.pageYOffset > 100 || document.documentElement.scrollTop > 100) {
      scrollToTopButton.classList.add('visible');
    } else {
      scrollToTopButton.classList.remove('visible');
    }
  }
  checkScroll();
  window.addEventListener('scroll', checkScroll);
  scrollToTopButton.addEventListener('click', (e) => {
    e.preventDefault();
    window.scrollTo({
      top: 0,
      behavior: 'smooth',
    });
  });
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initScrollToTop);
} else {
  initScrollToTop();
}

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
  anchor.addEventListener('click', function (e) {
    e.preventDefault();
    const target = document.querySelector(this.getAttribute('href'));
    if (target) {
      target.scrollIntoView({
        behavior: 'smooth',
        block: 'start',
      });
    }
  });
});
