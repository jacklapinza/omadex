import QtQuick
import qs.Commons
import "PokeApi.js" as PokeApi
import "PokemonCompareStore.js" as CompareStore
import "PokemonStore.js" as PokemonStore

Item {
  id: root

  property color foreground: Color.foreground
  property color accent: Color.accent
  property var leftPokemon: null
  property var rightPokemon: null
  property var pokemonIndex: []
  property var compareCache: ({})
  property string statusText: "Enter two Pokemon to compare their base stats."
  property string leftQuery: ""
  property string rightQuery: ""
  property alias focusItem: leftInput
  readonly property bool bothSelected: root.leftPokemon !== null && root.rightPokemon !== null
  readonly property int leftTotal: CompareStore.total(root.leftPokemon)
  readonly property int rightTotal: CompareStore.total(root.rightPokemon)
  readonly property var largestEdge: CompareStore.largestEdge(root.leftPokemon, root.rightPokemon)
  readonly property bool lightSurface:
    0.2126 * Color.popups.background.r + 0.7152 * Color.popups.background.g
      + 0.0722 * Color.popups.background.b > 0.5
  readonly property color winnerColor: root.lightSurface
    ? Qt.darker(root.accent, 1.4) : Qt.lighter(root.accent, 1.65)

  function focusCompare() {
    leftInput.focusInput()
  }

  function clearComparison() {
    leftInput.clearInput()
    rightInput.clearInput()
    root.leftQuery = ""
    root.rightQuery = ""
    root.leftPokemon = null
    root.rightPokemon = null
    root.statusText = "Enter two Pokemon to compare their base stats."
    leftInput.focusInput()
  }

  function loadPokemon(side, rawName) {
    var name = String(rawName || "").trim().toLowerCase()
    if (name.length === 0) return
    if (side === "left") root.leftQuery = name
    else root.rightQuery = name
    var cached = root.compareCache[name]
    if (cached) {
      setPokemon(side, cached)
      return
    }

    root.statusText = "Loading " + name + "..."
    PokeApi.loadPokemon(name, function(data) {
      root.compareCache[name] = data
      setPokemon(side, data)
    }, function(message) {
      root.statusText = message
    })
  }

  function setPokemon(side, pokemon) {
    if (side === "left") root.leftPokemon = pokemon
    else root.rightPokemon = pokemon
    root.statusText = root.leftPokemon && root.rightPokemon
      ? "Higher base stat wins each row"
      : "Enter two Pokemon to compare their base stats."
  }

  Column {
    anchors.fill: parent
    spacing: Style.space(10)

    Row {
      width: parent.width
      spacing: Style.space(10)
      z: 10

      CompareInput {
        id: leftInput
        width: (parent.width - parent.spacing) / 2
        label: root.leftPokemon ? root.leftPokemon.name.toUpperCase() : "POKEMON A"
        text: root.leftQuery
        suggestions: PokemonStore.search(root.pokemonIndex, root.leftQuery, 8)
        accent: root.accent
        foreground: root.foreground
        onTextEdited: function(value) {
          root.leftQuery = value
          root.leftPokemon = null
        }
        onSubmitted: root.loadPokemon("left", value)
      }

      CompareInput {
        id: rightInput
        width: (parent.width - parent.spacing) / 2
        label: root.rightPokemon ? root.rightPokemon.name.toUpperCase() : "POKEMON B"
        text: root.rightQuery
        suggestions: PokemonStore.search(root.pokemonIndex, root.rightQuery, 8)
        accent: root.accent
        foreground: root.foreground
        onTextEdited: function(value) {
          root.rightQuery = value
          root.rightPokemon = null
        }
        onSubmitted: root.loadPokemon("right", value)
      }
    }

    Row {
      width: parent.width
      height: visible ? Style.space(78) : 0
      spacing: Style.space(10)
      visible: !root.bothSelected && (root.leftPokemon !== null || root.rightPokemon !== null)

      Repeater {
        model: [
          { side: "A", pokemon: root.leftPokemon },
          { side: "B", pokemon: root.rightPokemon }
        ]
        delegate: Rectangle {
          required property var modelData
          width: (parent.width - parent.spacing) / 2
          height: parent.height
          radius: Style.space(10)
          color: modelData.pokemon
            ? Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.035)
            : "transparent"
          border.color: modelData.pokemon
            ? Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.08)
            : "transparent"
          border.width: 1

          Row {
            anchors.fill: parent
            anchors.margins: Style.space(8)
            spacing: Style.space(8)

            Image {
              width: height
              height: parent.height
              source: modelData.pokemon ? modelData.pokemon.sprites.front_default : ""
              fillMode: Image.PreserveAspectFit
              asynchronous: true
            }

            Column {
              anchors.verticalCenter: parent.verticalCenter
              visible: modelData.pokemon !== null

              Text {
                text: "POKEMON " + modelData.side
                color: root.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                font.bold: true
                font.letterSpacing: 1
              }
              Text {
                text: modelData.pokemon ? modelData.pokemon.name : ""
                color: root.foreground
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: true
                font.capitalization: Font.Capitalize
              }
              Text {
                text: modelData.pokemon ? "BST " + CompareStore.total(modelData.pokemon) : ""
                color: root.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
              }
            }
          }
        }
      }
    }

    Text {
      width: parent.width
      text: root.statusText
      color: root.foreground
      opacity: 0.55
      font.family: Style.font.family
      font.pixelSize: Style.font.bodySmall
      visible: !root.bothSelected
        && (root.statusText !== "Enter two Pokemon to compare their base stats."
          || (root.leftQuery.length === 0 && root.rightQuery.length === 0))
    }

    Item {
      width: parent.width
      height: visible ? parent.height - y : 0
      visible: root.bothSelected

      Row {
        id: heroRow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        width: parent.width
        height: Style.space(148)
        spacing: Style.space(10)

        ComparePokemonHero {
          width: (parent.width - Style.space(150) - parent.spacing * 2) / 2
          height: parent.height
          pokemon: root.leftPokemon
          side: "A"
          leading: root.leftTotal > root.rightTotal
          accent: root.accent
          winnerColor: root.winnerColor
          foreground: root.foreground
        }

        Column {
          width: Style.space(150)
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(5)

          Rectangle {
            width: Style.space(54)
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            radius: width / 2
            color: "transparent"
            border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.65)
            border.width: 2

            Text {
              anchors.centerIn: parent
              text: "VS"
              color: root.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.title
              font.bold: true
              font.letterSpacing: 1
            }
          }

          Text {
            width: parent.width
            text: root.leftTotal === root.rightTotal ? "BST TIE"
              : (root.leftTotal > root.rightTotal ? "A" : "B")
                + "  +" + Math.abs(root.leftTotal - root.rightTotal) + " BST"
            horizontalAlignment: Text.AlignHCenter
            color: root.winnerColor
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }

          Text {
            width: parent.width
            text: root.leftTotal + "  /  " + root.rightTotal
            horizontalAlignment: Text.AlignHCenter
            color: root.foreground
            opacity: 0.48
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }

        ComparePokemonHero {
          width: (parent.width - Style.space(150) - parent.spacing * 2) / 2
          height: parent.height
          pokemon: root.rightPokemon
          side: "B"
          mirrored: true
          leading: root.rightTotal > root.leftTotal
          accent: root.accent
          winnerColor: root.winnerColor
          foreground: root.foreground
        }
      }

      Rectangle {
        id: summaryStrip
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: heroRow.bottom
        anchors.topMargin: Style.space(10)
        width: parent.width
        height: Style.space(44)
        radius: Style.space(10)
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.055)
        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18)
        border.width: 1

        Row {
          anchors.fill: parent
          anchors.leftMargin: Style.space(16)
          anchors.rightMargin: Style.space(16)

          Text {
            width: parent.width / 3
            height: parent.height
            text: "A WINS  " + CompareStore.wins(root.leftPokemon, root.rightPokemon, "left")
            verticalAlignment: Text.AlignVCenter
            color: root.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }

          Text {
            width: parent.width / 3
            height: parent.height
            text: root.largestEdge.winner === "tie" ? "NO STAT EDGE"
              : "BIGGEST EDGE  ·  " + root.largestEdge.label + " +" + root.largestEdge.delta
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: root.winnerColor
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }

          Text {
            width: parent.width / 3
            height: parent.height
            text: CompareStore.wins(root.leftPokemon, root.rightPokemon, "right") + "  B WINS"
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            color: root.foreground
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
          }
        }
      }

      Rectangle {
        id: statPanel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: summaryStrip.bottom
        anchors.topMargin: Style.space(10)
        anchors.bottom: scaleFooter.top
        anchors.bottomMargin: Style.space(8)
        width: parent.width
        radius: Style.space(14)
        color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.02)
        border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.1)
        border.width: 1

        Column {
          anchors.fill: parent
          anchors.margins: Style.space(12)
          spacing: 0

          Row {
            width: parent.width
            height: Style.space(22)

            Text {
              width: parent.width / 3
              text: "A  ·  " + (root.leftPokemon ? root.leftPokemon.name.toUpperCase() : "")
              color: root.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              elide: Text.ElideRight
            }
            Text {
              width: parent.width / 3
              text: "BASE STAT DUEL"
              horizontalAlignment: Text.AlignHCenter
              color: root.foreground
              opacity: 0.48
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              font.letterSpacing: 1
            }
            Text {
              width: parent.width / 3
              text: (root.rightPokemon ? root.rightPokemon.name.toUpperCase() : "") + "  ·  B"
              horizontalAlignment: Text.AlignRight
              color: root.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              elide: Text.ElideLeft
            }
          }

          Repeater {
            model: CompareStore.rows(root.leftPokemon, root.rightPokemon)
            delegate: CompareStatRow {
              required property var modelData
              width: parent.width
              height: Style.space(40)
              stat: modelData
              accent: root.accent
              winnerColor: root.winnerColor
              foreground: root.foreground
            }
          }
        }
      }

      Text {
        id: scaleFooter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Style.space(20)
        text: "Bars use the official base-stat scale (0-255). Highlights mark the higher value."
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignBottom
        color: root.foreground
        opacity: 0.4
        font.family: Style.font.family
        font.pixelSize: Style.font.caption
      }
    }
  }

  Rectangle {
    width: Style.space(108)
    height: Style.space(24)
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    z: 5
    visible: root.leftQuery.length > 0 || root.rightQuery.length > 0
      || root.leftPokemon !== null || root.rightPokemon !== null
    radius: height / 2
    color: Color.popups.background
    border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.5)
    border.width: 1

    Text {
      anchors.centerIn: parent
      text: "CLEAR DUEL"
      color: root.accent
      font.family: Style.font.family
      font.pixelSize: Style.font.caption
      font.bold: true
      font.letterSpacing: 0.8
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: root.clearComparison()
    }
  }
}
