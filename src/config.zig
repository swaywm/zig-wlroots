const c = @cImport({
    @cInclude("wlr/config.h");
});

pub const has_eglmesaext_h = c.WLR_HAS_EGLMESAEXT_H != 0;

pub const has_systemd = c.WLR_HAS_SYSTEMD != 0;
pub const has_elogind = c.WLR_HAS_ELOGIND != 0;

pub const has_libseat = c.WLR_HAS_LIBSEAT != 0;

pub const has_x11_backend = c.WLR_HAS_X11_BACKEND != 0;

pub const has_xwayland = c.WLR_HAS_XWAYLAND != 0;

pub const has_xcb_errors = c.WLR_HAS_XCB_ERRORS != 0;
pub const has_xcb_iccm = c.WLR_HAS_XCB_ICCCM != 0;
