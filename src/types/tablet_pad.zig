const wlr = @import("../wlroots.zig");

const wl = @import("wayland").server.wl;

pub const TabletPad = extern struct {
    pub const event = struct {
        pub const Button = extern struct {
            time_msec: u32,
            button: u32,
            state: wl.Pointer.ButtonState,
            mode: isize,
            group: isize,
        };

        pub const Ring = extern struct {
            pub const Source = extern enum {
                unknown = 1,
                finger,
            };

            time_msec: u32,
            source: Source,
            ring: u32,
            position: f64,
            mode: isize,
        };

        pub const Strip = extern struct {
            pub const Source = extern enum {
                unknown = 1,
                finger,
            };

            time_msec: u32,
            source: Source,
            strip: u32,
            position: f64,
            mode: isize,
        };
    };

    const Impl = opaque {};

    impl: *const Impl,

    events: extern struct {
        button: wl.Signal(*event.Button),
        ring: wl.Signal(*event.Ring),
        strip: wl.Signal(*event.Strip),
        attach_tablet: wl.Signal(*wlr.TabletTool),
    },

    button_count: usize,
    ring_count: usize,
    strip_count: usize,

    groups: wl.list.Link,
    // wl.Array of *u8
    paths: wl.Array,

    data: usize,
};
