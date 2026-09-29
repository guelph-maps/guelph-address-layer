# Guelph Addresses Layer

Turns the City of Guelph [Addresses](https://explore.guelph.ca/datasets/cityofguelph::addresses-1)
dataset (~53,800 civic address points, updated daily by the city) into
map-tile layers (interactive vector + labelled raster) that OpenStreetMap
mappers can add to the **iD** and **JOSM** editors as a reference overlay.

**Live layer and how to add it: https://guelph-maps.github.io/guelph-address-layer/**

This is a thin repo: the whole pipeline is the
[`address-layerist`](../address-layerist) engine. All that lives here is
[`layer.toml`](layer.toml) (the data source + field map + site settings), a
`run.py` shim, and the city outline in `assets/boundary.geojson`.

It is the reference layer for the
[guelph-address-import](https://github.com/guelph-maps/guelph-address-import)
project (both live in the [guelph-maps](https://github.com/guelph-maps) organisation): the same source the import conflates against, drawn so a mapper can
check an address against the city's data without leaving the editor.

## Setup

```
pip install -r requirements.txt          # the engine + its deps
```

The vector-tile step needs WSL2 + tippecanoe once -- see
[../address-layerist/wsl-setup.md](../address-layerist/wsl-setup.md).

## Usage

```
addressvault pull guelph --wait   # acquire data into the vault (separate tool; --wait coalesces)
python run.py slim       # slim the latest guelph dump into a GeoJSONL + meta
python run.py vector     # vector (MVT) tiles via WSL tippecanoe
python run.py raster     # labelled raster (PNG) tiles
python run.py site       # render the landing page

python run.py build      # slim + vector + raster + site
python run.py update     # build + publish (the daily entry point)
```

The engine reads the newest `guelph-*.geojson` from `$ADDRESSVAULT_DIR` (or
`--input PATH`); it does not download. The daily task is
`addressvault pull guelph --wait && python run.py update`.

Build output lands in `build/site/`; that directory is what gets published to an
orphan `gh-pages` branch (history never grows).

## What the labels carry

Guelph publishes the house number, a separate suffix column (`52` + `B`), and a
unit on a quarter of its rows. All three go into the label, so `52B` and `52`
are distinct and a townhouse block reads `3-2280` per door rather than `2280`
repeated. The postcode ships as a tag in the vector tiles.

## Scheduling (Windows)

```powershell
.\schedule-add.ps1       # registers a daily task "kk-GuelphAddressLayer" at 16:00
.\schedule-remove.ps1    # unregisters it
```

The task pulls the vault first, then runs `python run.py update`, via the
shared `../pull-then-update.cmd`.

## Licence / attribution

Address data is &copy; City of Guelph, published under the
[Open Government Licence &ndash; City of Guelph](https://gismaps.guelph.ca/Images/OpenDataLicenceVersion2.pdf).
Tiles and the landing page carry that attribution. This repo is MIT licensed.
