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
    var link_url = $(this).attr('href');
    if (/data_type=branches/.test(link_url)) {
      var table_id = '#branches_table';
    } else if (/data_type=people/.test(link_url)) {
      var table_id = '#people_table';
    } else if (/data_type=companies/.test(link_url)) {
      var table_id = '#companies_table';
    } else {
      return(true);
    }
    $.ajax({type: 'GET',
            url: link_url,
            timeout: 5000,
            error: function (xhrObj, status, exception) {alert('Server Timed Out');},
            success: function (data, status, xhrObject){
              $(table_id).html(data);
              }
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
};

$(AgencyData.setup_branches);
$(AgencyData.setup_people);
$(AgencyData.setup_companies);
