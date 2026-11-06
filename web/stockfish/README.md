# Stockfish browser engine files

Unmodified Stockfish.js **v19.0.1**, based on Stockfish 19, by Nathan Rugg and the Stockfish contributors. This is the **lite, single-threaded** build from the [upstream release](https://github.com/nmrugg/stockfish.js/releases/tag/v19.0.1).

## Status

These files are bundled in preparation for issue #40. They are not connected to the Flutter game yet. Computer mode still uses random legal moves.

## Runtime files

Keep `stockfish-19-lite-single.js` and `stockfish-19-lite-single.wasm` together. This build embeds its evaluation network; the browser does not need to load the separate source network file. It does not require cross-origin isolation headers.

Flutter copies the contents of `web/` into the web build. Load the JavaScript as a Web Worker from `stockfish/stockfish-19-lite-single.js` relative to the app's base URL. Serve JavaScript as `text/javascript` and WebAssembly as `application/wasm`; opening the files directly from Finder is not sufficient.

The upstream browser handshake is:

```javascript
const engine = new Worker('stockfish/stockfish-19-lite-single.js');
engine.onmessage = (event) => console.log(event.data);
engine.postMessage('uci'); // Wait for uciok before configuring the engine.
```

Gameplay integration must also wait for `readyok` after sending `isready`, handle engine errors and cancellation, and terminate the worker when done.

## License and source

The engine is distributed under GNU GPL version 3. See [Copying.txt](Copying.txt) for the complete license and warranty disclaimer, and [AUTHORS](AUTHORS) for contributor acknowledgments. Preserve these notices when redistributing these files.

The matching [source archive](source/stockfish.js-v19.0.1.tar.gz), including build scripts, and [lite evaluation network](source/nn-61e7af4bb97d.nnue) are provided alongside the binaries. The source directory is for rebuilding; its files are not downloaded during normal gameplay. Upstream source is also available at the [v19.0.1 tag](https://github.com/nmrugg/stockfish.js/tree/v19.0.1).

To rebuild, extract the archive, place `nn-61e7af4bb97d.nnue` in its `src/` folder, and follow the included README and build script. The release documents Emscripten 6.0.9. With that toolchain active, Node.js and the required build tools installed, the lite single-threaded target is:

```bash
node build.js --lite --single-threaded --no-split
```

The source and network are supplied for rebuilding; we have not reproduced the upstream build locally. See `provenance.json` for download locations, sizes and SHA-256 checksums. The JavaScript and WebAssembly checksums were verified against the upstream release metadata before committing.
