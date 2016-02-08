var PusherTest = {

  setup: function () {
    var pusher = new Pusher('1d3d6764932fac0ac318');
    var channel = pusher.subscribe('my-channel');
    channel.bind('new-message', function(data) {
      alert('An event was triggered with message: ' + data.message);
    });
  }
};

$(PusherTest.setup);
