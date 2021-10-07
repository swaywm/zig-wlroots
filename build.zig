const std = @import("std");
const Builder = std.build.Builder;
const Pkg = std.build.Pkg;

const ScanProtocolsStep = @import("tinywl/deps/zig-wayland/build.zig").ScanProtocolsStep;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const scanner = ScanProtocolsStep.create(b);
    scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");
    scanner.addProtocolPath("protocol/wlr-layer-shell-unstable-v1.xml");
    scanner.addProtocolPath("protocol/wlr-output-power-management-unstable-v1.xml");
    scanner.addSystemProtocol("unstable/pointer-constraints/pointer-constraints-unstable-v1.xml");
    scanner.addSystemProtocol("unstable/pointer-gestures/pointer-gestures-unstable-v1.xml");
    scanner.addSystemProtocol("unstable/xdg-output/xdg-output-unstable-v1.xml");

    const wayland = Pkg{
        .name = "wayland",
        .path = .{ .generated = &scanner.result },
    };
    const xkbcommon = Pkg{
        .name = "xkbcommon",
        .path = .{ .path = "tinywl/deps/zig-xkbcommon/src/xkbcommon.zig" },
    };
    const pixman = Pkg{
        .name = "pixman",
        .path = .{ .path = "tinywl/deps/zig-pixman/pixman.zig" },
    };

    const wlr_test = b.addTest("src/wlroots.zig");
    wlr_test.setTarget(target);
    wlr_test.setBuildMode(mode);

    wlr_test.linkLibC();

    wlr_test.addPackage(wayland);
    wlr_test.linkSystemLibrary("wayland-server");
    wlr_test.step.dependOn(&scanner.step);
    // TODO: remove when https://github.com/ziglang/zig/issues/131 is implemented
    scanner.addCSource(wlr_test);

    wlr_test.addPackage(xkbcommon);
    wlr_test.linkSystemLibrary("xkbcommon");

    wlr_test.addPackage(pixman);
    wlr_test.linkSystemLibrary("pixman-1");

    wlr_test.linkSystemLibrary("wlroots");

    const test_step = b.step("test", "Run the tests");
    test_step.dependOn(&wlr_test.step);
}
