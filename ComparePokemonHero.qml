import QtQuick
import qs.Commons
import "PokemonCompareStore.js" as CompareStore

Rectangle {
  id: root

  property var pokemon: null
  property string side: "A"
  property bool mirrored: false
  property bool leading: false
  property color accent: Color.accent
  property color winnerColor: accent
  property color foreground: Color.foreground

  function typeText() {
    if (!root.pokemon || !root.pokemon.types) return ""
    return root.pokemon.types.map(function(item) {
      return String(item.type.name).toUpperCase()
    }).join("  /  ")
  }

  radius: Style.space(14)
  color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.025)
  border.color: root.leading
    ? root.winnerColor
    : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12)
  border.width: root.leading ? 2 : 1

  Rectangle {
    width: Style.space(4)
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: root.mirrored ? undefined : parent.left
    anchors.right: root.mirrored ? parent.right : undefined
    anchors.margins: Style.space(10)
    radius: width / 2
    color: root.leading ? root.winnerColor
      : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.22)
  }

  Image {
    id: artwork
    width: Style.space(124)
    height: Style.space(124)
    anchors.verticalCenter: parent.verticalCenter
    anchors.left: root.mirrored ? undefined : parent.left
    anchors.right: root.mirrored ? parent.right : undefined
    anchors.leftMargin: root.mirrored ? 0 : Style.space(18)
    anchors.rightMargin: root.mirrored ? Style.space(18) : 0
    source: root.pokemon
      ? (root.pokemon.sprites.other["official-artwork"].front_default
        || root.pokemon.sprites.front_default) : ""
    fillMode: Image.PreserveAspectFit
    asynchronous: true
  }

  Column {
    anchors.left: root.mirrored ? parent.left : artwork.right
    anchors.right: root.mirrored ? artwork.left : parent.right
    anchors.leftMargin: root.mirrored ? Style.space(20) : Style.space(8)
    anchors.rightMargin: root.mirrored ? Style.space(8) : Style.space(20)
    anchors.verticalCenter: parent.verticalCenter
    spacing: Style.space(5)

    Text {
      width: parent.width
      text: "POKEMON " + root.side + (root.leading ? "  ·  LEADING" : "")
      horizontalAlignment: root.mirrored ? Text.AlignRight : Text.AlignLeft
      color: root.leading ? root.winnerColor : root.accent
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      font.bold: true
      font.letterSpacing: 1.2
    }

    Text {
      width: parent.width
      text: root.pokemon ? root.pokemon.name : ""
      horizontalAlignment: root.mirrored ? Text.AlignRight : Text.AlignLeft
      color: root.foreground
      font.family: Style.font.family
      font.pixelSize: Style.font.title
      font.bold: true
      font.capitalization: Font.Capitalize
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      text: root.pokemon ? "#" + root.pokemon.id + "  ·  " + root.typeText() : ""
      horizontalAlignment: root.mirrored ? Text.AlignRight : Text.AlignLeft
      color: root.foreground
      opacity: 0.55
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      elide: Text.ElideRight
    }

    Text {
      width: parent.width
      text: root.pokemon ? CompareStore.total(root.pokemon) + " BST" : ""
      horizontalAlignment: root.mirrored ? Text.AlignRight : Text.AlignLeft
      color: root.leading ? root.winnerColor : root.foreground
      opacity: root.leading ? 1 : 0.72
      font.family: Style.font.family
      font.pixelSize: Style.font.body
      font.bold: true
    }
  }
}
