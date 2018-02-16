import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

import VisualDC from '../visual_dc/visual_dc'

document.visual_dc ||= new VisualDC()

import App from '../visual_dc/visual_dc.vue'

document.addEventListener 'turbolinks:load', =>
  dom = document.getElementById('visual_dc_vuejs')
  app = new Vue({
    render: (h) =>
      h(App)
  }).$mount(dom)
  console.log(app)
