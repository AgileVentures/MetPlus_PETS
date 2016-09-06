// Handler for Job Developer's job application and confirmation form 
var dataHandler = {
  js_user_id: '',
  jd_id: '',
  job_id: '',

  init: function () {
    this.jd_id = $('#jdApplyJobModal').data("jd");
    this.job_id = $('#jdApplyJobModal').data("job");
    return this;
  },

  load_form: function () {
    $('.alert_msg').html('');
    $('#jd_apply_job_select').val('');
    $("#jd_apply_job_select").select2({
      placeholder: "Select your Job Seekers",
      ajax: { 
        url: "/agency_people/"+this.jd_id+"/my_js_as_jd",
        dataType: 'json',
        type: "GET",
        delay: 250,
        data: function (term, page) {
          return {
              q: term,
              col: 'vdn'
          };
        },
        dropdownAutoWidth : true,
        cache: true,
      }
    });
    return this;
  },

  load_preview: function() {
    $.ajax({
      type: 'GET',
      url: '/job_seekers/'+this.js_user_id+'/preview_info',
      timeout: 1000,
      success: function (data) {
        $('#job_seeker').html(data);
        $('#previewModal').modal();
      },
      error: function (xhrObj, status, exception) {
        Notification.error_notification(xhrObj.responseText);
      }
    });
    return this.set_apply_url();
  },
  
  set_apply_url: function() {
    $('#previewModal_button').attr('href', '/jobs/'+this.job_id+'/apply/'+this.js_user_id);
    return this;
  }    
};

$(function() {
  $('.pagination-div, #application-show-links').on('click', '.accept_link', function() {
    var id = $(this).attr('data-application-id');
    var title = $(this).attr('data-job-title');
    var companyJobId = $(this).attr('data-job-companyJobId');
    var jobSeeker = $(this).attr('data-jobSeeker');
   
    $('#acceptModal').find('.modal-title').html(title);
    $('#acceptModal').find('#job_seeker').html("applicant's name: " + jobSeeker);
    $('#acceptModal').find('#title').html('job title: ' + title);
    $('#acceptModal').find('#company_job_id').html('company job id: ' + companyJobId);
    $('#acceptModal').find('#confirm_accept').attr('href','/job_applications/' + id + '/accept');
    $('#acceptModal').modal();
  });

  var handler = dataHandler.init();
  $("#jd-apply-button").click(handler.load_form);
  $('#jdApplyJobModal').on('shown.bs.modal', function () {
    $('#jdApplyJobModal_button').click(function () {
      if ($("#jd_apply_job_select").val() === null) {
        $('.alert_msg').html(' * Job Seeker cannot be empty.');
        return;
      }
      handler.js_user_id = $("#jd_apply_job_select").val();
      $("#jdApplyJobModal").modal('hide');
      handler.load_preview();
    });
  });
  $('#jdApplyJobModal').on('hidden.bs.modal', function () {
    $('#jdApplyJobModal_button').off('click');
  });
});


