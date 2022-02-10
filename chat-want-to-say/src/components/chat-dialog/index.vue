<template>
  <div id="mobile">
    <div id="mobile-head">
      <div id="mobile-head-title">{{ title }}</div>
    </div>
    <div id="mobile-body">
      <div id="mobile-body-bg"></div>
      <div id="mobile-body-content">
        <div id="mock-msg-row"
             class="msg-row">
          <div id="mock-msg"
               class="msg"
               v-html="latestMsgContent"></div>
        </div>
        <div class="msg-row"
             v-for="(msg, index) in messages"
             :key="index"
             :class="msg.author === 'author' ? 'msg-author' : 'msg-me'">
          <div class="msg"
               :style="msg.width && msg.height && {width: msg.width - 26 + 'px', height: msg.height - 18 + 'px'}"
               :class="{ 
                 'msg-bounce-in-left':  msg.author === 'author',
                 'msg-bounce-in-right':  msg.author === 'me',
                 'animate_breathe': index === (messages.length - 1) && status === 'componentClose' 
                }"
               @click="$emit('msg-click', msg)">
            <span v-if="msg.type === 'text'"
                  v-html="msg.content"></span>
            <component v-else
                       :is="msg.type"
                       v-bind="msg.props"
                       @open="handleComponentOpen(msg)"
                       @close="handleComponentClose"></component>
          </div>
        </div>
      </div>
    </div>
    <div id="mobile-foot">
      <var-row :gutter="10"
               justify="center"
               align="center"
               style="height: 100%;">
        <var-col :span="20">
          <div id="input-hint"
               class="say-something">
            <div style="background: white;width: 100%;height: 32px;line-height: 32px;">
              <span v-show="status === 'systemInput'"
                    style="color: black;"
                    class="system-input-element"></span>
              <var-input ref="userMsgInputRef"
                         v-show="status === 'userInput'"
                         class="animate_breathe"
                         :hint="false"
                         :line="false"
                         v-model="inputMessage" />
            </div>
          </div>
        </var-col>
        <var-col :span="4"
                 style="padding: 0;">
          <var-button ref="sendMsgBtnRef"
                      type="success"
                      size="small"
                      :disabled="sendBtnDisabled"
                      @click="sendUserMsg">发送</var-button>
        </var-col>
      </var-row>
    </div>
  </div>
  <MessageDetail v-if="currentOpenComponent"
                 :type="currentOpenComponent.type"
                 :options="currentOpenComponent.props"
                 @close="handleComponentClose">
  </MessageDetail>
</template>

<script>
import letter from './letter/cover.vue'
import vlog from './vlog/cover.vue'
import MessageDetail from './MessageDetail.vue'
import Typed from 'typed.js'
import './css/main.scss'
const AUTHOR = {
  AUTHOR: 'author',
  ME: 'me'
};
const TRIGGER_NEXT_ACTION_TYPE = {
  USER_INPUT: 'userInput',
  COMPONENT_CLOSE: 'componentClose'
};

export default {
  components: {
    letter,
    vlog,
    MessageDetail
  },
  props: {
    title: String,
    options: Array
  },
  computed: {
    sendBtnDisabled () {
      if (this.status === 'systemInput') {
        return true;
      }
      if (this.inputMessage && this.inputMessage.trim().length > 0) {
        return false;
      }
      return true;
    }
  },
  data () {
    return {
      // 已经展示的消息
      messages: [],
      // 消息链条
      msgChain: Promise.resolve(),
      // 输入消息
      inputMessage: '',
      // 用户交互触发器
      nextActionTrigger: null,
      // 当前状态 等待用户交互
      status: 'systemInput',
      // 当前打开的组件
      currentOpenComponent: null,
      isTyping: false,
      latestMsgContent: null
    }
  },
  watch: {
    options () {
      this.buildMsgChain(this.options);
    },
    status (newVal, oldVal) {
      if (newVal === TRIGGER_NEXT_ACTION_TYPE.USER_INPUT) {
        this.setUserInputFoucus();
      }
    }
  },
  methods: {
    buildMsgChain (messages) {
      messages.forEach(({ msgs, msgInputSpeed, author, triggerNextAction }) => {
        this.msgChain = this.msgChain
          .then(() => this.sendSysMsg(msgs, msgInputSpeed, author, triggerNextAction));
      })
    },

    sendSysMsg (messages, inputSpeed = 150, author, triggerNextAction = null) {
      return new Promise((resolve) => {
        this.sendSysMsgInner(messages, inputSpeed, author).then(() => {
          if (triggerNextAction) {
            // 需要行为触发下一个消息活动
            const trigger = () => delay(500).then(() => resolve());
            this.nextActionTrigger = {
              inputSpeed,
              triggerNextAction,
              trigger
            };
            console.log('set trigger', this.nextActionTrigger);
            const { type, options } = triggerNextAction;
            this.status = type;
          } else {
            resolve();
          }
        });
      });
    },

    sendSysMsgInner (messages, inputSpeed, author) {
      return new Promise((resolve) => {
        const message = Array.isArray(messages) ? messages[messages.length - 1] : messages;
        const messageType = this.getMsgType(message);
        this.status = 'systemInput';
        if (messageType === 'text') {
          let strings = [''];
          Array.isArray(messages) ? strings = strings.concat(messages) : strings.push(messages);
          const typed = new Typed(".system-input-element", {
            strings: strings,
            typeSpeed: inputSpeed,
            backSpeed: inputSpeed,
            onComplete: () => {
              typed.destroy();
              this.pushMsg(message, author || AUTHOR.AUTHOR, messageType);
              delay(500).then(() => resolve());
            }
          });
        } else {
          this.pushMsg(message, AUTHOR.AUTHOR, messageType);
          delay(500).then(() => resolve());
        }
      });
    },

    sendUserMsg () {
      const message = this.inputMessage;
      this.inputMessage = '';
      this.pushMsg(message, AUTHOR.ME, 'text');

      if (!this.nextActionTrigger) {
        return;
      }
      const { triggerNextAction, inputSpeed, tryCnt = 0 } = this.nextActionTrigger;
      const { type, options } = triggerNextAction;
      const { resolveKeyTexts, rejectKeyTexts, rejectHitTexts } = options;

      if (type === TRIGGER_NEXT_ACTION_TYPE.USER_INPUT) {
        if (this.rejectNextMsg(message, resolveKeyTexts, rejectKeyTexts)) {
          const rejectDisabled = tryCnt >= rejectHitTexts.length - 1;
          const rejectText = rejectHitTexts[Math.min(tryCnt, rejectHitTexts.length - 1)];
          let rejectSysMsgChain = Promise.resolve();
          if (Array.isArray(rejectText)) {
            // 多条回复
            rejectText.forEach(text => {
              rejectSysMsgChain = rejectSysMsgChain
                .then(() => this.sendSysMsg(text, inputSpeed));
            })
          } else {
            // 单条回复
            rejectSysMsgChain = this.sendSysMsg(rejectText, inputSpeed);
          }
          rejectSysMsgChain.then(() => {
            if (rejectDisabled) {
              this.handleTriggerNextAction();
            } else {
              this.status = TRIGGER_NEXT_ACTION_TYPE.USER_INPUT;
            }
          });
          this.nextActionTrigger.tryCnt = tryCnt + 1;
        } else {
          this.handleTriggerNextAction();
        }
      }
    },

    handleComponentOpen ({ type, props }) {
      this.currentOpenComponent = { type, props };
    },

    handleComponentClose () {
      this.currentOpenComponent = null;
      if (!this.nextActionTrigger) {
        return;
      }
      const triggerObj = this.nextActionTrigger;
      const { triggerNextAction } = triggerObj;
      const { type, options } = triggerNextAction;
      if (type === TRIGGER_NEXT_ACTION_TYPE.COMPONENT_CLOSE) {
        this.handleTriggerNextAction();
      }
    },

    handleTriggerNextAction () {
      if (!this.nextActionTrigger) {
        return;
      }
      const triggerObj = this.nextActionTrigger;
      const { trigger } = triggerObj;
      trigger();
      this.nextActionTrigger = null;
      console.log('remove trigger', this.nextActionTrigger);
    },

    setUserInputFoucus () {
      const iosSpecialProcess = () => {
        try {
          const isiOS = !!navigator.userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/);
          if (isiOS) {
            this.$refs['userMsgInputRef'].scrollIntoView(true);
          }
        } catch (ignore) {
        }
      }
      setTimeout(() => {
        this.$nextTick(() => {
          iosSpecialProcess();
          this.$refs['userMsgInputRef'].focus();
        });
      }, 1000);
    },

    rejectNextMsg (message, resolveKeyTexts = [], rejectKeyTexts = []) {
      if (rejectKeyTexts.some(rejectText => message.indexOf(rejectText) > -1)) {
        return true;
      }
      if (resolveKeyTexts.some(resolveKey => message.indexOf(resolveKey) > -1)) {
        return false;
      }
      return true;
    },

    pushMsg (message, author, type = 'text') {
      this.messages.push({
        author: author,
        content: message,
        type,
        props: this.getProps(message, type),
      });
      onMessageSending();
    },

    getProps (message, type) {
      const props = {};
      if (type === 'text') {
        return props;
      }
      const domParse = new DOMParser();
      const messageDoc = domParse.parseFromString(message, 'text/html');
      const messageDoms = messageDoc.getElementsByTagName(type);
      if (messageDoms.length === 1) {
        const messageDom = messageDoms[0];
        const attrs = messageDom.getAttributeNames();
        attrs.forEach(attrName => props[attrName] = messageDom.getAttribute(attrName));
      }
      return props;
    },

    getMsgType (message) {
      const isImg = /<img[^>]+>/.test(message);
      const isLetter = /<letter[^>]+>/.test(message);
      const isVlog = /<vlog[^>]+>/.test(message);
      if (isImg) return 'img';
      if (isLetter) return 'letter';
      if (isVlog) return 'vlog';
      return 'text';
    },

    markMsgSize (msg, content = null) {
      this.latestMsgContent = content || msg.content;
      return delay(0)
        .then(() => msg.type === 'img' && onImageLoad($('#mock-msg img')))
        .then(() => {
          Object.assign(msg, getMockMsgSize());
          this.messages = [...this.messages];
        });
    },


  }
}


/**
 * UI updating when new message is sending
 */
function onMessageSending () {
  setTimeout(() => {
    // update scroll position when vue has updated ui
    updateScroll();

    const $latestMsg = $('#mobile-body-content .msg-row:last-child .msg');

    // add target="_blank" for links
    $latestMsg.find('a').attr('target', '_blank');

    // update scroll position when images are loaded
    onImageLoad($latestMsg).then(updateScroll);
  });
}

function updateScroll () {
  const $chatbox = $('#mobile-body-content');

  const distance = $chatbox[0].scrollHeight - $chatbox.height() - $chatbox.scrollTop();
  const duration = 250;
  const startTime = Date.now();

  requestAnimationFrame(function step () {
    const p = Math.min(1, (Date.now() - startTime) / duration);
    $chatbox.scrollTop($chatbox.scrollTop() + distance * p);
    p < 1 && requestAnimationFrame(step);
  });
}

function delay (amount = 0) {
  return new Promise(resolve => {
    setTimeout(resolve, amount);
  });
}

function getMockMsgSize () {
  const $mockMsg = $('#mock-msg');
  return {
    width: $mockMsg.width(),
    height: $mockMsg.height()
  };
}

function onImageLoad ($img) {
  return new Promise(resolve => {
    $img.one('load', resolve)
      .each((index, target) => {
        // trigger load when the image is cached
        target.complete && $(target).trigger('load');
      });
  });
}
</script>

<style>
.animate_breathe {
  -webkit-animation-timing-function: ease-in-out;
  -webkit-animation-name: breathe;
  -webkit-animation-duration: 1500ms;
  animation-delay: 500ms;
  -webkit-animation-delay: 500ms;
  -webkit-animation-iteration-count: infinite;
  -webkit-animation-direction: alternate;
}
@-webkit-keyframes breathe {
  0% {
    opacity: 0.4;
    box-shadow: 0 1px 1px rgba(0, 147, 223, 0.4),
      0 1px 1px rgba(0, 147, 223, 0.1) inset;
  }

  100% {
    opacity: 1;
    box-shadow: 0 1px 15px #0093df, 0 1px 10px #0093df inset;
  }
}
</style>