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

    // Prep the post data for ajax .....
    post_data = AgencyData.prepare_property_data_for_ajax(job_property, 'add');

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
              // Clear input fields in the modal
              $(name_field_id).val('');
              $(desc_field_id).val('');
            },
            error: function (xhrObj, status, exception) {
              var model_errors_id = '#add_'+job_property+'_errors';
              ManageData.change_data_error(exception, xhrObj, model_errors_id);
            },
          });
    // Good background on returning error status in ajax controller action:
    // http://travisjeffery.com/b/2012/04/rendering-errors-in-json-with-rails/
  },

  prepare_property_data_for_ajax: function(job_property, type) {
    // type: 'add' or 'update'

    // Create the post/patch data for ajax .....
    var name_field_id = '#' + type + '_' + job_property + '_name';
    var desc_field_id = '#' + type + '_' + job_property + '_desc';
    var post_data = {};
    post_data[job_property + '[name]']        = $(name_field_id).val();
    post_data[job_property + '[description]'] = $(desc_field_id).val();

    var skill_ids = [];

    selector = '.droppable#' + type + '_job_category_skills';

    // if (job_property === 'job_category' &&
    //             $('.droppable#add_job_category_skills').length != 0) {
    if (job_property === 'job_category' && $(selector).length != 0) {

      $("div[id^='update_job_category_skill_']").each(function() {
        // The skill ID is the last digit(s) in the CSS ID
        skill_id = this.id.match(/\d+$/);
        skill_ids.push(skill_id[0]);
      })
      post_data[job_property + '[skill_ids]'] = skill_ids;
    }
    return post_data;
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

              // Set the attribute values in the modal
              var modal_id = 'update_' + job_property;
              var modal_selector = '#' + modal_id

              $(modal_selector + '_name').val(data.name);
              $(modal_selector + '_desc').val(data.description);

              var skills_list = '';

              // Clear any residual category skills from prior
              // category add or update action
              $("div[id^='update_job_category_skill_']").remove();

              // Show existing job_category skills in modal
              if (job_property === 'job_category' &&
                               data['skills'].length != 0) {
                var i;
                for (i = 0; i < data['skills'].length; i += 1) {
                  skill = data['skills'][i];
                  skills_list +=
                      '<div class="draggable_delete ui-widget-content" ' +
                      'id="update_job_category_skill_' + skill.id + '">' +
                      skill.name + '</div>';
                }
              }
              $(modal_selector + '_skills').html(skills_list);

              $(modal_selector).modal('show');
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
    patch_data = AgencyData.prepare_property_data_for_ajax(job_property, 'update');

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
                  "a[href^='/job_categories/'][data-method='edit']",
                                AgencyData.edit_job_category);
    $('#update_job_category_button').click(AgencyData.update_job_category);
    $('#job_categories_table').on('click',
                  // bind to 'delete category' anchor element
                  "a[data-method='delete']",
                                AgencyData.delete_job_category);

    $('#add_job_category').on('show.bs.modal', function(e) {
      // When the 'add_job_category' modal is about to be shown, clear
      // residual category skills that have been displayed in the
      // LHS of the category skills assignment section of the modal
      // (otherwise, skills left in the LHS from a prior 'update category'
      //  will still be present).
      $("div[id^='update_job_category_skill_']").remove();
    });

    // The items in the right-hand-side of the skills list consist
    // of all available skills.  These are added to class "draggable",
    // and can be dragged to the LHS to assign a skill to the category.
    // Dragging the skill does not remove it from the "all skills" list.
    $('.draggable').draggable({ revert: 'invalid',
                                cursor: 'pointer',
                                containment: 'document',
                                helper: 'clone' });

    // Class "droppable" is assigned to the container on the LHS.  These
    // are skills assigned (or to be assigned) to the category.
    // These skills are assigned class ".draggable_delete" because they
    // can be dragged back to the RHS to delete them from the list of
    // skills for the category.
    $('.droppable').droppable({
          activeClass: 'ui-state-hover',
          accept: '.draggable',
          // Handle dragging a skill to the container
          drop: function(event, ui) {
            var ele = $(ui.draggable[0]);
            // Add this element unless already present
            rg = new RegExp(ele.attr('id') + "\"");
            if (!rg.test($(this).html())) {

              add_skill = '<div class="draggable_delete ui-widget-content" ' +
              'id="update_job_category_' + ele.attr('id') + '">'
              + ele.text().trim() + '</div>';

              $(add_skill).appendTo(this);
            }
          }
        });
    $('.droppable').sortable();

    // Skills on the LHS can be dragged to the "all skills" (RHS) container
    // to remove them from assignment to the category.
    $('.all_skills').droppable({
          activeClass: 'ui-state-hover',
          accept: '.draggable_delete',
          tolerance: 'intersect',
          drop: function(event, ui) {
            // Delete element from skills for this category
            $(ui.draggable[0]).remove();
          }
        });
  },
  setup_manage_skill: function () {
    $('#add_skill_button').click(AgencyData.add_skill);
    $('#skills_table').on('click',
                  // bind to 'edit skill' anchor element
                  "a[href^='/skills/'][data-method='edit']",
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
