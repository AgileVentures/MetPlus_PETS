$(function () {
  $('#toggle_search_form').click(ManageData.toggle);
  $('#job_search_form').hide();
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
  });
