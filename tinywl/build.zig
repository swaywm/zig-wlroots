const std = @import("std");
const Builder = std.build.Builder;
const Pkg = std.build.Pkg;

const ScanProtocolsStep = @import("deps/zig-wayland/build.zig").ScanProtocolsStep;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const scanner = ScanProtocolsStep.create(b);
    scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");

    const wayland = Pkg{
        .name = "wayland",
        .path = .{ .generated = &scanner.result },
    };
    const xkbcommon = Pkg{
        .name = "xkbcommon",
        .path = .{ .path = "deps/zig-xkbcommon/src/xkbcommon.zig" },
    };
    const pixman = Pkg{
        .name = "pixman",
        .path = .{ .path = "deps/zig-pixman/pixman.zig" },
    };
    const wlroots = Pkg{
        .name = "wlroots",
        .path = .{ .path = "../src/wlroots.zig" },
        .dependencies = &[_]Pkg{ wayland, xkbcommon, pixman },
    };

    const exe = b.addExecutable("tinywl", "tinywl.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.linkLibC();

    exe.addPackage(wayland);
    exe.linkSystemLibrary("wayland-server");
    exe.step.dependOn(&scanner.step);
    // TODO: remove when https://github.com/ziglang/zig/issues/131 is implemented
    scanner.addCSource(exe);

    exe.addPackage(xkbcommon);
    exe.linkSystemLibrary("xkbcommon");

    exe.addPackage(wlroots);
    exe.linkSystemLibrary("wlroots");
    exe.linkSystemLibrary("pixman-1");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the compositor");
    run_step.dependOn(&run_cmd.step);
}
