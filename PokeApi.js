.pragma library

var apiBase = "https://pokeapi.co/api/v2"

function request(path, onSuccess, onFailure) {
  var xhr = new XMLHttpRequest()
  xhr.onreadystatechange = function() {
    if (xhr.readyState !== XMLHttpRequest.DONE) return
    if (xhr.status >= 200 && xhr.status < 300) {
      try {
        onSuccess(JSON.parse(xhr.responseText))
      } catch (error) {
        onFailure("The API returned invalid data.")
      }
    } else {
      onFailure("Pokemon data is currently unavailable.")
    }
  }
  xhr.open("GET", apiBase + path)
  xhr.send()
}

function loadIndex(onSuccess, onFailure) {
  request("/pokemon?limit=2000", function(data) {
    onSuccess(data.results || [])
  }, onFailure)
}

function loadPokemon(name, onSuccess, onFailure) {
  request("/pokemon/" + encodeURIComponent(name), onSuccess, onFailure)
}
