# Opal Devtools

Currently provides a console to execute ruby in the webpage context.
Works on Chrome and Firefox.

- clone
- `yarn install`
- `bundle install`
- `yarn run production_build` for a minified build

or
- `yarn run debug_build` to include source maps for debugging.
 
For Chrome:
- in Chrome extensions, turn on developer mode
- load the `chrome_extension` directory.

For Firefox:
- in Firefox, Add-ons, the gear, select "Debug Add-on"
- then "Load temporary Add-on"
- select `manifest.json` in the `firefox_extension` directory. 

If typing doesn't appear to work, it's out of focus, try clicking directly on the cursor.

#### Using
- opal
- opal-browser
- opal-webpack-loader
- isomorfeus-redux
- isomorfeus-react
- OpalConsole, integrated.

#### Credits
- Tab completion engine originally taken from @fkchang [opal-irb](https://github.com/fkchang/opal-irb)
