#!/usr/bin/env bash
rm -f chrome_extension/devtools/panel/*.js
rm -f firefox_extension/devtools/panel/*.js
rm -f chrome_extension/devtools/panel/*.map
rm -f firefox_extension/devtools/panel/*.map
rm *.zip

yarn run production_build

cd chrome_extension
zip -r ../opal_devtools_chrome.zip *
cd ..

cd firefox_extension
zip -r ../opal_devtools_firefox.zip *
cd ..

ls -al *.zip
