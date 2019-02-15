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

var PaginationHandler = function (url, viewSelector, successCallback, errorCallback, beforeGetCallback) {

    var self = this;

    this.spinner = PETS.spinner;

    this.url = url;
    this.viewSelector = viewSelector;
    this.name = viewSelector.substring(1);
    this.successCallback = successCallback;
    this.errorCallback = errorCallback;
    this.beforeGetCallback = beforeGetCallback;
    this.lastURL = '';

    this.load_div_from_url = function(target_idx, url) {

        if(typeof self.successCallback == 'undefined')
            self.successCallback = PaginationFunctions.getSuccessFunction(self.name);
        if(typeof self.errorCallback == 'undefined')
            self.errorCallback = PaginationFunctions.getErrorFunction(self.name);
        if(typeof self.beforeGetCallback == 'undefined')
            self.beforeGetCallback = PaginationFunctions.getBeforeGetFunction(self.name);

        if( typeof self.beforeGetCallback == "function" )
            self.beforeGetCallback();

        var target = $($(self.viewSelector)[target_idx]);
        var spinner = self.spinner(target);
        spinner.start();
        this.lastURL = url;
        $.ajax({type: 'GET',
            url: url,
            data: {},
            timeout: 5000,
            success: function (data){
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
        $(obj[target_idx]).off('pagination:reload')
                       .on('pagination:reload', function (event) {
            self.load_div_from_url(target_idx, self.lastURL);
        });

        obj.find(".pagination a").each(function(i, obj) {
            $(obj).off('click').click(self.paginate_div);
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

var PaginationFunctions = {
    successFunctions: {},
    errorFunctions: {},
    beforeGetFunctions: {},
    addFunction: function(divId, successCallback, errorCallback, beforeGetCallback) {
        PaginationFunctions.successFunctions[divId] = successCallback;
        PaginationFunctions.errorFunctions[divId] = errorCallback;
        PaginationFunctions.beforeGetFunctions[divId] = beforeGetCallback;
    },
    getSuccessFunction: function(divId) {
        if(divId in PaginationFunctions.successFunctions) {
            return PaginationFunctions.successFunctions[divId];
        }
        return undefined;
    },
    getErrorFunction: function(divId) {
        if(divId in PaginationFunctions.errorFunctions) {
            return PaginationFunctions.errorFunctions[divId];
        }
        return undefined;
    },
    getBeforeGetFunction: function(divId) {
        if(divId in PaginationFunctions.beforeGetFunctions) {
            return PaginationFunctions.beforeGetFunctions[divId];
        }
        return undefined;
    }
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
    setupAll: function(classSelector) {
        $('.'+classSelector).each(function(i, obj) {
            var id = $(obj).attr('id');
            PaginationManager.setupOne(obj,
                PaginationFunctions.getSuccessFunction(id),
                PaginationFunctions.getErrorFunction(id));
        });
    },
    setupOne: function(obj, successCallback, errorCallback) {
        var id = $(obj).attr('id');
        var url = $(obj).data('url');
        PaginationManager.handlers[id] = new PaginationHandler(url,
                                                                '#' + id,
                                                                successCallback,
                                                                errorCallback);
    }
};

$( document ).on('turbolinks:load', function() {
    PaginationManager.setupAll('pagination-div');

    // Callbacks for alternative pagination mechanism:

    // Paginate link sends AJAX request to controller, which renders new page
    // in JS response.  These callbacks execute at that point and replaces
    // the prior pagination page (DOM element) with the new page.

    $('body').on('ajax:success', '.searched_jobs_pagination', function (e, data) {
      $('#searched-job-list').html(data);
    });

    $('body').on('ajax:success', '.cmpy_people_pagination', function (e, data) {
      $('#cmpy-people-list').html(data);
    });

    $('body').on('ajax:success', '.jobs-pagination', function (e, data) {
      $('#jobs-list').html(data);
    });

    $('body').on('ajax:success', '.applications-pagination', function (e, data) {
      $('div[id^="applications-"]').html(data);
    });
});
