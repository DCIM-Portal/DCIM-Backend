#Main Admin coffee scripts

$(document).on 'turbolinks:load', ->

  # Due to materialize bug, we have to set click for these modal buttons
  $('#onboard_error_button').click ->
    $('#onboard_error').modal('open')

  $('#sync_error_button').click ->
    $('#sync_error').modal('open')

  $('#system_sync_error_button').click ->
    $('#system_sync_error').modal('open')

  # Datatable Defaults
  $.extend true, $.fn.dataTable.defaults,
    processing: true
    serverSide: true
    searching: true
    deferLoading: 0
    lengthMenu: [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]]
    deferRender: true
    ajax: {
      data: (d) ->
        if $('#filters').length
          return $.extend {}, $('#filters').serializeObject(), d
        else if document.datatables_state_cache[document.href]?.bmc_scan_request?.filters?
          return $.extend {}, $(document.datatables_state_cache[document.href]?.bmc_scan_request?.filters).serializeObject(), d
        return d
    }
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
        text: '<i class="fa fa-sign-in"></i> <span class="dt-btn-text">Onboard</span>'
        className: 'btn grey lighten-2 waves-effect onboard_submit'
        action: () ->
          # Show indicator that modal is loading
          $("#load-indicator").fadeIn()
          # Empty out any existing content to avoid old content visibility
          $("#onboard_modal").empty()
          # Make an array to store our IDs
          id_array = []
          # Get table rows that have a check
          rows_selected = document.detail_table.api().column(0).checkboxes.selected();
          $.each rows_selected, (index, rowId) ->
            # Add checked row IDs to the array
            id_array.push rowId
          # Send array via an ajax request to load the modal
          $.ajax
            url: '/admin/bmc_hosts/onboard_modal'
            type: 'post'
            data: selected_ids: id_array
            # If successful, load modal and conditions
            success: (data) ->
              # Populate modal with data
              $('#onboard_modal').html data
              # Hide the load indicator
              $('#load-indicator').hide()
              # Set collapsible content
              $('.modal-content-collapsible').collapsible
                onOpen: (e) ->
                  $(e).find('span.list_banner').html 'Click to hide list'
                onClose: (e) ->
                  $(e).find('span.list_banner').html 'Click to expand list'
              # Select all checkbox function
              $('.select_all').click ->
                $(this).closest('div.table-modal table').find('td input').prop 'checked', @checked
              # Checkbox click function
              $('.table-modal table input[type="checkbox"]').click ->
                table = $(this).closest('div.table-modal table')
                total = table.find('td input[type="checkbox"]').length
                count = table.find('td input[type="checkbox"]:checked').length
                select_all = table.find('th input[type="checkbox"]')
                # Update selected number of rows
                $(this).closest('li').find('span.num_selected').html count
                # Make select_all checkbox indeterminate, checked,
                # or unchecked depending on conditions
                if count > 0 and count < total
                  select_all.prop 'checked', true
                  select_all.prop 'indeterminate', true
                else if total == count
                  select_all.prop 'indeterminate', false
                  select_all.prop 'checked', true
                else if count == 0
                  select_all.prop 'checked', false
                  select_all.prop 'indeterminate', false
              # Parse times
              # XXX: Make this universal
              $('time').each (i, dom) ->
                dom = $(dom)
                dom.html(moment(dom.attr('datetime')).format('MMMM D YYYY, h:mma'))
              # Open the modal
              $('#onboard_modal').modal('open')
              # Custom modal close action
              $('div#onboard_modal.open, .modal-close').click ->
                $('#onboard_modal').modal('close')
              # Ensure that clicking inside the modal won't close it
              $('div.modal-dialog').click (e) ->
                e.stopPropagation()
              # Make the onboard submit button disabled
              $('.onboard').prop 'disabled', true
              # Make onboard submit button enabled on correct input value
              $('#confirm').keyup ->
                $('.onboard').prop 'disabled', if @value != 'Onboard Systems' then true else false
            error: (event, exception, status) ->
              data = '<div class="modal-dialog z-depth-3" role="document">' +
              '<div class="modal-header red lighten-2 z-depth-1">' +
              '<h4 class="modal-title white-text">Error</h4>' +
              '<a class="modal-action modal-close pull-right"><i class="fa fa-close"></i></a>' +
              '</div>' +
              '<div class="modal-body">' +
              '<p>Unable to process due to <strong><em>' + exception + ': ' + status + '</em></strong>.</p>' +
              '<div class="modal-footer">' +
              '<a class="btn blue-grey lighten-2 white-text modal-action modal-close pull-right">Close</a>' +
              '</div></div></div>'
              $('#onboard_modal').html data
              $('#load-indicator').hide()
              $('#onboard_modal').modal('open')
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
      # Logos
      { targets: 'th_brand'
      orderable: true
      render: (data, type, full) ->
        if /(HP)/.test(data)
          '<img alt="'+data+'" title="'+data+'" src="/images/hpe.svg" height="16" />'
        else if /(Cisco)/.test(data)
          '<img alt="'+data+'" title="'+data+'" src="/images/cisco.svg" height="25" />'
        else if /(DELL)/.test(data)
          '<img alt="'+data+'" title="'+data+'" src="/images/dell.svg" height="18" />'
        else if /(IBM)/.test(data)
          '<img alt="'+data+'" title="'+data+'" src="/images/ibm.svg" height="18" />'
        else if /(Supermicro)/.test(data)
          '<img alt="'+data+'" title="'+data+'" src="/images/supermicro.svg" height="10" />'
        else if !data
          'N/A'
        else
          data
      }
      # Checkboxes
      { targets: 'th_checkbox'
      checkboxes: {
        selectRow: true
        }
      }
      # URL
      { targets: 'th_url' 
      orderable: false
      }
      # Time
      { targets: 'th_time'
      render: (data, type, full) ->
        moment(data).format 'MMMM D YYYY, h:mma'
      }
      # Onboard Step
      { targets: 'th_onboard_step'
      orderable: false
      visible: false
      searchable: false
      }
      # Onboard Status
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
      # Power Status
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
      # Sync Status
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
      # Product
      { targets: 'th_product'
      orderable: true
      render: (data, type, full) ->
        if !data
          '<div class="model_cell">N/A</div>'
        else
          '<div class="model_cell">' + data + '</div>'
      }
      # Serial
      { targets: 'th_serial'
      orderable: true
      render: (data, type, full, meta) ->
        if data
          '<div class="serial">' + data + '</div>'
        else
          '<div class="serial">N/A</div>'
      width: 115
      }
      # BMC Address
      { targets: 'th_bmc_address'
      width: 75
      }
      # Scan Status
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

  # Nav Menu Expand Parent if Active
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

  # Hide message divs on load
  $("#success_explanation").hide()
  $('.form_card_error').hide()
  $("#waiting_explanation").hide()

  # Define standard ajax forms
  ajax_forms = "form#ajax_card_form_new, form#ajax_card_form_update, form#ajax_card_cred_new, form#ajax_card_cred_update"

  # Submit Ajax Form
  $('#ajax_submit_button').on 'click', (event) ->
    event.preventDefault()
    $('#ajax_submit_button').prop 'disabled', true
    $('#error_explanation').hide()
    $('#success_explanation').hide()
    $('#waiting_explanation').show()
    $(ajax_forms).submit()
    $('.card-reveal').css 'height', 'auto'
    autoHeight = $('.card-reveal').outerHeight()
    $('.card-reveal').css 'height', '100%'
    $('.ovf-hidden').animate { height: autoHeight }, 150

  # Reveal form and adjust card height
  $('.activator').click ->
    $('.card-reveal').css 'height', 'auto'
    autoHeight = $('.card-reveal').outerHeight()
    $('.card-reveal').css 'height', '100%'
    $('.ovf-hidden').animate { height: autoHeight }, 250
    $('#outer-card').hide()

  # Original card, adjust height
  $('.card-title').click ->
    $('#outer-card').show()
    # Identify Internet Explorer because it handles height differently
    ua = window.navigator.userAgent
    trident = ua.indexOf('Trident/')
    # Give more height to IE browser
    if trident > 0
      originalHeight = $('#height_check').outerHeight() + 107
    else
      originalHeight = $('#height_check').outerHeight() + 71
    $('.ovf-hidden').animate { height: originalHeight }, 250

  # Resize card if table becomes block
  $(window).on 'resize', (event) ->
    windowSize = $(this).width()
    if windowSize = 865 && $('.card-reveal').css('display') == 'none'
      ua = window.navigator.userAgent
      trident = ua.indexOf('Trident/')
      # Give more height to IE browser
      if trident > 0
        originalHeight = $('#height_check').outerHeight() + 107
      else
        originalHeight = $('#height_check').outerHeight() + 71
      $('.ovf-hidden').stop().animate { height: originalHeight }, 250

  # Ajax Form Success
  $(ajax_forms).on "ajax:success", (event, data, status, xhr) ->
    $("#waiting_explanation").hide()
    $("#success_explanation").show()
    $('.form_card_error').hide()
    if $('.card-reveal').css('display') == 'block'
      $('.card-reveal').css 'height', 'auto'
      autoHeight = $('.card-reveal').outerHeight()
      $('.card-reveal').css 'height', '100%'
      $('.ovf-hidden').animate { height: autoHeight }, 250
    $('#ajax_submit_button, #ajax_submit_creds').prop('disabled', false)

  # Ajax Form Error
  $(ajax_forms).on "ajax:error", (event, xhr, status, error) ->
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
    $('#ajax_submit_button, #ajax_submit_creds').prop('disabled', false)

  # Clear out ajax new form submission on success
  $('form#ajax_card_form_new, form#ajax_card_cred_new').on 'ajax:success', ->
    $('form#ajax_card_form_new, form#ajax_card_cred_new')[0].reset()

$(document).on 'turbolinks:before-cache', ->
  # Load overlay
  $('.overlay').show()

  # Hide message divs on load
  $("#waiting_explanation").hide()
  $("#success_explanation").hide()
  $('.form_card_error').hide()
  
  # Hide Async Wrapper
  $('#async_wrapper').hide()

  # Prevent duplicate selects
  $('.m_select').material_select 'destroy'

@render_onboard_status = ->
  $('.onboard_status').each (i, dom) ->
    j = $(dom)
    status_and_step = j.html().split(': ')
    status = status_and_step.shift()
    step = status_and_step.join(': ')
    switch status
      when "success" 
        color = 'green lighten-2'
        prefix = '<i class="fa fa-check-circle-o" aria-hidden="true"></i>'
      when "in_progress"
        color = 'blue lighten-2'
        prefix = '<svg class="spinner" viewBox="0 0 50 50"><circle class="path" cx="25" cy="25" r="20" fill="none" stroke-width="5"></circle></svg>'
      when ""
        color = 'blue-grey lighten-1'
        prefix = '<i class="fa fa-minus-circle" aria-hidden="true"></i>'
        content = 'Not Onboarded'
      else
        color = 'red lighten-2'
        prefix = '<i class="fa fa-exclamation-triangle" aria-hidden="true"></i>'
    content ||= I18n.t(status, scope: 'filters.options.onboard_request.status', defaultValue: status) +
                ': ' +
                I18n.t(step, scope: 'filters.options.onboard_request.step', defaultValue: step)
    j.html('<div class="'+color+' white-text z-depth-1 sync">' +
           prefix + ' ' + content + '</div>')

$(document).on 'ajaxSuccess', ->
  do render_onboard_status
$(document).on 'turbolinks:load', ->
  do render_onboard_status

# LiveUpdates
@live_update_connected = ->

@live_update_received = (time) ->

  # Renderer: Model
  $('[data-livetype="model"]').each (i, dom) ->
    j = $(dom)
    url = j.data('source') || window.location.pathname
    $.ajax
      url: url
      method: 'get'
      headers:
        'Accept': 'application/json'
      success: (data) ->
        document.sync_model(data)
      error: (xhr, status, exception) ->
        console.log "LiveUpdate error: AJAX received " + exception + " with XHR:"
        console.log xhr

  # Renderer: Datatable
  $('[data-livetype="datatable"]').each (i, dom) ->
    j = $(dom)
    t = j.dataTable().api()
    params = t.ajax.params()
    $.ajax
      url: j.data('source')
      data: params
      method: 'get'
      headers:
        'Accept': 'application/json'
      success: (new_dt) ->
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
      error: (xhr, status, exception) ->
        console.log "LiveUpdate error: AJAX received " + exception + " with XHR:"
        console.log xhr

  # Renderer: Partial
  # TODO
