import QtQuick
import qs.Commons

Item {
  id: root

  property string currentPage: "search"
  property color accent: Color.accent
  property color foreground: Color.foreground
  signal pageSelected(string page)

  implicitHeight: Style.space(40)
  property var pages: [
    { id: "search", label: "SEARCH" },
    { id: "compare", label: "COMPARE" }
  ]

  Rectangle {
    anchors.fill: parent
    color: "transparent"
    radius: Style.space(10)
    border.width: 0

    Row {
      anchors.fill: parent
      anchors.margins: Style.space(4)
      spacing: Style.space(4)

      Repeater {
        model: root.pages
        delegate: MouseArea {
          required property var modelData
          width: (parent.width - parent.spacing * (root.pages.length - 1)) / root.pages.length
          height: parent.height
          hoverEnabled: true
          onClicked: root.pageSelected(modelData.id)

          Rectangle {
             anchors.fill: parent
             radius: Style.space(7)
             color: "transparent"
             border.color: root.currentPage === modelData.id
               ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.8)
               : (parent.containsMouse
                 ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.5)
                 : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.18))
             border.width: 1

            Text {
              anchors.centerIn: parent
              text: modelData.label
              color: root.currentPage === modelData.id ? root.accent : root.foreground
              opacity: root.currentPage === modelData.id ? 1 : 0.55
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              font.letterSpacing: 1
            }
          }
        }
      }
    }
  }
}
