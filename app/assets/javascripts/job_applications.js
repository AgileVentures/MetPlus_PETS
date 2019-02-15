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

    load_form: function (jd_id) {
        $('.alert_msg').html('');
        $('#jd_apply_job_select').val('');
        $("#jd_apply_job_select").select2({
            placeholder: "Select your Job Seekers",
            ajax: {
                url: "/agency_people/"+jd_id+"/my_js_as_jd",
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
    },

    load_preview: function() {
        $.ajax({
            type: 'GET',
            url: '/job_seekers/'+this.js_user_id+'/preview_info',
            timeout: 1000,
            success: function (data) {
                $('#job_seeker').html(data);
                try{
                    $('#previewModal').modal();
                } catch(err) {}
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

var handlers = {
    setup: function () {
        var handler = dataHandler.init();
        $("#jd-apply-button").click(handler.load_form(handler.jd_id));

        $('#jdApplyJobModal').on('shown.bs.modal', function () {
            $('#jdApplyJobModal_button').click(function () {
                if ($("#jd_apply_job_select").val() === null) {
                    $('.alert_msg').html(' * Job Seeker cannot be empty.');
                    return;
                }
                handler.js_user_id = $("#jd_apply_job_select").val();
                try{
                    $("#jdApplyJobModal").modal('hide');
                } catch(err) {}
                handler.load_preview();
                return false;
            });
        });

        $('#jdApplyJobModal').on('hidden.bs.modal', function () {
            $('#jdApplyJobModal_button').off('click');
        });
    }

};

$( document ).on('turbolinks:load', function() {
    $('.pagination-div, #application-show-links').on('click', '.action_link', function() {
        var id = $(this).attr('data-application-id');
        var title = $(this).attr('data-job-title');
        var companyJobId = $(this).attr('data-job-companyJobId');
        var jobSeeker = $(this).attr('data-jobSeeker');
        var action = $(this).attr('data-action');

        $(action).find('.modal-title').html(title);
        $(action).find('#job_seeker').html("Applicant's Name: " + jobSeeker);
        $(action).find('#title').html('Job Title: ' + title);
        $(action).find('#company_job_id').html('Company Job ID: ' + companyJobId);
        if(action == "#acceptModal")
            $(action).find('#confirm_accept').attr('href','/job_applications/' + id + '/accept');
        else if(action == "#processModal") {
            $(action).find('#confirm_process').attr('href', '/job_applications/' + id + '/process');
        }
        else {
            $(action).find('#confirm_reject').attr('href',
                    '/job_applications/' + id + '/reject');

            $(action).find('#confirm_reject_noxhr').attr('action',
                    '/job_applications/' + id + '/reject');

            $('#job_reject_errors').hide(); // Hide error div in modal
        }
        $(action).modal('show');
        event.preventDefault();
    });
    handlers.setup();

});


var RejectAppln = {
    reject_action: function (e) {
        var link_url = $(this).attr('href');
        if(!RejectAppln.check_for_reason()) {
            // Prevent closing the modal
            e.preventDefault();
            e.stopPropagation();
        }
        else {
            $.ajax({
                type: 'PATCH',
                url: link_url,
                timeout: 10000,
                // Get the message entered by the user in the dialog box
                data: {reason_for_rejection: $('#reason_text').val()},
                error: function (xhrObj, status, exception) {
                    alert('Server Timed Out');
                },
                success: function (data) {
                    switch (data.status) {
                        case 200:
                            Notification.success_notification(data.message);
                            // 'click' on current pagination page link to force reload of page
                            ele = $('.pagination-div li.active a');
                            if (ele.length === 0) {
                                // if no pagination link present, reload the div directly
                                $.ajax({
                                    type: 'GET',
                                    url: $('#applications-job').attr('data-url'),
                                    timeout: 10000,
                                    error: function (xhrObj, status, exception) {
                                        alert('Server Timed Out');
                                    },
                                    success: function (apps_data) {
                                        $('#applications-job').html(apps_data);
                                    }
                                });
                            } else {
                                ele.click();
                            }
                            break;
                        default:
                            Notification.alert_notification(data.message);
                    }
                }
            });
            return true;
        }
    },
    check_for_reason: function () {
        var reason_text = $('#reason_text').val();
        if (reason_text) {
            return (true);  // Continue processing in controller or callback
        } else {
            $('#job_reject_errors').html('Please enter a reason for rejecting this application.');
            $('#job_reject_errors').show();
            return (false);
        }
    },
    setup: function () {
        $('#confirm_reject').click(RejectAppln.reject_action);

        $('#rejectModal').on('hidden.bs.modal', function(e)
                {
                    $(this).find('textarea').val('');
                });

        $('#confirm_reject_noxhr').on('click', "input[type='submit']",
                RejectAppln.check_for_reason);
    }
};
$( document ).on('turbolinks:load', RejectAppln.setup);
