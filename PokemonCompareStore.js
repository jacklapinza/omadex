.pragma library

var statOrder = [
  { key: "hp", label: "HP" },
  { key: "attack", label: "ATK" },
  { key: "defense", label: "DEF" },
  { key: "special-attack", label: "SP. ATK" },
  { key: "special-defense", label: "SP. DEF" },
  { key: "speed", label: "SPEED" }
]

function statValue(pokemon, key) {
  if (!pokemon || !pokemon.stats) return 0
  for (var i = 0; i < pokemon.stats.length; i++) {
    if (pokemon.stats[i].stat.name === key) return Number(pokemon.stats[i].base_stat || 0)
  }
  return 0
}

function total(pokemon) {
  if (!pokemon || !pokemon.stats) return 0
  return pokemon.stats.reduce(function(sum, item) {
    return sum + Number(item.base_stat || 0)
  }, 0)
}

function rows(left, right) {
  return statOrder.map(function(stat) {
    var leftValue = statValue(left, stat.key)
    var rightValue = statValue(right, stat.key)
    return {
      key: stat.key,
      label: stat.label,
      left: leftValue,
      right: rightValue,
      delta: Math.abs(leftValue - rightValue),
      winner: leftValue === rightValue ? "tie" : (leftValue > rightValue ? "left" : "right")
    }
  })
}

function wins(left, right, side) {
  return rows(left, right).filter(function(row) {
    return row.winner === side
  }).length
}

function largestEdge(left, right) {
  var result = rows(left, right).slice(0).sort(function(a, b) {
    return b.delta - a.delta
  })[0]
  return result || { label: "", delta: 0, winner: "tie" }
}
