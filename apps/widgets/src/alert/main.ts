import './style.css';
import { io } from 'socket.io-client';
import gsap from 'gsap';

// Get widget configuration from URL
const urlParams = new URLSearchParams(window.location.search);
const widgetId = urlParams.get('widgetId');
const token = urlParams.get('token');

if (!widgetId || !token) {
  console.error('Missing widgetId or token in URL');
}

// Connect to WebSocket server
const socket = io(import.meta.env.VITE_WS_URL || 'ws://localhost:3000', {
  auth: { token },
  transports: ['websocket'],
});

socket.on('connect', () => {
  console.log('✅ Connected to server');
  socket.emit('join', widgetId);
});

socket.on('disconnect', () => {
  console.log('❌ Disconnected from server');
});

// Event handlers
socket.on('event:follow', (data: { user: string; platform: string }) => {
  showAlert('새로운 팔로워!', `${data.user}님이 팔로우했습니다`, '🎉');
});

socket.on('event:subscribe', (data: { user: string; platform: string; tier?: string }) => {
  showAlert('새로운 구독자!', `${data.user}님이 구독했습니다`, '⭐');
});

socket.on('event:donation', (data: { user: string; amount: number; message?: string }) => {
  const message = data.message || `${data.amount.toLocaleString()}원 후원`;
  showAlert('후원 감사합니다!', `${data.user}: ${message}`, '💝');
});

// Alert display logic
function showAlert(title: string, message: string, icon: string) {
  const alertElement = document.getElementById('alert');
  const titleElement = document.querySelector('.alert-title');
  const messageElement = document.querySelector('.alert-message');
  const iconElement = document.querySelector('.alert-icon');

  if (!alertElement || !titleElement || !messageElement || !iconElement) {
    return;
  }

  // Set content
  titleElement.textContent = title;
  messageElement.textContent = message;
  iconElement.textContent = icon;

  // Show alert
  alertElement.classList.remove('hidden');

  // Animate in
  gsap.fromTo(
    alertElement,
    {
      scale: 0,
      opacity: 0,
      y: -50,
    },
    {
      scale: 1,
      opacity: 1,
      y: 0,
      duration: 0.5,
      ease: 'back.out(1.7)',
    }
  );

  // Animate out after 5 seconds
  setTimeout(() => {
    gsap.to(alertElement, {
      scale: 0,
      opacity: 0,
      y: 50,
      duration: 0.3,
      ease: 'back.in(1.7)',
      onComplete: () => {
        alertElement.classList.add('hidden');
      },
    });
  }, 5000);
}

// Development test
if (import.meta.env.DEV) {
  setTimeout(() => {
    showAlert('테스트 알림', '개발 모드에서 표시되는 테스트입니다', '🧪');
  }, 2000);
}
