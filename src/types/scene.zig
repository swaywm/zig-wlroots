const wlr = @import("../wlroots.zig");

const std = @import("std");
const os = std.os;

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
    parent: ?*SceneNode,

    link: wl.list.Link,

    enabled: bool,
    x: c_int,
    y: c_int,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    data: usize,

    addons: wlr.AddonSet,

    // private state

    visible: pixman.Region32,

    extern fn wlr_scene_node_at(node: *SceneNode, lx: f64, ly: f64, nx: *f64, ny: *f64) ?*SceneNode;
    pub const at = wlr_scene_node_at;

    extern fn wlr_scene_node_coords(node: *SceneNode, lx: *c_int, ly: *c_int) bool;
    pub const coords = wlr_scene_node_coords;

    extern fn wlr_scene_node_destroy(node: *SceneNode) void;
    pub const destroy = wlr_scene_node_destroy;

    extern fn wlr_scene_node_for_each_buffer(
        node: *SceneNode,
        iterator: *const fn (buffer: *SceneBuffer, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void,
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
                fn wrapper(b: *SceneBuffer, sx: c_int, sy: c_int, d: ?*anyopaque) callconv(.C) void {
                    iterator(b, sx, sy, @ptrCast(T, @alignCast(@alignOf(T), d)));
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
};

pub const SceneTree = extern struct {
    node: SceneNode,

    children: wl.list.Head(SceneNode, "link"),

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
};

pub const Scene = extern struct {
    tree: SceneTree,

    outputs: wl.list.Head(SceneOutput, "link"),

    presentation: ?*wlr.Presentation,

    // private state

    presentation_destroy: wl.Listener(void),

    debug_damage_option: enum(c_int) {
        none,
        rerender,
        highlight,
    },

    direct_scanout: bool,
    calculate_visibility: bool,

    extern fn wlr_scene_create() ?*Scene;
    pub fn create() !*Scene {
        return wlr_scene_create() orelse error.OutOfMemory;
    }

    extern fn wlr_scene_attach_output_layout(scene: *Scene, output_layout: *wlr.OutputLayout) bool;
    pub fn attachOutputLayout(scene: *Scene, output_layout: *wlr.OutputLayout) !void {
        if (!wlr_scene_attach_output_layout(scene, output_layout)) return error.OutOfMemory;
    }

    extern fn wlr_scene_get_scene_output(scene: *Scene, output: *wlr.Output) ?*SceneOutput;
    pub const getSceneOutput = wlr_scene_get_scene_output;

    extern fn wlr_scene_set_presentation(scene: *Scene, presentation: *wlr.Presentation) void;
    pub const setPresentation = wlr_scene_set_presentation;

    extern fn wlr_scene_output_create(scene: *Scene, output: *wlr.Output) ?*SceneOutput;
    pub fn createSceneOutput(scene: *Scene, output: *wlr.Output) !*SceneOutput {
        return wlr_scene_output_create(scene, output) orelse error.OutOfMemory;
    }
};

pub const SceneSurface = extern struct {
    buffer: *SceneBuffer,
    surface: *wlr.Surface,

    // private state

    addon: wlr.Addon,

    output_enter: wl.Listener(*SceneOutput),
    output_leave: wl.Listener(*SceneOutput),
    output_present: wl.Listener(*SceneOutput),
    frame_done: wl.Listener(*os.timespec),
    surface_destroy: wl.Listener(void),
    surface_commit: wl.Listener(void),

    extern fn wlr_scene_surface_from_buffer(buffer: *SceneBuffer) ?*SceneSurface;
    pub const fromBuffer = wlr_scene_surface_from_buffer;
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
};

pub const SceneBuffer = extern struct {
    node: SceneNode,
    buffer: ?*wlr.Buffer,

    events: extern struct {
        output_enter: wl.Signal(*SceneOutput),
        output_leave: wl.Signal(*SceneOutput),
        output_present: wl.Signal(*SceneOutput),
        frame_done: wl.Signal(*os.timespec),
    },

    point_accepts_input: ?*const fn (buffer: *SceneBuffer, sx: c_int, sy: c_int) callconv(.C) bool,

    primary_output: ?*wlr.Output,

    // private state

    active_outputs: u64,
    texture: ?*wlr.Texture,
    src_box: wlr.FBox,
    dst_width: c_int,
    dst_height: c_int,
    transform: wl.Output.Transform,
    opaque_region: pixman.Region32,

    extern fn wlr_scene_buffer_from_node(node: *SceneNode) *SceneBuffer;
    pub const fromNode = wlr_scene_buffer_from_node;

    extern fn wlr_scene_buffer_set_buffer(scene_buffer: *SceneBuffer, buffer: ?*wlr.Buffer) void;
    pub const setBuffer = wlr_scene_buffer_set_buffer;

    extern fn wlr_scene_buffer_set_buffer_with_damage(scene_buffer: *SceneBuffer, buffer: *wlr.Buffer, region: *pixman.Region32) void;
    pub const setBufferWithDamage = wlr_scene_buffer_set_buffer_with_damage;

    extern fn wlr_scene_buffer_set_opaque_region(scene_buffer: *SceneBuffer, region: *pixman.Region32) void;
    pub const setOpaqueRegion = wlr_scene_buffer_set_opaque_region;

    extern fn wlr_scene_buffer_set_dest_size(scene_buffer: *SceneBuffer, width: c_int, height: c_int) void;
    pub const setDestSize = wlr_scene_buffer_set_dest_size;

    extern fn wlr_scene_buffer_set_source_box(scene_buffer: *SceneBuffer, box: *const wlr.FBox) void;
    pub const setSourceBox = wlr_scene_buffer_set_source_box;

    extern fn wlr_scene_buffer_set_transform(scene_buffer: *SceneBuffer, transform: wl.Output.Transform) void;
    pub const setTransform = wlr_scene_buffer_set_transform;

    extern fn wlr_scene_buffer_send_frame_done(scene_buffer: *SceneBuffer, now: *os.timespec) void;
    pub const sendFrameDone = wlr_scene_buffer_send_frame_done;
};

pub const SceneOutput = extern struct {
    output: *wlr.Output,
    /// Scene.outputs
    link: wl.list.Link,
    scene: *Scene,
    addon: wlr.Addon,

    damage_ring: *wlr.DamageRing,

    x: c_int,
    y: c_int,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    // private state

    index: u8,
    prev_scanout: bool,

    output_commit: wl.Listener(*wlr.Output.event.Commit),
    output_mode: wl.Listener(*wlr.Output),
    output_damage: wl.Listener(void),
    output_needs_frame: wl.Listener(void),

    // Actually the head of the list, but the element type is private.
    damage_highlight_regions: wl.list.Link,

    render_list: wl.Array,

    extern fn wlr_scene_output_commit(scene_output: *SceneOutput) bool;
    pub const commit = wlr_scene_output_commit;

    extern fn wlr_scene_output_destroy(scene_output: *SceneOutput) void;
    pub const destroy = wlr_scene_output_destroy;

    extern fn wlr_scene_output_for_each_buffer(
        scene_output: *SceneOutput,
        iterator: *const fn (buffer: *SceneBuffer, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void,
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
                fn wrapper(b: *SceneBuffer, sx: c_int, sy: c_int, d: ?*anyopaque) callconv(.C) void {
                    iterator(b, sx, sy, @ptrCast(T, @alignCast(@alignOf(T), d)));
                }
            }.wrapper,
            data,
        );
    }

    extern fn wlr_scene_output_send_frame_done(scene_output: *SceneOutput, now: *os.timespec) void;
    pub const sendFrameDone = wlr_scene_output_send_frame_done;

    extern fn wlr_scene_output_set_position(scene_output: *SceneOutput, lx: c_int, ly: c_int) void;
    pub const setPosition = wlr_scene_output_set_position;
};

pub const SceneLayerSurfaceV1 = extern struct {
    tree: *SceneTree,
    layer_surface: *wlr.LayerSurfaceV1,

    // private state

    tree_destroy: wl.Listener(void),
    layer_surface_destroy: wl.Listener(*wlr.LayerSurfaceV1),
    layer_surface_map: wl.Listener(*wlr.LayerSurfaceV1),
    layer_surface_unmap: wl.Listener(*wlr.LayerSurfaceV1),

    extern fn wlr_scene_layer_surface_v1_configure(
        scene_layer_surface: *SceneLayerSurfaceV1,
        full_area: *const wlr.Box,
        usable_area: *wlr.Box,
    ) void;
    pub const configure = wlr_scene_layer_surface_v1_configure;
};
