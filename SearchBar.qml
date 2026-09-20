import QtQuick
import qs.Commons

Item {
  id: root

  property alias inputItem: searchInput
  property alias text: searchInput.text
  property color accent: Color.accent
  property color foreground: Color.foreground
  property int selectedIndex: -1
  signal searchChanged(string text)
  signal moveSelection(int direction)
  signal acceptSelection()
  signal escapeRequested()
  signal cleared()

  implicitHeight: Style.space(42)

  function focusSearch() {
    searchInput.forceActiveFocus()
  }

  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
    radius: Style.space(10)
    border.color: searchInput.activeFocus
      ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.65)
      : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.08)
    border.width: 1

    TextInput {
      id: searchInput
      anchors.fill: parent
      anchors.leftMargin: Style.space(14)
       anchors.rightMargin: Style.space(42)
      verticalAlignment: TextInput.AlignVCenter
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      clip: true
      selectByMouse: true
      onTextChanged: root.searchChanged(text)
      Keys.onDownPressed: function(event) {
        root.moveSelection(1)
        event.accepted = true
      }
      Keys.onUpPressed: function(event) {
        root.moveSelection(-1)
        event.accepted = true
      }
      Keys.onReturnPressed: function(event) {
        root.acceptSelection()
        event.accepted = true
      }
      Keys.onEnterPressed: function(event) {
        root.acceptSelection()
        event.accepted = true
      }
      Keys.onEscapePressed: root.escapeRequested()
    }

    Text {
      anchors.left: parent.left
      anchors.leftMargin: Style.space(14)
      anchors.verticalCenter: parent.verticalCenter
      text: "Search by Pokemon name..."
      color: root.foreground
      opacity: 0.45
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      visible: searchInput.text.length === 0
    }

    MouseArea {
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      width: Style.space(34)
      height: parent.height
      visible: searchInput.text.length > 0
      onClicked: {
        searchInput.clear()
        searchInput.forceActiveFocus()
        root.cleared()
      }

      Text {
        anchors.centerIn: parent
        text: "x"
        color: root.accent
        opacity: 0.8
        font.family: Style.font.family
        font.pixelSize: Style.font.body
        font.bold: true
      }
    }
  }
}
