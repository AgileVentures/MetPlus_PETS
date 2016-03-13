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

    // 'event.currentTarget' is the div element that delegated the event
    var div_id = '#' + $(event.currentTarget).attr('id')

    // 'this' is anchor element that recieved the event
    var link_url = $(this).attr('href');

    AgencyData.get_updated_data(div_id, link_url);
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
  },
  add_job_category: function () {
    // this function is bound to 'click' event on 'Add Category' button
    // in 'agency_admin/_add_job_category.html.haml'
    // Create the job category .....
    $.ajax({type: 'POST',
            url: '/job_categories/',
            // Get the data entered by the user in the dialog box
            data: { 'job_category[name]': $('#add_category_name').val(),
                    'job_category[description]': $('#add_category_desc').val() },
            timeout: 5000,
            success: function (data, status, xhrObject){
              // If this is the first job category added, the job categories
              // table ID will not yet be visible - in that case, reload page
              if ($('#job_categories_table').length === 0) {
                document.location.reload(true);
              } else {
                // Find the current (active) pagination anchor and
                // force a reload of the page section in case the new
                // category shows up in that section.
                var paginate_link = $('a', 'li.active','div.pagination');
                if (paginate_link.length != 0) {
                  paginate_url = paginate_link.attr('href');
                } else {
                  // If there are too few items on the page the paginate links
                  // will not be present - create appropriate url instead
                  paginate_url = '/agency_admin/job_properties?data_type=' +
                                 'job_categories&job_categories_page=1';
                }
                AgencyData.get_updated_data('#job_categories_table',
                                            paginate_url);
              }
              $('#add_model_errors').html(''); // Clear model errors in modal
              $('#add_job_category').modal('hide');
            },
            error: function (xhrObj, status, exception) {
              // If model error(s), show content in div in modal
              // (Firefox seems to add a trailing whitespace char to
              // 'exception'... hence the 'trim()' function)
              if (exception.trim() === 'Unprocessable Entity') {
                $('#add_model_errors').html(xhrObj.responseText);
              } else {
                alert('Server Error');
              }
            },
          });
    // Good background on returning error status in ajax controller action:
    // http://travisjeffery.com/b/2012/04/rendering-errors-in-json-with-rails/
  },
  edit_job_category: function () {
    // Get the current attribute values for this job category
    $.ajax({type: 'GET',
            url: $(this).attr('href'),
            timeout: 5000,
            success: function (data, status, xhrObject){
              // Store the job_category ID for retrieval in update action
              AgencyData.job_category_id = data.id;

              // Set the attribute values in the modal and make modal visible
              $('#update_category_name').val(data.name)
              $('#update_category_desc').val(data.description)
              $('#update_job_category').modal('show')
            },
            error: function (xhrObj, status, exception) {
              alert('Error retrieving category attributes');
            },
          });
    return(false);
  },
  job_category_id: id = 0,
  update_job_category: function () {

    $.ajax({type: 'PATCH',
            url: '/job_categories/' + AgencyData.job_category_id,
            data: { 'job_category[name]': $('#update_category_name').val(),
                    'job_category[description]': $('#update_category_desc').val() },
            timeout: 5000,
            success: function (data, status, xhrObject) {
              // Find the current (active) pagination anchor and
              // force a reload of the page section in case the updated
              // category shows up in that section.
              var paginate_link = $('a', 'li.active','div.pagination');
              if (paginate_link.length != 0) {
                paginate_url = paginate_link.attr('href');
              } else {
                // If there are too few items on the page the paginate links
                // will not be present - create appropriate url instead
                paginate_url = '/agency_admin/job_properties?data_type=' +
                               'job_categories&job_categories_page=1';
              }
              AgencyData.get_updated_data('#job_categories_table',
                                          paginate_url);
              $('#update_model_errors').html(''); // Clear model errors in modal
              $('#update_job_category').modal('hide');
            },
            error: function (xhrObj, status, exception) {
              // If model error(s), show content in div in modal
              // (Firefox seems to add a trailing whitespace char to
              // 'exception'... hence the 'trim()' function)
              if (exception.trim() === 'Unprocessable Entity') {
                $('#update_model_errors').html(xhrObj.responseText);
              } else {
                alert('Server Error');
              }
            },
          });
    return(false);
  },
  changed_job_category: function (modal_id, model_errors_id) {
    // Find the current (active) pagination anchor and
    // force a reload of the page section in case the new
    // category shows up in that section.
    var paginate_link = $('a', 'li.active','div.pagination');
    if (paginate_link.length != 0) {
      paginate_url = paginate_link.attr('href');
    } else {
      // If there are too few items on the page the paginate links
      // will not be present - create appropriate url instead
      paginate_url = '/agency_admin/job_properties?data_type=' +
                     'job_categories&job_categories_page=1';
    }
    AgencyData.get_updated_data('#job_categories_table',
                                paginate_url);
    $(model_errors_id).html(''); // Clear model errors in modal
    $(modal_id).modal('hide');
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
    $('#job_categories_table').on('click',
                  // bind to 'edit category' anchor element
                  "a[href^='/job_categories/'][href$='edit']",
                                AgencyData.edit_job_category);
  },
  setup_manage_job_category: function () {
    $('#add_category_button').click(AgencyData.add_job_category);
    $('#update_category_button').click(AgencyData.update_job_category);
  }
};
$(function () {
  AgencyData.setup_branches();
  AgencyData.setup_people();
  AgencyData.setup_companies();
  AgencyData.setup_job_categories();
  AgencyData.setup_manage_job_category();
});
