// API Constants
export const API_VERSION = 'v1';
export const API_PREFIX = `/api/${API_VERSION}`;

// WebSocket Events
export const WS_EVENTS = {
  // Client -> Server
  JOIN: 'join',
  LEAVE: 'leave',
  TEST_EVENT: 'test_event',

  // Server -> Client
  EVENT_FOLLOW: 'event:follow',
  EVENT_SUBSCRIBE: 'event:subscribe',
  EVENT_DONATION: 'event:donation',
  EVENT_CHAT: 'event:chat',
  EVENT_GAME: 'event:game',
} as const;

// Default Settings
export const DEFAULT_WIDGET_SETTINGS = {
  displayDuration: 5,
  position: 'top-center',
  theme: 'default',
  animationIn: 'slide',
  animationOut: 'fade',
  soundEnabled: true,
  soundVolume: 0.5,
} as const;

// Limits
export const LIMITS = {
  MAX_WIDGETS_PER_USER: 50,
  MAX_CUSTOM_CSS_LENGTH: 10000,
  MIN_DONATION_AMOUNT: 100,
  MAX_WIDGET_NAME_LENGTH: 100,
} as const;
