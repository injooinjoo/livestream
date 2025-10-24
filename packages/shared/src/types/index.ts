// Platform types
export enum Platform {
  YOUTUBE = 'youtube',
  CHZZK = 'chzzk',
  SOOP = 'soop',
  NEXON = 'nexon',
}

// Event types
export enum EventType {
  FOLLOW = 'follow',
  SUBSCRIBE = 'subscribe',
  DONATION = 'donation',
  CHAT = 'chat',
  GAME_LEVELUP = 'game_levelup',
  GAME_BOSS_KILL = 'game_boss_kill',
  GAME_ITEM_DROP = 'game_item_drop',
}

// Widget types
export enum WidgetType {
  ALERT = 'alert',
  CHAT = 'chat',
  GOAL = 'goal',
  POLL = 'poll',
  RECENT_EVENTS = 'recent_events',
}

// User
export interface User {
  id: string;
  email: string;
  username: string;
  createdAt: Date;
  updatedAt: Date;
}

// Platform Connection
export interface PlatformConnection {
  id: string;
  userId: string;
  platform: Platform;
  platformUserId: string;
  platformUsername: string;
  accessToken: string;
  refreshToken?: string;
  expiresAt?: Date;
  createdAt: Date;
  updatedAt: Date;
}

// Widget
export interface Widget {
  id: string;
  userId: string;
  type: WidgetType;
  name: string;
  settings: WidgetSettings;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
}

export interface WidgetSettings {
  // Display settings
  displayDuration?: number; // seconds
  position?: 'top-left' | 'top-center' | 'top-right' | 'center' | 'bottom-left' | 'bottom-center' | 'bottom-right';

  // Style settings
  theme?: string;
  backgroundColor?: string;
  textColor?: string;
  fontSize?: number;
  fontFamily?: string;

  // Animation settings
  animationIn?: 'fade' | 'slide' | 'zoom' | 'bounce';
  animationOut?: 'fade' | 'slide' | 'zoom';

  // Sound settings
  soundEnabled?: boolean;
  soundVolume?: number;
  soundUrl?: string;

  // Custom CSS
  customCss?: string;

  // Event filters
  enabledEvents?: EventType[];
  minDonationAmount?: number;

  [key: string]: any;
}

// Event
export interface StreamEvent {
  id: string;
  userId: string;
  widgetId?: string;
  platform: Platform;
  eventType: EventType;
  eventData: EventData;
  createdAt: Date;
}

export interface EventData {
  user: string;
  userId?: string;
  message?: string;
  amount?: number;
  tier?: string;
  months?: number;
  [key: string]: any;
}

// WebSocket Events
export interface WsEventPayload {
  widgetId: string;
  eventType: EventType;
  data: EventData;
}

// API Response
export interface ApiResponse<T = any> {
  success: boolean;
  data?: T;
  error?: {
    code: string;
    message: string;
  };
}
