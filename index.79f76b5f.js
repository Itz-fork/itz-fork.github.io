// Author: Itz-fork
//  Pre-defined variables
var intWidth = window.innerWidth;
var intHeight = window.innerHeight;
const container = document.getElementById("sqbg");
const cursor = document.getElementById("cursor");
const size = 100;
let columns = 0, rows = 0;
const codes = [
    "backend",
    "frontend",
    "full-stack",
    "python",
    "javascript",
    "typescript",
    "bash",
    "dart",
    "vlang",
    "html",
    "css",
    "Arch btw",
    "android",
    "windows",
    "deno",
    "svelte",
    "nuxt",
    "git",
    "docker",
    "Fastapi",
    "API",
    "CLI",
    "Web scraping",
    "scripting",
    "$ sudo -b",
    "$ whoami",
    "$ ifconfig",
    "$ ping",
    "$ route",
    "$ netstat",
    "pub fn",
    "def hello()",
    "while True",
    "struct Code",
    "interface Life"
];
// Background grid
function AddSqrs(sq) {
    while(sq > 0){
        let sqrel = document.createElement("div");
        sqrel.classList.add("sqr_block");
        sqrel.innerText = codes[Math.floor(Math.random() * codes.length)];
        container.appendChild(sqrel);
        sq--;
    }
}
const CalcGrid = ()=>{
    container.innerHTML = "";
    columns = Math.floor(window.innerWidth / size);
    rows = Math.floor(window.innerHeight / size);
    container.style.setProperty("--columns", columns);
    container.style.setProperty("--rows", rows);
    AddSqrs(columns * rows);
};
CalcGrid();
// Generate grid on resize
window.onresize = ()=>{
    let curWidth = window.innerWidth;
    let curHeight = window.innerHeight;
    if (curWidth != intWidth || curHeight != intHeight) CalcGrid();
};
// Mouse move effect
window.onmousemove = (ev)=>{
    let position = Math.floor(ev.x / 100) + Math.floor(ev.y / 100) * columns;
    let el = container.children[position];
    try {
        el.animate({
            opacity: [
                0.2,
                0.9,
                1
            ],
            offset: [
                0,
                0.8
            ],
            easing: [
                "ease-in",
                "ease-out"
            ]
        }, 2000);
    } catch (e) {}
};

//# sourceMappingURL=index.79f76b5f.js.map
