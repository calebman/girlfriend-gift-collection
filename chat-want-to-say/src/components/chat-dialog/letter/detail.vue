<template>
  <div class="letter-cover-wapper">
    <LetterCover :flap="status === 'opening'"
                 :openTip="openTip"></LetterCover>
  </div>
  <div class="letter-cover-wapper"
       style="position: relative;z-index: 2200;"
       v-if="status === 'opened'">
    <LetterContent @close="$emit('close')"
                   :title="title"
                   :paragraphs="paragraphs"
                   :speed="speed"></LetterContent>
  </div>

</template>

<script>
import LetterCover from './cover.vue'
import LetterContent from './content.vue'
export default {
  props: {
    type: String,
    src: String
  },
  components: {
    LetterContent,
    LetterCover
  },
  data () {
    return {
      openTip: '',
      title: '',
      paragraphs: [],
      speed: 120,
      // cover opening opened
      status: 'cover'
    }
  },
  mounted () {
    setTimeout(() => {
      this.status = 'opening';
      setTimeout(() => {
        this.status = 'opened';
      }, 2500);
    }, 1000);
  },
  created () {
    $.getJSON(this.src, ({ openTip, title, paragraphs, speed }) => {
      this.openTip = openTip;
      this.paragraphs = paragraphs;
      this.title = title;
      this.speed = speed;
    });
  }
}
</script>

<style>
.letter-cover-wapper {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: #d46466;
  display: flex;
  justify-content: center;
  align-items: center;
  inset: 0px;
  z-index: 2000;
}
</style>