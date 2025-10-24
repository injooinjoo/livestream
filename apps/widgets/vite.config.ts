import { defineConfig } from 'vite';
import { resolve } from 'path';

// https://vitejs.dev/config/
export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        alert: resolve(__dirname, 'src/alert/index.html'),
        chat: resolve(__dirname, 'src/chat/index.html'),
        goal: resolve(__dirname, 'src/goal/index.html'),
        poll: resolve(__dirname, 'src/poll/index.html'),
      },
    },
  },
  server: {
    port: 5174,
  },
});
