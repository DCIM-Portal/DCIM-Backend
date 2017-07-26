#Main Admin coffee scripts

$(document).on 'turbolinks:load', ->

  #Nav Menu Expand Parent if Active
  setTimeout (->
    $('li#unfold > div.collapsible-body').slideDown
      duration: 350
      easing: 'easeOutQuart'
      queue: false
      complete: ->
        $(this).css 'height', ''
    $('li#unfold > a > i.rotate-icon').addClass 'rotate-element'
    $('li#unfold').addClass 'active'
    $('li#unfold > a.collapsible-header').addClass 'active'
  ), 150

  #Hide message divs on load
  $("#success_explanation").hide()
  $('.form_card_error').hide()
  $("#waiting_explanation").hide()

  #Submit Ajax Form
  $('#ajax_submit_button').on 'click', (event) ->
    event.preventDefault()
    $('#ajax_submit_button').prop 'disabled', true
    $('#error_explanation').hide()
    $('#success_explanation').hide()
    $('#waiting_explanation').show()
    $('#ajax_card_form').submit()
    $('.card-reveal').css 'height', 'auto'
    autoHeight = $('.card-reveal').outerHeight()
    $('.card-reveal').css 'height', '100%'
    $('.ovf-hidden').animate { height: autoHeight }, 150

  #Reveal form and adjust card height
  $('.activator').click ->
    $('.card-reveal').css 'height', 'auto'
    autoHeight = $('.card-reveal').outerHeight()
    $('.card-reveal').css 'height', '100%'
    $('.ovf-hidden').animate { height: autoHeight }, 250

  #Original card, adjust height
  $('.card-title').click ->
    #Identify Internet Explorer because it handles height differently
    ua = window.navigator.userAgent
    trident = ua.indexOf('Trident/')
    #Give more height to IE browser
    if trident > 0
      originalHeight = $('#height_check').outerHeight() + 107
    else
      originalHeight = $('#height_check').outerHeight() + 71
    $('.ovf-hidden').animate { height: originalHeight }, 250

  #Resize card if table becomes block
  $(window).on 'resize', (event) ->
    windowSize = $(this).width()
    if windowSize = 865 && $('.card-reveal').css('display') == 'none'
      ua = window.navigator.userAgent
      trident = ua.indexOf('Trident/')
      #Give more height to IE browser
      if trident > 0
        originalHeight = $('#height_check').outerHeight() + 107
      else
        originalHeight = $('#height_check').outerHeight() + 71
      $('.ovf-hidden').stop().animate { height: originalHeight }, 250

  #Ajax Form Success
  $("form#ajax_card_form").on "ajax:success", (event, data, status, xhr) ->
    $("#waiting_explanation").hide()
    $("#success_explanation").show()
    $('.form_card_error').hide()
    $('.card-reveal').css 'height', 'auto'
    autoHeight = $('.card-reveal').outerHeight()
    $('.card-reveal').css 'height', '100%'
    $('.ovf-hidden').animate { height: autoHeight }, 250
    $('#ajax_submit_button').prop('disabled', false)

  #Ajax Form Error
  $("form#ajax_card_form").on "ajax:error", (event, xhr, status, error) ->
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
    $('#ajax_submit_button').prop('disabled', false)

$(document).on 'turbolinks:before-cache', ->
  #Load overlay
  $('.overlay').show()

  #If we select any items in a datatable,
  #we must remove the selected attribute on reload
  $('tr').removeClass('selected')
  
  #Hide message divs on load
  $("#waiting_explanation").hide()
  $("#success_explanation").hide()
  $('.form_card_error').hide()
  
  #Hide Async Wrapper
  $('#async_wrapper').hide()
