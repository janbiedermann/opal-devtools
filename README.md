# Opal Devtools

Currently provides a console to execute ruby in the webpage context.
Works on Chrome and Firefox.

### Community and Support
At the [Isomorfeus Framework Project](http://isomorfeus.com) 

### Installation
- clone
- `yarn install`
- `bundle install`
- `yarn run production_build` for a minified build

or
- `yarn run debug_build` to include source maps for debugging, webpack will continue running and rebuild on file changes.
 
For Chrome:
- in Chrome extensions, turn on developer mode
- load the `chrome_extension` directory.

For Firefox:
- in Firefox, Add-ons, the gear, select "Debug Add-on"
- then "Load temporary Add-on"
- select `manifest.json` in the `firefox_extension` directory. 

### Usage
`help` show available commands.

Commands can by default only be executed if Opal is loaded on the page.

If Opal is not loaded on the page it can be injected with `inject_opal`,
on any page. Afterwards Opal Ruby can be used to manipulate the DOM. Everything from opal-browser is available, eg:
```
my_div = $document['div']
```
However, `inject_opal` puts the console in "inject" mode. In this mode the Javascript context of the page is not available,
only access to the DOM is possible.
To go out of "inject" mode use `go_iso`, it loads the Isomorfeus website with Opal loaded, execution of Opal Ruby commands in page context
is then possible again. Afterwards any other page with Opal loaded can be visited and Opal Ruby commands be executed.

### Based on
- opal
- opal-browser
- opal-webpack-loader
- isomorfeus-redux
- isomorfeus-react
- OpalConsole, integrated.

### Credits
- Tab completion engine originally taken from @fkchang [opal-irb](https://github.com/fkchang/opal-irb)
