const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;
const zwp = wayland.server.zwp;

pub const TabletPad = extern struct {
    pub const event = extern struct {
        pub const Button = extern struct {
            time_msec: u32,
            button: u32,
            state: zwp.TabletPadV2.ButtonState,
            mode: c_uint,
            group: c_uint,
        };

        pub const Ring = extern struct {
            pub const Source = enum(c_int) {
                unknown,
                finger,
            };

            time_msec: u32,
            source: Source,
            ring: u32,
            position: f64,
            mode: c_uint,
        };

        pub const Strip = extern struct {
            pub const Source = enum(c_int) {
                unknown,
                finger,
            };

            time_msec: u32,
            source: Source,
            strip: u32,
            position: f64,
            mode: c_uint,
        };
    };

    pub const Group = extern struct {
        link: wl.list.Link, // TabletPad.groups

        button_count: usize,
        buttons: [*]c_uint,

        strip_count: usize,
        strips: [*]c_uint,

        ring_count: usize,
        rings: [*]c_uint,

        mode_count: c_uint,
    };

    base: wlr.InputDevice,
    impl: *const opaque {},

    events: extern struct {
        button: wl.Signal(*event.Button),
        ring: wl.Signal(*event.Ring),
        strip: wl.Signal(*event.Strip),
        attach_tablet: wl.Signal(*wlr.TabletTool),
    },

    button_count: usize,
    ring_count: usize,
    strip_count: usize,
    groups: wl.list.Head(Group, .link),
    paths: wl.Array, // char *

    data: ?*anyopaque,
};
