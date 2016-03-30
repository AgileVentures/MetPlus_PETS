var AgencyData = {
  toggle: function () {
    var toggle_id = $(this).attr('href');

    if (/Show/.test($(this).text())) {
      $(toggle_id).show(800);
      $(this).text($(this).text().replace('Show', 'Hide'));
    } else {
      $(toggle_id).hide(800);
      $(this).text($(this).text().replace('Hide', 'Show'));
    };

    return(false);
  },
  add_job_category: function () {
    // this function is bound to 'click' event on 'Add Category' button
    // in Bootstrap modal:  'agency_admin/_property_modal.html.haml'
    AgencyData.add_job_property('job_category', 'job_categories');
  },
  add_skill: function () {
    // this function is bound to 'click' event on 'Add Skill' button
    // in Bootstrap modal:  'agency_admin/_property_modal.html.haml'
    AgencyData.add_job_property('skill', 'skills');
  },
  add_job_property: function (job_property, job_prop_plural) {
    // This functions handles the event created when the
    // "Add <property>" button is clicked on the bootstrap modal.

    // The arguments are:
    //     job_property: the name of the property, eg. 'job_category', 'skill'
    //     job_prop_plural: the pluralized version of job_property,
    //                      e.g. 'job_categories', 'skills'

    // Create the post data for ajax .....
    var name_field_id = '#add_' + job_property + '_name';
    var desc_field_id = '#add_' + job_property + '_desc';
    var post_data = {};
    post_data[job_property + '[name]']        = $(name_field_id).val();
    post_data[job_property + '[description]'] = $(desc_field_id).val();

    $.ajax({type: 'POST',
            url: '/' + job_prop_plural + '/',
            // Get the data entered by the user in the dialog box
            data: post_data,
            timeout: 5000,
            success: function (data, status, xhrObject){
              // If this is the first job category added, the job categories
              // table ID will not yet be visible - in that case, reload page
              var property_table_id = '#'+job_prop_plural+'_table';
              if ($(property_table_id).length === 0) {
                document.location.reload(true);
              } else {
                var modal_id        = '#add_' + job_property;
                var model_errors_id = '#add_' + job_property + '_errors';
                AgencyData.change_job_property_success(modal_id,
                                                       model_errors_id,
                                                       job_prop_plural);
              }
            },
            error: function (xhrObj, status, exception) {
              var model_errors_id = '#add_'+job_property+'_errors';
              ManageData.change_data_error(exception, xhrObj, model_errors_id);
            },
          });
    // Good background on returning error status in ajax controller action:
    // http://travisjeffery.com/b/2012/04/rendering-errors-in-json-with-rails/
  },
  edit_job_category: function () {
    // Get the url from the anchor element that was clicked
    var url = $(this).attr('href');
    AgencyData.edit_job_property('job_category', url);
    return false;
  },
  edit_skill: function () {
    // Get the url from the anchor element that was clicked
    var url = $(this).attr('href');
    AgencyData.edit_job_property('skill', url);
    return false;
  },
  edit_job_property: function (job_property, edit_url) {
    // This functions handles the event created when the
    // edit <property> link is clicked on the page.

    // The arguments are:
    //     job_property: the name of the property, eg. 'job_category', 'skill'
    //     edit_url: the href attribute of the anchor element that was clicked

    // Retrieve the current attribute values for this job property
    $.ajax({type: 'GET',
            url: edit_url,
            timeout: 5000,
            success: function (data, status, xhrObject){
              // Store the job property ID for retrieval in update action
              AgencyData[job_property + '_id'] = data.id;

              // Set the attribute values in the modal and make modal visible
              var name_field_id = '#update_' + job_property + '_name';
              var desc_field_id = '#update_' + job_property + '_desc';
              var modal_id = '#update_' + job_property;

              $(name_field_id).val(data.name);
              $(desc_field_id).val(data.description);
              $(modal_id).modal('show');
            },
            error: function (xhrObj, status, exception) {
              alert('Error retrieving property attributes');
            },
          });
    return(false);
  },

  job_category_id: id = 0,
  skill_id: id = 0,

  update_job_category: function () {
    // this function is bound to 'click' event on 'Update Category' button
    // in Bootstrap modal:  'agency_admin/_property_modal.html.haml'
    AgencyData.update_job_property('job_category', 'job_categories');
  },

  update_skill: function () {
    // this function is bound to 'click' event on 'Update Skill' button
    // in Bootstrap modal:  'agency_admin/_property_modal.html.haml'
    AgencyData.update_job_property('skill', 'skills');
  },

  update_job_property: function (job_property, job_prop_plural) {
    // This functions handles the event created when the
    // "Update <property>" button is clicked on the bootstrap modal.

    // The arguments are:
    //     job_property: the name of the property, eg. 'job_category', 'skill'
    //     job_prop_plural: the pluralized version of job_property,
    //                      e.g. 'job_categories', 'skills'

    // Create the PATCH data for ajax .....
    var name_field_id = '#update_' + job_property + '_name';
    var desc_field_id = '#update_' + job_property + '_desc';
    var patch_data = {};
    patch_data[job_property + '[name]']        = $(name_field_id).val();
    patch_data[job_property + '[description]'] = $(desc_field_id).val();

    $.ajax({type: 'PATCH',
            url: '/'+job_prop_plural+'/' + AgencyData[job_property + '_id'],
            data: patch_data,
            timeout: 5000,
            success: function (data, status, xhrObject) {
              var modal_id        = '#update_' + job_property;
              var model_errors_id = '#update_' + job_property + '_errors';
              AgencyData.change_job_property_success(modal_id,
                                                     model_errors_id,
                                                     job_prop_plural);
            },
            error: function (xhrObj, status, exception) {
              var model_errors_id = '#update_' + job_property + '_errors';
              ManageData.change_data_error(exception, xhrObj, model_errors_id);
            },
          });
    return(false);
  },

  delete_job_category: function () {
    // Get the url from the anchor element that was clicked
    var url = $(this).attr('href');
    AgencyData.delete_job_property('job_category', 'job_categories', url);
    return false;
  },

  delete_skill: function () {
    // Get the url from the anchor element that was clicked
    var url = $(this).attr('href');
    AgencyData.delete_job_property('skill', 'skills', url);
    return false;
  },

  delete_job_property: function (job_property, job_prop_plural, delete_url) {
    // This functions handles the event created when the
    // delete <property> link is clicked on the page.

    // The arguments are:
    //     job_property: the name of the property, eg. 'job_category', 'skill'
    //     job_prop_plural: the pluralized version of job_property,
    //                      e.g. 'job_categories', 'skills'
    //     delete_url: the href attribute of the anchor element that was clicked

    $.ajax({type: 'DELETE',
            url: delete_url,
            timeout: 5000,
            success: function (data, status, xhrObject) {
              // If this was the last property, the properties
              // table ID should not be loaded - in that case, reload page
              if (data[job_property+'_count'] === 0) {
                document.location.reload(true);
              } else {
                // Find the current (active) pagination anchor and force a
                // reload of the page section.
                var job_properties_table_id = '#' + job_prop_plural + '_table';
                var selector = job_properties_table_id +
                                  ' div.pagination li.active a';
                var paginate_link = $(selector);
                var paginate_url;

                if (paginate_link.length != 0) {
                  // If we are here it means that pagination links are present

                  // Also need to check if the last job property on this
                  // page has been deleted - if so, go to previous page link
                  // (otherwise, will_paginate will show a blank page
                  //  with no pagination links)

                  selector = job_properties_table_id + ' tbody tr';

                  if ($(selector).length === 1) {
                    // length === 1 if only the title row is present

                    selector = job_properties_table_id +
                                ' div.pagination li.previous_page a';

                    paginate_url = $(selector).attr('href');
                  } else {
                    paginate_url = paginate_link.attr('href');
                  }
                } else {
                  // If there are too few items on the page the paginate links
                  // will not be present - create appropriate url instead
                  paginate_url = '/agency_admin/job_properties?data_type=' +
                          job_prop_plural + '&' + job_prop_plural + '_page=1';
                }
                ManageData.get_updated_data(job_properties_table_id,
                                          paginate_url);
              }
            },
            error: function (xhrObj, status, exception) {
              alert('Error deleting job property');
            },
          });
    return(false);
  },

  change_job_property_success: function (modal_id, model_errors_id,
                                         job_prop_plural) {
    // This function is called when a successful change (add or update)
    // of a job property has occurred.  It updates the page view so the
    // change is visible to the user.  Then, it clears any model errors
    // and closes the modal.

    // The arguments are:
    //     modal_id:        the id of the modal that is used as a form for
    //                      for adding or updating the job property.  This must
    //                      include the '#' for jquery css selection,
    //                      e.g. '#add_job_category', '#update_job_category',
    //                           '#add_skill', '#update_skill'
    //     model_errors_id: the id of the div that is used to display
    //                      model errors on the modal form.  This must
    //                      include the '#' for jquery css selection,
    //                      e.g. '#add_job_category_errors',
    //                           '#update_job_category_errors',
    //                           '#add_skill_errors',
    //                           '#update_skill_errors'
    //     job_prop_plural: the pluralized version of job_property,
    //                      e.g. 'job_categories', 'skills'

    // Find the current (active) pagination anchor and force a reload of the page
    // section in case the new or updated category shows up in that section.
    var job_properties_table_id = '#' + job_prop_plural + '_table'
    var selector = job_properties_table_id + ' div.pagination li.active a'
    var paginate_link = $(selector);

    if (paginate_link.length != 0) {
      var paginate_url = paginate_link.attr('href');
    } else {
      // If there are too few items on the page the paginate links
      // will not be present - create appropriate url instead
      var paginate_url = '/agency_admin/job_properties?data_type=' +
                      job_prop_plural + '&' + job_prop_plural + '_page=1';
    }
    ManageData.get_updated_data(job_properties_table_id,
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
  setup_skills: function () {
    $('#toggle_skills').click(AgencyData.toggle);
    $('#skills_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_manage_job_category: function () {
    $('#add_job_category_button').click(AgencyData.add_job_category);
    $('#job_categories_table').on('click',
                  // bind to 'edit category' anchor element
                  "a[href^='/job_categories/'][href$='edit']",
                                AgencyData.edit_job_category);
    $('#update_job_category_button').click(AgencyData.update_job_category);
    $('#job_categories_table').on('click',
                  // bind to 'delete category' anchor element
                  "a[data-method='delete']",
                                AgencyData.delete_job_category);
  },
  setup_manage_skill: function () {
    $('#add_skill_button').click(AgencyData.add_skill);
    $('#skills_table').on('click',
                  // bind to 'edit skill' anchor element
                  "a[href^='/skills/'][href$='edit']",
                                AgencyData.edit_skill);
    $('#update_skill_button').click(AgencyData.update_skill);
    $('#skills_table').on('click',
                  // bind to 'delete category' anchor element
                  "a[data-method='delete']",
                                AgencyData.delete_skill);
  }
};
$(function () {
  AgencyData.setup_branches();
  AgencyData.setup_people();
  AgencyData.setup_companies();
  AgencyData.setup_job_categories();
  AgencyData.setup_skills();
  AgencyData.setup_manage_job_category();
  AgencyData.setup_manage_skill();
});
