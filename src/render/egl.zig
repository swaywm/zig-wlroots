pub const Egl = opaque {
    extern fn wlr_egl_create_with_context(display: *Display, context: *Context) ?*Egl;
    pub fn createWithContext(display: *Display, context: *Context) !*Egl {
        return wlr_egl_create_with_context(display, context) orelse return error.EglCreateFailed;
    }

    extern fn wlr_egl_get_display(egl: *Egl) *Display;
    pub const getDisplay = wlr_egl_get_display;

    extern fn wlr_egl_get_context(egl: *Egl) *Context;
    pub const getContext = wlr_egl_get_context;

    pub const Display = opaque {};
    pub const Context = opaque {};
};
