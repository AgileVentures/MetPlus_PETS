var AgencyData = {
  toggle: function () {
    var toggle_id = $(this).attr('href');

    if (/Show/.test($(this).text())) {
      $(toggle_id).show(800);
      $(this).text($(this).text().replace('Show', 'Hide'))
    } else {
      $(toggle_id).hide(800);
      $(this).text($(this).text().replace('Hide', 'Show'))
    };

    return(false);
  },
  update_data: function () {
    // Check if this anchor element is disabled (e.g. 'Previous'
    // link is disabled when on page 1 of pagination)
    // (anchor is contained in 'li' element which will have 'disabled' class)
    if ($(this).parent().hasClass('disabled')) { return false; };

    // 'this' is anchor element that recieved the event
    var link_url = $(this).attr('href');

    // 'event.currentTarget' is the div element that delegated the event
    var table_id = '#' + $(event.currentTarget).attr('id')

    $.ajax({type: 'GET',
            url: link_url,
            timeout: 5000,
            error: function (xhrObj, status, exception) {
                              alert('Server Timed Out');},
            success: function (data, status, xhrObject) {
                      alert('In Success Function');
                                 $(table_id).html(data);}
            });
    return(false);
  },
  get_update_data: function(div_id) {
    // 'this' is anchor element that recieved the event
    var link_url = $(this).attr('href');

    $.ajax({type: 'GET',
            url: link_url,
            timeout: 5000,
            error: function (xhrObj, status, exception) {
                              alert('Server Timed Out');},
            success: function (data, status, xhrObject) {
                      alert('In Success Function');
                                 $(div_id).html(data);}
            });
    return(false);
  },
  add_job_category: function () {
    // set up action_url (no id needed so can hard-wire)
    // get category name
    // get category description
    // send AJAX request (controller adds category and returns success)
    // - on success:
    //   - determine 'active' pagination anchor
    //   - 'click' that anchor link
    //   - return true
    // - on error (for status = 422)
    //   - get the model error messages
    //   - render the error messages in the modal window
    //   - return false
    $.ajax({type: 'POST',
            url: '/job_categories/create/',
            // Get the data entered by the user in the dialog box
            data: { 'job_category[name]': $('#category_name').val(),
                    'job_category[description]': $('#category_desc').val() },
            timeout: 5000,
            success: function (data, status, xhrObject){
              alert('Job Category Created');
              // Find the current (active) pagination anchor and click it -
              // to force a reload of the page section in case the new
              // category shows up in that section.
              $('a', 'li.active','div.pagination').click();
              return(true);
              },
            error: function (xhrObj, status, exception) {alert('Server Timed Out');},
            });

    // http://travisjeffery.com/b/2012/04/rendering-errors-in-json-with-rails/
    // http://tomdallimore.com/blog/ajax-and-json-error-handling-on-rails/
  },
  setup_branches: function () {
    $('#toggle_branches').click(AgencyData.toggle);
    $('#branches_table').on('click', '.pagination a', AgencyData.update_data);
  },
  setup_people: function () {
    $('#toggle_people').click(AgencyData.toggle);
    $('#people_table').on('click', '.pagination a', AgencyData.update_data);
  },
  setup_companies: function () {
    $('#toggle_companies').click(AgencyData.toggle);
    $('#companies_table').on('click', '.pagination a', AgencyData.update_data);
  },
  setup_job_categories: function () {
    $('#toggle_job_categories').click(AgencyData.toggle);
    $('#job_categories_table').on('click', '.pagination a', AgencyData.update_data);
  },
  setup_add_job_category: function () {
    $('#add_category_button').click(AgencyData.add_job_category);
  }
};
$(function () {
  AgencyData.setup_branches();
  AgencyData.setup_people();
  AgencyData.setup_companies();
  AgencyData.setup_job_categories();
  AgencyData.setup_add_job_category();
});
