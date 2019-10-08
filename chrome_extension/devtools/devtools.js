'use strict';

/**
This script is run whenever the devtools are open.
In here, we can create our panel.
*/

let count = 0;

function check_page_for_opal() {
    chrome.devtools.inspectedWindow.eval(
        `var framework = null;
        var opal_version = null;
        var devtools_support = false;
        if (typeof Opal !== "undefined") {
            opal_version = Opal.RUBY_ENGINE_VERSION;
            if (typeof Opal.Isomorfeus !== "undefined") { framework = "isomorfeus" }
            else if (typeof Opal.Hyperstack !== "undefined") { framework = "hyperstack" }
            else if (typeof Opal.Hyperloop !== "undefined") { framework = "hyperloop" }
            else if (typeof Opal.Clearwater !== "undefined") { framework = "clearwater" }
            if (typeof Opal.opal_devtools_object_registry !== "undefined") { devtools_support = true }
        }
        [opal_version, framework, devtools_support]`,
        {},
        function(res, error) {
            if (!res[0] && count < 6) {
                // browser possibly did not finish loading the page, so try again.
                count++;
                setTimeout(function() {
                    check_page_for_opal();
                }, 1000);
            } else {
                count = 0;
                let event = new CustomEvent('OpalDevtoolsPageCheck', {detail: {opal_version: res[0], framework: res[1], devtools_support: res[2]}});
                panel_window.dispatchEvent(event);
            }
        });
}

let panel_window = null;

function handleShown(p_window) {
    panel_window = p_window;
    check_page_for_opal();
    chrome.devtools.network.onNavigated.addListener(check_page_for_opal);
}

function handleHidden() {
    chrome.devtools.network.onNavigated.removeListener(check_page_for_opal);
}

chrome.devtools.network.onNavigated.addListener(check_page_for_opal);

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
                    let event = new CustomEvent('OpalDevtoolsResult', { detail: message });
                    panel_window.dispatchEvent(event);
                }
            });
        });
        chrome.runtime.connect({name: "opal-devtools-page"});
    });
