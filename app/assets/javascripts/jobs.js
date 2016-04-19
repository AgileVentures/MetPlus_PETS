var JobsManager = function () {

    var self = this;
    this.last_load_url = "/jobs/list/";

    this.load_jobs_from_url = function(target_idx, url) {
        var target = $($('.jobs-view')[target_idx]);
        target.html("Page is loading...");
        $.ajax({type: 'GET',
            url: url,
            data: {},
            timeout: 5000,
            success: function (data){
                target.replaceWith(data);
                target = $($('.jobs-view')[target_idx]);
                self.init(target, target_idx);
            },
            error: function (xhrObj, status, exception) {
                Notification.error_notification(xhrObj.responseJSON['message']);
            }
        });
    };
    this.refresh_jobs = function (target_idx, url) {
        self.load_jobs_from_url(target_idx, url);
    };
    this.paginate_jobs = function() {
        self.load_jobs_from_url($(this).data('position'), this.href);
        return false;
    };

    this.init = function(obj, target_idx) {
        obj.find(".pagination a").each(function(i, obj) {
            $(obj).click(self.paginate_jobs);
            $(obj).data('position', target_idx);
        });
    };

    this.setup = function() {
        $('.jobs-view').each(function(i, obj) {
            var job_type = $(obj).data('job-type');
            self.refresh_jobs(i, self.last_load_url + job_type)
        });
    };
    this.setup();
};

$(document).ready(function () {
    JobsManager();
});