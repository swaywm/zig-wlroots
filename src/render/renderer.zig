const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Renderer = extern struct {
    const Impl = opaque {};

    pub const CreateFn = fn (
        egl: *wlr.Egl,
        platform: c_uint, // EGLenum
        remote_display: ?*c_void,
        config_attribs: *i32, // EGLint
        visual_id: i32, // EGLint
    ) callconv(.C) ?*Renderer;

    impl: *const Impl,
    rendering: bool,
    events: extern struct {
        destroy: wl.Signal(*Renderer),
    },

    // TODO: int types
    extern fn wlr_renderer_begin(r: *Renderer, width: c_int, height: c_int) void;
    pub const begin = wlr_renderer_begin;

    pub extern fn wlr_renderer_end(r: *Renderer) void;
    pub const end = wlr_renderer_end;

    extern fn wlr_renderer_clear(r: *Renderer, color: *const [4]f32) void;
    pub const clear = wlr_renderer_clear;

    extern fn wlr_renderer_init_wl_display(r: *Renderer, server: *wl.Server) bool;
    pub fn initServer(r: *Renderer, server: *wl.Server) !void {
        if (!wlr_renderer_init_wl_display(r, server)) {
            return error.RenderInitFailure;
        }
    }

    extern fn wlr_resource_get_buffer_size(resource: *wl.Buffer, renderer: *wlr.Renderer, width: *c_int, height: *c_int) bool;
    pub inline fn getBufferSize(renderer: *wlr.Renderer, resource: *wl.Buffer, width: *c_int, height: *c_int) bool {
        return wlr_resource_get_buffer_size(resource, renderer, width, height);
    }

    extern fn wlr_render_texture_with_matrix(r: *Renderer, texture: *wlr.Texture, matrix: *const [9]f32, alpha: f32) bool;
    pub fn renderTextureWithMatrix(r: *Renderer, texture: *wlr.Texture, matrix: *const [9]f32, alpha: f32) !void {
        if (!wlr_render_texture_with_matrix(r, texture, matrix, alpha)) {
            return error.RenderFailure;
        }
    }
};
