.pragma library

function indexPath() {
  return "/pokemon?limit=2000"
}

function pokemonPath(name) {
  return "/pokemon/" + encodeURIComponent(name)
}
