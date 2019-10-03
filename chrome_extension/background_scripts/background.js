'use strict';

chrome.runtime.onConnect.addListener(function(port) {
    console.log("connection from:", port.name);
    let devtoolsListener = function(message, sender) {
        if (sender.name == "opal-devtools-panel" && message.injectScript) {
            chrome.tabs.executeScript(message.tabId, {file: message.injectScript}, function (result) {
                console.log("Result from executeScript script:", result);
                sender.postMessage({result: result});
            });
        } else if (sender.name == "opal-devtools-panel" && message.injectCode) {
            chrome.tabs.executeScript(message.tabId, { code: message.injectCode}, function (result) {
                console.log("Result from executeScript code:", result);
                sender.postMessage({result: result, fromConsole: true, tabId: message.tabId});
            });
        } else {
            sender.postMessage({background_received: message});
        }
    };

    port.onMessage.addListener(devtoolsListener);

    port.onDisconnect.addListener(function() {
        console.log('disconnected:', port.name);
        port.onMessage.removeListener(devtoolsListener);
    });
});
