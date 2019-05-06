var utcToLocal = {
  setup: function () {
    $.each($('.utc_to_local_time'), function (index, value) {
        var utcTime = moment.tz(value.innerHTML.replace(/ UTC/, ''), 'UTC');
        $(value).text(moment(utcTime).tz(moment.tz.guess()).format('LLL'));
    });
  }
};

$( document ).on('turbolinks:load', utcToLocal.setup);
