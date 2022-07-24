'use strict'
const dxvkStatus = document.querySelector("#dxvk-status");
const dxvkAsyncStatus = document.querySelector("#dxvk-async-status");
const fileName = document.querySelector("#file-name");
const sha256Text = document.querySelector("#sha256-text");

fetch("https://api.github.com/repos/teppyboy/dxvk-async-builder/releases/latest")
    .then(response => response.json())
    .then(data => parseJsonFromBody(data.body))

function parseJsonFromBody(body) {
    const bodyLines = body.split("\n");
    let jsonStr = "";
    let status = 0;
    bodyLoop:
    for (const line of bodyLines) {
        switch (status) {
            case 0:
                if (line.includes("```json")) {
                    status = 1;
                }
                break;
            case 1:
                if (line.includes("```")) {
                    break bodyLoop;
                }
                jsonStr += line;
                break;
        }
    }
    const json = JSON.parse(jsonStr);
    applyApiStatus(json);
}

function applyApiStatus(api) {
    console.log(api);
    dxvkStatus.setAttribute("href", dxvkStatus.getAttribute("href").replace("{GIT_DXVK_COMMIT_HASH}", api.dxvk_commit));
    dxvkStatus.innerHTML = dxvkStatus.innerHTML
        .replace("{GIT_DXVK_SHORT_COMMIT_HASH}", api.dxvk_commit_short)
        .replace("{GIT_DXVK_BRANCH}", "master"); // TODO
    dxvkAsyncStatus.setAttribute("href", dxvkAsyncStatus.getAttribute("href").replace("{GIT_DXVK_ASYNC_COMMIT_HASH}", api.dxvk_async_commit));
    dxvkAsyncStatus.innerHTML = dxvkAsyncStatus.innerHTML
        .replace("{GIT_DXVK_ASYNC_SHORT_COMMIT_HASH}", api.dxvk_async_commit_short)
        .replace("{GIT_DXVK_ASYNC_BRANCH}", "master"); // TODO
    fileName.innerHTML = api.file_name;
    sha256Text.innerHTML = api.sha256;
}