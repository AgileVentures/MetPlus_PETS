/*
 * This is an empty class that will returna Pusher object.
 * The object is completely back because we are some what creating
 * a dummy double to ensure Pusher exists when we run the tests.
 *
 * The difference between this object and a dummy is that the dummy
 * would fail if called, which is not the case of this double.
 * It just mimics the interface.
 */
var Pusher = function (key) {
  return {
    channel: function (nameOfChannel) {
      return {
        bind: function () {
        }
      };
    },
    subscribe: function (nameOfChannel) {

    }
  }
}