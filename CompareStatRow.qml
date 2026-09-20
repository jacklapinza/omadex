import QtQuick
import qs.Commons

Item {
  id: root

  property var stat: ({ left: 0, right: 0, label: "", winner: "tie", delta: 0 })
  property color accent: Color.accent
  property color winnerColor: accent
  property color foreground: Color.foreground
  readonly property real barWidth: Math.max(1,
    (width - Style.space(84) - Style.space(116) - Style.space(32)) / 2)

  implicitHeight: Style.space(42)

  Row {
    anchors.fill: parent
    spacing: Style.space(8)

    Text {
      width: Style.space(42)
      height: parent.height
      text: root.stat.left
      horizontalAlignment: Text.AlignRight
      verticalAlignment: Text.AlignVCenter
      color: root.stat.winner === "left" ? root.winnerColor : root.foreground
      opacity: root.stat.winner === "right" ? 0.5 : 1
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      font.bold: true
    }

    Item {
      width: root.barWidth
      height: parent.height

      Rectangle {
        width: parent.width
        height: Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2
        color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.09)

        Rectangle {
          width: parent.width * Math.min(1, Number(root.stat.left) / 255)
          height: parent.height
          anchors.right: parent.right
          radius: parent.radius
          color: root.stat.winner === "left" ? root.winnerColor
            : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.34)
        }
      }
    }

    Column {
      width: Style.space(116)
      anchors.verticalCenter: parent.verticalCenter
      spacing: 0

      Text {
        width: parent.width
        text: root.stat.label
        horizontalAlignment: Text.AlignHCenter
        color: root.foreground
        font.family: Style.font.family
        font.pixelSize: Style.font.bodySmall
        font.bold: true
        font.letterSpacing: 0.7
      }

      Text {
        width: parent.width
        text: root.stat.winner === "tie" ? "EVEN"
          : (root.stat.winner === "left" ? "A" : "B") + "  +" + root.stat.delta
        horizontalAlignment: Text.AlignHCenter
        color: root.stat.winner === "tie" ? root.foreground : root.winnerColor
        opacity: root.stat.winner === "tie" ? 0.42 : 0.8
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
        font.bold: true
      }
    }

    Item {
      width: root.barWidth
      height: parent.height

      Rectangle {
        width: parent.width
        height: Style.space(8)
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2
        color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.09)

        Rectangle {
          width: parent.width * Math.min(1, Number(root.stat.right) / 255)
          height: parent.height
          anchors.left: parent.left
          radius: parent.radius
          color: root.stat.winner === "right" ? root.winnerColor
            : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.34)
        }
      }
    }

    Text {
      width: Style.space(42)
      height: parent.height
      text: root.stat.right
      horizontalAlignment: Text.AlignLeft
      verticalAlignment: Text.AlignVCenter
      color: root.stat.winner === "right" ? root.winnerColor : root.foreground
      opacity: root.stat.winner === "left" ? 0.5 : 1
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      font.bold: true
    }
  }
}
