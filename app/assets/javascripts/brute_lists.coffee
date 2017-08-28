# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#Update credential row span value (visual only)
updateCredrow = ->
  $('.row_order').each (i) ->
    $(this).html i + 1

#Update execute order
updateIndexes = ->
  $('.number_order').each (i) ->
    $(this).val i + 1

#Remove credential row and update span value
$(document).on 'click', '#del_credrow', (e) ->
  e.preventDefault()
  $(this).parent().parent().remove()
  updateCredrow()
  $('.ovf-hidden').animate { height: '-=78' }, 150

#Add new credential row
$(document).on 'click', '#add_credrow', (e) ->
    e.preventDefault()
    counter = $('#cred_details').find("tbody > .credential_row").length + 1
    $('#cred_details > tbody:last-child').append '<tr class="credential_row"><td><span class="row_order">' + counter + '</span><input class="number_order" type="hidden" value="' + counter + '" name="brute_list[brute_list_secrets_attributes][' + counter + '][order]"></td><td><input type="text" name="brute_list[brute_list_secrets_attributes][' + counter + '][username]" class="form-control input-sm browser-default"></td><td><input type="text" name="brute_list[brute_list_secrets_attributes][' + counter + '][password]" class="form-control input-sm browser-default"></td><td><a id="del_credrow" class="btn red lighten-2 btn-sm"><i class="fa fa-trash-o" aria-hidden="true"></i></a></td>'
    $('.ovf-hidden').animate { height: '+=78' }, 150

$(document).on 'turbolinks:load', ->

  #When page loads, remove any duplicate rows (visual only)
  seen = {}
  $('#cred_detail_tbody tr').each ->
    txt = $(this).text()
    if seen[txt]
      $(this).remove()
    else
      seen[txt] = true

  #Submit Cred Ajax Form
  $('#ajax_submit_creds').on 'click', (event) ->
    event.preventDefault()
    $('#ajax_submit_creds').prop 'disabled', true
    $('#error_explanation').hide()
    $('#success_explanation').hide()
    $('#flash_success').hide()
    $('#waiting_explanation').show()
    $('.credential_row').each (i) ->
      $(this).children('td').children('input').each ->
        name = undefined
        name = $(this).attr('name')
        name = name.replace(/\[[0-9]+\]/g, '[' + i + ']')
        $(this).attr 'name', name
    updateIndexes()
    $('#ajax_card_cred').submit()
    $('.card-reveal').css 'height', 'auto'
    autoHeight = $('.card-reveal').outerHeight()
    $('.card-reveal').css 'height', '100%'
    $('.ovf-hidden').animate { height: autoHeight }, 150


  #Cred Ajax Form Success
  $("form#ajax_card_cred").on "ajax:success", (event, data, status, xhr) ->
    $("#waiting_explanation").hide()
    $("#success_explanation").show()
    $('.form_card_error').hide()
    $('.card-reveal').css 'height', 'auto'
    autoHeight = $('.card-reveal').outerHeight()
    $('.card-reveal').css 'height', '100%'
    $('.ovf-hidden').animate { height: autoHeight }, 250
    $('#ajax_submit_creds').prop('disabled', false)

  #Cred Ajax Form Error
  $("form#ajax_card_cred").on "ajax:error", (event, xhr, status, error) ->
    $("#waiting_explanation").hide()
    errors = jQuery.parseJSON(xhr.responseText)
    $("#success_explanation").hide()
    $('.form_card_error').empty()
    $('.form_card_error').append('<ul>')
    for e in errors
      $('.form_card_error ul').append('<li>' + e + '</li>')
    $('.form_card_error').show()
    $('.card-reveal').css 'height', 'auto'
    autoHeight = $('.card-reveal').outerHeight()
    $('.card-reveal').css 'height', '100%'
    $('.ovf-hidden').animate { height: autoHeight }, 250
    $('#ajax_submit_creds').prop('disabled', false)

  #Values for soft function on edit page
  sort_edit = $('#cred_detail_tbody')

  #Enable sorting of table rows on edit page
  sort_edit.sortable
    itemSelector: '.credential_row'
    containerSelector: '#cred_detail_tbody'
    stop: (event, ui) ->
      updateCredrow()

  document.render.detail_table.brute_list = (view) ->
    #Brute List main table
    document.detail_table_selector = '#cred_table'
    document.detail_table = $(document.detail_table_selector).dataTable
      data: view
      stateSave: true
      stateSaveCallback: (settings, data) ->
        document.datatables_state_cache[document.href] ||= {}
        document.datatables_state_cache[document.href].brute_list = {'settings': settings, 'data': data}
      stateLoadCallback: (settings, callback) ->
        callback(document.datatables_state_cache[document.href]?.brute_list.data)
        return undefined
      ajax: {
        url: $(document.detail_table_selector).data('source')
        data: (d) ->
          if $('#filters').length
            return $.extend {}, $('#filters').serializeObject(), d
          else if document.datatables_state_cache[document.href]?.brute_list?.filters?
            return $.extend {}, $(document.datatables_state_cache[document.href]?.brute_list?.filters).serializeObject(), d
          return d
      }
      columns: [
        { "data": "id" },
        { "data": "name" },
        { "data": "created_at" },
        { "data": "url" }
      ]
      dom: '<"top clearfix"lf><t><"bottom"ip><"clearfix">'
      createdRow: (row, data, dataIndex) ->
        $(row).find('td:eq(0)').attr 'data-title', 'Credential List ID:'
        $(row).find('td:eq(1)').attr 'data-title', 'Credential List Name:'
        $(row).find('td:eq(2)').attr 'data-title', 'Date Created:'
      order: [ 0, 'asc' ]
