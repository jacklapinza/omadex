.pragma library

function total(stats) {
  if (!stats) return 0
  return stats.reduce(function(sum, item) {
    return sum + Number(item.base_stat || 0)
  }, 0)
}

function percent(stats) {
  return Math.round(Math.min(1, total(stats) / 720) * 100)
}

function asciiBar(stats, length) {
  var size = length || 18
  var filled = Math.round(percent(stats) / 100 * size)
  return "[" + "#".repeat(filled) + "-".repeat(size - filled) + "]"
}

function label(name) {
  var labels = {
    hp: "HP",
    attack: "ATK",
    defense: "DEF",
    "special-attack": "SP. ATK",
    "special-defense": "SP. DEF",
    speed: "SPEED"
  }
  return labels[name] || String(name).toUpperCase()
}
