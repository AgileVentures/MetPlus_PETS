var AgencyData = {
  add_job_category: function () {
    // this function is bound to 'click' event on 'Add Category' button
    // in Bootstrap modal:  'agency_admin/_property_modal.html.haml'
    AgencyData.add_job_property('job_category', 'job_categories',
                                'name', 'description');
  },
  add_skill: function () {
    // this function is bound to 'click' event on 'Add Skill' button
    // in Bootstrap modal:  'agency_admin/_property_modal.html.haml'
    AgencyData.add_job_property('skill', 'skills',
                                'name', 'description');
  },
  add_license: function () {
    // this function is bound to 'click' event on 'Add License' button
    // in Bootstrap modal:  'agency_admin/_property_modal.html.haml'
    AgencyData.add_job_property('license', 'licenses',
                                'abbr', 'title');
  },
  add_job_property: function (job_property, job_prop_plural, attr1, attr2) {
    // This functions handles the event created when the
    // "Add <property>" button is clicked on the bootstrap modal.

    // The arguments are:
    //     job_property: the name of the property, eg. 'job_category', 'skill'
    //     job_prop_plural: the pluralized version of job_property,
    //                      e.g. 'job_categories', 'skills', licenses
    //     attr1: the name of the first attribute displayed in the modal
    //     attr2: the name of the second attribute displayed in the modal

    // NOTE: This function is used to add job properties (job skills,
    //       job categories, licenses)
    //       to the Agency.  This is ALSO used to add job skills to a company.  In
    //       the latter case, the company_id is accessed via a hidden field in
    //       the modal form that is used to add and edit job properties.
    //       All CSS id's used here to gather data from that modal form are the
    //       same across all like uses of the form (that is, for Agency job skills,
    //       Agency job categories and company-specific job skills).

    // Create the post data for ajax .....
    var id_prefix = '#add_' + job_property;
    var attr1_field_id = id_prefix + '_attr1';
    var attr2_field_id = id_prefix + '_attr2';

    var company_id = null;
    var user_type = $('#user_type').val();

    var post_data = {};

    post_data[job_property + '[' + attr1 + ']'] = $(attr1_field_id).val();
    post_data[job_property + '[' + attr2 + ']'] = $(attr2_field_id).val();

    if (user_type == 'company_person') {
      company_id = $('#company_id').val();
      post_data[job_property + '[company_id]'] = company_id;
    }

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
                                                       job_prop_plural,
                                                       company_id, user_type);
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
    AgencyData.edit_job_property('job_category', url,
                                 'name', 'description');
    return false;
  },
  edit_skill: function () {
    // Get the url from the anchor element that was clicked
    var url = $(this).attr('href');
    AgencyData.edit_job_property('skill', url,
                                 'name', 'description');
    return false;
  },
  edit_license: function () {
    // Get the url from the anchor element that was clicked
    var url = $(this).attr('href');
    AgencyData.edit_job_property('license', url,
                                 'abbr', 'title');
    return false;
  },
  edit_job_property: function (job_property, edit_url, attr1, attr2) {
    // This functions handles the event created when the
    // edit <property> link is clicked on the page.

    // The arguments are:
    //     job_property: the name of the property, eg. 'job_category', 'skill'
    //     edit_url: the href attribute of the anchor element that was clicked
    //     attr1: the name of the first attribute displayed in the modal
    //     attr2: the name of the second attribute displayed in the modal

    // Retrieve the current attribute values for this job property
    $.ajax({type: 'GET',
            url: edit_url,
            timeout: 5000,
            success: function (data, status, xhrObject){
              // Store the job property ID for retrieval in update action
              AgencyData[job_property + '_id'] = data.id;

              // Set the attribute values in the modal and make modal visible
              var attr1_field_id = '#update_' + job_property + '_attr1';
              var attr2_field_id = '#update_' + job_property + '_attr2';
              var modal_id = '#update_' + job_property;

              $(attr1_field_id).val(data[attr1]);
              $(attr2_field_id).val(data[attr2]);
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
    AgencyData.update_job_property('job_category', 'job_categories',
                                   'name', 'description');
  },

  update_skill: function () {
    // this function is bound to 'click' event on 'Update Skill' button
    // in Bootstrap modal:  'agency_admin/_property_modal.html.haml'
    AgencyData.update_job_property('skill', 'skills',
                                   'name', 'description');
  },

  update_license: function () {
    // this function is bound to 'click' event on 'Update License' button
    // in Bootstrap modal:  'agency_admin/_property_modal.html.haml'
    AgencyData.update_job_property('license', 'licenses',
                                   'abbr', 'title');
  },

  update_job_property: function (job_property, job_prop_plural, attr1, attr2) {
    // This functions handles the event created when the
    // "Update <property>" button is clicked on the bootstrap modal.

    // The arguments are:
    //     job_property: the name of the property, eg. 'job_category', 'skill'
    //     job_prop_plural: the pluralized version of job_property,
    //                      e.g. 'job_categories', 'skills', licenses
    //     attr1: the name of the first attribute displayed in the modal
    //     attr2: the name of the second attribute displayed in the modal

    // Create the PATCH data for ajax .....
    var id_prefix = '#update_' + job_property;
    var attr1_field_id = id_prefix + '_attr1';
    var attr2_field_id = id_prefix + '_attr2';

    var company_id = null;
    var user_type = $('#user_type').val();

    var patch_data = {};

    patch_data[job_property + '[' + attr1 + ']'] = $(attr1_field_id).val();
    patch_data[job_property + '[' + attr2 + ']'] = $(attr2_field_id).val();

    if (user_type == 'company_person') {
      company_id = $('#company_id').val();
      patch_data[job_property + '[company_id]'] = company_id;
    }

    $.ajax({type: 'PATCH',
            url: '/'+job_prop_plural+'/' + AgencyData[job_property + '_id'],
            data: patch_data,
            timeout: 5000,
            success: function (data, status, xhrObject) {
              var modal_id        = '#update_' + job_property;
              var model_errors_id = '#update_' + job_property + '_errors';
              AgencyData.change_job_property_success(modal_id,
                                                     model_errors_id,
                                                     job_prop_plural,
                                                     company_id, user_type);
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

  delete_license: function () {
    // Get the url from the anchor element that was clicked
    var url = $(this).attr('href');
    AgencyData.delete_job_property('license', 'licenses', url);
    return false;
  },

  delete_job_property: function (job_property, job_prop_plural, delete_url) {
    // This functions handles the event created when the
    // delete <property> link is clicked on the page.

    // The arguments are:
    //     job_property: the name of the property, eg. 'job_category', 'skill'
    //     job_prop_plural: the pluralized version of job_property,
    //                      e.g. 'job_categories', 'skills', licenses
    //     delete_url: the href attribute of the anchor element that was clicked

    $.ajax({type: 'DELETE',
            url: delete_url,
            timeout: 5000,
            success: function (data, status, xhrObject) {

              var company_id = null;
              if ($('#company_id') != null) {
                company_id = $('#company_id').val();
              }

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
                  if (company_id != null) {
                    paginate_url = '/company_people/' + company_id + '/home' +
                                   '?data_type=' + job_prop_plural + '&' +
                                   job_prop_plural + '_page=1';
                  } else {
                    paginate_url = '/agency_admin/job_properties?data_type=' +
                            job_prop_plural + '&' + job_prop_plural + '_page=1';
                  }
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
                                         job_prop_plural, company_id,
                                         user_type) {
    // This function is called when a successful change (add or update)
    // of a job property has occurred.  It updates the page view so the
    // change is visible to the user.  Then, it clears any model errors
    // and closes the modal.

    // The arguments are:
    //     modal_id:        the id of the modal that is used as a form for
    //                      for adding or updating the job property.  This must
    //                      include the '#' for jquery css selection,
    //                      e.g. '#add_job_category', '#update_job_category',
    //                           '#add_skill', '#update_skill',
    //                           '#add_license', '#update_license'
    //     model_errors_id: the id of the div that is used to display
    //                      model errors on the modal form.  This must
    //                      include the '#' for jquery css selection,
    //                      e.g. '#add_job_category_errors',
    //                           '#update_job_category_errors',
    //                           '#add_skill_errors',
    //                           '#update_skill_errors',
    //                           '#add_license_errors',
    //                           '#update_license_errors'
    //     job_prop_plural: the pluralized version of job_property,
    //                      e.g. 'job_categories', 'skills', 'licenses'

    // Find the current (active) pagination anchor and force a reload of the page
    // section in case the new or updated category shows up in that section.
    var job_properties_table_id = '#' + job_prop_plural + '_table'
    var selector = job_properties_table_id + ' div.pagination li.active a'
    var paginate_link = $(selector);
    var paginate_url;

    if (paginate_link.length != 0) {
      paginate_url = paginate_link.attr('href');
    } else {
      // If there are too few items on the page the paginate links
      // will not be present - create appropriate url instead
      if (user_type == 'company_person') {
        paginate_url = '/company_people/' + company_id + '/home' + '?data_type=' +
                        job_prop_plural + '&' + job_prop_plural + '_page=1';
      } else {
        paginate_url = '/agency_admin/job_properties?data_type=' +
                        job_prop_plural + '&' + job_prop_plural + '_page=1';
      }
    }
    ManageData.get_updated_data(job_properties_table_id,
                                paginate_url);
    $(model_errors_id).html(''); // Clear model errors in modal
    $(modal_id).modal('hide');
  },
  setup_branches: function () {
    $('#branches_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_people: function () {
    $('#people_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_companies: function () {
    $('#companies_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_job_categories: function () {
    $('#job_categories_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_skills: function () {
    $('#skills_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_licenses: function () {
    $('#licenses_table').on('click', '.pagination a',
                            ManageData.update_paginate_data);
  },
  setup_manage_job_category: function () {
    $('#add_job_category_button').click(AgencyData.add_job_category);
    $('#job_categories_table').on('click',
                  // bind to 'edit category' anchor element
                  "a[href^='/job_categories/'][data-method='edit']",
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
                  "a[href^='/skills/'][data-method='edit']",
                                AgencyData.edit_skill);
    $('#update_skill_button').click(AgencyData.update_skill);
    $('#skills_table').on('click',
                  // bind to 'delete skill' anchor element
                  "a[data-method='delete']",
                                AgencyData.delete_skill);
  },
  setup_manage_license: function () {
    $('#add_license_button').click(AgencyData.add_license);
    $('#licenses_table').on('click',
                  // bind to 'edit license' anchor element
                  "a[href^='/licenses/'][data-method='edit']",
                                AgencyData.edit_license);
    $('#update_license_button').click(AgencyData.update_license);
    $('#licenses_table').on('click',
                  // bind to 'delete license' anchor element
                  "a[data-method='delete']",
                                AgencyData.delete_license);
  }
};
$( document ).on('turbolinks:load', function() {
  AgencyData.setup_branches();
  AgencyData.setup_people();
  AgencyData.setup_companies();
  AgencyData.setup_job_categories();
  AgencyData.setup_skills();
  AgencyData.setup_licenses();
  AgencyData.setup_manage_job_category();
  AgencyData.setup_manage_skill();
  AgencyData.setup_manage_license();
});
