const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("wlroots", .{
        .root_source_file = b.path("src/wlroots.zig"),
    });

    const enable_tests = b.option(bool, "enable-tests", "allow running tests") orelse false;

    // Hack to allow making all dependencies required for tests lazy.
    if (!enable_tests) return;

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const Scanner = (b.lazyImport(@This(), "wayland") orelse return).Scanner;

    const scanner = Scanner.create(b, .{});

    scanner.addSystemProtocol("stable/xdg-shell/xdg-shell.xml");
    scanner.addSystemProtocol("unstable/pointer-constraints/pointer-constraints-unstable-v1.xml");
    scanner.addSystemProtocol("unstable/pointer-gestures/pointer-gestures-unstable-v1.xml");
    scanner.addSystemProtocol("unstable/xdg-decoration/xdg-decoration-unstable-v1.xml");
    scanner.addSystemProtocol("unstable/tablet/tablet-unstable-v2.xml");
    scanner.addSystemProtocol("staging/ext-session-lock/ext-session-lock-v1.xml");
    scanner.addSystemProtocol("unstable/linux-dmabuf/linux-dmabuf-unstable-v1.xml");
    scanner.addSystemProtocol("staging/cursor-shape/cursor-shape-v1.xml");
    scanner.addSystemProtocol("staging/tearing-control/tearing-control-v1.xml");
    scanner.addSystemProtocol("staging/content-type/content-type-v1.xml");
    scanner.addSystemProtocol("staging/ext-image-copy-capture/ext-image-copy-capture-v1.xml");

    scanner.addCustomProtocol(b.path("protocol/wlr-layer-shell-unstable-v1.xml"));
    scanner.addCustomProtocol(b.path("protocol/wlr-output-power-management-unstable-v1.xml"));

    // These must be manually kept in sync with the versions wlroots supports
    // until wlroots gives the option to request a specific version.
    scanner.generate("wl_compositor", 4);
    scanner.generate("wl_subcompositor", 1);
    scanner.generate("wl_shm", 1);
    scanner.generate("wl_output", 4);
    scanner.generate("wl_seat", 7);
    scanner.generate("wl_data_device_manager", 3);

    scanner.generate("xdg_wm_base", 2);

    scanner.generate("ext_session_lock_manager_v1", 1);
    scanner.generate("ext_image_copy_capture_manager_v1", 1);

    scanner.generate("zwp_pointer_gestures_v1", 3);
    scanner.generate("zwp_pointer_constraints_v1", 1);
    scanner.generate("zxdg_decoration_manager_v1", 1);
    scanner.generate("zwp_tablet_manager_v2", 1);
    scanner.generate("zwp_linux_dmabuf_v1", 4);
    scanner.generate("wp_cursor_shape_manager_v1", 1);
    scanner.generate("wp_tearing_control_manager_v1", 1);
    scanner.generate("wp_content_type_manager_v1", 1);

    scanner.generate("zwlr_layer_shell_v1", 4);
    scanner.generate("zwlr_output_power_manager_v1", 1);

    const wayland = b.createModule(.{ .root_source_file = scanner.result });
    const xkbcommon = (b.lazyDependency("xkbcommon", .{}) orelse return).module("xkbcommon");
    const pixman = (b.lazyDependency("pixman", .{}) orelse return).module("pixman");

    const wlr_test = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/wlroots.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    wlr_test.linkLibC();

    wlr_test.root_module.addImport("wayland", wayland);
    wlr_test.linkSystemLibrary("wayland-server");

    wlr_test.root_module.addImport("xkbcommon", xkbcommon);
    wlr_test.linkSystemLibrary("xkbcommon");

    wlr_test.root_module.addImport("pixman", pixman);
    wlr_test.linkSystemLibrary("pixman-1");

    wlr_test.linkSystemLibrary("wlroots-0.19");

    const test_step = b.step("test", "Run the tests");
    test_step.dependOn(&wlr_test.step);
}
