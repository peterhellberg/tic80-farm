const std = @import("std");

pub fn build(b: *std.Build) !void {
    const exe = b.addExecutable(.{
        .name = "cart",
        .root_source_file = b.path("src/main.zig"),
        .target = b.resolveTargetQuery(.{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
        }),
        .optimize = .ReleaseSmall,
    });

    // Add the tic module to the executable
    exe.root_module.addImport("tic", b.dependency("tic", .{}).module("tic"));

    // No entry point in the WASM
    exe.entry = .disabled;

    // All the memory below 96kb is reserved for TIC
    // and memory mapped I/O so our own usage must
    // start above the 96kb mark
    exe.global_base = 96 * 1024;
    exe.stack_size = 8192;

    // Four WASM memory pages
    const memory: u64 = 65536 * 4;
    exe.initial_memory = memory;
    exe.max_memory = memory;
    exe.import_memory = true;

    // Export symbols for use by TIC
    exe.root_module.export_symbol_names = &[_][]const u8{
        "BOOT",
        "TIC",
    };

    // Run command that requires you to have a TIC-80 Pro binary
    const run_cmd = b.addSystemCommand(&[_][]const u8{
        "tic80-pro",
        "--skip",
        "--fs",
        ".",
        "--keepcmd",
        "cart.wasmp",
        "--cmd",
        "load cart.wasmp &" ++
            " import binary zig-out/bin/cart.wasm &" ++
            " save &" ++
            " run",
    });
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the cart in TIC-80 Pro");
    run_step.dependOn(&run_cmd.step);

    const spy_cmd = b.addSystemCommand(&[_][]const u8{
        "spy",
        "--exc",
        "zig-cache",
        "--inc",
        "**/*.zig",
        "-q",
        "clear-zig",
        "build",
    });
    const spy_step = b.step("spy", "Run spy watching for file changes");
    spy_step.dependOn(&spy_cmd.step);

    b.installArtifact(exe);
}
