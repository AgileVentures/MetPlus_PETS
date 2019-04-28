import * as Noty from 'noty'

/* eslint-env es6 */
export namespace Notifications {
    function notify (text, type) {
      const closeWith: ('button' | 'click')[] = (/href ?=/.test(text) ? ['button'] : ['click'])
      new Noty({
        text: text,
        theme: 'semanticui',
        layout: 'bottomRight',
        type: type,
        closeWith: closeWith
      }).show()
    }

    export function successNotification (text) {
      notify(text, 'success')
    }

    export function errorNotification (text) {
      notify(text, 'error')
    }

    export function infoNotification (text) {
      notify(text, 'information')
    }

    export function alertNotification (text) {
      notify(text, 'alert')
    }
}
