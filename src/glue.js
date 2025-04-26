let data = [];
let mem = null;

function data(pointer, length) {
    let index = data.findIndex((x) => x == null);
    let slice = mem.slice(pointer, pointer + length);
    let u8a = new Uint8Array(slice);
    data[index] = u8a;
    return index;
}

function free(aptr) {
    data[aptr] = null;
}

function print(aptr) {
    console.log(new TextDecoder().decode(data[aptr]));
}

await WebAssembly.instantiateStreaming(fetch('add.wasm'), {
    env: {
        data: data,
        free: free,
        print: print,
    }
}).then(
    (obj) => {
        mem = obj.instance.exports.memory;
        obj.instance.exports.entry();
    },
);
