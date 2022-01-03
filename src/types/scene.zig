const wlr = @import("../wlroots.zig");

const std = @import("std");
const os = std.os;

const wayland = @import("wayland");
const wl = wayland.server.wl;

const pixman = @import("pixman");

pub const SceneNode = extern struct {
    pub const Type = enum(c_int) {
        root,
        tree,
        surface,
        rect,
        buffer,
    };

    pub const State = extern struct {
        link: wl.list.Link,
        children: wl.list.Head(SceneNode.State, "link"),

        enabled: bool,
        x: c_int,
        y: c_int,
    };

    type: Type,
    parent: ?*SceneNode,
    state: State,

    events: extern struct {
        destroy: wl.Signal(void),
    },

    data: usize,

    extern fn wlr_scene_node_at(node: *SceneNode, lx: f64, ly: f64, nx: *f64, ny: *f64) ?*SceneNode;
    pub const at = wlr_scene_node_at;

    extern fn wlr_scene_node_coords(node: *SceneNode, lx: *c_int, ly: *c_int) bool;
    pub const coords = wlr_scene_node_coords;

    extern fn wlr_scene_node_destroy(node: *SceneNode) void;
    pub const destroy = wlr_scene_node_destroy;

    extern fn wlr_scene_node_for_each_surface(
        node: *SceneNode,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachSurface(
        node: *SceneNode,
        comptime T: type,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) callconv(.C) void,
        data: T,
    ) void {
        wlr_scene_node_for_each_surface(
            node,
            @ptrCast(fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void, iterator),
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

    extern fn wlr_scene_node_reparent(node: *SceneNode, new_parent: *SceneNode) void;
    pub const reparent = wlr_scene_node_reparent;

    extern fn wlr_scene_node_set_enabled(node: *SceneNode, enabled: bool) void;
    pub const setEnabled = wlr_scene_node_set_enabled;

    extern fn wlr_scene_node_set_position(node: *SceneNode, x: c_int, y: c_int) void;
    pub const setPosition = wlr_scene_node_set_position;

    extern fn wlr_scene_tree_create(parent: *SceneNode) ?*SceneTree;
    pub fn createSceneTree(parent: *SceneNode) !*SceneTree {
        return wlr_scene_tree_create(parent) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_surface_create(parent: *SceneNode, surface: *wlr.Surface) ?*SceneSurface;
    pub fn createSceneSurface(parent: *SceneNode, surface: *wlr.Surface) !*SceneSurface {
        return wlr_scene_surface_create(parent, surface) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_rect_create(parent: *SceneNode, width: c_int, height: c_int, color: *const [4]f32) ?*SceneRect;
    pub fn createSceneRect(parent: *SceneNode, width: c_int, height: c_int, color: *const [4]f32) !*SceneRect {
        return wlr_scene_rect_create(parent, width, height, color) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_buffer_create(parent: *SceneNode, buffer: *wlr.Buffer) ?*SceneBuffer;
    pub fn createSceneBuffer(parent: *SceneNode, buffer: *wlr.Buffer) !*SceneBuffer {
        return wlr_scene_buffer_create(parent, buffer) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_subsurface_tree_create(parent: *SceneNode, surface: *wlr.Surface) ?*SceneNode;
    pub fn createSceneSubsurfaceTree(parent: *SceneNode, surface: *wlr.Surface) !*SceneNode {
        return wlr_scene_subsurface_tree_create(parent, surface) orelse error.OutOfMemory;
    }

    extern fn wlr_scene_xdg_surface_create(parent: *SceneNode, xdg_surface: *wlr.XdgSurface) ?*SceneNode;
    pub fn createSceneXdgSurface(parent: *SceneNode, xdg_surface: *wlr.XdgSurface) !*SceneNode {
        return wlr_scene_xdg_surface_create(parent, xdg_surface) orelse error.OutOfMemory;
    }
};

pub const Scene = extern struct {
    node: SceneNode,

    outputs: wl.list.Head(SceneOutput, "link"),

    // private state

    presentation: ?*wlr.Presentation,
    presentation_destroy: wl.Listener(void),

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

    extern fn wlr_scene_render_output(scene: *Scene, output: *wlr.Output, lx: c_int, ly: c_int, damage: ?*pixman.Region32) void;
    pub const renderOutput = wlr_scene_render_output;

    extern fn wlr_scene_set_presentation(scene: *Scene, presentation: *wlr.Presentation) void;
    pub const setPresentation = wlr_scene_set_presentation;

    extern fn wlr_scene_output_create(scene: *Scene, output: *wlr.Output) ?*SceneOutput;
    pub fn createSceneOutput(scene: *Scene, output: *wlr.Output) !*SceneOutput {
        return wlr_scene_output_create(scene, output) orelse error.OutOfMemory;
    }
};

pub const SceneTree = extern struct {
    node: SceneNode,
};

pub const SceneSurface = extern struct {
    node: SceneNode,
    surface: *wlr.Surface,

    primary_output: ?*wlr.Output,

    // private state

    prev_width: c_int,
    prev_height: c_int,

    surface_destroy: wl.Listener(void),
    surface_commit: wl.Listener(void),

    extern fn wlr_scene_surface_from_node(node: *SceneNode) *SceneSurface;
    pub const fromNode = wlr_scene_surface_from_node;
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
    buffer: *wlr.Buffer,

    // private state

    texture: ?*wlr.Texture,
    src_box: wlr.FBox,
    dst_width: c_int,
    dst_height: c_int,
    transform: wl.Output.Transform,

    extern fn wlr_scene_buffer_set_dest_size(scene_buffer: *SceneBuffer, width: c_int, height: c_int) void;
    pub const setDestSize = wlr_scene_buffer_set_dest_size;

    extern fn wlr_scene_buffer_set_source_box(scene_buffer: *SceneBuffer, box: *const wlr.FBox) void;
    pub const setSourceBox = wlr_scene_buffer_set_source_box;

    extern fn wlr_scene_buffer_set_transform(scene_buffer: *SceneBuffer, transform: wl.Output.Transform) void;
    pub const setTransform = wlr_scene_buffer_set_transform;
};

pub const SceneOutput = extern struct {
    output: *wlr.Output,
    /// Scene.outputs
    link: wl.list.Link,
    scene: *Scene,
    addon: wlr.Addon,

    damage: *wlr.OutputDamage,

    x: c_int,
    y: c_int,

    // private state

    prev_scanout: bool,

    extern fn wlr_scene_output_commit(scene_output: *SceneOutput) bool;
    pub const commit = wlr_scene_output_commit;

    extern fn wlr_scene_output_destroy(scene_output: *SceneOutput) void;
    pub const destroy = wlr_scene_output_destroy;

    extern fn wlr_scene_output_for_each_surface(
        scene_output: *SceneOutput,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void,
        user_data: ?*anyopaque,
    ) void;
    pub inline fn forEachSurface(
        scene_output: *SceneOutput,
        comptime T: type,
        iterator: fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: T) callconv(.C) void,
        data: T,
    ) void {
        wlr_scene_output_for_each_surface(
            scene_output,
            @ptrCast(fn (surface: *wlr.Surface, sx: c_int, sy: c_int, data: ?*anyopaque) callconv(.C) void, iterator),
            data,
        );
    }

    extern fn wlr_scene_output_send_frame_done(scene_output: *SceneOutput, now: *os.timespec) void;
    pub const sendFrameDone = wlr_scene_output_send_frame_done;

    extern fn wlr_scene_output_set_position(scene_output: *SceneOutput, lx: c_int, ly: c_int) void;
    pub const setPosition = wlr_scene_output_set_position;
};
