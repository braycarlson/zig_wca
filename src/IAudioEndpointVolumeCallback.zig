const guid = @import("guid.zig");
const types = @import("types.zig");

const GUID = guid.GUID;
const HRESULT = types.HRESULT;

pub const AUDIO_VOLUME_NOTIFICATION_DATA = extern struct {
    event_context: GUID,
    muted: i32,
    master_volume: f32,
    channels: u32,
    channel_volumes: [1]f32,
};

pub const IAudioEndpointVolumeCallbackVtbl = extern struct {
    QueryInterface: *const fn (*IAudioEndpointVolumeCallback, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT,
    AddRef: *const fn (*IAudioEndpointVolumeCallback) callconv(.winapi) u32,
    Release: *const fn (*IAudioEndpointVolumeCallback) callconv(.winapi) u32,
    OnNotify: *const fn (*IAudioEndpointVolumeCallback, *AUDIO_VOLUME_NOTIFICATION_DATA) callconv(.winapi) HRESULT,
};

pub const IAudioEndpointVolumeCallback = extern struct {
    vtable: *const IAudioEndpointVolumeCallbackVtbl,
};
