import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'

// https://vitejs.dev/config/
export default ({ mode }) => {
  return defineConfig({
    base: loadEnv(mode, process.cwd()).VITE_BASE_URL,
    plugins: [vue()]
  })
}
