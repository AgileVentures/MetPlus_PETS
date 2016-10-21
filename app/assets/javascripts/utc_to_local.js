$(".job_seekers.edit").ready(function() {
    $('#utc_to_local_time').text(moment($('#utc_to_local_time')[0].innerHTML).format('LLLL'));
})