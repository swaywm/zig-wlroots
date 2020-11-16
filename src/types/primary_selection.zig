const wlr = @import("wlroots");

const wl = @import("wayland").server.wl;

pub const PrimarySelectionSource = extern struct {
    pub const Impl = extern struct {
        send: fn (source: *PrimarySelectionSource, mime_type: [*:0]const u8, fd: c_int) callconv(.C) void,
        destroy: ?fn (source: *PrimarySelectionSource) callconv(.C) void,
    };

    impl: *const Impl,

    mime_types: wl.Array,

    events: extern struct {
        destroy: wl.Signal(*PrimarySelectionSource),
    },

    data: usize,

    extern fn wlr_primary_selection_source_init(source: *PrimarySelectionSource, impl: *const PrimarySelectionSource.Impl) void;
    pub const init = wlr_primary_selection_source_init;

    extern fn wlr_primary_selection_source_destroy(source: *PrimarySelectionSource) void;
    pub const destroy = wlr_primary_selection_source_destroy;

    extern fn wlr_primary_selection_source_send(source: *PrimarySelectionSource, mime_type: [*:0]const u8, fd: c_int) void;
    pub const send = wlr_primary_selection_source_send;
};
