// Author: Itz-fork


//  Pre-defined variables
var intWidth = window.innerWidth
var intHeight = window.innerHeight
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
    const fragment = document.createDocumentFragment();
    while (sq > 0) {
        let sqrel = document.createElement("div");
        sqrel.classList.add("sqr_block");
        sqrel.innerText = codes[~~(Math.random() * codes.length)];
        fragment.appendChild(sqrel);
        sq--;
    }
    container.appendChild(fragment);
}

// Grid children
let cchildren = container.children;

// Calculate grid
const CalcGrid = () => {
    container.innerHTML = "";
    columns = Math.floor(window.innerWidth / size);
    rows = Math.floor(window.innerHeight / size);
    container.style.setProperty("--columns", columns);
    container.style.setProperty("--rows", rows);
    AddSqrs(columns * rows);
    // Update grid children
    cchildren = container.children;
};
CalcGrid();

// Generate grid on resize
window.onresize = () => {
    const curWidth = window.innerWidth
    const curHeight = window.innerHeight
    if (curWidth != intWidth && curHeight != intHeight) {
        CalcGrid()
    }
};

// Mouse move effect
window.onmousemove = (ev) => {
    const position = Math.floor(ev.x / size) + Math.floor(ev.y / size) * columns;

    let el = cchildren[position];
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
    } catch (e) { }
};
