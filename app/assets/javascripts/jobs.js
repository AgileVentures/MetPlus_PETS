$(function () {
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
              $('#address_select').html(data);
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
    $('#revokeModal').modal();

  });

  $('#q_address_city_in').select2();
  $('#q_skills_id_in').select2();
  $('#q_company_id_in').select2();

});
