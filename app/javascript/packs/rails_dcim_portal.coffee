import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

Turbolinks = require("turbolinks")
Turbolinks.start()

import App from '../rails_dcim_portal'

document.addEventListener 'turbolinks:load', =>
  dom = document.getElementById('app')
  app = new Vue({
    render: (h) =>
      h(App)
  }).$mount(dom)
  console.log(app)
