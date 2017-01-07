/**
 * Created by joao on 4/8/16.
 */

var Notification = {
    notify: function(text, type) {
        var closeWith = (/href ?=/.test(text) ? ['button'] : ['click']);
        noty({text: text,
            theme: 'bootstrapTheme',
            layout: 'bottomRight',
            type: type,
            closeWith: closeWith});
    },
    success_notification: function(text) {
        Notification.notify(text, 'success');
    },
    error_notification: function(text) {
        Notification.notify(text, 'error');
    },
    info_notification: function(text) {
        Notification.notify(text, 'information');
    },
    alert_notification: function(text) {
        Notification.notify(text, 'alert');
    }
};
