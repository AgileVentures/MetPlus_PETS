var RegistrationDeny = {
  deny_action: function () {
    var action_url = $('#company_approve_link').attr('href').replace(/approve$/, 'deny');

    $.ajax({type: 'PATCH',
            url: action_url,
            // Get the message entered by the user in the dialog box
            data: { email_text: $('#message_text').val() },
            timeout: 10000,
            error: function (xhrObj, status, exception) {alert('Server Timed Out');},
            success: function (data, status, xhrObject){
              $('#company_status').html(data);
              }
            });

    return(true);
  },
  setup: function () {
    // Add button-click event callback to the 'Send email' button in the
    // dialog box that is opened when the 'Deny' button is clicked.
    $('#send_button').click(RegistrationDeny.deny_action);
  }
};

$( document ).on('turbolinks:load', RegistrationDeny.setup);
