.pragma library

function search(index, query, limit) {
  var needle = String(query || "").trim().toLowerCase()
  if (needle.length === 0) return []
  return (index || []).filter(function(item) {
    return item.name.indexOf(needle) !== -1
  }).slice(0, limit || 30)
}

function cached(cache, name) {
  return cache && cache[name] ? cache[name] : null
}

function cache(cache, name, value) {
  var next = cache || ({})
  next[name] = value
  return next
}
