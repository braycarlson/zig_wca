const guid = @import("guid.zig");
const types = @import("types.zig");
const IAudioSessionControl = @import("IAudioSessionControl.zig").IAudioSessionControl;

const GUID = guid.GUID;
const HRESULT = types.HRESULT;

pub const IAudioSessionNotificationVtbl = extern struct {
    QueryInterface: *const fn (*IAudioSessionNotification, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT,
    AddRef: *const fn (*IAudioSessionNotification) callconv(.winapi) u32,
    Release: *const fn (*IAudioSessionNotification) callconv(.winapi) u32,
    OnSessionCreated: *const fn (*IAudioSessionNotification, *IAudioSessionControl) callconv(.winapi) HRESULT,
};

pub const IAudioSessionNotification = extern struct {
    vtable: *const IAudioSessionNotificationVtbl,
};
