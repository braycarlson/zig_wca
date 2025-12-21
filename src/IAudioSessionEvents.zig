const guid = @import("guid.zig");
const types = @import("types.zig");

const GUID = guid.GUID;
const HRESULT = types.HRESULT;

pub const AudioSessionDisconnectReason = enum(u32) {
    DeviceRemoval = 0,
    ServerShutdown = 1,
    FormatChanged = 2,
    SessionLogoff = 3,
    SessionDisconnected = 4,
    ExclusiveModeOverride = 5,
};

pub const IAudioSessionEventsVtbl = extern struct {
    QueryInterface: *const fn (*IAudioSessionEvents, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT,
    AddRef: *const fn (*IAudioSessionEvents) callconv(.winapi) u32,
    Release: *const fn (*IAudioSessionEvents) callconv(.winapi) u32,
    OnDisplayNameChanged: *const fn (*IAudioSessionEvents, ?[*:0]const u16, *const GUID) callconv(.winapi) HRESULT,
    OnIconPathChanged: *const fn (*IAudioSessionEvents, ?[*:0]const u16, *const GUID) callconv(.winapi) HRESULT,
    OnSimpleVolumeChanged: *const fn (*IAudioSessionEvents, f32, i32, *const GUID) callconv(.winapi) HRESULT,
    OnChannelVolumeChanged: *const fn (*IAudioSessionEvents, u32, [*]f32, u32, *const GUID) callconv(.winapi) HRESULT,
    OnGroupingParamChanged: *const fn (*IAudioSessionEvents, *const GUID, *const GUID) callconv(.winapi) HRESULT,
    OnStateChanged: *const fn (*IAudioSessionEvents, types.AudioSessionState) callconv(.winapi) HRESULT,
    OnSessionDisconnected: *const fn (*IAudioSessionEvents, AudioSessionDisconnectReason) callconv(.winapi) HRESULT,
};

pub const IAudioSessionEvents = extern struct {
    vtable: *const IAudioSessionEventsVtbl,
};
