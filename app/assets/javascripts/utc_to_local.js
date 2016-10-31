$(document).ready(function () {
    $.each($('.utc_to_local_time'), function (index, value) {
        utc_time = moment.tz(value.innerHTML.replace(/ UTC/, ''), 'UTC')
        $(value).text(moment(utc_time).tz(moment.tz.guess()).format('LLL'));
    })
});
