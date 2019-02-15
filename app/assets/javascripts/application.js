// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.

//= require jquery3
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require js.cookie
//= require analytics
//= require_self
//= require cocoon
//= require_tree .

PETS = {
    /**
     * Create an object that abstracts the spinner used by the application
     *
     * To start the spinner:
     * var mySpinner = PETS.spinner($('.placeholder'));
     * mySpinner.start();
     *
     * To stop the spinner:
     * mySpinner.stop();
     *
     *
     * @param target JQuery object with the location where the spinner should be placed
     * @returns A Spinner instance
     */
    spinner: function(target){
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
    }
};
