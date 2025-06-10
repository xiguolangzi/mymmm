# Vue3 项目实战 Pinan状态管理

## 8.1 安装依赖

```bash
# 1 安装 pinia 依赖
npm install pinia@next
# 2 安装 pinia 持久化依赖
npm install pinia-plugin-persistedstate
```

## 8.2 封装pinia

```js
// /src/stores/index.js
import { createPinia } from 'pinia'
import persist from 'pinia-plugin-persistedstate'
// 创建 pinia 实例
const pinia = createPinia()
// 注册 持久化插件
pinia.use(persist)
// 导出 pinia
export default pinia
```

## 8.3 全局注册

```js
import { createApp } from 'vue'
import App from './App.vue'
// 引入模版的全局样式
import '@/styles/main.scss'
import pinia from './stores'
const app = createApp(App)
app.use(pinia)
app.mount('#app')
```

## 8.4 封装 Store

```javascript
// stores/language.js
import { defineStore } from 'pinia'
import { readonly } from 'vue'
import { ref } from 'vue'

export const useLanguageStore = defineStore('language', () => {
  // 1 支持的语言列表（可根据需要扩展）
  const supportedLanguages = ['zh', 'en', 'es']

  // 2 初始化语言（从浏览器语言检测）
  function initLanguage() {
    // 1 获取浏览器默认语言
    const browserLang = navigator.language?.toLowerCase().split('-')[0]
    // 2 获取本地存储语言
    const storyData = localStorage.getItem('app-language')
    const localStoryLanguage = storyData ? JSON.parse(storyData).language : null;
    // 3 返回结果
    const res = localStoryLanguage || browserLang || 'zh'
    return res
  }

  // 3 当前语言
  const language = ref(initLanguage())

  // 4 设置语言
  function setLanguage(lang) {
    if (supportedLanguages.includes(lang)) {
      language.value = lang
      return true
    }
    return false
  }

  return {
    language: readonly(language),
    setLanguage
  }
}, {
  persist: {
    key: 'app-language', // 自定义存储键名
    storage: localStorage, // 明确使用 localStorage（默认值）
  }
})
```

## 8.5 Vue组件内适用

```vue
<script>
  import { useLanguageStore } from "@/src/stores/language.js"
  
  const languageStore = useLanguageStore()
  
  // 1 直接适用状态
  languageStore.language
  // 2 设置状态
  languageStore.setLanguage(lang)
</script>

```

## 8.6 vue组件之外的调用

注意：外部调用 不在vue组件控制范围，会导致在同步本地数据之前取的初始值！！需要手动刷新浏览器才更新！！！

```js
// 普通的js文件调用 pinia 的状态，会报错' 使用之前没有创建 pinia ',解决办法如下：
import { createI18n } from "vue-i18n"
import { useLanguageStore } from "@/stores/modules/useLanguageStore.js"
import zh from "./language/zh.js"
import en from "./language/en.js"
import es from "./language/es.js"
const messages = {
  zh: zh,
  en: en,
  es: es,
}
// vue模块 之外的调用方法
import { createPinia } from "pinia"
const pinia = createPinia()
const languageStore = useLanguageStore(pinia)

console.log("---- i18n.js ---" + languageStore.lang)
const i18n = createI18n({
  // 使用状态
  locale: languageStore.lang,
  fallbackLocale: 'en',
  messages: messages,
})
```

