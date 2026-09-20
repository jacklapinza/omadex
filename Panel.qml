import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import qs.Commons
import qs.Ui
import "PokeApi.js" as PokeApi
import "PokemonStore.js" as PokemonStore

Panel {
  id: root
  moduleName: "io.github.jacklapinza.omadex"
  manageIpc: false

  readonly property color themeAccent: Color.accent
  readonly property color panelForeground: root.bar ? root.bar.foreground : Color.foreground
  property var anchorItem: null
  property var hostWidget: null
  property var bar: null
  property string query: ""
  property string statusText: "Loading Pokemon..."
  property string selectedName: ""
  property var selectedPokemon: null
  property var detailCache: ({})
  property var pokemonIndex: []
  property int resultIndex: -1
  property string currentPage: "search"
  property bool windowSetupReady: false
  readonly property int preferredWidth: Style.space(1180)
  readonly property int preferredHeight: Style.space(760)
  readonly property string windowPath:
    Qt.resolvedUrl("omadex-window").toString().replace(/^file:\/\//, "")

  function open(payloadJson) {
    root.controller.show()
    if (!root.windowSetupReady) return
    Qt.callLater(function() {
      if (root.currentPage === "compare") comparePage.focusCompare()
      else searchBar.focusSearch()
    })
  }

  function close() {
    root.controller.hide()
  }

  function loadIndex() {
    PokeApi.loadIndex(function(data) {
      root.pokemonIndex = data
      root.statusText = data.length + " Pokemon available"
      updateResults()
    }, function(message) {
      root.statusText = message
    })
  }

  function updateResults() {
    resultsModel.clear()
    root.resultIndex = -1
    if (root.query.trim().length === 0) {
      root.selectedName = ""
      root.selectedPokemon = null
    }
    var matches = PokemonStore.search(root.pokemonIndex, root.query, 30)
    matches.forEach(function(item) { resultsModel.append({ name: item.name }) })
    if (matches.length > 0) root.resultIndex = 0
    root.statusText = matches.length === 0 ? "No Pokemon found" : ""
  }

  function moveSelection(direction) {
    if (resultsModel.count === 0) return
    root.resultIndex = Math.max(0, Math.min(
      resultsModel.count - 1,
      root.resultIndex + direction
    ))
    searchResults.highlightedIndex = root.resultIndex
  }

  function acceptSelection() {
    if (root.resultIndex < 0 || root.resultIndex >= resultsModel.count) return
    loadPokemon(resultsModel.get(root.resultIndex).name)
  }

  function loadPokemon(name) {
    root.selectedName = name
    root.statusText = "Loading " + name + "..."
    var cached = PokemonStore.cached(root.detailCache, name)
    if (cached) {
      root.selectedPokemon = cached
      root.statusText = ""
      return
    }

    PokeApi.loadPokemon(name, function(data) {
      root.detailCache = PokemonStore.cache(root.detailCache, name, data)
      root.selectedPokemon = data
      root.statusText = ""
    }, function(message) {
      root.statusText = message
    })
  }

  function registerWindowSetup() {
    windowSetupReady = false
    if (!windowSetupProcess.running) windowSetupProcess.running = true
  }

  Component.onCompleted: {
    loadIndex()
    registerWindowSetup()
  }

  Process {
    id: windowSetupProcess
    command: [root.windowPath, String(root.preferredWidth), String(root.preferredHeight)]
    onExited: function(exitCode) {
      root.windowSetupReady = exitCode === 0
      if (root.opened) {
        Qt.callLater(function() {
          if (root.currentPage === "compare") comparePage.focusCompare()
          else searchBar.focusSearch()
        })
      }
    }
  }

  Timer {
    id: searchTimer
    interval: 180
    onTriggered: root.updateResults()
  }

  ListModel { id: resultsModel }

  FloatingWindow {
    id: panel
    visible: root.opened
    title: "Omadex"
    color: "transparent"
    implicitWidth: root.preferredWidth
    implicitHeight: root.preferredHeight
    minimumSize: Qt.size(Style.space(900), Style.space(620))
    HyprlandWindow.opacity: 1

    PanelKeyCatcher {
      anchors.fill: parent
      onCloseRequested: root.close()

      Rectangle {
        anchors.fill: parent
        color: Color.popups.background
        radius: Style.cornerRadius
        border.color: Color.popups.border
        border.width: 1

        Column {
          anchors.fill: parent
          anchors.margins: Style.space(16)
          spacing: Style.space(14)

          Row {
            width: parent.width
            spacing: Style.space(12)

            Text {
              text: "OMADEX"
              color: root.panelForeground
              font.family: Style.font.family
              font.pixelSize: Style.font.title
              font.bold: true
              font.letterSpacing: 1.5
            }

            Text {
              text: "POKEMON ENCYCLOPEDIA"
              color: root.panelForeground
              opacity: 0.55
              font.family: Style.font.family
              font.pixelSize: Style.font.bodySmall
              font.letterSpacing: 1.1
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          PageTabs {
            width: parent.width
            currentPage: root.currentPage
            accent: root.themeAccent
            foreground: root.panelForeground
            onPageSelected: function(page) {
              root.currentPage = page
              if (page === "compare") comparePage.focusCompare()
              else searchBar.focusSearch()
            }
          }

          SearchBar {
            id: searchBar
            width: parent.width
            height: root.currentPage === "search" ? implicitHeight : 0
            visible: root.currentPage === "search"
            accent: root.themeAccent
            foreground: root.panelForeground
            selectedIndex: root.resultIndex
            onSearchChanged: function(value) {
              root.query = value
              root.resultIndex = -1
              if (value.trim().length === 0) {
                root.selectedName = ""
                root.selectedPokemon = null
              }
              searchTimer.restart()
            }
            onMoveSelection: function(direction) { root.moveSelection(direction) }
            onAcceptSelection: root.acceptSelection()
            onEscapeRequested: root.close()
          }

          Row {
            width: parent.width
            height: root.currentPage === "search" ? parent.height - y : 0
            spacing: Style.space(12)
            visible: root.currentPage === "search"

            Rectangle {
              width: Style.space(290)
              height: parent.height
              color: Color.popups.background
              radius: Style.space(12)
              border.color: Qt.rgba(root.themeAccent.r, root.themeAccent.g,
                root.themeAccent.b, 0.3)
              border.width: 1

              SearchResults {
                id: searchResults
                anchors.fill: parent
                anchors.margins: Style.space(8)
                color: "transparent"
                border.width: 0
                model: resultsModel
                highlightedIndex: root.resultIndex
                selectedName: root.selectedName
                accent: root.themeAccent
                foreground: root.panelForeground
                onIndexSelected: function(index, name) {
                  root.resultIndex = index
                  root.loadPokemon(name)
                }
              }
            }

            Rectangle {
              width: parent.width - Style.space(302)
              height: parent.height
              color: Color.popups.background
              radius: Style.space(12)
              border.color: Qt.rgba(root.themeAccent.r, root.themeAccent.g,
                root.themeAccent.b, 0.3)
              border.width: 1

              PokemonDetails {
                anchors.fill: parent
                anchors.margins: Style.space(14)
                pokemon: root.selectedPokemon
                foreground: root.panelForeground
                accent: root.themeAccent
                statusText: root.statusText
              }
            }
          }

          PokemonCompare {
            id: comparePage
            width: parent.width
            height: root.currentPage === "compare" ? parent.height - y : 0
            visible: root.currentPage === "compare"
            foreground: root.panelForeground
            accent: root.themeAccent
            pokemonIndex: root.pokemonIndex
          }
        }
      }
    }
  }
}
