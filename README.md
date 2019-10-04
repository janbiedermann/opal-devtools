<h1 align="center">
  <img src="https://raw.githubusercontent.com/isomorfeus/opal-devtools/master/opal_devtools.png" 
  align="center" title="Opal logo by Elia Schito combined with Tools" width="111" height="125" />
  <br/>
  Opal Developer Tools<br/>
  <img src="https://img.shields.io/badge/Opal-Ruby%20💛%20JavaScript%20💛%20Firefox%20💛%20Chrome%20💛%20Edge%20Canary-yellow.svg?logo=ruby&style=social&logoColor=777"/>
</h1>

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
 
For Chrome and Edge (Canary, the one based on Chromium, >= V79):
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
- [opal](http://opalrb.com)
- [opal-browser](https://github.com/opal/opal-browser)
- [opal-webpack-loader](https://github.com/isomorfeus/opal-webpack-loader)
- [isomorfeus-redux](https://github.com/isomorfeus/isomorfeus-redux/tree/master/ruby)
- [isomorfeus-react](https://github.com/isomorfeus/isomorfeus-react/tree/master/ruby)
- [OpalConsole, integrated.](https://github.com/isomorfeus/opal-devtools/tree/master/isomorfeus/components)

### Credits
- Tab completion engine originally taken from @fkchang [opal-irb](https://github.com/fkchang/opal-irb)
