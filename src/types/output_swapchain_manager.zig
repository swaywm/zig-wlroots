const wlr = @import("../wlroots.zig");

const wayland = @import("wayland");
const wl = wayland.server.wl;

pub const OutputSwapchainManager = extern struct {
    backend: *wlr.Backend,

    private: extern struct {
        outputs: wl.Array,
    },

    extern fn wlr_output_swapchain_manager_init(manager: *OutputSwapchainManager, backend: *wlr.Backend) void;
    pub const init = wlr_output_swapchain_manager_init;

    extern fn wlr_output_swapchain_manager_prepare(manager: *OutputSwapchainManager, states: [*]const wlr.Backend.OutputState, states_len: usize) bool;
    pub fn prepare(manager: *OutputSwapchainManager, states: []const wlr.Backend.OutputState) bool {
        return wlr_output_swapchain_manager_prepare(manager, states.ptr, states.len);
    }

    extern fn wlr_output_swapchain_manager_get_swapchain(manager: *OutputSwapchainManager, output: *wlr.Output) ?*wlr.Swapchain;
    pub const getSwapchain = wlr_output_swapchain_manager_get_swapchain;

    extern fn wlr_output_swapchain_manager_apply(manager: *OutputSwapchainManager) void;
    pub const apply = wlr_output_swapchain_manager_apply;

    extern fn wlr_output_swapchain_manager_finish(manager: *OutputSwapchainManager) void;
    pub const finish = wlr_output_swapchain_manager_finish;
};
