const wlr = @import("../wlroots.zig");

const std = @import("std");
const posix = std.posix;

const wayland = @import("wayland");
const wl = wayland.server.wl;

const pixman = @import("pixman");

pub const SceneNode = extern struct {
    pub const Type = enum(c_int) {
        tree,
        rect,
        buffer,
    };

    type: Type,
    parent: ?*SceneTree,

    link: wl.list.Link,

    enabled: bool,
    x: c_int,
    y: c_int,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    data: ?*anyopaque,

    addons: wlr.AddonSet,

    private: extern struct {
        visible: pixman.Region32,
    },

    extern fn wlr_scene_node_at(node: *SceneNode, lx: f64, ly: f64, nx: *f64, ny: *f64) ?*SceneNode;
    pub const at = wlr_scene_node_at;

    extern fn wlr_scene_node_coords(node: *SceneNode, lx: *c_int, ly: *c_int) bool;
    pub const coords = wlr_scene_node_coords;

    extern fn wlr_scene_node_destroy(node: *SceneNode) void;
    pub const destroy = wlr_scene_node_destroy;

    extern fn wlr_scene_node_for_each_buffer(
        node: *SceneNode,
        iterator: *const fn (buffer: *SceneBuffer, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.c) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachBuffer(
        node: *SceneNode,
        comptime T: type,
        comptime iterator: fn (buffer: *SceneBuffer, sx: c_int, sy: c_int, data: T) void,
        data: T,
    ) void {
        wlr_scene_node_for_each_buffer(
            node,
            struct {
                fn wrapper(b: *SceneBuffer, sx: c_int, sy: c_int, d: ?*anyopaque) callconv(.c) void {
                    iterator(b, sx, sy, @ptrCast(@alignCast(d)));
                }
            }.wrapper,
            data,
        );
    }

    extern fn wlr_scene_node_lower_to_bottom(node: *SceneNode) void;
    pub const lowerToBottom = wlr_scene_node_lower_to_bottom;

    extern fn wlr_scene_node_place_above(node: *SceneNode, sibling: *SceneNode) void;
    pub const placeAbove = wlr_scene_node_place_above;

    extern fn wlr_scene_node_place_below(node: *SceneNode, sibling: *SceneNode) void;
    pub const placeBelow = wlr_scene_node_place_below;

    extern fn wlr_scene_node_raise_to_top(node: *SceneNode) void;
    pub const raiseToTop = wlr_scene_node_raise_to_top;

    extern fn wlr_scene_node_reparent(node: *SceneNode, new_parent: *SceneTree) void;
    pub const reparent = wlr_scene_node_reparent;

    extern fn wlr_scene_node_set_enabled(node: *SceneNode, enabled: bool) void;
    pub const setEnabled = wlr_scene_node_set_enabled;

    extern fn wlr_scene_node_set_position(node: *SceneNode, x: c_int, y: c_int) void;
    pub const setPosition = wlr_scene_node_set_position;

    extern fn wlr_scene_subsurface_tree_set_clip(node: *SceneNode, clip: ?*const wlr.Box) void;
    pub const subsurfaceTreeSetClip = wlr_scene_subsurface_tree_set_clip;
};

pub const SceneTree = extern struct {
    node: SceneNode,

    children: wl.list.Head(SceneNode, .link),

    extern fn wlr_scene_tree_create(parent: *SceneTree) ?*SceneTree;
    pub fn createSceneTree(parent: *SceneTree) !*SceneTree {
        return wlr_scene_tree_create(parent) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_surface_create(parent: *SceneTree, surface: *wlr.Surface) ?*SceneSurface;
    pub fn createSceneSurface(parent: *SceneTree, surface: *wlr.Surface) !*SceneSurface {
        return wlr_scene_surface_create(parent, surface) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_rect_create(parent: *SceneTree, width: c_int, height: c_int, color: *const [4]f32) ?*SceneRect;
    pub fn createSceneRect(parent: *SceneTree, width: c_int, height: c_int, color: *const [4]f32) !*SceneRect {
        return wlr_scene_rect_create(parent, width, height, color) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_buffer_create(parent: *SceneTree, buffer: ?*wlr.Buffer) ?*SceneBuffer;
    pub fn createSceneBuffer(parent: *SceneTree, buffer: ?*wlr.Buffer) !*SceneBuffer {
        return wlr_scene_buffer_create(parent, buffer) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_subsurface_tree_create(parent: *SceneTree, surface: *wlr.Surface) ?*SceneTree;
    pub fn createSceneSubsurfaceTree(parent: *SceneTree, surface: *wlr.Surface) !*SceneTree {
        return wlr_scene_subsurface_tree_create(parent, surface) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_xdg_surface_create(parent: *SceneTree, xdg_surface: *wlr.XdgSurface) ?*SceneTree;
    pub fn createSceneXdgSurface(parent: *SceneTree, xdg_surface: *wlr.XdgSurface) !*SceneTree {
        return wlr_scene_xdg_surface_create(parent, xdg_surface) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_layer_surface_v1_create(parent: *SceneTree, layer_surface: *wlr.LayerSurfaceV1) ?*SceneLayerSurfaceV1;
    pub fn createSceneLayerSurfaceV1(parent: *SceneTree, layer_surface: *wlr.LayerSurfaceV1) !*SceneLayerSurfaceV1 {
        return wlr_scene_layer_surface_v1_create(parent, layer_surface) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_drag_icon_create(parent: *SceneTree, drag_icon: *wlr.Drag.Icon) ?*SceneTree;
    pub fn createSceneDragIcon(parent: *SceneTree, drag_icon: *wlr.Drag.Icon) !*SceneTree {
        return wlr_scene_drag_icon_create(parent, drag_icon) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_tree_from_node(node: *SceneNode) *SceneTree;
    pub const fromNode = wlr_scene_tree_from_node;
};

pub const Scene = extern struct {
    tree: SceneTree,

    outputs: wl.list.Head(SceneOutput, .link),

    linux_dmabuf_v1: ?*wlr.LinuxDmabufV1,
    gamma_control_manager_v1: ?*wlr.GammaControlManagerV1,

    private: extern struct {
        linux_dmabuf_v1_destroy: wl.Listener(void),
        gamma_control_manager_v1_destroy: wl.Listener(void),
        gamma_control_manager_v1_set_gamma: wl.Listener(void),

        debug_damage_option: c_int,
        direct_scanout: bool,
        calculate_visibility: bool,
        highlight_transparent_region: bool,
    },

    extern fn wlr_scene_create() ?*Scene;
    pub fn create() !*Scene {
        return wlr_scene_create() orelse error.OutOfMemory;
    }

    extern fn wlr_scene_attach_output_layout(scene: *Scene, output_layout: *wlr.OutputLayout) ?*SceneOutputLayout;
    pub fn attachOutputLayout(scene: *Scene, output_layout: *wlr.OutputLayout) !*SceneOutputLayout {
        return wlr_scene_attach_output_layout(scene, output_layout) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_get_scene_output(scene: *Scene, output: *wlr.Output) ?*SceneOutput;
    pub const getSceneOutput = wlr_scene_get_scene_output;

    extern fn wlr_scene_set_linux_dmabuf_v1(scene: *Scene, linux_dmabuf_v1: *wlr.LinuxDmabufV1) void;
    pub const setLinuxDmabufV1 = wlr_scene_set_linux_dmabuf_v1;

    extern fn wlr_scene_set_gamma_control_manager_v1(scene: *Scene, gamma_control: *wlr.GammaControlManagerV1) void;
    pub const setGammaControlManagerV1 = wlr_scene_set_gamma_control_manager_v1;

    extern fn wlr_scene_output_create(scene: *Scene, output: *wlr.Output) ?*SceneOutput;
    pub fn createSceneOutput(scene: *Scene, output: *wlr.Output) !*SceneOutput {
        return wlr_scene_output_create(scene, output) orelse error.OutOfMemory;
    }
};

pub const SceneOutputLayout = opaque {
    extern fn wlr_scene_output_layout_add_output(sol: *SceneOutputLayout, lo: *wlr.OutputLayout.Output, so: *SceneOutput) void;
    pub const addOutput = wlr_scene_output_layout_add_output;
};

pub const SceneSurface = extern struct {
    buffer: *SceneBuffer,
    surface: *wlr.Surface,

    private: extern struct {
        clip: wlr.Box,
        addon: wlr.Addon,

        outputs_update: wl.Listener(void),
        output_enter: wl.Listener(void),
        output_leave: wl.Listener(void),
        output_sample: wl.Listener(void),
        frame_done: wl.Listener(void),
        surface_destroy: wl.Listener(void),
        surface_commit: wl.Listener(void),
    },

    extern fn wlr_scene_surface_try_from_buffer(buffer: *SceneBuffer) ?*SceneSurface;
    pub const tryFromBuffer = wlr_scene_surface_try_from_buffer;
};

pub const SceneRect = extern struct {
    node: SceneNode,
    width: c_int,
    height: c_int,
    color: [4]f32,

    extern fn wlr_scene_rect_set_color(rect: *SceneRect, color: *const [4]f32) void;
    pub const setColor = wlr_scene_rect_set_color;

    extern fn wlr_scene_rect_set_size(rect: *SceneRect, width: c_int, height: c_int) void;
    pub const setSize = wlr_scene_rect_set_size;

    extern fn wlr_scene_rect_from_node(node: *SceneNode) *SceneRect;
    pub const fromNode = wlr_scene_rect_from_node;
};

pub const SceneBuffer = extern struct {
    pub const event = struct {
        pub const OutputsUpdate = extern struct {
            active: [*]*SceneOutput,
            size: usize,
        };
        pub const OutputSample = extern struct {
            output: *SceneOutput,
            direct_scanout: bool,
        };
    };

    node: SceneNode,
    buffer: ?*wlr.Buffer,

    events: extern struct {
        outputs_update: wl.Signal(*event.OutputsUpdate),
        output_enter: wl.Signal(*SceneOutput),
        output_leave: wl.Signal(*SceneOutput),
        output_sample: wl.Signal(*event.OutputSample),
        frame_done: wl.Signal(*posix.timespec),
    },

    point_accepts_input: ?*const fn (buffer: *SceneBuffer, sx: *f64, sy: *f64) callconv(.c) bool,

    primary_output: ?*wlr.SceneOutput,

    opacity: f32,
    filter_mode: wlr.RenderPass.ScaleFilterMode,
    src_box: wlr.FBox,
    dst_width: c_int,
    dst_height: c_int,
    transform: wl.Output.Transform,
    opaque_region: pixman.Region32,

    private: extern struct {
        active_outputs: u64,
        texture: ?*wlr.Texture,
        prev_feedback_options: wlr.LinuxDmabufFeedbackV1.InitOptions,

        own_buffer: bool,
        buffer_width: c_int,
        buffer_height: c_int,
        buffer_is_opaque: bool,

        wait_timeline: ?*wlr.DrmSyncobjTimeline,
        wait_point: u64,

        buffer_release: wl.Listener(void),
        renderer_destroy: wl.Listener(void),

        is_single_pixel_buffer: bool,
        single_pixel_buffer_color: [4]u32,
    },

    extern fn wlr_scene_buffer_from_node(node: *SceneNode) *SceneBuffer;
    pub const fromNode = wlr_scene_buffer_from_node;

    extern fn wlr_scene_buffer_set_buffer(scene_buffer: *SceneBuffer, buffer: ?*wlr.Buffer) void;
    pub const setBuffer = wlr_scene_buffer_set_buffer;

    extern fn wlr_scene_buffer_set_buffer_with_damage(scene_buffer: *SceneBuffer, buffer: *wlr.Buffer, region: *const pixman.Region32) void;
    pub const setBufferWithDamage = wlr_scene_buffer_set_buffer_with_damage;

    extern fn wlr_scene_buffer_set_opaque_region(scene_buffer: *SceneBuffer, region: *const pixman.Region32) void;
    pub const setOpaqueRegion = wlr_scene_buffer_set_opaque_region;

    extern fn wlr_scene_buffer_set_dest_size(scene_buffer: *SceneBuffer, width: c_int, height: c_int) void;
    pub const setDestSize = wlr_scene_buffer_set_dest_size;

    extern fn wlr_scene_buffer_set_source_box(scene_buffer: *SceneBuffer, box: *const wlr.FBox) void;
    pub const setSourceBox = wlr_scene_buffer_set_source_box;

    extern fn wlr_scene_buffer_set_transform(scene_buffer: *SceneBuffer, transform: wl.Output.Transform) void;
    pub const setTransform = wlr_scene_buffer_set_transform;

    extern fn wlr_scene_buffer_set_opacity(scene_buffer: *SceneBuffer, opacity: f32) void;
    pub const setOpacity = wlr_scene_buffer_set_opacity;

    extern fn wlr_scene_buffer_set_filter_mode(scene_buffer: *SceneBuffer, filter_mode: wlr.RenderPass.ScaleFilterMode) void;
    pub const setFilterMode = wlr_scene_buffer_set_filter_mode;

    extern fn wlr_scene_buffer_send_frame_done(scene_buffer: *SceneBuffer, now: *posix.timespec) void;
    pub const sendFrameDone = wlr_scene_buffer_send_frame_done;
};

pub const SceneOutput = extern struct {
    output: *wlr.Output,
    /// Scene.outputs
    link: wl.list.Link,
    scene: *Scene,
    addon: wlr.Addon,

    damage_ring: wlr.DamageRing,

    x: c_int,
    y: c_int,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    private: extern struct {
        pending_commit_damage: pixman.Region32,

        index: u8,

        dmabuf_feedback_debounce: u8,
        prev_scanout: bool,

        gamma_lut_changed: bool,
        gamma_lut: ?*wlr.GammaControlV1,

        output_commit: wl.Listener(void),
        output_damage: wl.Listener(void),
        output_needs_frame: wl.Listener(void),

        damage_highlight_regions: wl.list.Link,

        render_list: wl.Array,

        in_timeline: ?*wlr.DrmSyncobjTimeline,
        in_point: u64,
    },

    pub const StateOptions = extern struct {
        timer: ?*wlr.SceneTimer = null,
        color_transform: ?*wlr.ColorTransform = null,
        swapchain: ?*wlr.Swapchain = null,
    };

    extern fn wlr_scene_output_needs_frame(scene_output: *SceneOutput) bool;
    pub const needsFrame = wlr_scene_output_needs_frame;

    extern fn wlr_scene_output_commit(scene_output: *SceneOutput, options: ?*const StateOptions) bool;
    pub const commit = wlr_scene_output_commit;

    extern fn wlr_scene_output_build_state(scene_output: *SceneOutput, state: *wlr.Output.State, options: ?*const StateOptions) bool;
    pub const buildState = wlr_scene_output_build_state;

    extern fn wlr_scene_output_destroy(scene_output: *SceneOutput) void;
    pub const destroy = wlr_scene_output_destroy;

    extern fn wlr_scene_output_for_each_buffer(
        scene_output: *SceneOutput,
        iterator: *const fn (buffer: *SceneBuffer, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.c) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachBuffer(
        scene_output: *SceneOutput,
        comptime T: type,
        comptime iterator: fn (buffer: *SceneBuffer, sx: c_int, sy: c_int, data: T) void,
        data: T,
    ) void {
        wlr_scene_output_for_each_buffer(
            scene_output,
            struct {
                fn wrapper(b: *SceneBuffer, sx: c_int, sy: c_int, d: ?*anyopaque) callconv(.c) void {
                    iterator(b, sx, sy, @ptrCast(@alignCast(d)));
                }
            }.wrapper,
            data,
        );
    }

    extern fn wlr_scene_output_send_frame_done(scene_output: *SceneOutput, now: *posix.timespec) void;
    pub const sendFrameDone = wlr_scene_output_send_frame_done;

    extern fn wlr_scene_output_set_position(scene_output: *SceneOutput, lx: c_int, ly: c_int) void;
    pub const setPosition = wlr_scene_output_set_position;
};

pub const SceneTimer = extern struct {
    pre_render_duration: i64,
    render_timer: ?*wlr.RenderTimer,

    extern fn wlr_scene_timer_get_duration_ns(timer: *SceneTimer) i64;
    pub const getDurationNs = wlr_scene_timer_get_duration_ns;

    extern fn wlr_scene_timer_finish(timer: *SceneTimer) void;
    pub const finish = wlr_scene_timer_finish;
};

pub const SceneLayerSurfaceV1 = extern struct {
    tree: *SceneTree,
    layer_surface: *wlr.LayerSurfaceV1,

    private: extern struct {
        tree_destroy: wl.Listener(void),
        layer_surface_destroy: wl.Listener(void),
        layer_surface_map: wl.Listener(void),
        layer_surface_unmap: wl.Listener(void),
    },

    extern fn wlr_scene_layer_surface_v1_configure(
        scene_layer_surface: *SceneLayerSurfaceV1,
        full_area: *const wlr.Box,
        usable_area: *wlr.Box,
    ) void;
    pub const configure = wlr_scene_layer_surface_v1_configure;
};
