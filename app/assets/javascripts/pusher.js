var PusherTest = {

  setup: function () {
    var pusher = new Pusher('1d3d6764932fac0ac318');
    var channel = pusher.subscribe('my_channel');
    channel.bind('new_message', function(data) {
      alert('An event was triggered with message: ' + data.message);
    });
  }
};

$(PusherTest.setup);
$(PusherTest) {alert('this is a test')};
