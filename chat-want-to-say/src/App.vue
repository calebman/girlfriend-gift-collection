

<template>
  <MobileDialog :src="src" :title="title" />
</template>

<script setup>
import MobileDialog from './pages/mobile-dialog/index.vue'
document.title = import.meta.env.VITE_APP_TITLE
const src = import.meta.env.VITE_CHAT_OPTIONS_PATH
const title = import.meta.env.VITE_APP_TITLE
</script>
