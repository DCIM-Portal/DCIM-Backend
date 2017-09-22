# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->

  document.render.category_table.system = (record) ->
    for key, value of record
      switch key
        when "status"
          value = text_to_status('system', value)
        when "updated_at"
          value = moment(value).format('MMMM DD YYYY, h:mma')
        when "ram_total"
          value = formatBytes(value) 
      $(".category_system_" + key).html(value) if value != $(".category_system_" + key).html()
