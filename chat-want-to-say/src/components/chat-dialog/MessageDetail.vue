<template>
  <LetterDetail v-if="type === 'letter'"
                v-bind="options"
                @close="$emit('close')"></LetterDetail>
  <VlogDetail v-if="type === 'vlog'"
              v-bind="options"
              @close="$emit('close')"></VlogDetail>
</template>

<script>
import LetterDetail from './letter/detail.vue'
import VlogDetail from './vlog/detail.vue'
export default {
  props: {
    type: String,
    options: Object
  },
  components: {
    LetterDetail,
    VlogDetail
  }
}
</script>

<style>
</style>