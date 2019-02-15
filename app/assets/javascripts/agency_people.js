var AssignAgencyPerson = {
  // assign an agency person, as a job developer or case manager, to a job seeker
  assign_action: function () {

    // 'this' is the element (button) that was clicked
    var id = $(this).attr('id');
    // the action URL is attached to button as a custom data attribute
    var action_url = $(this).data('url');

    $.ajax({type: 'PATCH',
            url: action_url,
            timeout: 10000,
            error: function (xhrObj, status, exception) {
              Notification.error_notification(xhrObj.responseJSON['message']);
            },
            success: function (data, status, xhrObject){
              // check if JD or CM assignment
              if (/jd/.test(id)) {
                $('#assigned_job_developer').html(data);
              } else if (/cm/.test(id)) {
                $('#assigned_case_manager').html(data);
              }
            }});

    return(true);
  },
  setup: function () {
    $('#assign_jd').click(AssignAgencyPerson.assign_action);
    $('#assign_cm').click(AssignAgencyPerson.assign_action);
  }
};

$( document ).on('turbolinks:load', AssignAgencyPerson.setup);
