document.category_name = undefined
document.detail_name   = undefined
document.join_name     = undefined
document.category_id   = undefined
document.category_associations = []
document.detail_associations   = []
document.plurals = {}
document.render = {}
document.render.category_table = {}
document.render.detail_table = {}
document.data_cache ||= {}
document.datatables_state_cache ||= {}
document.filters_state_cache ||= {}
document.render_count = 0

@ready = ->
  document.href = document.location.href
  document.make_detail_table?(document.data_cache?[document.location.href]?[document.detail_name])
  if document.documentElement.hasAttribute("data-turbolinks-preview")
    return
  document.detail_table?.api?().ajax.reload()
  $("#load-indicator").fadeOut(350)
  document.render_count += 1

  # Filters updated in detail table
  $('.ajax_reload').on 'change', ->
    document.detail_table.api().ajax.reload()

  #Click event for table refresh alert
  $('#reload_table').on 'click', ->
    document.detail_table?.api?().ajax.reload()
    $('.table-refresh-alert').slideUp 'fast'
    

  subscribe_to_live_view(document.category_name)
  subscribe_to_live_view(document.detail_name)

$(document).on 'turbolinks:render', ->
  ready()
$(document).ready ->
  ready()

@live_view_datatable = (view, params) ->
  App.live_views?[view]?.watch_view('datatable', $(document.detail_table_selector).data('source'), $.param(params))

@connected_callback = (name) ->
  live_view_datatable(document.detail_name, document.last_datatables_payload) if name == document.detail_name && document.last_datatables_payload
  App.live_views?[name]?.watch_view('model', document.location.pathname, 'json') if name == document.category_name

$(document).on 'preXhr.dt', (e, settings, data) ->
  document.last_datatables_payload = data
  return unless document.detail_table
  live_view_datatable(document.detail_name, data)

$(document).on 'turbolinks:before-cache', ->
  document.data_cache[document.href] = {}
  document.data_cache[document.href][document.detail_name] = document.detail_table?.api?().rows().data().toArray()
  document.filters_state_cache[document.href] ||= {}
  document.filters_state_cache[document.href][document.detail_name] = $('#filters').get() if $('#filters').length
  document.detail_table?.api?().destroy()
  document.detail_table = undefined # XXX: Properly detect if DataTable is destroyed
  document.render_count = 0
  document.category_name = undefined
  document.detail_name   = undefined
  document.join_name     = undefined
  document.category_id   = undefined
  document.category_associations = []
  document.detail_associations   = []
  $("#load-indicator").show()

document.sync_view_category = (record, destroyed=null) ->
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

@received_callback = (data) ->
  # Category
  if data["request"]["name"] == document.category_name
    new_info = JSON.parse(data["response"])
    document.sync_view_category(new_info)

  # Detail
  if data["request"]["name"] == document.detail_name
    new_dt = JSON.parse(data["response"])
    new_row_ids = new_dt.data.map (row) ->
      row.DT_RowId
    cur_row_ids = document.detail_table.api().rows().ids().toArray()
    ids_matched = cur_row_ids.length == new_row_ids.length && cur_row_ids.every (v, i) ->
      v == new_row_ids[i]
    
    if !ids_matched
      $('.table-refresh-alert').slideDown 'fast' if $('.table-refresh-alert').css('display') == 'none'
      return
    $('.table-refresh-alert').slideUp 'fast'

    document.detail_table.api().rows().data().each (v, i) ->
      # XXX: Find faster way to compare these objects
      if JSON.stringify(v) != JSON.stringify(new_dt.data[i])
        document.detail_table.api().row('#'+v.DT_RowId).data(new_dt.data[i])

    # TODO: Update recordsTotal
    # TODO: Update recordsFiltered
