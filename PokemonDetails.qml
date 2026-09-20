import QtQuick
import qs.Commons
import "Stats.js" as Stats

Item {
  id: root

  property var pokemon: null
  property color foreground: Color.foreground
  property color accent: Color.accent
  property string statusText: ""
  readonly property int baseStatTotal: Stats.total(root.pokemon ? root.pokemon.stats : [])
  readonly property int baseStatPercent: Stats.percent(root.pokemon ? root.pokemon.stats : [])

  Column {
    anchors.fill: parent
    spacing: Style.space(10)
    visible: root.pokemon !== null

    Row {
      width: parent.width
      height: Style.space(150)
      spacing: Style.space(16)

      Rectangle {
        width: height
        height: parent.height
        color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.035)
        radius: Style.space(12)
        border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)
        border.width: 1

        Image {
          id: pokemonImage
          anchors.fill: parent
          anchors.margins: Style.space(10)
          source: root.pokemon
            ? (root.pokemon.sprites.other["official-artwork"].front_default
               || root.pokemon.sprites.front_default)
            : ""
          fillMode: Image.PreserveAspectFit
          asynchronous: true
          visible: status === Image.Ready
        }

        Text {
          anchors.centerIn: parent
          text: "No image"
          color: root.foreground
          opacity: 0.45
          visible: pokemonImage.status !== Image.Ready
        }
      }

      Column {
        width: parent.width - Style.space(166)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Style.space(6)

        Text {
          width: parent.width
          text: root.pokemon ? root.pokemon.name : ""
          color: root.foreground
          font.family: Style.font.family
          font.pixelSize: Style.font.display
          font.bold: true
          font.capitalization: Font.Capitalize
          wrapMode: Text.WordWrap
          maximumLineCount: 2
          elide: Text.ElideRight
        }

        Row {
          spacing: Style.space(6)
          Repeater {
            model: root.pokemon ? root.pokemon.types : []
            delegate: Rectangle {
              required property var modelData
              width: typeLabel.implicitWidth + Style.space(16)
              height: Style.space(26)
              radius: height / 2
              color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.14)
              border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.3)
              border.width: 1

              Text {
                id: typeLabel
                anchors.centerIn: parent
                text: modelData.type.name
                color: root.accent
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.bold: true
              }
            }
          }
        }

        Text {
          text: root.pokemon
            ? "#" + root.pokemon.id + "  " + root.pokemon.height / 10 + " m  " + root.pokemon.weight / 10 + " kg"
            : ""
          color: root.foreground
          opacity: 0.55
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
        }
      }
    }

    Row {
      width: parent.width
      spacing: Style.space(8)

      Text {
        text: "BASE STATS"
        color: root.accent
        font.family: Style.font.family
        font.pixelSize: Style.font.bodySmall
        font.bold: true
        font.letterSpacing: 1.2
        anchors.verticalCenter: parent.verticalCenter
      }

      Rectangle {
        width: statTotal.implicitWidth + Style.space(14)
        height: Style.space(24)
        radius: Style.space(7)
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.12)
        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.28)
        border.width: 1
        anchors.verticalCenter: parent.verticalCenter

        Text {
          id: statTotal
          anchors.centerIn: parent
          text: root.baseStatTotal
          color: root.accent
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          font.bold: true
        }
      }
    }

    Rectangle {
      width: parent.width
      height: Style.space(58)
      radius: Style.space(10)
      color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.035)
      border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.07)
      border.width: 1

      Row {
        anchors.fill: parent
        anchors.margins: Style.space(10)
        spacing: Style.space(10)

        Column {
          width: parent.width - recapBar.implicitWidth - recapPercent.implicitWidth - Style.space(20)
          anchors.verticalCenter: parent.verticalCenter
          spacing: Style.space(2)

          Text {
            text: "OM ADEX INDEX"
            color: root.foreground
            opacity: 0.55
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
            font.letterSpacing: 1
          }

          Text {
            text: "Derived from base stats"
            color: root.foreground
            opacity: 0.42
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
          }
        }

        Text {
          id: recapBar
          text: Stats.asciiBar(root.pokemon ? root.pokemon.stats : [], 16)
          color: root.accent
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          font.bold: true
          anchors.verticalCenter: parent.verticalCenter
        }

        Text {
          id: recapPercent
          text: root.baseStatPercent + "%"
          color: root.accent
          font.family: Style.font.family
          font.pixelSize: Style.font.bodySmall
          font.bold: true
          anchors.verticalCenter: parent.verticalCenter
        }
      }
    }

    Grid {
      id: statsGrid
      width: parent.width
      columns: 2
      rowSpacing: Style.space(7)
      columnSpacing: Style.space(8)
      Repeater {
        model: root.pokemon ? root.pokemon.stats : []
        delegate: Rectangle {
          required property var modelData
          width: (statsGrid.width - statsGrid.columnSpacing) / 2
          height: Style.space(34)
          radius: Style.space(8)
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.035)
          border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)
          border.width: 1

          Row {
            anchors.fill: parent
            anchors.leftMargin: Style.space(9)
            anchors.rightMargin: Style.space(9)
            spacing: Style.space(7)

            Text {
              width: Style.space(58)
              text: Stats.label(modelData.stat.name)
              color: root.accent
              font.family: Style.font.family
              font.pixelSize: Style.font.caption
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }

            Item {
              width: parent.width - Style.space(58) - Style.space(7) - statValue.implicitWidth
              height: parent.height
              anchors.verticalCenter: parent.verticalCenter

              Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: Style.space(5)
                radius: height / 2
                color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.1)

                Rectangle {
                  width: parent.width * Math.min(1, modelData.base_stat / 255)
                  height: parent.height
                  radius: parent.radius
                  color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.65)
                }
              }
            }

            Text {
              id: statValue
              text: modelData.base_stat
              color: root.foreground
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.bold: true
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }
      }
    }

    Text {
      text: root.pokemon
        ? "Abilities: " + root.pokemon.abilities.map(function(item) { return item.ability.name }).join(", ")
        : ""
      color: root.foreground
      opacity: 0.6
      font.family: Style.font.family
      font.pixelSize: Style.font.bodySmall
      wrapMode: Text.WordWrap
      width: parent.width
    }
  }

  Text {
    anchors.centerIn: parent
    text: root.statusText
    color: root.foreground
    opacity: 0.55
    font.family: Style.font.family
    font.pixelSize: Style.font.body
    visible: root.pokemon === null
  }
}
