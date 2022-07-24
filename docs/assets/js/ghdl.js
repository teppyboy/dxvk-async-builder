'use strict'
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
    window.location.href = api.download.github;
}