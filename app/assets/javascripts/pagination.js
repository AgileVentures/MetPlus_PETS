/**
 * This manager can handle the pagination on any page
 * @param url This parameter is used as the URL for the AJAX call
 *             it will be concatenated with the type of pagination found
 * @param viewSelector Selector used to find the div that will be replaced by the answer from AJAX
 * @param paginationType This is the name of the data field in the div selected that contains
 *                       the rest of the URL
 * @param successCallback After changing the div with the latest information calls this function
 *                        that can be or not present.
 *                        Only use this functions if you need to execute more operations
 *                        after the div is changed
 * @param errorCallback If an error occur during the AJAX call this function is called after a error notification
 *                      is launched
 *                      Only use this function if you need to execute more operations
 * example:
 * I need to paginate my potato collection.
 * The list can be retrieve using AJAX from the url: /potatos/list/all-my-potatoes
 *
 * The implementation:
 * Add the following HTML code to your page
 * <div id='potato-1' class='potato-view' data-potato-pagination-type='all-my-potatoes'>
 * </div>
 *
 * Add one of the following options to your JS file
 *   Select by id
 *     PaginationManager('/potatos/list/', '#potato-1', 'potato-pagination-type')
 *
 *   Select by class if we have more then 1
 *     PaginationManager('/potatos/list/', '.potato-view', 'potato-pagination-type'
 */
var PaginationManager = function (url, viewSelector, paginationType, successCallback, errorCallback) {

    var self = this;
    this.url = url;
    this.viewSelector = viewSelector;
    this.paginationType = paginationType;

    this.load_jobs_from_url = function(target_idx, url) {
        var target = $($(self.viewSelector)[target_idx]);
        target.html("Page is loading...");
        $.ajax({type: 'GET',
            url: url,
            data: {},
            timeout: 5000,
            success: function (data){
                target.replaceWith(data);
                target = $($(self.viewSelector)[target_idx]);
                self.init(target, target_idx);
                if( typeof successCallback == "function" )
                    successCallback();
            },
            error: function (xhrObj) {
                Notification.error_notification(xhrObj.responseJSON['message']);
                if( typeof errorCallback == "function" )
                    errorCallback();
            }
        });
    };
    this.refresh_div = function (target_idx, url) {
        self.load_jobs_from_url(target_idx, url);
    };
    this.paginate_jobs = function(ev) {
        ev.preventDefault();
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
        $(self.viewSelector).each(function(i, obj) {
            var job_type = $(obj).data(self.paginationType);
            self.refresh_div(i, self.url + job_type)
        });
    };
    this.setup();
    return this;
};
