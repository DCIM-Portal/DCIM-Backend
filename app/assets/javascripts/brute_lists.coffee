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
  updateIndexes()

#Add input fields button
$(document).on 'click', '[data-role="dynamic-fields"] > .form-inline [data-role="add"]', (e) ->
  e.preventDefault()
  container = $(this).closest('[data-role="dynamic-fields"]')
  new_field_group = container.children().filter('.form-inline:first-child').clone()
  new_field_group.find('input').each ->
    $(this).val ''
  container.append new_field_group
  updateIndexes()

#Re-purpose submit button
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
  #Submit the Form
  $('#new_brute_list').submit()


$(document).on 'turbolinks:load', ->

  #Values for sort function
  sort_form = $('.field_contain')
  itemsCount = $('.field_contain .form-inline').length

  #Update values for 'order' inputs (for turbolinks)
  updateIndexes()

  #Enable sorting of username/password fields
  sort_form.sortable
    itemSelector: '.form-inline'
    containerSelector: '.field_contain'
    stop: (event, ui) ->
      updateIndexes()

  #Brute List main table
  $('#cred_table').DataTable
    deferRender: true
    columnDefs: [ 
      orderable: false
      targets: [1,2,3]
    ]
    order: [ 0, 'asc' ]
    responsive: true
    scrollY: '365px'
    drawCallback: ->
      $('#main_header').show()
      $('#main_table_body').show()
      $('.overlay').hide()

  #Brute List detail table
  $('#cred_detail_table').DataTable
    deferRender: true
    columnDefs: [
      orderable: false
      targets: [0,1,2]
    ]
    order: [ 0, 'asc' ]
    responsive: true
    scrollY: '365px'
    drawCallback: ->
      $('#main_header').show()
      $('#main_table_body').show()
      $('.overlay').hide()


$(document).on 'turbolinks:before-cache', ->
  #Load overlay and hide tables
  $('.overlay').show()
  $('#main_table_body').hide()
  $('#main_header').hide()
  $('#cred_table').DataTable().destroy()
  #If we select any items in a datatable,
  #we must remove the selected attribute on reload
  $('tr').removeClass('selected')
