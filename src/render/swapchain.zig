const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const Swapchain = extern struct {
    pub const Slot = extern struct {
        buffer: ?*wlr.Buffer,
        /// Waiting for release
        acquired: bool,

        private: extern struct {
            release: wl.Listener(void),
        },
    };

    /// `null` if destroyed
    allocator: ?*wlr.Allocator,

    width: c_int,
    height: c_int,
    format: wlr.DrmFormat,

    slots: [4]Slot,

    private: extern struct {
        allocator_destroy: wl.Listener(void),
    },

    extern fn wlr_swapchain_create(alloc: *wlr.Allocator, width: c_int, height: c_int, format: *wlr.DrmFormat) ?*Swapchain;
    pub fn create(alloc: *wlr.Allocator, width: c_int, height: c_int, format: *wlr.DrmFormat) !*Swapchain {
        return wlr_swapchain_create(alloc, width, height, format) orelse error.SwapchainCreateFailed;
    }

    extern fn wlr_swapchain_destroy(swapchain: *Swapchain) void;
    pub const destroy = wlr_swapchain_destroy;

    /// Acquire a buffer from the swap chain.
    ///
    /// The returned buffer is locked. When the caller is done with it, they must
    /// unlock it by calling `wlr.Buffer.unlock`.
    extern fn wlr_swapchain_acquire(swapchain: *Swapchain) ?*wlr.Buffer;
    pub fn acquire(swapchain: *Swapchain) !*wlr.Buffer {
        return wlr_swapchain_acquire(swapchain) orelse error.SwapchainAquireBufferFailed;
    }

    /// Returns `true` if this buffer has been created by this swapchain, and false otherwise
    extern fn wlr_swapchain_has_buffer(swapchain: *Swapchain, buffer: *wlr.Buffer) bool;
    pub const hasBuffer = wlr_swapchain_has_buffer;
};
