import Vue from 'vue'
import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

import VisualDC from '../visual_dc/visual_dc'

document.visual_dc ||= new VisualDC()

#document.addEventListener('turbolinks:load', =>
#  dom_visual_dc = $("#visual_dc")[0]
#  if (dom_visual_dc)
#    vm = new Vue( ->
#      el: dom_visual_dc
#    )
