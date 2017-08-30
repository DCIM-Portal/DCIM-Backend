#Main Admin coffee scripts

$(document).on 'turbolinks:load', ->

  #Datatable Defaults
  $.extend true, $.fn.dataTable.defaults,
    processing: true
    serverSide: true
    searching: true
    deferLoading: 0
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
    deferRender: true
    buttons: [
      {
        extend: 'copyHtml5'
        text:  '<i class="fa fa-clipboard"></i> <span class="dt-btn-text">Copy to Clipboard</span>'
        exportOptions: rows: '.selected'
        className: 'btn grey lighten-2 waves-effect'
      }
      {
        extend: 'csvHtml5'
        text: '<i class="fa fa-file-text"></i> <span class="dt-btn-text">Save to Excel</span>'
        exportOptions: rows: '.selected'
        className: 'btn grey lighten-2 waves-effect'
      }
      {
        text: '<i class="fa fa-minus-square-o"></i> <span class="dt-btn-text">De-select All</span>'
        className: 'btn grey lighten-2 waves-effect'
        action: () ->
          document.detail_table.api().column(0).checkboxes.deselectAll()
      }
      {
        text: '<i class="fa fa-share-square-o"></i> <span class="dt-btn-text">Onboard</span>'
        className: 'btn grey lighten-2 waves-effect modal-trigger onboard_submit'
        action: () ->
          id_array = []
          rows_selected = document.detail_table.api().column(0).checkboxes.selected();
          $.each rows_selected, (index, rowId) ->
            id_array.push rowId
          $.ajax
            url: '/admin/bmc_hosts/onboard_modal'
            type: 'post'
            data: selected_ids: id_array
          $('.onboard_submit').attr 'href', '#onboard_modal'
      }
      {
        text: '<i class="fa fa-refresh"></i> <span class="dt-btn-text">Refresh BMC Facts</span>'
        className: 'btn grey lighten-2 waves-effect bmc_refresh_submit'
        action: () ->
          id_array = []
          rows_selected = document.detail_table.api().column(0).checkboxes.selected();
          $.each rows_selected, (index, rowId) ->
            id_array.push rowId
          $.ajax
            url: '/admin/bmc_hosts/multi_refresh'
            type: 'post'
            data: selected_ids: id_array
      }
    ]
    columnDefs: [
      #LOGOS
      { targets: 'th_brand'
      orderable: true
      render: (data, type, full) ->
        if /(HP)/.test(data)
          '<img src="/images/hpe.svg" height=30 />'
        else if /(Cisco)/.test(data)
          '<img src="/images/cisco.svg" height=25 />'
        else if /(DELL)/.test(data)
          '<img src="/images/dell.svg" height=18 />'
        else if /(IBM)/.test(data)
          '<img src="/images/ibm.svg" height=18 />'
        else if /(Supermicro)/.test(data)
          '<img src="/images/supermicro.svg" height=10 />'
        else if !data
          'N/A'
        else
          data
      }
      #CHECKBOXES
      { targets: 'th_checkbox'
      checkboxes: {
        selectRow: true
        }
      }
      #URL
      { targets: 'th_url' 
      orderable: false
      }
      #Time
      { targets: 'th_time'
      render: (data, type, full) ->
        moment(data).format 'MMMM D YYYY, h:mma'
      }
      #Onboard Step
      { targets: 'th_onboard_step'
      orderable: false
      visible: false
      searchable: false
      }
      #Onboard Status
      { targets: 'th_onboard_status'
      render: (data, type, full) ->
        if !data
          '<div class="blue-grey lighten-1 white-text z-depth-1 sync"><i class="fa fa-minus-circle" aria-hidden="true"></i> Not Onboarded</div>'
        else if data == "success"
          '<div class="green lighten-2 white-text z-depth-1 sync"><i class="fa fa-check-circle-o" aria-hidden="true"></i> '  + I18n.t(data, scope: 'filters.options.onboard_request.status') + ': ' + I18n.t(full.onboard_request_step, scope: 'filters.options.onboard_request.step') + '</div>'
        else if data == "in_progress"
          '<div class="blue lighten-2 white-text z-depth-1 sync"><svg class="spinner" viewBox="0 0 50 50"><circle class="path" cx="25" cy="25" r="20" fill="none" stroke-width="5"></circle></svg> ' + I18n.t(data, scope: 'filters.options.onboard_request.status') + ': ' + I18n.t(full.onboard_request_step, scope: 'filters.options.onboard_request.step') + '</div>'
        else
          '<div class="red lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> ' + I18n.t(data, scope: 'filters.options.onboard_request.status') + ': ' + I18n.t(full.onboard_request_step, scope: 'filters.options.onboard_request.step') + '</div>'
      }
      #Power Status
      { targets: 'th_power'
      render: (data, type, full, meta) ->
        if data == "on"
          '<div class="power_status green lighten-2 z-depth-1"><i class="fa fa-power-off"></i> On</div>'
        else if data == "off"
          '<div class="power_status red lighten-2 z-depth-1"><i class="fa fa-power-off"></i> Off</div>'
        else
          '<div class="black-text">N/A</div>'
      width: 50
      }
      #Sync Status
      { targets: 'th_bmc_sync'
      render: (data, type, full) ->
        if !data
          '<div class="blue-grey darken-2 white-text z-depth-1 sync"><i class="fa fa-hourglass-start" aria-hidden="true"></i> Queued</div>'
        else if data == "success"
          '<div class="green lighten-2 white-text z-depth-1 sync"><i class="fa fa-check-circle-o" aria-hidden="true"></i> ' + I18n.t(data, scope: 'filters.options.bmc_host.sync_status') + '</div>'
        else if /(invalid)/.test(data)
          '<div class="orange lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> ' + I18n.t(data, scope: 'filters.options.bmc_host.sync_status') + '</div>'
        else if data == "in_progress"
          '<div class="blue lighten-2 white-text z-depth-1 sync"><svg class="spinner" viewBox="0 0 50 50"><circle class="path" cx="25" cy="25" r="20" fill="none" stroke-width="5"></circle></svg> Syncing</div>'
        else
          '<div class="red lighten-2 white-text z-depth-1 sync"><i class="fa fa-exclamation-triangle" aria-hidden="true"></i> ' + I18n.t(data, scope: 'filters.options.bmc_host.sync_status') + '</div>'
      width: 200
      }
      #Product
      { targets: 'th_product'
      orderable: true
      render: (data, type, full) ->
        if !data
          '<div class="model_cell">N/A</div>'
        else
          '<div class="model_cell">' + data + '</div>'
      }
      #Serial
      { targets: 'th_serial'
      orderable: true
      render: (data, type, full, meta) ->
        if data
          '<div class="serial">' + data + '</div>'
        else
          '<div class="serial">N/A</div>'
      width: 115
      }
      #BMC Address
      { targets: 'th_bmc_address'
      width: 75
      }
      #Scan Status
      { targets: 'th_scan_status'
      searchable: false
      render: (data, type, full, meta) ->
        if !data
          '<div class="blue-grey darken-2 white-text z-depth-1 sync"><i class="fa fa-hourglass-start" aria-hidden="true"></i> Queued</div>'
        else if data == "scan_complete"
          '<div class="green lighten-2 white-text z-depth-1 sync">' + I18n.t(data, scope: 'filters.options.bmc_scan_request.status') + '</div>'
        else if data == "in_progress"
          '<div class="blue lighten-2 white-text z-depth-1 sync">' + I18n.t(data, scope: 'filters.options.bmc_scan_request.status') + ' <div class="throbber-loader"></div></div>'
        else
          '<div class="red lighten-2 white-text z-depth-1 sync">' + I18n.t(data, scope: 'filters.options.bmc_scan_request.status') + '</div>'
      }
      { targets: 'th_id'
      width: 50
      }
    ]

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
    $('#outer-card').hide()

  #Original card, adjust height
  $('.card-title').click ->
    $('#outer-card').show()
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
    if $('.card-reveal').css('display') == 'block'
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
    if $('.card-reveal').css('display') == 'block'
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
  #$('tr').removeClass('selected')
  
  #Hide message divs on load
  $("#waiting_explanation").hide()
  $("#success_explanation").hide()
  $('.form_card_error').hide()
  
  #Hide Async Wrapper
  $('#async_wrapper').hide()

  #Prevent duplicate selects
  $('.m_select').material_select 'destroy'
