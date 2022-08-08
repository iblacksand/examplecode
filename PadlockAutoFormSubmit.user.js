// ==UserScript==
// @name         Padlock Device Revoker (All Browsers)
// @namespace    *
// @version     1.0
// @description      Automatically revokes all devices in the padlock dashboard.
// @author       John Elizarraras
// @include     https://*
// @include     http://*
// @grant        none
// ==/UserScript==

// BROKEN

(function() {
    'use strict';
    //if title is padlock
    if (document.title.toLowerCase().indexOf("padlock") === -1) return;
    //fi title is padlock

    //if sheets contain dashboard
    var close = true;
    var sheets = document.styleSheets;
    for (var x = 0, len = sheets.length; x < len; x++) {
        if (sheets[x].href && sheets[x].href.toLowerCase().indexOf("dashboard")!==-1) {
            close = false;
        }
    }
    if (close) return;
    //fi sheets contain dashboard

    // if pairing
    var parameters = location.search.substring(1).split("&");
    if (parameters.length === 0) return;
    var name = unescape(parameters[0].split("=")[0]).toLowerCase();
    if (name == "paired") return;
    // fi pairing

    // if reset
    var parameters = location.search.substring(1).split("&");
    if (parameters.length === 0) return;
    var name = unescape(parameters[0].split("=")[0]).toLowerCase();
    if (name == "datareset") return;
    // fi reset

    // location.replace("?datareset=1");  doesn't work

    var forms = document.forms;
    for(var n = 0, len = forms.length; n < len; n++){
        forms[n].submit();
    }
})();