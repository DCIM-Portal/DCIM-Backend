#Main Admin coffee scripts

$(document).on 'turbolinks:load', ->

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
    createdRow: (row, data, dataIndex) ->
      $(row).attr 'data-source', data.host_path
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
        className: 'btn grey lighten-2 waves-effect'
        action: () ->
          # Show indicator that modal is loading
          $("#load-indicator").fadeIn()
          # Empty out any existing content to avoid old content visibility
          $("#admin_modal").empty()
          $("#admin_modal").addClass('bootstrap-sheet')
          $("#admin_modal").css("bottom", "inherit")
          # Make an array to store our IDs
          id_array = []
          # Get table rows that have a check
          rows_selected = document.detail_table.api().column(0).checkboxes.selected();
          $.each rows_selected, (index, rowId) ->
            # Add checked row IDs to the array
            id_array.push rowId
          # Send array via an ajax request to load the modal
          $.ajax
            url: '/admin/bmc_hosts/onboard_requests/new_modal'
            type: 'post'
            data: selected_ids: id_array
            # If successful, load modal and conditions
            success: (data) ->
              # Populate modal with data
              $('#admin_modal').html data
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
              $('#admin_modal').modal('open')
              # Custom modal close action
              $('div#admin_modal.open, .modal-close').click ->
                $('#admin_modal').modal('close')
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
              $('#admin_modal').html data
              $('#load-indicator').hide()
              $('#admin_modal').modal('open')
      }
      {
        text: '<i class="fa fa-files-o"></i> <span class="dt-btn-text">BMC Bulk Actions</span>'
        className: 'btn grey lighten-2 waves-effect'
        action: () ->
          $("#load-indicator").fadeIn()
          $("#admin_modal").empty()
          $("#admin_modal").addClass('bootstrap-sheet')
          $("#admin_modal").css("bottom", "inherit")
          id_array = []
          rows_selected = document.detail_table.api().column(0).checkboxes.selected();
          $.each rows_selected, (index, rowId) ->
            id_array.push rowId
          $.ajax
            url: '/admin/bmc_hosts/new_modal'
            type: 'post'
            data: selected_ids: id_array
            # If successful, load modal and conditions
            success: (data) ->
              # Populate modal with data
              $('#admin_modal').html data
              # Hide the load indicator
              $('#load-indicator').hide()
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
              $('#admin_modal').modal('open')
              # Custom modal close action
              $('div#admin_modal.open, .modal-close').click ->
                $('#admin_modal').modal('close')
              # Ensure that clicking inside the modal won't close it
              $('div.modal-dialog').click (e) ->
                e.stopPropagation()
              # Make the onboard submit button disabled
              $('.bulk_action').prop 'disabled', true
              # Make onboard submit button enabled on correct input value
              $('#confirm').keyup ->
                $('.bulk_action').prop 'disabled', if @value != 'Commit Action' then true else false
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
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-title', 'Brand:'
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
        if !data
          "N/A"
        else
          moment(data).format 'MMMM D YYYY, h:mma'
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-title', 'Updated At:'
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
        text_to_onboard_status(data + ': ' + full.onboard_step)
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-errorfield', 'onboard_error_message' if /(stack_trace|timeout)/.test(rowData.onboard_status)
        $(td).attr 'data-title', 'Onboard Status:'
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
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-title', 'Power Status:'
      }
      # Sync Status
      { targets: 'th_bmc_sync'
      render: (data, type, full) ->
        text_to_request_status('bmc_host', data)
      width: 200
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-errorfield', 'bmc_host_error_message' if /(error|stack_trace)/.test(rowData.sync_status)
        $(td).attr 'data-title', 'Sync Status:'
      }
      # Product
      { targets: 'th_product'
      orderable: true
      render: (data, type, full) ->
        if !data
          '<div class="model_cell">N/A</div>'
        else
          '<div class="model_cell">' + data + '</div>'
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-title', 'Product:'
      }
      # Serial
      { targets: 'th_serial'
      orderable: true
      render: (data, type, full, meta) ->
        if data
          '<div class="serial">' + data + '</div>'
        else
          '<div class="serial">N/A</div>'
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-title', 'Serial:'
      width: 115
      }
      # BMC Address
      { targets: 'th_bmc_address'
      width: 75
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-title', 'BMC Address:'
      }
      # BMC Scan Request Status
      { targets: 'th_scan_status'
      searchable: false
      render: (data, type, full, meta) ->
        text_to_request_status('bmc_scan_request', data)
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-errorfield', 'bmc_scan_request_error_message' if /(smart|invalid)/.test(rowData.status)
      }
      { targets: 'th_id'
      width: 50
      }
      # Onboard Request Status
      { targets: 'th_ob_scan_status'
      searchable: false
      render: (data, type, full, meta) ->
        text_to_request_status('onboard_request', data)
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-errorfield', 'onboard_request_error_message' if /(error|stack_trace)/.test(rowData.status)
      }
      { targets: 'th_id'
      width: 50
      }
      # Zone
      { targets: 'th_zone'
      createdCell: (td, cellData, rowData) ->
        $(td).attr 'data-title', 'Datacenter Zone:'
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

  # Menu Aim for Sidenav
  $menu = $('ul.sidenav-menu')

  activateSubmenu = (row) ->
    $row = $(row)
    $submenu = $row.children('ul.sidenav-menu')
    $row.children('li ul.sidenav-popout-menu').addClass 'menu-is-active'
    return
  
  deactivateSubmenu = (row) ->
    $row = $(row)
    $submenu = $row.children('ul.sidenav-menu')
    $row.children('li ul.sidenav-popout-menu').removeClass 'menu-is-active'
    return
  
  $menu.menuAim
    activate: activateSubmenu
    deactivate: deactivateSubmenu
    exitMenu: ->
      true

  # Hide message divs on load
  $("#success_explanation").hide()
  $('.form_card_error').hide()
  $("#waiting_explanation").hide()

# Define standard ajax forms
ajax_forms = "form#ajax_card_form_new, form#ajax_card_form_update, form#ajax_card_cred_new, form#ajax_card_cred_update"

# Submit Ajax Form
$(document).on 'click', '#ajax_submit_button', (event) ->
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
$(document).on 'click', '.activator', ->
  $('.card-reveal').css 'height', 'auto'
  autoHeight = $('.card-reveal').outerHeight()
  $('.card-reveal').css 'height', '100%'
  $('.ovf-hidden').animate { height: autoHeight }, 250
  $('#outer-card').hide()

# Original card, adjust height
$(document).on 'click', '.card-title', ->
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
$(document).on 'ajax:success', ajax_forms, (event, data, status, xhr) ->
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
$(document).on 'ajax:error', ajax_forms, (event, xhr, status, error) ->
  $("#waiting_explanation").hide()
  errors = jQuery.parseJSON(xhr.responseText)
  $("#success_explanation").hide()
  $('.form_card_error').empty()
  $('.form_card_error').append('<ul>')
  if errors.error
    $('.form_card_error ul').append('<li>' + errors.error + '</li>')
  else
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
$(document).on 'ajax_success', 'form#ajax_card_form_new, form#ajax_card_cred_new', ->
  $('form#ajax_card_form_new, form#ajax_card_cred_new')[0].reset()

# Modal status errors
$(document).on 'click', '.modal_error_button', ->
  # Show indicator that modal is loading
  $("#load-indicator").fadeIn()
  # Empty out any existing content to avoid old content visibility
  $("#admin_modal").empty()
  $("#admin_modal").addClass('bottom-sheet')
  $('div#admin_modal').off('click')
  source = $(this).closest('[data-source]').data('source')
  error_type = $(this).closest('[data-errorfield]').data('errorfield')
  $.ajax
    url: source + '.json'
    type: 'GET'
    success: (data) ->
      # XXX: Make locale translation into a function
      # BMC Sync Status Error
      if error_type == "bmc_host_error_message"
        $('#admin_modal').html '<div class="modal-content"><blockquote>BMC Host ' +
        data.ip_address + ' Sync Status - ' + I18n.t(data.sync_status, scope: 'filters.options.bmc_host.sync_status', defaultValue: data.sync_status) +
        ' <a class="modal-action modal-close pull-right"><i class="fa fa-close"></i></a></blockquote>' +
        if !data.error_message
          '<p>No additional details were captured for this error.</p></div>'
        else
          simpleFormat(data.error_message) + '</div>'
      # BMC Onboard Error
      else if error_type == "onboard_error_message"
        $('#admin_modal').html '<div class="modal-content"><blockquote>BMC Host ' +
        data.ip_address + ' Onboard Status - ' + I18n.t(data.onboard_status, scope: 'filters.options.bmc_host.onboard_status', defaultValue: data.onboard_status) + ': ' + I18n.t(data.onboard_step, scope: 'filters.options.bmc_host.onboard_step', defaultValue: data.onboard_step) +
        ' <a class="modal-action modal-close pull-right"><i class="fa fa-close"></i></a></blockquote>' +
        if !data.onboard_error_message
          '<p>No additional details were captured for this error.</p></div>'
        else
          simpleFormat(data.onboard_error_message) + '</div>'
      # System Sync Status Error
      else if error_type == "system_error_message"
        $('#admin_modal').html '<div class="modal-content"><blockquote>Foreman System ' +
        data.foreman_host_id + ' Sync Status - ' + I18n.t(data.sync_status, scope: 'filters.options.system.sync_status', defaultValue: data.sync_status) +
        ' <a class="modal-action modal-close pull-right"><i class="fa fa-close"></i></a></blockquote>' +
        if !data.error_message
          '<p>No additional details were captured for this error.</p></div>'
        else
          simpleFormat(data.error_message) + '</div>'
      # BmcScanRequest status error
      else if error_type == "bmc_scan_request_error_message"
        $('#admin_modal').html '<div class="modal-content"><blockquote>BMC Scan Request ' +
        data.id + ' Status - ' + I18n.t(data.status, scope: 'filters.options.bmc_scan_request.status', defaultValue: data.status) +
        ' <a class="modal-action modal-close pull-right"><i class="fa fa-close"></i></a></blockquote>' +
        if !data.error_message
          '<p>No additional details were captured for this error.</p></div>'
        else
          simpleFormat(data.error_message) + '</div>'
      # OnboardRequest status error
      else if error_type == "onboard_request_error_message"
        $('#admin_modal').html '<div class="modal-content"><blockquote>Onboard Request ' +
        data.id + ' Status - ' + I18n.t(data.status, scope: 'filters.options.onboard_request.status', defaultValue: data.status) +
        ' <a class="modal-action modal-close pull-right"><i class="fa fa-close"></i></a></blockquote>' +
        if !data.error_message
          '<p>No additional details were captured for this error.</p></div>'
        else
          simpleFormat(data.error_message) + '</div>'
      $('#load-indicator').hide()
      $('#admin_modal').modal('open')

# Nav Menu Controls

$(document).on 'click', '.toggle-extended-menu', ->
  $('nav.sidenav-menu-wrapper').addClass('extended-sidenav')
  $('ul.sidenav-menu').addClass('extended-menu')
  $('ul.extended-menu li.active ul.sidenav-popout-menu').removeClass('sidenav-popout-menu')
  $('main.fixed-side-nav').addClass('side-nav-extended')
  $('.toggle-extended-menu').addClass('toggle-icon-menu').removeClass('toggle-extended-menu')
  $('ul.sidenav-menu li.activate-menu').removeClass('icon-view')

$(document).on 'click', '.toggle-icon-menu', ->
  $('ul.sidenav-menu li.activate-menu').addClass('icon-view')
  $('.toggle-icon-menu').addClass('toggle-extended-menu').removeClass('toggle-icon-menu')
  $('main.fixed-side-nav').removeClass('side-nav-extended')
  $('ul.sidenav-menu li.active ul.dropdown-content').addClass('sidenav-popout-menu')
  $('ul.sidenav-menu').removeClass('extended-menu')
  $('nav.sidenav-menu-wrapper').removeClass('extended-sidenav')

$(document).on 'turbolinks:before-cache', ->
  # Load overlay
  $('.overlay').show()

  # Close any open modal and overlay
  $('#admin_modal').modal('close')
  $('.modal-overlay').remove()

  # Hide message divs on load
  $("#waiting_explanation").hide()
  $("#success_explanation").hide()
  $('.form_card_error').hide()
  
  # Hide Async Wrapper
  $('#async_wrapper').hide()

  # Prevent duplicate selects
  $('.m_select').material_select 'destroy'

  # Hide Submenus
  $('ul.sidenav-popout-menu').removeClass 'menu-is-active'

@formatBytes = (a, b) ->
  if 0 == a || !a
    return ''
  c = 1024
  d = b or 1
  e = [
    'Bytes'
    'KB'
    'MB'
    'GB'
    'TB'
    'PB'
    'EB'
    'ZB'
    'YB'
  ]
  f = Math.floor(Math.log(a) / Math.log(c))
  parseFloat((a / c ** f).toFixed(d)) + ' ' + e[f]

@simpleFormat = (str) ->
  str = str.replace(/\r\n?/, '\n')
  str = $.trim(str)
  if str.length > 0
    str = str.replace(/\n\n+/g, '</p><p>')
    str = str.replace(/\n/g, '<br />')
    str = '<p>' + str + '</p>'
  str

@text_to_onboard_status = (text) ->
    status_and_step = text.split(': ')
    status = status_and_step.shift() || "null"
    step = status_and_step.join(': ') || "null"
    append = ''
    switch status
      when "success" 
        color = 'green lighten-2'
        prefix = '<i class="fa fa-check-circle-o" aria-hidden="true"></i>'
      when "in_progress"
        color = 'blue lighten-2'
        prefix = '<svg class="spinner" viewBox="0 0 50 50"><circle class="path" cx="25" cy="25" r="20" fill="none" stroke-width="5"></circle></svg>'
        append = ': ' + I18n.t(step, scope: 'filters.options.bmc_host.onboard_step', defaultValue: step)
      when "null"
        color = 'blue-grey lighten-1'
        prefix = '<i class="fa fa-minus-circle" aria-hidden="true"></i>'
      else
        color = 'red lighten-2'
        prefix = '<i class="fa fa-exclamation-triangle" aria-hidden="true"></i>'
        append = ': ' + I18n.t(step, scope: 'filters.options.bmc_host.onboard_step', defaultValue: step)
    content = I18n.t(status, scope: 'filters.options.bmc_host.onboard_status', defaultValue: status) + append
    return '<div class="'+color+' white-text z-depth-1 sync">' + prefix + ' ' + content + '</div>' unless /red/.test(color)
    return '<div class="'+color+' white-text z-depth-1 sync modal_error_button" data-target="admin_modal">' + prefix + ' ' + content + '</div>' if /red/.test(color)

@render_onboard_status = ->
  $('.onboard_status').each (i, dom) ->
    j = $(dom)
    return false if j.has('div').length
    status_and_step = j.html()
    j.html(text_to_onboard_status(status_and_step))

#XXX: Change naming
@text_to_request_status = (type, text) ->
  switch text
    when "complete", "scan_complete", "success"
      color = 'green lighten-2'
      prefix = '<i class="fa fa-check-circle-o" aria-hidden="true"></i>'
    when "in_progress"
      color = 'blue lighten-2'
      prefix = '<svg class="spinner" viewBox="0 0 50 50"><circle class="path" cx="25" cy="25" r="20" fill="none" stroke-width="5"></circle></svg>'
    when ""
      color = 'blue-grey darken-2'
      prefix = '<i class="fa fa-hourglass-start" aria-hidden="true"></i>'
      content = 'Queued'
    when "invalid_credentials_error", "invalid_username_error", "invalid_password_error"
      color = 'orange lighten-2'
      prefix = '<i class="fa fa-exclamation-triangle" aria-hidden="true"></i>'
    else
      color = 'red lighten-2'
      prefix = '<i class="fa fa-exclamation-triangle" aria-hidden="true"></i>'
  content ||= I18n.t(text, scope: 'filters.options.'+type+'.status', defaultValue: text) if /request/.test(type)
  content ||= I18n.t(text, scope: 'filters.options.'+type+'.sync_status', defaultValue: text) if (type == "bmc_host" || type == "system")
  return '<span class="white-text z-depth-1 sync '+color+'">' + prefix + ' ' + content + '</span>' unless /red/.test(color)
  return '<span class="white-text z-depth-1 sync '+color+' modal_error_button" data-target="admin_modal">' + prefix + ' ' + content + '</span>' if /red/.test(color)

#XXX: Change naming
@render_standard_request_status = ->
  $('.standard_request_status').each (i, dom) ->
    j = $(dom)
    return false if j.has('span').length
    status = j.html()
    type = 'onboard_request' if j.attr('id') == 'category_onboard_request_status'
    type = 'bmc_scan_request' if j.attr('id') == 'category_bmc_scan_request_status' 
    type = 'bmc_host' if j.hasClass 'category_bmc_host_sync_status'
    type = 'system' if j.hasClass 'category_system_sync_status'
    j.html(text_to_request_status(type, status))

$(document).on 'ajaxSuccess', ->
  do render_onboard_status
  do render_standard_request_status
$(document).on 'turbolinks:load', ->
  do render_onboard_status
  do render_standard_request_status

# LiveUpdates
@live_update_connected = ->

@live_update_lock = (j) ->
  j.attr('data-livelocked', true)

@live_update_locked = (j) ->
  return j.attr('data-livelocked')

@live_update_unlock = (j) ->
  j.removeAttr('data-livelocked')

@live_update_set_run_again = ->
  document.live_update_run_again = true

@live_update_should_run_again = ->
  return false if $('[data-livelocked]').length > 0
  return document.live_update_run_again

@live_update_run_again = ->
  document.live_update_run_again = false
  live_update_received((new Date).getTime())

@live_update_received = (time) ->

  # Renderer: Model
  $('[data-livetype="model"]').each (i, dom) ->
    j = $(dom)
    url = j.data('source') || window.location.pathname
    if live_update_locked(j)
      live_update_set_run_again
      return true
    live_update_lock(j)
    $.ajax
      url: url + '.json'
      method: 'get'
      #headers:
      #  'Accept': 'application/json'
      success: (data) ->
        document.sync_model(data)
      error: (xhr, status, exception) ->
        console.log "LiveUpdate error: AJAX received " + exception + " with XHR:"
        console.log xhr
      complete: ->
        live_update_unlock(j)
        live_update_run_again() if live_update_should_run_again()

  # Renderer: Datatable
  $('[data-livetype="datatable"]').each (i, dom) ->
    j = $(dom)
    t = j.dataTable().api()
    params = t.ajax.params()
    if live_update_locked(j)
      live_update_set_run_again
      return true
    live_update_lock(j)
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
      complete: ->
        live_update_unlock(j)
        live_update_run_again() if live_update_should_run_again()

  # Renderer: Partial
  # TODO
