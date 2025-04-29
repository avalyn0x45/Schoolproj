//This code sucks, but forgive me, I don't use JavaScript.
import {Terminal} from './xterm.mjs';

let data = [];
window.data = data;

let wasm = null;
let mem = null;
var term = new Terminal();
window.term = term;

let telem = document.getElementById('term');
term.open(telem);

//term.resize(Math.floor((term.cols / telem.offsetWidth) * screen.width), Math.floor((term.rows / telem.offsetHeight) * screen.height))
term.resize(200,60);

telem.addEventListener("click", (e) => telem.requestFullscreen());
term.onKey((key, ev) => {
    if (key.key.length == 1) {
        wasm.instance.exports.onKey(key.key.codePointAt(0));
    } else if (key.key == "\x1b[A") {
        wasm.instance.exports.upKey();
    } else if (key.key == "\x1b[B") {
        wasm.instance.exports.downKey();
    } else if (key.key == "\x1b[C") {
        wasm.instance.exports.rightKey();
    } else if (key.key == "\x1b[D") {
        wasm.instance.exports.leftKey();
    }
});

var audioCtx = new(window.AudioContext || window.webkitAudioContext)();

function umem() {
    mem = wasm.instance.exports.memory.buffer;
}

function pdata(pointer, length) {
    umem();
    let index = data.indexOf(null);
    if (index == -1) {
        index = data.length;
    }
    let slice = mem.slice(pointer, pointer + length);
    let u8a = new Uint8Array(slice);
    data[index] = u8a;
    return index;
}

function exec(aptr) {
    eval(new TextDecoder().decode(data[aptr]));
}
function setcookie(aptr) {
    document.cookie = new TextDecoder().decode(data[aptr]);
}

function getcookie(aptr) {
    let index = data.findIndex((x) => x == null);
    if (index == -1) {
        index = data.length;
    }
    const cookiename = new TextDecoder().decode(data[aptr]);
}

function free(aptr) {
    data[aptr] = null;
}

function print(aptr) {
    term.write(data[aptr]);
}

function log(aptr) {
    console.log(new TextDecoder().decode(data[aptr]));
}

function read(aptr, index) {
    umem();
    return data[aptr][index];
}

function runWASM(aptr, timeout) {
    setTimeout(() => {
        const fnname = new TextDecoder().decode(data[aptr]);
        wasm.instance.exports[fnname]();
    }, timeout);
}

function tone(freq, time, type) {
    var oscillator = audioCtx.createOscillator();
    oscillator.type = ["sine", "square", "sawtooth", "triangle"][type];
    oscillator.frequency.value = freq;
    oscillator.connect(audioCtx.destination);
    oscillator.start();
    setTimeout(() => oscillator.stop(), time);
}

function sizex() {
    return term.cols;
}

function sizey() {
    return term.rows;
}

await WebAssembly.instantiateStreaming(fetch('inkheart.wasm'), {
    env: {
        data: pdata,
        free: free,
        print: print,
        exec: exec,
        read: read,
        run: runWASM,
        tone: tone,
        sizex: sizex,
        sizey: sizey,
        jlog: log,
        logn: (n) => console.log(n),
        sleep: (delay) => new Promise((resolve) => setTimeout(resolve, delay)),
    }
}).then(
    (obj) => {
        wasm = obj;
        window.wasm = wasm;
        mem = obj.instance.exports.memory.buffer;
        obj.instance.exports.entry();
    },
);
