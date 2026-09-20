import QtQuick
import qs.Commons

Rectangle {
  id: root

  property alias model: resultList.model
  property int highlightedIndex: -1
  property string selectedName: ""
  property color accent: Color.accent
  property color foreground: Color.foreground
  signal indexSelected(int index, string name)

  color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.035)
  radius: Style.space(12)
  border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)
  border.width: 1

  onHighlightedIndexChanged: {
    if (resultList.currentIndex !== highlightedIndex)
      resultList.currentIndex = highlightedIndex
    if (highlightedIndex >= 0)
      resultList.positionViewAtIndex(highlightedIndex, ListView.Contain)
  }

  ListView {
    id: resultList
    anchors.fill: parent
    anchors.margins: Style.space(8)
    clip: true
    delegate: Rectangle {
      required property string name
      required property int index
      property bool hovered: false
      width: resultList.width
      height: Style.space(38)
      radius: Style.cornerRadius
      color: root.selectedName === name
        ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.16)
        : (ListView.isCurrentItem
          ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.08)
          : (hovered
            ? Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.05)
            : "transparent"))
      border.color: root.selectedName === name
        ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.5)
        : (ListView.isCurrentItem
          ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.65)
          : "transparent")
      border.width: 1

      Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Style.space(3)
        radius: width / 2
        color: root.accent
        visible: ListView.isCurrentItem
      }

      Text {
        anchors.fill: parent
        anchors.leftMargin: Style.space(10)
        verticalAlignment: Text.AlignVCenter
        text: parent.name
        color: root.selectedName === name || ListView.isCurrentItem
          ? root.accent : root.foreground
        opacity: root.selectedName === name ? 1 : 0.72
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.capitalization: Font.Capitalize
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: parent.hovered = true
        onExited: parent.hovered = false
        onClicked: {
          resultList.currentIndex = index
          root.indexSelected(index, name)
        }
      }
    }
  }
}
