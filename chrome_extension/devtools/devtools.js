'use strict';

/**
 This script is run whenever the devtools are open.
 In here, we can create our panel.
 */

let panel_window = null;

function handleShown(p_window) {
    panel_window = p_window;
}

function handleHidden() {
    // console.log("panel is being hidden");
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

        /** communicate with page */
        chrome.runtime.onConnect.addListener(function(port) {
            port.onMessage.addListener(function (message, sender) {
                if (panel_window && message.tabId && message.fromConsole) {
                    console.log("opal-devtools-page received message:", message);
                    console.log("will dispatch", message);
                    let event = new CustomEvent('OpalDevtoolsResult', { detail: message });
                    console.log("dispatching event:", event);
                    console.log("window:", panel_window);
                    panel_window.dispatchEvent(event);
                }
            });
        });
        chrome.runtime.connect({name: "opal-devtools-page"});
    });

