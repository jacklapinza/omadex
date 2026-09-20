import QtQuick
import qs.Ui

BarWidget {
  id: root

  moduleName: "io.github.jacklapinza.omadex"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\udb81\udc1d"
    tooltipText: "Open Omadex"

    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton && root.bar)
        root.bar.run("omarchy-shell shell toggle io.github.jacklapinza.omadex")
    }
  }
}
