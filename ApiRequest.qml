import QtQuick
import Quickshell.Io

QtObject {
  id: root

  property string path: ""
  property var successCallback: null
  property var failureCallback: null
  readonly property string helperPath:
    Qt.resolvedUrl("poke-fetch").toString().replace(/^file:\/\//, "")

  function fail(message) {
    if (root.failureCallback) root.failureCallback(message)
    Qt.callLater(function() { root.destroy() })
  }

  function complete(exitCode) {
    if (exitCode !== 0) {
      fail("Pokemon data is currently unavailable.")
      return
    }

    try {
      var data = JSON.parse(output.text)
      if (root.successCallback) root.successCallback(data)
      Qt.callLater(function() { root.destroy() })
    } catch (error) {
      fail("The API returned invalid data.")
    }
  }

  Process {
    id: process
    command: [root.helperPath, root.path]

    stdout: StdioCollector {
      id: output
    }

    onExited: function(exitCode) {
      root.complete(exitCode)
    }
  }

  Component.onCompleted: process.running = true
}
