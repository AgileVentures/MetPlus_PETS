function reloadScript(name) {
    jQuery.ajax({
        async: false,
        dataType: 'script',
        type: 'GET',
        url: $('script[src*="/' + name + '"]').attr('src'),
        success: function(src) { eval(src); }
    });
}