<template>
  <div class="vlog-cover">
    <div class="vlog-cover-action">
      <var-icon name="play-circle-outline"
                @click="$emit('open')"
                style="font-size: 55px;color: aliceblue;" />
    </div>
    <img :src="`${src}.jpg`"
         class="vlog-cover-img" />
  </div>
</template>

<script>
export default {
  props: {
    src: String
  }
}
</script>

<style>
.vlog-cover {
  position: relative;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  display: flex;
  justify-items: center;
  align-items: center;
  inset: 0px;
}
.vlog-cover-action {
  position: absolute;
  text-align: center;
  width: 100%;
}
.vlog-cover-img {
}
</style>