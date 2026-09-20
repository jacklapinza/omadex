# Omadex

Omadex is a searchable Pokemon encyclopedia and base-stat comparison panel for
Omarchy Quattro.

It uses [PokeAPI](https://pokeapi.co/) for Pokemon names, artwork, types,
abilities, and base stats. It does not require an API key.

## Features

- Fast local-name search with keyboard navigation
- Artwork, typing, abilities, measurements, and base stats
- Two-Pokemon comparison with mirrored stat bars and transparent differences
- Theme-aware centered window
- Poké Ball bar launcher with interactive placement during installation
- Mouse and keyboard operation

## Install

```bash
omarchy plugin add https://github.com/jacklapinza/omadex.git --enable
```

Summon it with:

```bash
omarchy-shell shell summon io.github.jacklapinza.omadex '{}'
```

Press Escape to close it.

Click the Poké Ball icon in the bar to open or close Omadex. Move it later with:

```bash
omarchy bar move io.github.jacklapinza.omadex --section left
```

## Remove

```bash
omarchy plugin remove io.github.jacklapinza.omadex
```

## Development notes

- The plugin runs inside the long-lived `omarchy-shell` process.
- PokeAPI asks clients to cache resources and avoid abusive traffic.
- Detail responses are cached in memory for the current shell session.
- Comparison results use PokéAPI base stats and do not claim to be competitive
  rankings or an official power score.

## Attribution

Pokémon names and character names are trademarks of Nintendo. Omadex is not
affiliated with or endorsed by Nintendo, The Pokémon Company, or Game Freak.
Review the licenses and provenance of any sprites before bundling or
redistributing them.
