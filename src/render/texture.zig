const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

const pixman = @import("pixman");

pub const Texture = extern struct {
    const TextureAttribs = extern struct {
        target: c_uint,
        tex: c_uint,

        hasAlpha: bool,
    };

    const Impl = opaque {};

    impl: *const Impl,
    width: u32,
    height: u32,

    extern fn wlr_texture_is_gles2(renderer: *wlr.Renderer) bool;
    pub const isGles2 = wlr_texture_is_gles2;

    extern fn wlr_texture_from_pixels(renderer: *wlr.Renderer, wl_fmt: wl.Shm.Format, stride: u32, width: u32, height: u32, data: *const anyopaque) ?*Texture;
    pub const fromPixels = wlr_texture_from_pixels;

    extern fn wlr_texture_from_dmabuf(renderer: *wlr.Renderer, attribs: *wlr.DmabufAttributes) ?*Texture;
    pub const fromDmabuf = wlr_texture_from_dmabuf;

    extern fn wlr_texture_update_from_buffer(texture: *Texture, buffer: *wlr.Buffer, damage: *pixman.Region32) bool;
    pub const updateFromBuffer = wlr_texture_update_from_buffer;

    extern fn wlr_texture_destroy(texture: *Texture) void;
    pub const destroy = wlr_texture_destroy;

    extern fn wlr_texture_from_buffer(renderer: *wlr.Renderer, buffer: *wlr.Buffer) ?*Texture;
    pub const fromBuffer = wlr_texture_from_buffer;

    extern fn wlr_gles2_texture_get_attribs(texture: *wlr.Texture, attribs: *TextureAttribs) void;
    pub const getAttributes = wlr_gles2_texture_get_attribs;
};
