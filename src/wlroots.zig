pub const Backend = @import("backend.zig").Backend;

pub const Device = @import("backend/session.zig").Device;
pub const Session = @import("backend/session.zig").Session;

pub const DmabufAttributes = @import("render/dmabuf.zig").DmabufAttributes;
pub const Renderer = @import("render/renderer.zig").Renderer;
pub const RenderTimer = @import("render/renderer.zig").RenderTimer;
pub const RenderPass = @import("render/renderer.zig").RenderPass;
pub const Texture = @import("render/texture.zig").Texture;
pub const Allocator = @import("render/allocator.zig").Allocator;
pub const Swapchain = opaque {};
pub const DrmFormat = @import("render/drm_format_set.zig").DrmFormat;
pub const DrmFormatSet = @import("render/drm_format_set.zig").DrmFormatSet;

pub const ShmAttributes = @import("types/buffer.zig").ShmAttributes;
pub const BufferCap = @import("types/buffer.zig").BufferCap;
pub const Buffer = @import("types/buffer.zig").Buffer;
pub const ClientBuffer = @import("types/buffer.zig").ClientBuffer;

pub const SinglePixelBufferManagerV1 = @import("types/single_pixel_buffer_v1.zig").SinglePixelBufferManagerV1;

pub const DmabufBufferV1 = @import("types/linux_dmabuf_v1.zig").DmabufBufferV1;
pub const LinuxDmabufV1 = @import("types/linux_dmabuf_v1.zig").LinuxDmabufV1;
pub const LinuxDmabufFeedbackV1 = @import("types/linux_dmabuf_v1.zig").LinuxDmabufFeedbackV1;

pub const Compositor = @import("types/compositor.zig").Compositor;
pub const Surface = @import("types/compositor.zig").Surface;
pub const Subcompositor = @import("types/subcompositor.zig").Subcompositor;
pub const Subsurface = @import("types/subcompositor.zig").Subsurface;

pub const Viewporter = @import("types/viewporter.zig").Viewporter;

pub const Presentation = @import("types/presentation_time.zig").Presentation;
pub const PresentationFeedback = @import("types/presentation_time.zig").PresentationFeedback;
pub const PresentationEvent = @import("types/presentation_time.zig").PresentationEvent;

pub const XdgShell = @import("types/xdg_shell.zig").XdgShell;
pub const XdgClient = @import("types/xdg_shell.zig").XdgClient;
pub const XdgSurface = @import("types/xdg_shell.zig").XdgSurface;
pub const XdgToplevel = @import("types/xdg_shell.zig").XdgToplevel;
pub const XdgPositioner = @import("types/xdg_shell.zig").XdgPositioner;
pub const XdgPopupGrab = @import("types/xdg_shell.zig").XdgPopupGrab;
pub const XdgPopup = @import("types/xdg_shell.zig").XdgPopup;

pub const XdgDecorationManagerV1 = @import("types/xdg_decoration_v1.zig").XdgDecorationManagerV1;
pub const XdgToplevelDecorationV1 = @import("types/xdg_decoration_v1.zig").XdgToplevelDecorationV1;

pub const XdgActivationV1 = @import("types/xdg_activation_v1.zig").XdgActivationV1;
pub const XdgActivationTokenV1 = @import("types/xdg_activation_v1.zig").XdgActivationTokenV1;

pub const LayerShellV1 = @import("types/layer_shell_v1.zig").LayerShellV1;
pub const LayerSurfaceV1 = @import("types/layer_shell_v1.zig").LayerSurfaceV1;

pub const SessionLockManagerV1 = @import("types/session_lock_v1.zig").SessionLockManagerV1;
pub const SessionLockV1 = @import("types/session_lock_v1.zig").SessionLockV1;
pub const SessionLockSurfaceV1 = @import("types/session_lock_v1.zig").SessionLockSurfaceV1;

pub const Seat = @import("types/seat.zig").Seat;
pub const SerialRange = @import("types/seat.zig").SerialRange;
pub const SerialRingset = @import("types/seat.zig").SerialRingset;
pub const TouchPoint = @import("types/seat.zig").TouchPoint;

pub const InputDevice = @import("types/input_device.zig").InputDevice;
pub const InputMethodV2 = @import("types/input_method_v2.zig").InputMethodV2;
pub const InputMethodManagerV2 = @import("types/input_method_v2.zig").InputMethodManagerV2;
pub const InputPopupSurfaceV2 = @import("types/input_method_v2.zig").InputPopupSurfaceV2;

pub const TextInputV3 = @import("types/text_input_v3.zig").TextInputV3;
pub const TextInputManagerV3 = @import("types/text_input_v3.zig").TextInputManagerV3;

pub const Keyboard = @import("types/keyboard.zig").Keyboard;
pub const KeyboardGroup = @import("types/keyboard_group.zig").KeyboardGroup;
pub const KeyboardShortcutsInhibitorV1 = @import("types/keyboard_shortcuts_inhibit_v1.zig").KeyboardShortcutsInhibitorV1;
pub const KeyboardShortcutsInhibitManagerV1 = @import("types/keyboard_shortcuts_inhibit_v1.zig").KeyboardShortcutsInhibitManagerV1;

pub const Cursor = @import("types/cursor.zig").Cursor;
pub const Pointer = @import("types/pointer.zig").Pointer;
pub const PointerConstraintV1 = @import("types/pointer_constraints_v1.zig").PointerConstraintV1;
pub const PointerConstraintsV1 = @import("types/pointer_constraints_v1.zig").PointerConstraintsV1;
pub const PointerGesturesV1 = @import("types/pointer_gestures_v1.zig").PointerGesturesV1;
pub const AxisOrientation = @import("types/pointer.zig").AxisOrientation;
pub const AxisSource = @import("types/pointer.zig").AxisSource;

pub const RelativePointerManagerV1 = @import("types/relative_pointer_v1.zig").RelativePointerManagerV1;
pub const RelativePointerV1 = @import("types/relative_pointer_v1.zig").RelativePointerV1;

pub const Touch = @import("types/touch.zig").Touch;

pub const Tablet = @import("types/tablet_tool.zig").Tablet;
pub const TabletTool = @import("types/tablet_tool.zig").TabletTool;

pub const Switch = @import("types/switch.zig").Switch;

pub const VirtualPointerManagerV1 = @import("types/virtual_pointer_v1.zig").VirtualPointerManagerV1;
pub const VirtualPointerV1 = @import("types/virtual_pointer_v1.zig").VirtualPointerV1;

pub const VirtualKeyboardManagerV1 = @import("types/virtual_keyboard_v1.zig").VirtualKeyboardManagerV1;
pub const VirtualKeyboardV1 = @import("types/virtual_keyboard_v1.zig").VirtualKeyboardV1;

pub const Idle = @import("types/idle.zig").Idle;
pub const IdleTimeout = @import("types/idle.zig").IdleTimeout;

pub const IdleInhibitManagerV1 = @import("types/idle_inhibit_v1.zig").IdleInhibitManagerV1;
pub const IdleInhibitorV1 = @import("types/idle_inhibit_v1.zig").IdleInhibitorV1;

pub const IdleNotifierV1 = @import("types/idle_notify_v1.zig").IdleNotifierV1;

pub const InputInhibitManager = @import("types/input_inhibitor.zig").InputInhibitManager;

pub const DataDeviceManager = @import("types/data_device.zig").DataDeviceManager;
pub const DataOffer = @import("types/data_device.zig").DataOffer;
pub const DataSource = @import("types/data_device.zig").DataSource;
pub const Drag = @import("types/data_device.zig").Drag;

pub const DataControlManagerV1 = @import("types/data_control_v1.zig").DataControlManagerV1;
pub const DataControlDeviceV1 = @import("types/data_control_v1.zig").DataControlDeviceV1;

pub const PrimarySelectionSource = @import("types/primary_selection.zig").PrimarySelectionSource;

pub const PrimarySelectionDeviceManagerV1 = @import("types/primary_selection_v1.zig").PrimarySelectionDeviceManagerV1;
pub const PrimarySelectionDeviceV1 = @import("types/primary_selection_v1.zig").PrimarySelectionDeviceV1;

pub const Output = @import("types/output.zig").Output;
pub const OutputCursor = @import("types/output.zig").OutputCursor;
pub const OutputLayout = @import("types/output_layout.zig").OutputLayout;

pub const DamageRing = @import("types/damage_ring.zig").DamageRing;

pub const XdgOutputManagerV1 = @import("types/xdg_output_v1.zig").XdgOutputManagerV1;
pub const XdgOutputV1 = @import("types/xdg_output_v1.zig").XdgOutputV1;

pub const OutputPowerManagerV1 = @import("types/output_power_management_v1.zig").OutputPowerManagerV1;
pub const OutputPowerV1 = @import("types/output_power_management_v1.zig").OutputPowerV1;

pub const ExportDmabufManagerV1 = @import("types/export_dmabuf_v1.zig").ExportDmabufManagerV1;
pub const ExportDmabufFrameV1 = @import("types/export_dmabuf_v1.zig").ExportDmabufFrameV1;

pub const ScreencopyManagerV1 = @import("types/screencopy_v1.zig").ScreencopyManagerV1;
pub const ScreencopyClientV1 = @import("types/screencopy_v1.zig").ScreencopyClientV1;
pub const ScreencopyFrameV1 = @import("types/screencopy_v1.zig").ScreencopyFrameV1;

pub const GammaControlManagerV1 = @import("types/gamma_control_v1.zig").GammaControlManagerV1;
pub const GammaControlV1 = @import("types/gamma_control_v1.zig").GammaControlV1;

pub const XcursorImage = @import("xcursor.zig").XcursorImage;
pub const Xcursor = @import("xcursor.zig").Xcursor;
pub const XcursorTheme = @import("xcursor.zig").XcursorTheme;

pub const XcursorManager = @import("types/xcursor_manager.zig").XcursorManager;
pub const XcursorManagerTheme = @import("types/xcursor_manager.zig").XcursorManagerTheme;

pub usingnamespace if (config.has_xwayland) struct {
    pub const XwaylandServer = @import("xwayland/server.zig").XwaylandServer;
    pub const Xwayland = @import("xwayland/xwayland.zig").Xwayland;
    pub const XwaylandSurface = @import("xwayland/xwayland.zig").XwaylandSurface;
    pub const XwaylandCursor = @import("xwayland/xwayland.zig").XwaylandCursor;
    pub const Xwm = @import("xwayland/xwayland.zig").Xwm;
} else struct {};

pub const matrix = @import("types/matrix.zig");

pub const AddonSet = @import("util/addon.zig").AddonSet;
pub const Addon = @import("util/addon.zig").Addon;
pub const Box = @import("util/box.zig").Box;
pub const FBox = @import("util/box.zig").FBox;
pub const Edges = @import("util/edges.zig").Edges;
pub const log = @import("util/log.zig");
pub const region = @import("util/region.zig");

pub const OutputManagerV1 = @import("types/output_management_v1.zig").OutputManagerV1;
pub const OutputHeadV1 = @import("types/output_management_v1.zig").OutputHeadV1;
pub const OutputConfigurationV1 = @import("types/output_management_v1.zig").OutputConfigurationV1;

pub const ForeignToplevelManagerV1 = @import("types/foreign_toplevel_management_v1.zig").ForeignToplevelManagerV1;
pub const ForeignToplevelHandleV1 = @import("types/foreign_toplevel_management_v1.zig").ForeignToplevelHandleV1;

pub const SceneNode = @import("types/scene.zig").SceneNode;
pub const Scene = @import("types/scene.zig").Scene;
pub const SceneTree = @import("types/scene.zig").SceneTree;
pub const SceneSurface = @import("types/scene.zig").SceneSurface;
pub const SceneRect = @import("types/scene.zig").SceneRect;
pub const SceneBuffer = @import("types/scene.zig").SceneBuffer;
pub const SceneOutput = @import("types/scene.zig").SceneOutput;
pub const SceneOutputLayout = @import("types/scene.zig").SceneOutputLayout;
pub const SceneTimer = @import("types/scene.zig").SceneTimer;
pub const SceneLayerSurfaceV1 = @import("types/scene.zig").SceneLayerSurfaceV1;

pub const config = @import("config.zig");
pub const version = @import("version.zig");

comptime {
    if (version.major != 0 or version.minor != 17) {
        @compileError("zig-wlroots requires wlroots version 0.17");
    }
}
test {
    const std = @import("std");
    @setEvalBranchQuota(100000);
    std.testing.refAllDeclsRecursive(@This());
}
