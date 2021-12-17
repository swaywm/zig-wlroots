const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Presentation = extern struct {
    global: *wl.Global,
    // TODO: use std.os.clockid_t when available.
    clock: c_int,

    events: extern struct {
        destroy: wl.Signal(*wlr.Presentation),
    },

    server_destroy: wl.Listener(*wl.Server),

    extern fn wlr_presentation_create(server: *wl.Server, backend: *wlr.Backend) ?*wlr.Presentation;
    pub fn create(server: *wl.Server, backend: *wlr.Backend) !*wlr.Presentation {
        return wlr_presentation_create(server, backend) orelse error.OutOfMemory;
    }

    extern fn wlr_presentation_surface_sampled(presentation: *wlr.Presentation, surface: *wlr.Surface) ?*wlr.PresentationFeedback;
    pub const surfaceSampled = wlr_presentation_surface_sampled;

    extern fn wlr_presentation_surface_sampled_on_output(presentation: *wlr.Presentation, surface: *wlr.Surface, output: *wlr.Output) void;
    pub const surfaceSampledOnOutput = wlr_presentation_surface_sampled_on_output;
};

pub const PresentationFeedback = extern struct {
    resources: wl.list.Head(wl.Resource, null),

    output: ?*wlr.Output,
    output_committed: bool,
    output_commit_seq: u32,

    output_commit: wl.Listener(*wlr.Output.event.Commit),
    output_present: wl.Listener(*wlr.Output.event.Present),
    output_destroy: wl.Listener(*wlr.Output),

    extern fn wlr_presentation_feedback_send_presented(feedback: *wlr.PresentationFeedback, event: *wlr.PresentationEvent) void;
    pub const sendPresented = wlr_presentation_feedback_send_presented;

    extern fn wlr_presentation_feedback_destroy(feedback: *wlr.PresentationFeedback) void;
    pub const destroy = wlr_presentation_feedback_destroy;
};

pub const PresentationEvent = extern struct {
    output: *wlr.Output,
    tv_sec: u64,
    tv_nsec: u32,
    refresh: u32,
    seq: u64,
    flags: u32,

    extern fn wlr_presentation_event_from_output(event: *wlr.PresentationEvent, output_event: *const wlr.Output.event.Present) void;
    pub const fromOutput = wlr_presentation_event_from_output;
};
