import App from './App.vue'
import Varlet from '@varlet/ui'
import { createApp } from 'vue'
import '@varlet/ui/es/style.js'
import 'animate.css/animate.min.css'

createApp(App).use(Varlet).mount('#app')