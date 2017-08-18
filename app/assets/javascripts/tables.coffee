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
document.render_count = 0

@ready = ->
  # If Turbolinks replaced cached data with fresh data, reset detail_table
  if document.render_count > 0
    document.detail_table?.destroy()
    document.detail_table = undefined
  if document.data_cache[document.location.href] && !document.detail_table?
    document.make_detail_table?(document.data_cache[document.location.href][document.detail_name])
  document.href = document.location.href
  document.render_count += 1
  subscribe_to_live_view(document.category_name)
  subscribe_to_live_view(document.detail_name)

$(document).on 'turbolinks:render', ->
  ready()
$(document).ready ->
  ready()

@live_view_datatable = (view, params) ->
  App.live_views?[view]?.watch_view(document.detail_name, 'datatable', $(document.detail_table_selector).data('source'), $.param(params))

@connected_callback = (name) ->
  live_view_datatable(document.detail_name, document.last_datatables_payload) if name == document.detail_name && document.last_datatables_payload

$(document).on 'preXhr.dt', (e, settings, data) ->
  document.last_datatables_payload = data
  return unless document.detail_table
  live_view_datatable(document.detail_name, data)

$(document).on 'turbolinks:before-cache', ->
  document.data_cache[document.href] = {}
  document.data_cache[document.href][document.detail_name] = document.detail_table?.rows().data().toArray()
  document.detail_table?.destroy()
  document.detail_table = undefined # XXX: Properly detect if DataTable is destroyed
  document.render_count = 0
  document.category_name = undefined
  document.detail_name   = undefined
  document.join_name     = undefined
  document.category_id   = undefined
  document.category_associations = []
  document.detail_associations   = []
  $("#cache-indicator").show()

document.sync_view_category = (record, destroyed) ->
  document.render.category_table[document.category_name]?(record, destroyed)

document.make_detail_table = (record, destroyed) ->
  if document.category_name
    document.render.detail_table[document.category_name][document.detail_name]?(record, destroyed)
  else
    document.render.detail_table[document.detail_name]?(record, destroyed)

@received_callback = (data) ->
  # Detail
  if data["request"]["id"] == document.detail_name
    new_dt = JSON.parse(data["response"])
    console.log new_dt
    new_row_ids = new_dt.data.map (row) ->
      row.DT_RowId
    cur_row_ids = document.detail_table.api().rows().ids().toArray()
    ids_matched = cur_row_ids.length == new_row_ids.length && cur_row_ids.every (v, i) ->
      v == new_row_ids[i]
    
    if !ids_matched
      console.log("ROWS ADDED OR REMOVED; MANUALLY REFRESH TABLE")
      console.log new_row_ids
      console.log cur_row_ids
      return

    console.log("ADD CODE TO UPDATE TABLE HERE")
    document.detail_table.api().rows().data().each (v, i) ->
      # XXX: Find faster way to compare these objects
      if JSON.stringify(v) != JSON.stringify(new_dt.data[i])
        document.detail_table.api().row('#'+v.DT_RowId).data(new_dt.data[i])

    # TODO: Update recordsTotal
    # TODO: Update recordsFiltered
