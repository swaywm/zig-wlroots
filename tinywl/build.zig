const std = @import("std");

const Scanner = @import("deps/zig-wayland/build.zig").Scanner;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const scanner = Scanner.create(b, .{});
    scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");

    const wayland = b.createModule(.{ .source_file = scanner.result });
    const xkbcommon = b.createModule(.{
        .source_file = .{ .path = "deps/zig-xkbcommon/src/xkbcommon.zig" },
    });
    const pixman = b.createModule(.{
        .source_file = .{ .path = "deps/zig-pixman/pixman.zig" },
    });
    const wlroots = b.createModule(.{
        .source_file = .{ .path = "../src/wlroots.zig" },
        .dependencies = &.{
            .{ .name = "wayland", .module = wayland },
            .{ .name = "xkbcommon", .module = xkbcommon },
            .{ .name = "pixman", .module = pixman },
        },
    });

    // These must be manually kept in sync with the versions wlroots supports
    // until wlroots gives the option to request a specific version.
    scanner.generate("wl_compositor", 4);
    scanner.generate("wl_subcompositor", 1);
    scanner.generate("wl_shm", 1);
    scanner.generate("wl_output", 4);
    scanner.generate("wl_seat", 7);
    scanner.generate("wl_data_device_manager", 3);
    scanner.generate("xdg_wm_base", 2);

    const tinywl = b.addExecutable(.{
        .name = "tinywl",
        .root_source_file = .{ .path = "tinywl.zig" },
        .target = target,
        .optimize = optimize,
    });

    tinywl.linkLibC();

    tinywl.addModule("wayland", wayland);
    tinywl.linkSystemLibrary("wayland-server");

    // TODO: remove when https://github.com/ziglang/zig/issues/131 is implemented
    scanner.addCSource(tinywl);

    tinywl.addModule("xkbcommon", xkbcommon);
    tinywl.linkSystemLibrary("xkbcommon");

    tinywl.addModule("wlroots", wlroots);
    tinywl.linkSystemLibrary("scenefx");
    tinywl.linkSystemLibrary("wlroots");
    tinywl.linkSystemLibrary("pixman-1");

    b.installArtifact(tinywl);
}
