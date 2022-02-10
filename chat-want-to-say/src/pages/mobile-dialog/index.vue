<template>
  <ChatDialog :options="chatOptions"
              :title="props.title"
              @msg-click="handleMsgClick"></ChatDialog>
</template>

<script setup>
import { ref, defineProps, onMounted } from 'vue'
import ChatDialog from '../../components/chat-dialog/index.vue'
const props = defineProps({
  src: String,
  title: String
});
const chatOptions = ref();
onMounted(() => {
  $.getJSON(props.src, (options) => {
    chatOptions.value = options;
  });
})
function handleMsgClick ({ author, content, type }) {
  console.log(author, content, type)
}
</script>