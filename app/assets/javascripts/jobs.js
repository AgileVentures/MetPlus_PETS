var JobsManager = function () {

    var self = this;
    this.last_load_url = "/jobs/list/";

    this.load_jobs_from_url = function(target, url) {
        target.html("Page is loading...");
        $.ajax({type: 'GET',
            url: url,
            data: {},
            timeout: 5000,
            success: function (data){
                target.replaceWith(data);
                self.init(target);
            },
            error: function (xhrObj, status, exception) {
                Notification.error_notification(xhrObj.responseJSON['message']);
            }
        });
    };
    this.refresh_jobs = function (target, url) {
        self.load_jobs_from_url(target, url);
    };
    this.paginate_jobs = function() {
        self.load_tasks_from_url(target, this.href);
        return false;
    };

    this.init = function(obj) {
        obj.find(".pagination a").click(self.paginate_jobs);
    };

    this.setup = function() {
        $('.jobs-view').each(function(i, obj) {
            var job_type = $(obj).data('job-type');
            self.refresh_jobs($(obj), self.last_load_url + job_type)
        });
    };
    this.setup();
};

$(document).ready(function () {
    JobsManager();
});