import QtQuick
import qs.Commons

Item {
  id: root

  property string label: ""
  property string text: ""
  property string placeholder: "Pokemon name"
  property var suggestions: []
  property int highlightedIndex: -1
  property bool suggestionsVisible: false
  property string submittedText: ""
  property color accent: Color.accent
  property color foreground: Color.foreground
  signal textEdited(string value)
  signal submitted(string value)

  implicitHeight: labelText.implicitHeight + Style.space(6) + Style.space(40)

  Text {
    id: labelText
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    text: root.label
    horizontalAlignment: Text.AlignHCenter
    color: root.accent
    font.family: Style.font.family
    font.pixelSize: Style.font.bodySmall
    font.bold: true
    font.letterSpacing: 1
  }

  Rectangle {
    id: inputFrame
    width: parent.width
    height: Style.space(40)
    anchors.top: labelText.bottom
    anchors.topMargin: Style.space(6)
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
    radius: Style.space(9)
    border.color: input.activeFocus
      ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.65)
      : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.08)
    border.width: 1

    TextInput {
      id: input
      text: root.text
      anchors.fill: parent
      anchors.leftMargin: Style.space(12)
       anchors.rightMargin: Style.space(42)
      verticalAlignment: TextInput.AlignVCenter
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      clip: true
      selectByMouse: true
       onTextChanged: {
         root.text = text
         root.highlightedIndex = 0
         if (text === root.submittedText) root.submittedText = ""
         else root.suggestionsVisible = text.length > 0
         root.textEdited(text)
       }
       Keys.onReturnPressed: function(event) {
         root.submitSelection()
         event.accepted = true
       }
       Keys.onEnterPressed: function(event) {
         root.submitSelection()
         event.accepted = true
       }
       Keys.onPressed: function(event) {
         if (event.key === Qt.Key_Up) {
           root.moveSuggestion(-1)
           event.accepted = true
         } else if (event.key === Qt.Key_Down) {
           root.moveSuggestion(1)
           event.accepted = true
         }
       }
     }

     MouseArea {
       anchors.right: parent.right
       anchors.verticalCenter: parent.verticalCenter
       width: Style.space(34)
       height: parent.height
       visible: input.text.length > 0
       onClicked: {
         root.submittedText = ""
         input.clear()
         input.forceActiveFocus()
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

     Text {
      anchors.left: parent.left
      anchors.leftMargin: Style.space(12)
      anchors.verticalCenter: parent.verticalCenter
      text: root.placeholder
      color: root.foreground
      opacity: 0.42
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      visible: input.text.length === 0
    }
  }

  Rectangle {
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: inputFrame.bottom
    anchors.topMargin: Style.space(6)
    height: root.suggestionsVisible && root.suggestions.length > 0 && input.text.length > 0
      ? Math.min(root.suggestions.length, 6) * Style.space(30) : 0
    visible: height > 0
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)
    radius: Style.space(7)
    border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.1)
    border.width: 1
    z: 20

    ListView {
      anchors.fill: parent
      clip: true
      model: root.suggestions
      interactive: false

      delegate: Rectangle {
        required property var modelData
        required property int index
        width: ListView.view.width
        height: Style.space(30)
        color: index === root.highlightedIndex
          ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18)
          : "transparent"

        Text {
          anchors.fill: parent
          anchors.leftMargin: Style.space(10)
          verticalAlignment: Text.AlignVCenter
          text: modelData.name
          color: root.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
        }

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true
          onEntered: root.highlightedIndex = index
          onClicked: {
            root.highlightedIndex = index
            root.submitSelection()
          }
        }
      }
    }
  }

  function moveSuggestion(direction) {
    if (root.suggestions.length === 0) return
    root.highlightedIndex = Math.max(0, Math.min(
      root.suggestions.length - 1,
      (root.highlightedIndex < 0 ? 0 : root.highlightedIndex) + direction
    ))
  }

  function submitSelection() {
    var value = input.text
    if (root.highlightedIndex >= 0
        && root.highlightedIndex < root.suggestions.length) {
      value = root.suggestions[root.highlightedIndex].name
    }
    root.suggestionsVisible = false
    root.submittedText = value
    root.submitted(value)
  }

  function focusInput() {
    input.forceActiveFocus()
  }

  function clearInput() {
    root.submittedText = ""
    root.suggestionsVisible = false
    root.highlightedIndex = -1
    input.clear()
  }
}
