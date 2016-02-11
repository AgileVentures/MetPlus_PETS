var VisibilityToggle = {
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
  setup_branches: function () {
    $('#toggle_branches').click(VisibilityToggle.toggle);
  },
  setup_people: function () {
    $('#toggle_people').click(VisibilityToggle.toggle);
  },
  setup_companies: function () {
    $('#toggle_companies').click(VisibilityToggle.toggle);
  }
};
