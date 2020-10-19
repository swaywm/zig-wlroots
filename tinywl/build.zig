const std = @import("std");
const Builder = std.build.Builder;
const Step = std.build.Step;
const Pkg = std.build.Pkg;

pub fn build(b: *Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const scan_protocols = ScanProtocolsStep.create(b);

    const wayland = Pkg{ .name = "wayland", .path = "../../zig-wayland/wayland.zig" };
    const xkbcommon = Pkg{ .name = "xkbcommon", .path = "../../zig-xkbcommon/src/xkbcommon.zig" };
    const pixman = Pkg{ .name = "pixman", .path = "../../zig-pixman/pixman.zig" };
    const wlroots = Pkg{
        .name = "wlroots",
        .path = "../src/wlroots.zig",
        .dependencies = &[_]Pkg{ wayland, xkbcommon, pixman },
    };

    const exe = b.addExecutable("tinywl", "tinywl.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.linkLibC();

    exe.addPackage(wayland);
    exe.linkSystemLibrary("wayland-server");
    exe.step.dependOn(&scan_protocols.step);
    exe.addCSourceFile("xdg_shell.c", &[_][]const u8{"-std=c99"});

    exe.addPackage(xkbcommon);
    exe.linkSystemLibrary("xkbcommon");

    exe.addPackage(wlroots);
    exe.linkSystemLibrary("wlroots");
    exe.linkSystemLibrary("pixman-1");

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

const ScanProtocolsStep = struct {
    builder: *Builder,
    step: Step,

    fn create(builder: *Builder) *ScanProtocolsStep {
        const self = builder.allocator.create(ScanProtocolsStep) catch @panic("out of memory");
        self.* = init(builder);
        return self;
    }

    fn init(builder: *Builder) ScanProtocolsStep {
        return ScanProtocolsStep{
            .builder = builder,
            .step = Step.init(.Custom, "Scan Protocols", builder.allocator, make),
        };
    }

    fn make(step: *Step) !void {
        const self = @fieldParentPtr(ScanProtocolsStep, "step", step);

        const protocol_dir = std.fmt.trim(try self.builder.exec(
            &[_][]const u8{ "pkg-config", "--variable=pkgdatadir", "wayland-protocols" },
        ));

        const xml_path = try std.fs.path.join(self.builder.allocator, &[_][]const u8{ protocol_dir, "stable/xdg-shell/xdg-shell.xml" });

        // Extension is .xml, so slice off the last 4 characters
        const basename = std.fs.path.basename(xml_path);
        const basename_no_ext = basename[0..(basename.len - 4)];
        _ = try self.builder.exec(
            &[_][]const u8{ "wayland-scanner", "private-code", xml_path, "xdg_shell.c" },
        );
    }
};
