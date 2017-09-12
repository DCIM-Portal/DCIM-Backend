document.category_name = undefined
document.detail_name   = undefined
document.render = {}
document.render.category_table = {}
document.render.detail_table = {}
document.data_cache ||= {}
document.datatables_state_cache ||= {}
document.filters_state_cache ||= {}

@ready = ->
  document.href = document.location.href
  document.make_detail_table?(document.data_cache?[document.location.href]?[document.detail_name])
  if document.documentElement.hasAttribute("data-turbolinks-preview")
    return
  document.detail_table?.api?().ajax.reload(null, false)
  $("#load-indicator").fadeOut(350)

  # Filters updated in detail table
  $('.ajax_reload').on 'change', ->
    document.detail_table.api().ajax.reload()

  # Click event for table refresh alert
  $('#reload_table').on 'click', ->
    document.detail_table?.api?().ajax.reload(null, false)
    $('.table-refresh-alert').slideUp 'fast'
    
  subscribe_to_live_update()

$(document).on 'turbolinks:render', ->
  ready()
$(document).ready ->
  ready()

$(document).on 'turbolinks:before-cache', ->
  document.data_cache[document.href] = {}
  document.data_cache[document.href][document.detail_name] = document.detail_table?.api?().rows().data().toArray()
  document.filters_state_cache[document.href] ||= {}
  document.filters_state_cache[document.href][document.detail_name] = $('#filters').get() if $('#filters').length
  document.detail_table?.api?().destroy()
  document.detail_table = undefined # XXX: Properly detect if DataTable is destroyed
  document.category_name = undefined
  document.detail_name   = undefined
  $("#load-indicator").show()

document.sync_model = (record, destroyed=null) ->
  document.render.category_table[document.category_name]?(record, destroyed)

document.make_detail_table = (record, destroyed) ->
  if document.category_name
    document.render.detail_table[document.category_name][document.detail_name]?(record, destroyed)
  else
    document.render.detail_table[document.detail_name]?(record, destroyed)
  if document.filters_state_cache[document.href]?[document.detail_name]
    $('#filters').detach()
    $(document.filters_state_cache[document.href]?[document.detail_name]).appendTo('div.f_toolbar')
  else
    $('#filters').detach().appendTo('div.f_toolbar')
  $('.m_select').material_select('destroy');
  $('.m_select').material_select();
  $('div.m_select input').on 'click', ->
    if $(this).parent('div').hasClass('active')
      $('.select-dropdown').dropdown 'close'
      $(this).parent('div').removeClass 'active'
    else
      $('div.m_select').removeClass 'active'
      $(this).parent('div').addClass 'active'
  $(document).on 'click', (e) ->
    if $(e.target).is('div.m_select input') == false
      $('div.m_select').removeClass 'active'
