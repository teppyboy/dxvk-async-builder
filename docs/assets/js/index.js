'use strict'
const dxvkStatus = document.querySelector("#dxvk-status");
const dxvkAsyncStatus = document.querySelector("#dxvk-async-status");
const fileName = document.querySelector("#file-name");
const sha256Text = document.querySelector("#sha256-text");

fetch("https://api.github.com/repos/teppyboy/dxvk-async-builder/releases/latest")
    .then(response => response.json())
    .then(data => {
        console.log(data);
    })

function applyApiStatus(api) {
    // TODO
    console.log(api);
}