/**
This script is run whenever the devtools are open.
In here, we can create our panel.
*/

function handleShown() {
  console.log("panel is being shown");
}

function handleHidden() {
  console.log("panel is being hidden");
}

/**
Create a panel, and add listeners for panel show/hide events.
*/

chrome.devtools.panels.create(
  "Opal",
  "/icons/opal_devtools_48.png",
  "/devtools/panel/panel.html",
  function(panel) {
    panel.onShown.addListener(handleShown);
    panel.onHidden.addListener(handleHidden);
  });


/** communicate with page */
// let backgroundPageConnection = chrome.runtime.connect({name: "devtools-page"});
//
// backgroundPageConnection.onMessage.addListener(function(message) {});

// Relay the tab ID to the background page
//chrome.runtime.sendMessage({
//    tabId: chrome.devtools.inspectedWindow.tabId,
//    scriptToInject: "panel/opal-inject.js"
//});