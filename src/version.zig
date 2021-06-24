const c = @cImport(@cInclude("wlr/version.h"));

pub const str = c.WLR_VERSION_STR;

pub const major = c.WLR_VERSION_MAJOR;
pub const minor = c.WLR_VERSION_MINOR;
pub const micro = c.WLR_VERSION_MICRO;

pub const num = c.WLR_VERSION_NUM;
