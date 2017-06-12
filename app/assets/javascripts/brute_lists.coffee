# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#Function to update values for hidden 'order' input
updateIndexes = ->
  $('.number_order').each (i) ->
    $(this).val i + 1

#Remove input fields button
$(document).on 'click', '[data-role="dynamic-fields"] > .form-inline [data-role="remove"]', (e) ->
  e.preventDefault()
  $(this).closest('.form-inline').remove()

#Add input fields button
$(document).on 'click', '[data-role="dynamic-fields"] > .form-inline [data-role="add"]', (e) ->
  e.preventDefault()
  container = $(this).closest('[data-role="dynamic-fields"]')
  new_field_group = container.children().filter('.form-inline:first-child').clone()
  new_field_group.find('input').each ->
    $(this).val ''
  container.append new_field_group

#Re-purpose submit new brute-list button
$(document).on 'click', '#new_cred_submit', (e) ->
  e.preventDefault()
  #Disable Button to avoid multiple clicks
  $(this).attr 'disabled', true
  #Re-number order name attribute
  $('.form-container').each (i) ->
    $(this).children('input').each ->
      name = $(this).attr 'name'
      name = name.replace(/\[[0-9]+\]/g, '[' + i + ']')
      $(this).attr 'name', name
  #Update order value
  updateIndexes()
  #Submit the Form
  $('#new_brute_list').submit()

#Re-purpose submit button for brute_list edit
$(document).on 'click', '#edit_cred_submit', (e) ->
  e.preventDefault()
  #Disable Button to avoid multiple clicks
  $(this).attr 'disabled', true
  #Re-number order name attribute
  $('.secret_row').each (i) ->
    $(this).children('td').children('input').each ->
      name = $(this).attr 'name'
      name = name.replace(/\[[0-9]+\]/g, '[' + i + ']')
      $(this).attr 'name', name
  #Update order value
  updateIndexes()
  #Submit the Form
  $('.edit_brute_list').submit()

#Update credential row span value (visual only)
updateCredrow = ->
  $('.row_order').each (i) ->
    $(this).html i + 1

#Remove credential row and update span value
$(document).on 'click', '#del_credrow', (e) ->
  e.preventDefault()
  $(this).parent().parent().remove()
  updateCredrow()
  
#Add new credential row
$(document).on 'click', '#add_credrow', (e) ->
    e.preventDefault()
    counter = $('#cred_details').find("tbody > .credential_row").length + 1
    $('#cred_details > tbody:last-child').append '<tr class="credential_row"><td><span class="row_order">' + counter + '</span><input class="number_order" type="hidden" value="' + counter + '" name="brute_list[brute_list_secrets_attributes][' + counter + '][order]"></td><td><input type="text" name="brute_list[brute_list_secrets_attributes][' + counter + '][username]" class="form-control input-sm"></td><td><input type="text" name="brute_list[brute_list_secrets_attributes][' + counter + '][password]" class="form-control input-sm"></td><td><button id="del_credrow" class="btn btn-danger"><i class="fa fa-trash-o" aria-hidden="true"></i></button></td>'
    
$(document).on 'turbolinks:load', ->

  #When page loads, remove any duplicate rows (visual only)
  seen = {}
  $('#cred_detail_tbody tr').each ->
    txt = $(this).text()
    if seen[txt]
      $(this).remove()
    else
      seen[txt] = true

  #Values for sort function on new page
  sort_form = $('.field_contain')

  #Enable sorting of username/password fields on new page
  sort_form.sortable
    itemSelector: '.form-inline'
    containerSelector: '.field_contain'

  #Values for soft function on edit page
  sort_edit = $('#cred_detail_tbody')

  #Enable sorting of table rows on edit page
  sort_edit.sortable
    itemSelector: '.credential_row'
    containerSelector: '#cred_detail_tbody'
    stop: (event, ui) ->
      updateCredrow()

  #Brute List main table
  $('#cred_table').DataTable
    deferRender: true
    columnDefs: [ 
      orderable: false
      targets: [1,2,3]
    ]
    order: [ 0, 'asc' ]
    responsive: true
    drawCallback: ->
      $('#main_header').show()
      $('#main_table_body').show()
      $('.overlay').hide()

$(document).on 'turbolinks:before-cache', ->
  #Hide cred table
  $('#cred_table').DataTable().destroy()
