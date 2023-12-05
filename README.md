# tic80-farm :carrot:

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

> [!Note]
> Reload the cart using `Ctrl-R`

