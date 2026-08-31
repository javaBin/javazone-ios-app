# Docs

This directory provides the github pages for this project.

They are published under

https://javabin.github.io/javazone-ios-app/info.json

## Format

JSON - with the following fields

### `title`

Required - shown in info list

### `body`

Optional description

### `url`

Optional external link - has `title` and `url` fields

### `infoType`

Optional flag to specify extra type info - currently only value that can be set is `urgent`

## Assets

Any other file in this directory is published alongside `info.json` at the same base URL —
the whole `docs/` folder is uploaded by `.github/workflows/pages.yml`. For example
`venue_map_2026.png` is served from

https://javabin.github.io/javazone-ios-app/venue_map_2026.png

and is linked from an `info.json` entry so the app opens it in the browser.
