# tic80-farm :zap:

Using [Zig](https://ziglang.org/) to compile a `.wasm` that is
then imported into a [TIC-80](https://tic80.com/) cart.

## Development

File watcher can be started by calling:
```sh
zig build spy
```

Running TIC-80 (Pro) is done via:
```sh
zig build run
```

After exiting the cart, you can
`import binary zig-out/bin/cart.wasm`
and then `run` to load new code.

> [!Note]
> I've bound **button 4** to exit the cart.

