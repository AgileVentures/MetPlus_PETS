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
});