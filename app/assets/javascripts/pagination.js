/**
 * This handler will do the pagination for one specific table.
 * This function should be used for more advanced control over the paginate.
 *
 *
 * Automatic pagination
 * ** If you want to add a basic pagination, please scroll down to the PaginationManager **
 *
 *
 * @param url This parameter is used as the URL for the AJAX call
 *             it will be concatenated with the type of pagination found
 * @param viewSelector Selector used to find the div that will be replaced by the answer from AJAX
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
 * <div id='potato-1' class='potato-view'>
 * </div>
 *
 * Add one of the following options to your JS file
 *   Select by id
 *     PaginationHandler('/potatos/list/potato-pagination-type', '#potato-1')
 *
 *    Select by class if we have more than one pagination section on the page for the same collection
 *    (e.g. a view showing "Job Seekers without a Job Developer" and "Job Seekers without a Case Manager")
 *     PaginationHandler('/potatos/list/potato-pagination-type', '.potato-view')
 */
var PaginationHandler = function (url, viewSelector, successCallback, errorCallback) {

    var self = this;

    this.spinner = function(target){
        var self = this;
        this.spinnerOpts = {
            lines: 13 // The number of lines to draw
            , length: 28 // The length of each line
            , width: 17 // The line thickness
            , radius: 13 // The radius of the inner circle
            , scale: 0.25 // Scales overall size of the spinner
            , corners: 1 // Corner roundness (0..1)
            , color: '#6495ed' // #rgb or #rrggbb or array of colors
            , opacity: 0.3 // Opacity of the lines
            , rotate: 30 // The rotation offset
            , direction: 1 // 1: clockwise, -1: counterclockwise
            , speed: 1 // Rounds per second
            , trail: 100 // Afterglow percentage
            , fps: 20 // Frames per second when using setTimeout() as a fallback for CSS
            , zIndex: 2e9 // The z-index (defaults to 2000000000)
            , className: 'spinner' // The CSS class to assign to the spinner
            , top: '50%' // Top position relative to parent
            , left: '50%' // Left position relative to parent
            , shadow: false // Whether to render a shadow
            , hwaccel: false // Whether to use hardware acceleration
        };
        this._spinner = new Spinner(self.spinnerOpts);
        this.start = function() {
            target.addClass('opaque');
            self._spinner.spin(target[0]);
        };
        this.stop = function() {
            target.removeClass('opaque');
            self._spinner.stop();
        };
        return this;
    };

    this.url = url;
    this.viewSelector = viewSelector;
    this.successCallback = successCallback;
    this.errorCallback = errorCallback;

    this.load_div_from_url = function(target_idx, url) {
        var target = $($(self.viewSelector)[target_idx]);
        var spinner = self.spinner(target);
        spinner.start();
        $.ajax({type: 'GET',
            url: url,
            data: {},
            timeout: 5000,
            success: function (data){
                target.removeClass('opaque');
                spinner.stop();
                target.html(data);
                target = $($(self.viewSelector)[target_idx]);
                self.init(target, target_idx);
                if( typeof self.successCallback == "function" )
                    self.successCallback();
            },
            error: function (xhrObj) {
                spinner.stop();
                if(typeof xhrObj.responseJSON == 'undefined') {
                    Notification.error_notification('Unable to retrieve the intended page of results');
                } else {
                    Notification.error_notification(xhrObj.responseJSON['message']);
                }
                if( typeof self.errorCallback == "function" )
                    self.errorCallback();
            }
        });
    };
    this.refresh_div = function (target_idx, url) {
        self.load_div_from_url(target_idx, url);
    };
    this.paginate_div = function(ev) {
        // Check if this anchor element is disabled (e.g. 'Previous'
        // link is disabled when on page 1 of pagination)
        // (anchor is contained in 'li' element which will have 'disabled' class)

        if ($(this).parent().hasClass('disabled')) { return false; }

        ev.preventDefault();
        self.load_div_from_url($(this).data('position'), this.href);
        return false;
    };

    this.init = function(obj, target_idx) {
        obj.find(".pagination a").each(function(i, obj) {
            $(obj).click(self.paginate_div);
            $(obj).data('position', target_idx);
        });
    };

    this.setup = function() {
        $(self.viewSelector).each(function(i, obj) {
            self.refresh_div(i, self.url)
        });
    };

    this.addSuccessCallback = function(successCallback) {
        self.successCallback = successCallback;
    };

    this.addErrorCallback = function(errorCallback) {
        self.errorCallback = errorCallback;
    };

    this.setup();
    return this;
};

var PaginationFunctions = function() {
    var self = this;
    this.successFunctions = {};
    this.errorFunctions = {};
    this.addFunction = function(divId, successCallback, errorCallback) {
        self.successFunctions[divId] = successCallback;
        self.errorFunctions[divId] = errorCallback;
    };
    this.getSuccessFunction = function(divId) {
        if(divId in self.successFunctions) {
            return self.successFunctions[divId];
        }
        return undefined;
    };
    this.getErrorFunction = function(divId) {
        if(divId in self.errorFunctions) {
            return self.errorFunctions[divId];
        }
        return undefined;
    };
    return this;
};

/**
 * The pagination manager will try to load in all the site the pagination tables that
 * use the class 'pagination-div'
 *
 * Example of a div that automatically be loaded:
 * I need to paginate my potato collection.
 * The list can be retrieve using AJAX from the url: /potatos/list/all-my-potatoes
 *
 * The implementation:
 * Add the following HTML code to your page
 * <div id='potato-1' class='pagination-div' data-url='/potatos/list/' data-potato-pagination-type='all-my-potatoes'>
 * </div>
 *
 * Remark, the ID of the div should never be the same, to make sure everything works as expected.
 *
 * If you want to setup a specific callback for success or error in the previous example you should do:
 * PaginationManager.handlers['potato-1'].addSuccessCallback(function(){
 *    ....
 * });
 * PaginationManager.handlers['potato-1'].addErrorCallback(function(){
 *    ....
 * });
 *
 * @type {{setupAll: PaginationManager.setupAll, setupOne: PaginationManager.setupOne}}
 */
var PaginationManager = {
    handlers: {},
    setupAll: function(classSelector, paginationFunctions) {
        var funs = (typeof paginationFunctions === 'undefined') ? PaginationFunctions() : paginationFunctions;

        $('.'+classSelector).each(function(i, obj) {
            var id = $(obj).attr('id');
            PaginationManager.setupOne(obj,
                funs.getSuccessFunction(id),
                funs.getErrorFunction(id));
        });
    },
    setupOne: function(obj, successCallback, errorCallback) {
        var id = $(obj).attr('id');
        var url = $(obj).data('url');
        PaginationManager.handlers[id] = PaginationHandler(url,
                                                '#' + id,
                                                successCallback,
                                                errorCallback);
    }
};

$(document).ready(function () {
    PaginationManager.setupAll('pagination-div');
});