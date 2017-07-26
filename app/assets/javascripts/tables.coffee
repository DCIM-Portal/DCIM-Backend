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
  subscribe_to_record(document.category_name)
  subscribe_to_record(document.detail_name)
  subscribe_to_record(document.join_name)
  connected_callback(document.category_name)
  connected_callback(document.detail_name)

$(document).on 'turbolinks:render', ->
  ready()
$(document).ready ->
  ready()

@connected_callback = (name) ->
  App[name]?.fullLoad(document.category_id, document.category_associations) if name == document.category_name
  App[name]?.fullLoad(null, document.detail_associations) if name == document.detail_name && !document.category_name?

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
  $("#cache-container").show()

document.sync_view_category = (record, destroyed) ->
  document.render.category_table[document.category_name]?(record, destroyed)

document.make_detail_table = (record, destroyed) ->
  document.render.detail_table[document.detail_name]?(record, destroyed)

@sync_view = (data) ->

  # Cache Indicator
  $("#cache-container").hide()

  record = JSON.parse(data["data"])

  # Category
  if data["record"] == document.category_name
    # Only care about our page's ID
    return unless record["id"] == document.category_id

    # Update, Add, or Delete
    document.sync_view_category?(record, data["destroyed"])

    # Initialize detail table
    if !document.detail_table?
      document.make_detail_table?(record[document.plurals[document.detail_name]])

    # Replace full set of details
    else if record[document.plurals[document.detail_name]]
      detail_items = record[document.plurals[document.detail_name]]
      cur_row_ids = document.detail_table.rows().ids().map (id) ->
        return parseInt(id) # XXX: Do we need to cast to int?
      new_row_ids = detail_items.map (detail_item) ->
        return detail_item.id
      common_ids = $(cur_row_ids).filter(new_row_ids)
      added_ids = $(new_row_ids).not(common_ids)
      removed_ids = $(cur_row_ids).not(common_ids)

      # Remove records that no longer exist
      for removed_id in removed_ids
        detail_item = detail_items.filter (detail_item) ->
          return detail_item.id == removed_id
        @sync_view_detail?(detail_item.shift(), true)

      # Add new records
      for added_id in added_ids
        detail_item = detail_items.filter (detail_item) ->
          return detail_item.id == added_id
        @sync_view_detail?(detail_item.shift(), false)

      # Update existing records. TODO: For performance, only do this if changed
      for common_id in common_ids
        detail_item = detail_items.filter (detail_item) ->
          return detail_item.id == common_id
        @sync_view_detail?(detail_item.shift(), false)

      # Poor performance implementation
#      document.detail_table?.clear()
#      for detail_item in record[document.plurals[document.detail_name]]
#        document.detail_table?.row.add(detail_item).draw()

  # Detail
  if data["record"] == document.detail_name
    # Initialize detail table
    document.make_detail_table?({}) unless document.detail_table?

    # Update, Add, or Delete
    @sync_view_detail?(record, data["destroyed"])

  # Join
  if data["record"] == document.join_name
    record = JSON.parse(data["data"])

    # Delete
    if data["destroyed"] && record[document.category_name + "_id"] == document.category_id
      document.detail_table.row('#'+record[document.detail_name + "_id"]).remove().draw()
 
@sync_view_detail = (record, destroyed=false) ->
  # Check if our category has this detail
  if !record[document.plurals[document.category_name] || document.category_name] || record[document.plurals[document.category_name] || document.category_name].some((category) ->
      return category["id"] == document.category_id
      )

    # Update or Delete
    if document.detail_table.row("#"+record["id"]).id()

      # Delete
      if destroyed
        document.detail_table.row("#"+record["id"]).remove().draw()

      # Update
      else
        document.detail_table.row("#"+record["id"]).data(record)

    # Add
    else
      row = document.detail_table.row.add(record).draw().nodes()
      $(row).hide()
      $(row).fadeIn(500)
