var JobAndResume = {
  match: function () {
    $('#match_my_resume').on('click', function() {
      var answer = confirm('This will match your résumé against all active jobs ' +
                           ' and may take a while.     Do you want to proceed?');
      if (answer) {
        var mySpinner = PETS.spinner($('.table.table-bordered'));
        mySpinner.start();

        $.ajax({type: 'GET',
                url: '/jobs/' + $(this).data('jobId') + '/match_resume' +
                              '?job_seeker_id=' + $(this).data('jobSeekerId'),
                timeout: 60000,
                success: function (data) {
                  mySpinner.stop();
                  if(data.status === 404) {
                    Notification.error_notification('An error occurred: ' +
                                                    data.message);
                    return;
                  }
                  $('#resumeMatchScore').html(data.stars_html);
                  $('#resumeMatchModal').modal();

                },
                error: function () {
                  mySpinner.stop();
                  Notification.error_notification('Not able to perform matching');
                }
        });
      }
    });
  }
};

var ContactJobDeveloper = {
  jsInterest: function () {
    $('.js_interest').on('click', function() {
      var answer = confirm('Notify job developer of your ' +
                           'interest in this job seeker?');
      if (answer) {

        var url = '/jobs/' + $(this).data('jobId') + '/notify_job_developer' +
                  '?job_seeker_id=' + $(this).data('jobSeekerId') +
                  '&company_person_id=' + $(this).data('companyPersonId') +
                  '&job_developer_id=' + $(this).data('jobDeveloperId');

        $.ajax({type: 'GET',
                url: url,
                timeout: 10000,
                success: function () {
                  Notification.success_notification('Notified job developer');
                },
                error: function () {
                  Notification.error_notification('Unable to notify job developer');
                }
        });
      }
    });
  }
};

$( document ).on('turbolinks:load', function() {
  $('#toggle_search_form').click(ManageData.toggle);
  $(document).on('change', '#job_company_id', function() {
    $.ajax({url: '/jobs/update_addresses',
            type: 'GET',
            data: {
              company_id: $('#job_company_id option:selected').val()
            },
            error: function (jqXHR, textStatus) {
              Notification.error_notification('Ajax Error: ' + textStatus);
            },
            success: function (data) {
              $('#address-select').html(data);
            }
          });
  });


  $('button[data-action="revoke"], #revoke_link').on('click', function() {
    var id = $(this).attr('data-job-id');
    var title = $(this).attr('data-job-title');
    var companyJobId = $(this).attr('data-job-companyJobId');

    $('#revokeModal').find('.modal-title').html(title);
    $('#revokeModal').find('#title').html('job title: ' + title);
    $('#revokeModal').find('#company_job_id').html('company job id: ' + companyJobId);
    $('#revokeModal').find('#confirm_revoke').attr('href','/jobs/' + id + '/revoke');
    $('#revokeModal').modal('show');
    return false;
  });

  $('#q_address_city_in').select2();
  $('#q_skills_id_in').select2();
  $('#q_company_id_in').select2();
  $('#q_status_in').select2();
  $('.job-type-multiple').select2();
  $('.job-shift-multiple').select2();

  JobAndResume.match();

  ContactJobDeveloper.jsInterest();

  $('#job-seekers-select').select2({
    placeholder: 'Choose Job Seekers'
  });

  $('#match-resumes-link').click(function () {
    $('#match-resumes-modal-form').modal();
    return false;
  });

  // To remove the alert after the user has selected a job seeker from dropdown
  $('#job-seekers-select').on('change', function() {
    $('#message').html('');
    $('#message').removeClass('alert alert-danger');
  });

  $('#run-match-btn').click(function () {
    var selectedValues = $('#job-seekers-select').val();
    if (selectedValues === null) {
      $('#message').html('Please choose a job seeker');
      $('#message').addClass('alert alert-danger');
      var glyphicon = '<i class="glyphicon glyphicon-exclamation-sign">&nbsp;';
      $('#message').prepend(glyphicon);
      return false;
    }
    return confirm("This will match your job seekers' résumés against the job" +
                    " and may take a while. Do you want to proceed?");
  });

  $('body').on('ajax:success', '.pagination', function (e, data) {
    $('#searched-job-list').html(data);
  });

  if ($('#new-address-subform').is(':visible') !== true) {
    // When job form is rendered, disable "new address" fields unless those
    // fields are visible - if visible, the user is trying to create a new
    // address and the form has been re-rendered with model errors.
    $('.new_address_field').prop('disabled', true);
  };

  $('#toggle-address-fields').click(function (event) {
    // toggle new address fields (visible, not visible) on job form
    var toggleId = $('#new-address-subform');  // element to be toggled

    // Disabled input fields will not be sent to the server
    if ($(toggleId).is(':visible') === true) {

      $(toggleId).addClass('hidden');
      $('.new_address_field').prop('disabled', true);
      $(this).text('Create new location');

    } else {

      $(toggleId).removeClass('hidden');
      $('.new_address_field').prop('disabled', false);
      $(this).text('Cancel new location');

    }
    return false;
  });

  // Job questions radio boxes in job apply modal ("Yes", "No")
  $('.job-question-rb').click(function () {
    // Get total number of radio boxes - if 1/2 are checked all questions answered

    if ($('.job-question-rb').length/2 ===
        $('.job-question-rb').filter(':checked').length) {
          $('#modal-apply-id').prop('disabled', false);
        }

    return false;
  });

});
