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
                AgencyData.change_job_category_success('#add_job_category',
                                                       '#add_model_errors');
              }
            },
            error: function (xhrObj, status, exception) {
              ManageData.change_data_error(exception, xhrObj,
                                          '#add_model_errors');
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
              AgencyData.change_job_category_success('#update_job_category',
                                                     '#update_model_errors');
            },
            error: function (xhrObj, status, exception) {
              ManageData.change_data_error(exception, xhrObj,
                                          '#update_model_errors');
            },
          });
    return(false);
  },
  delete_job_category: function () {
    $.ajax({type: 'DELETE',
            url: $(this).attr('href'),
            timeout: 5000,
            success: function (data, status, xhrObject) {
              // If this was the last job category, the job categories
              // table ID should not be loaded - in that case, reload page
              if (data.job_category_count === 0) {
                document.location.reload(true);
              } else {
                // Find the current (active) pagination anchor and force a
                // reload of the page section.
                var paginate_link = $('a', 'li.active','div.pagination');
                if (paginate_link.length != 0) {
                  // Also need to check if the last job category on this
                  // page has been deleted - if so, go to previous page link
                  // (otherwise, will_paginate wil show a blank page
                  //  with no pagination links)
                  if ($('#job_categories_table tbody tr').length === 1) {
                    paginate_url = $('a', '.prev', '.previous_page').attr('href');
                  } else {
                    paginate_url = paginate_link.attr('href');
                  }
                } else {
                  // If there are too few items on the page the paginate links
                  // will not be present - create appropriate url instead
                  paginate_url = '/agency_admin/job_properties?data_type=' +
                                 'job_categories&job_categories_page=1';
                }
                ManageData.get_updated_data('#job_categories_table',
                                          paginate_url);
              }
            },
            error: function (xhrObj, status, exception) {
              alert('Error deleting category attributes');
            },
          });
    return(false);

  },
  change_job_category_success: function (modal_id, model_errors_id) {
    // Find the current (active) pagination anchor and force a reload of the page
    // section in case the new or updated category shows up in that section.
    var paginate_link = $('a', 'li.active','div.pagination');
    if (paginate_link.length != 0) {
      paginate_url = paginate_link.attr('href');
    } else {
      // If there are too few items on the page the paginate links
      // will not be present - create appropriate url instead
      paginate_url = '/agency_admin/job_properties?data_type=' +
                     'job_categories&job_categories_page=1';
    }
    ManageData.get_updated_data('#job_categories_table',
                                paginate_url);
    $(model_errors_id).html(''); // Clear model errors in modal
    $(modal_id).modal('hide');
  },
  setup_branches: function () {
    $('#toggle_branches').click(AgencyData.toggle);
    $('#branches_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_people: function () {
    $('#toggle_people').click(AgencyData.toggle);
    $('#people_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_companies: function () {
    $('#toggle_companies').click(AgencyData.toggle);
    $('#companies_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_job_categories: function () {
    $('#toggle_job_categories').click(AgencyData.toggle);
    $('#job_categories_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_manage_job_category: function () {
    $('#add_category_button').click(AgencyData.add_job_category);
    $('#job_categories_table').on('click',
                  // bind to 'edit category' anchor element
                  "a[href^='/job_categories/'][href$='edit']",
                                AgencyData.edit_job_category);
    $('#update_category_button').click(AgencyData.update_job_category);
    $('#job_categories_table').on('click',
                  // bind to 'delete category' anchor element
                  "a[data-method='delete']",
                                AgencyData.delete_job_category);
  }
};
$(function () {
  AgencyData.setup_branches();
  AgencyData.setup_people();
  AgencyData.setup_companies();
  AgencyData.setup_job_categories();
  AgencyData.setup_manage_job_category();
});
