import QtQuick

QtObject {
  id: root

  function request(path, onSuccess, onFailure) {
    var request = requestComponent.createObject(root, {
      path: path,
      successCallback: onSuccess,
      failureCallback: onFailure
    })
    if (!request && onFailure) onFailure("Pokemon data is currently unavailable.")
  }

  Component {
    id: requestComponent
    ApiRequest {}
  }
}
