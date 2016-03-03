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
                                 $(table_id).html(data);}
            });
    return(false);
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
  }
};
$(function () {
  AgencyData.setup_branches();
  AgencyData.setup_people();
  AgencyData.setup_companies();
  AgencyData.setup_job_categories();
});
