pub const Importance = enum(c_int) {
    silent = 0,
    err = 1,
    info = 2,
    debug = 3,
    last,
};

// TODO: callback is really a
//    typedef void (*wlr_log_func_t)(enum wlr_log_importance importance,
//     const char *fmt, va_list args);
// but zig doesn't have good varargs support yet, so use a void pointer for
// now and always pass null, indicating that the default log function
// should be used.
extern fn wlr_log_init(verbosity: Importance, callback: ?*anyopaque) void;
pub fn init(verbosity: Importance) void {
    wlr_log_init(verbosity, null);
}

extern fn wlr_log_get_verbosity() Importance;
pub const getVerbosity = wlr_log_get_verbosity;
