'use strict';

chrome.runtime.onConnect.addListener(function(port) {
    let devtoolsListener = function(message, sender) {
        if (sender.name == "opal-devtools-panel" && message.injectScript) {
            chrome.tabs.executeScript(message.tabId, {file: message.injectScript}, function (result) {
                sender.postMessage({result: result});
            });
        } else if (sender.name == "opal-devtools-panel" && message.injectCode) {
            chrome.tabs.executeScript(message.tabId, { code: message.injectCode}, function (result) {
                sender.postMessage({result: result, fromConsole: true, tabId: message.tabId, completion: message.completion});
            });
        } else {
            sender.postMessage({background_received: message});
        }
    };

    port.onMessage.addListener(devtoolsListener);

    port.onDisconnect.addListener(function() {
        port.onMessage.removeListener(devtoolsListener);
    });
});
