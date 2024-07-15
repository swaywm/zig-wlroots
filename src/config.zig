const c = @cImport(@cInclude("wlr/config.h"));

pub const has_drm_backend = c.WLR_HAS_DRM_BACKEND != 0;
pub const has_libinput_backend = c.WLR_HAS_LIBINPUT_BACKEND != 0;
pub const has_x11_backend = c.WLR_HAS_X11_BACKEND != 0;

pub const has_gles2_renderer = c.WLR_HAS_GLES2_RENDERER != 0;
pub const has_vulkan_renderer = c.WLR_HAS_VULKAN_RENDERER != 0;

pub const has_gbm_allocator = c.WLR_HAS_GBM_ALLOCATOR != 0;

pub const has_xwayland = c.WLR_HAS_XWAYLAND != 0;

pub const has_session = c.WLR_HAS_SESSION != 0;

pub const has_color_management = c.WLR_HAS_COLOR_MANAGEMENT != 0;
