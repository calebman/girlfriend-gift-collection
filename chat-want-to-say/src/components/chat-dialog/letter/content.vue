<template>
  <div class="letter-content animate__animated animate__fadeInUp">
    <div class="letter-title"
         ref="letter-title">
    </div>
    <div class="letter-detail">
      <div v-for="({ type, content, loading, ref }, i) in contents"
           :key="i"
           :ref="`letter-detail-item-${i}`">
        <var-loading v-if="loading"
                     color="#f44336"
                     type="cube" />
        <div v-show="!loading">
          <p v-if="type === 'text'"
             :ref="ref"></p>
          <div v-else style="text-align: center;">
            <span :ref="ref"
                  v-html="content"></span>
          </div>
        </div>
      </div>
      <div class="finish-action"
           v-show="finish"
           @click="$emit('close')">
        <var-icon name="chevron-left" />
        <text>回到聊天页</text>
      </div>
    </div>
    <div class="letter-action">
      <var-icon name="window-close"
                style="font-size: 25px;"
                @click="$emit('close')" />
    </div>
    <var-back-top style="z-index: 2000;"
                  :duration="300">
    </var-back-top>
  </div>
</template>

<script>
import Typed from 'typed.js'
export default {
  props: {
    title: String,
    paragraphs: Array,
    speed: Number
  },
  data () {
    return {
      contents: [],
      finish: false
    }
  },
  methods: {
    append (ele, content) {
      return new Promise((resolve) => {
        const typed = new Typed(ele, {
          strings: ['', content],
          typeSpeed: this.speed,
          backSpeed: this.speed,
          showCursor: false,
          onComplete: () => {
            typed.stop();
            setTimeout(() => resolve(), 500);
          }
        });
      })
    },
    initContent () {
      let paragraphChain = Promise.resolve();
      paragraphChain = paragraphChain.then(() => this.append(this.$refs['letter-title'], this.title, 120));
      this.paragraphs.forEach((paragraph, i) => {
        paragraphChain = paragraphChain.then(() => {
          return new Promise((resolve) => {
            const isImg = /<img[^>]+>/.test(paragraph);
            if (isImg) {
              const imgContent = {
                type: 'img',
                loading: true,
                content: paragraph,
                ref: `paragraph-img-${i}`
              }
              this.contents.push(imgContent);

              setTimeout(() => {
                imgContent.loading = false;
                this.$nextTick(() => {
                  imgContent.dom = this.$refs[imgContent.ref][0];
                  resolve();
                  this.autoScroll();
                });
              }, 1200);
            } else {
              const textContent = {
                type: 'text',
                content: paragraph,
                ref: `paragraph-text-${i}`
              }
              this.contents.push(textContent);
              this.$nextTick(() => {
                textContent.dom = this.$refs[textContent.ref][0];
                this.append(textContent.dom, paragraph)
                  .then(() => {
                    this.autoScroll();
                    resolve();
                  });
              })
            }
          })
        });
      });
      paragraphChain.then(() => this.finish = true);
    },
    autoScroll () {
      this.$nextTick(() => {
        this.computeDistance().then(distance => {
          const duration = 250;
          const startTime = Date.now();
          console.log('auto scroll', distance)
          const curScrollTop = document.body.scrollTop + document.documentElement.scrollTop;
          requestAnimationFrame(function step () {
            const p = Math.min(1, (Date.now() - startTime) / duration);
            document.body.scrollTop = curScrollTop + distance * p;
            document.documentElement.scrollTop = curScrollTop + distance * p;
            p < 1 && requestAnimationFrame(step);
          });
        })
      });
    },
    computeDistance () {
      return new Promise((resolve) => {
        const lastContentIndex = this.contents.length - 1;
        if (lastContentIndex === this.paragraphs.length - 1) {
          // 最后一行不滚动
          resolve(0);
          return;
        }
        const content = this.contents[lastContentIndex];
        if (content.type === 'img') {
          const imgDom = content.dom.children[0];
          this.onImageLoad(imgDom)
            .then(() => {
              setTimeout(() => {
                resolve(content.dom.offsetHeight);
              }, 100);
            });
        } else {
          resolve(content.dom.offsetHeight);
        }
      })
    },
    onImageLoad (dom) {
      const $img = $(dom);
      return new Promise(resolve => {
        $img.one('load', resolve)
          .each((index, target) => {
            // trigger load when the image is cached
            target.complete && $(target).trigger('load');
          });
      });
    }
  },
  mounted () {
    this.initContent();
  }
}
</script>

<style>
.letter-title {
  font-size: 1.25rem;
  margin: 15px 0;
  text-align: center;
}
.letter-content {
  width: 100%;
  line-height: 30px;
  margin: 0 auto;
  color: black;
  padding: 15px 32px 29px;
  background-color: #f9f9f9;
  box-shadow: 0px 2px 5px 0px rgba(0, 0, 0, 0.26);
  -moz-border-radius-bottomleft: 20px 500px;
  -moz-border-radius-bottomright: 500px 30px;
  -moz-border-radius-topright: 5px 100px;
  -webkit-border-bottom-left-radius: 20px 500px;
  -webkit-border-bottom-right-radius: 64px 10px;
  -webkit-border-top-right-radius: 5px 100px;
  border-bottom-left-radius: 20px 500px;
  border-bottom-right-radius: 64px 10px;
  border-top-right-radius: 5px 100px;
  -webkit-background-size: 100% 30px;
  -moz-box-shadow: 0 2px 10px 1px rgba(0, 0, 0, 0.2);
  -webkit-box-shadow: 0 2px 10px 1px rgba(0, 0, 0, 0.2);
  text-shadow: 0 1px 0 #f6ef97;
  position: relative;
  font-family: "Architects Daughter", cursive !important;
}
.letter-detail {
  position: relative;
  top: 0;
  left: 0;
  z-index: 2;
  min-height: 1500vh;
  background: repeating-linear-gradient(
    to bottom,
    #f9f9f9,
    #f9f9f9 31px,
    #d46466 2px,
    #f9f9f9
  );
  background-size: 100% 32px;
}
.letter-detail p {
  letter-spacing: 0.4rem;
}
.letter-ititle {
  font-size: 1.25rem !important;
}
.letter-detail p {
  position: relative;
  line-height: 2rem !important;
  text-indent: 2em;
  font-size: 1rem !important;
  margin-block-start: 0em;
  margin-block-end: 0em;
  margin-inline-start: 0px;
  margin-inline-end: 0px;
}
.letter-detail span {
  display: block;
  margin-block-start: 2rem;
  margin-block-end: 2rem;
}
@media only screen and (max-width: 600px) {
  .letter-content:after {
    left: 24px;
  }
  .letter-content::before {
    right: 24px;
  }
}
.letter-action {
  position: absolute;
  top: 10px;
  right: 20px;
  color: red;
}
.finish-action {
  float: right;
  margin-top: 30px;
  color: red;
}
</style>