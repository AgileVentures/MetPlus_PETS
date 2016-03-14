var ManageData = {

  change_data_error: function (exception, xhrObj, model_errors_id) {
    // This helper function is called when an object 'new' or 'update'
    // action (invoked via ajax) returns with an error.
    // It is most likely one or more model validation errors.
    // In that case, post the errors to the model errors div
    // (typically, this div is in a modal dialog box which is
    //  presenting the form for model attributes to the user).

    // If you use this, be sure that your controller action returns the
    // 'Unprocessable Entity' status (422) upon model validation failure.

    // (Firefox adds a trailing whitespace char to 'exception' -
    //  hence the 'trim()' function)

    if (exception.trim() === 'Unprocessable Entity') {
      $(model_errors_id).html(xhrObj.responseText);
    } else {
      alert('Server Error');
    }
  },

  update_paginate_data: function () {
    // This helper function will update visible data when a will_paginate
    // link is clicked.
    // The data to be updated must be enclosed in a div (here, 'div_id')
    // (e.g., this is typically a div that contains a table, which in turn
    // contains the data to be updated).  That div also has to encompass
    // the will_paginate pagination links.
    // For an example of this div, see view/branches/_branches.html.haml

    // This function is bound to the 'click' event for the div_id, which
    // is delegated to the pagination anchor element.  For example:

    // $('#branches_table').on('click', '.pagination a',
    //                          ManageData.update_data);

    // Check if this anchor element is disabled (e.g. 'Previous'
    // link is disabled when on page 1 of pagination)
    // (anchor is contained in 'li' element which will have 'disabled' class)
    if ($(this).parent().hasClass('disabled')) { return false; };

    // 'event.currentTarget' is the div element that delegated the event
    var div_id = '#' + $(event.currentTarget).attr('id')

    // 'this' is anchor element that recieved the event
    var link_url = $(this).attr('href');

    ManageData.get_updated_data(div_id, link_url);
    return(false);
  },

  get_updated_data: function(div_id, link_url) {
    // calls link_url to get data and replace content of div with that
    $.ajax({type: 'GET',
            url: link_url,
            timeout: 5000,
            error: function (xhrObj, status, exception) {
                              alert('Server Timed Out');},
            success: function (data, status, xhrObject) {
                                 $(div_id).html(data);}
            });
  }
}
