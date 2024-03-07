const std = @import("std");

const Scanner = @import("deps/zig-wayland/build.zig").Scanner;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const scanner = Scanner.create(b, .{});
    scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");

    // Some of these versions may be out of date with what wlroots implements.
    // This is not a problem in practice though as long as tinywl successfully compiles.
    // These versions control Zig code generation and have no effect on anything internal
    // to wlroots. Therefore, the only thing that can happen due to a version being too
    // old is that tinywl fails to compile.
    scanner.generate("wl_compositor", 4);
    scanner.generate("wl_subcompositor", 1);
    scanner.generate("wl_shm", 1);
    scanner.generate("wl_output", 4);
    scanner.generate("wl_seat", 7);
    scanner.generate("wl_data_device_manager", 3);
    scanner.generate("xdg_wm_base", 2);

    const wayland = b.createModule(.{
        .root_source_file = scanner.result,
        .target = target,
    });
    wayland.linkSystemLibrary("wayland-server", .{});

    const xkbcommon = b.createModule(.{
        .root_source_file = .{ .path = "deps/zig-xkbcommon/src/xkbcommon.zig" },
        .target = target,
    });
    xkbcommon.linkSystemLibrary("xkbcommon", .{});

    const pixman = b.createModule(.{
        .root_source_file = .{ .path = "deps/zig-pixman/pixman.zig" },
        .target = target,
    });
    pixman.linkSystemLibrary("pixman-1", .{});

    const wlroots = b.createModule(.{
        .root_source_file = .{ .path = "../src/wlroots.zig" },
        .imports = &.{
            .{ .name = "wayland", .module = wayland },
            .{ .name = "xkbcommon", .module = xkbcommon },
            .{ .name = "pixman", .module = pixman },
        },
        .target = target,
    });
    wlroots.linkSystemLibrary("wlroots", .{});

    const tinywl = b.addExecutable(.{
        .name = "tinywl",
        .root_source_file = .{ .path = "tinywl.zig" },
        .target = target,
        .optimize = optimize,
    });

    tinywl.linkLibC();

    tinywl.root_module.addImport("wayland", wayland);
    tinywl.root_module.addImport("xkbcommon", xkbcommon);
    tinywl.root_module.addImport("wlroots", wlroots);

    // TODO: remove when https://github.com/ziglang/zig/issues/131 is implemented
    scanner.addCSource(tinywl);

    b.installArtifact(tinywl);
}
