const wlr = @import("../wlroots.zig");

const std = @import("std");
const posix = std.posix;

const wayland = @import("wayland");
const wl = wayland.server.wl;
const zwp = wayland.server.zwp;

pub const DmabufBufferV1 = extern struct {
    base: wlr.Buffer,

    resource: ?*wl.Resource,
    attributes: wlr.DmabufAttributes,

    private: extern struct {
        release: wl.Listener(void),
    },

    extern fn wlr_dmabuf_v1_buffer_try_from_buffer_resource(buffer_resource: *wl.Resource) ?*DmabufBufferV1;
    pub const tryFromBufferResource = wlr_dmabuf_v1_buffer_try_from_buffer_resource;
};

pub const LinuxDmabufFeedbackV1 = extern struct {
    pub const Tranche = extern struct {
        target_device: posix.dev_t,
        flags: zwp.LinuxDmabufFeedbackV1.TrancheFlags,
        formats: wlr.DrmFormatSet,
    };

    main_device: posix.dev_t,
    tranches: wl.Array,

    private: extern struct {
        default_feedback: *LinuxDmabufFeedbackV1Compiled,
        default_formats: wlr.DrmFormatSet,
        surfaces: wl.list.Link,

        main_device_fd: c_int,

        server_destroy: wl.Listener(void),

        check_dmabuf_callback: ?*anyopaque,
        check_dmabuf_callback_data: ?*anyopaque,
    },

    extern fn wlr_linux_dmabuf_feedback_add_tranche(feedback: *LinuxDmabufFeedbackV1) ?*Tranche;
    pub fn addTranche(feedback: *LinuxDmabufFeedbackV1) !*Tranche {
        return wlr_linux_dmabuf_feedback_add_tranche(feedback) orelse error.OutOfMemory;
    }

    extern fn wlr_linux_dmabuf_feedback_v1_finish(feedback: *LinuxDmabufFeedbackV1) void;
    pub const finish = wlr_linux_dmabuf_feedback_v1_finish;

    pub const InitOptions = extern struct {
        main_renderer: *wlr.Renderer,
        scanout_primary_output: ?*wlr.Output,
        // TODO: Bind wlr_output_layer and related structs
        output_layer_feedback_event: ?*const anyopaque,
    };
    extern fn wlr_linux_dmabuf_feedback_v1_init_with_options(feedback: LinuxDmabufFeedbackV1, options: InitOptions) bool;
    pub const initWithOptions = wlr_linux_dmabuf_feedback_v1_init_with_options;
};

pub const LinuxDmabufFeedbackV1Compiled = opaque {};

pub const LinuxDmabufV1 = extern struct {
    global: *wl.Global,

    events: extern struct {
        destroy: wl.Signal(*LinuxDmabufV1),
    },

    extern fn wlr_linux_dmabuf_v1_create(server: *wl.Server, version: u32, default_feedback: *const LinuxDmabufFeedbackV1) ?*LinuxDmabufV1;
    pub fn create(server: *wl.Server, version: u32, default_feedback: *const LinuxDmabufFeedbackV1) !*LinuxDmabufV1 {
        return wlr_linux_dmabuf_v1_create(server, version, default_feedback) orelse error.OutOfMemory;
    }

    extern fn wlr_linux_dmabuf_v1_create_with_renderer(server: *wl.Server, version: u32, renderer: *wlr.Renderer) ?*LinuxDmabufV1;
    pub fn createWithRenderer(server: *wl.Server, version: u32, renderer: *wlr.Renderer) !*LinuxDmabufV1 {
        return wlr_linux_dmabuf_v1_create_with_renderer(server, version, renderer) orelse error.OutOfMemory;
    }

    extern fn wlr_linux_dmabuf_v1_set_surface_feedback(linux_dmabuf: *LinuxDmabufV1, surface: *wlr.Surface, feedback: ?*const LinuxDmabufFeedbackV1) bool;
    pub const setSurfaceFeedback = wlr_linux_dmabuf_v1_set_surface_feedback;
};
