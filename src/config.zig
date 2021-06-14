const c = @cImport({
    @cInclude("wlr/config.h");
});

pub const has_x11_backend = c.WLR_HAS_X11_BACKEND != 0;

pub const has_gles2_renderer = c.WLR_HAS_GLES2_RENDERER != 0;

pub const has_xwayland = c.WLR_HAS_XWAYLAND != 0;
