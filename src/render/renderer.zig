const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Renderer = extern struct {
    const Impl = opaque {};

    impl: *const Impl,
    rendering: bool,
    events: extern struct {
        destroy: wl.Signal(*Renderer),
    },

    // wlr_renderer functions:

    extern fn wlr_renderer_autocreate(backend: *wlr.Backend) ?*Renderer;
    pub fn autocreate(backend: *wlr.Backend) !*Renderer {
        return wlr_renderer_autocreate(backend) orelse error.RendererCreateFailed;
    }

    extern fn wlr_renderer_begin(renderer: *Renderer, width: u32, height: u32) void;
    pub const begin = wlr_renderer_begin;

    pub extern fn wlr_renderer_end(renderer: *Renderer) void;
    pub const end = wlr_renderer_end;

    extern fn wlr_renderer_clear(renderer: *Renderer, color: *const [4]f32) void;
    pub const clear = wlr_renderer_clear;

    extern fn wlr_renderer_init_wl_display(renderer: *Renderer, server: *wl.Server) bool;
    pub fn initServer(renderer: *Renderer, server: *wl.Server) !void {
        if (!wlr_renderer_init_wl_display(renderer, server)) {
            return error.RenderInitFailed;
        }
    }

    extern fn wlr_resource_get_buffer_size(resource: *wl.Buffer, renderer: *wlr.Renderer, width: *c_int, height: *c_int) bool;
    pub inline fn getBufferSize(renderer: *wlr.Renderer, resource: *wl.Buffer, width: *c_int, height: *c_int) bool {
        return wlr_resource_get_buffer_size(resource, renderer, width, height);
    }

    extern fn wlr_renderer_scissor(renderer: *Renderer, box: ?*wlr.Box) void;
    pub const scissor = wlr_renderer_scissor;

    extern fn wlr_renderer_get_shm_texture_formats(renderer: *Renderer, len: *usize) [*]const u32;
    pub const getShmTextureFormats = wlr_renderer_get_shm_texture_formats;

    extern fn wlr_renderer_resource_is_wl_drm_buffer(renderer: *Renderer, buffer: *wl.Buffer) bool;
    pub const resourceIsWlDrmBuffer = wlr_renderer_resource_is_wl_drm_buffer;

    extern fn wlr_renderer_wl_drm_buffer_get_size(
        renderer: *Renderer,
        buffer: *wl.Buffer,
        width: *c_int,
        height: *c_int,
    ) void;
    pub const wlDrmBufferGetSize = wlr_renderer_wl_drm_buffer_get_size;

    // TODO:
    //extern fn wlr_renderer_get_dmabuf_texture_formats(renderer: *Renderer) [*c]const struct_wlr_drm_format_set;
    //pub const getDmabufFormats = wlr_renderer_get_dmabuf_formats;

    extern fn wlr_renderer_read_pixels(
        renderer: *Renderer,
        fmt: u32,
        flags: ?*u32,
        stride: u32,
        width: u32,
        height: u32,
        src_x: u32,
        src_y: u32,
        dst_x: u32,
        dst_y: u32,
        data: [*]u8,
    ) bool;
    pub const readPixels = wlr_renderer_read_pixels;

    extern fn wlr_renderer_blit_dmabuf(
        renderer: *Renderer,
        dst: *wlr.DmabufAttributes,
        src: *wlr.DmabufAttributes,
    ) bool;
    pub const blitDmabuf = wlr_renderer_blit_dmabuf;

    extern fn wlr_renderer_get_drm_fd(renderer: *Renderer) c_int;
    pub const getDrmFd = wlr_renderer_get_drm_fd;

    extern fn wlr_renderer_destroy(renderer: *Renderer) void;
    pub const destroy = wlr_renderer_destroy;

    // wlr_render functions:

    extern fn wlr_render_texture(
        renderer: *Renderer,
        texture: *wlr.Texture,
        projection: *const [9]f32,
        x: c_int,
        y: c_int,
        alpha: f32,
    ) bool;
    pub fn renderTexture(
        renderer: *Renderer,
        texture: *wlr.Texture,
        projection: *const [9]f32,
        x: c_int,
        y: c_int,
        alpha: f32,
    ) !void {
        if (!wlr_render_texture(renderer, texture, projection, x, y, alpha))
            return error.RenderFailed;
    }

    extern fn wlr_render_texture_with_matrix(
        renderer: *Renderer,
        texture: *wlr.Texture,
        matrix: *const [9]f32,
        alpha: f32,
    ) bool;
    pub fn renderTextureWithMatrix(
        renderer: *Renderer,
        texture: *wlr.Texture,
        matrix: *const [9]f32,
        alpha: f32,
    ) !void {
        if (!wlr_render_texture_with_matrix(renderer, texture, matrix, alpha))
            return error.RenderFailed;
    }

    extern fn wlr_render_subtexture_with_matrix(
        renderer: *Renderer,
        texture: *wlr.Texture,
        box: *const wlr.FBox,
        matrix: *const [9]f32,
        alpha: f32,
    ) bool;
    pub fn renderSubtextureWithMatrix(
        renderer: *Renderer,
        texture: *wlr.Texture,
        box: *const wlr.FBox,
        matrix: *const [9]f32,
        alpha: f32,
    ) !void {
        if (!wlr_render_subtexture_with_matrix(renderer, texture, box, matrix, alpha))
            return error.RenderFailed;
    }

    extern fn wlr_render_rect(
        renderer: *Renderer,
        box: *const wlr.Box,
        color: *const [4]f32,
        projection: *const [9]f32,
    ) void;
    pub const renderRect = wlr_render_rect;

    extern fn wlr_render_quad_with_matrix(
        renderer: *Renderer,
        color: *const [4]f32,
        matrix: *const [9]f32,
    ) void;
    pub const renderQuadWithMatrix = wlr_render_quad_with_matrix;

    extern fn wlr_render_ellipse(
        renderer: *Renderer,
        box: *const wlr.Box,
        color: *const [4]f32,
        projection: *const [9]f32,
    ) void;
    pub const renderEllipse = wlr_render_ellipse;

    extern fn wlr_render_ellipse_with_matrix(
        renderer: *Renderer,
        color: *const [4]f32,
        matrix: *const [9]f32,
    ) void;
    pub const renderEllipseWithMatrix = wlr_render_ellipse_with_matrix;
};
