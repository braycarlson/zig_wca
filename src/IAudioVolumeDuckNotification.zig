const guid = @import("guid.zig");
const types = @import("types.zig");

const GUID = guid.GUID;
const HRESULT = types.HRESULT;

pub const IAudioVolumeDuckNotificationVtbl = extern struct {
    QueryInterface: *const fn (*IAudioVolumeDuckNotification, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT,
    AddRef: *const fn (*IAudioVolumeDuckNotification) callconv(.winapi) u32,
    Release: *const fn (*IAudioVolumeDuckNotification) callconv(.winapi) u32,
    OnVolumeDuckNotification: *const fn (*IAudioVolumeDuckNotification, ?[*:0]const u16, u32) callconv(.winapi) HRESULT,
    OnVolumeUnduckNotification: *const fn (*IAudioVolumeDuckNotification, ?[*:0]const u16) callconv(.winapi) HRESULT,
};

pub const IAudioVolumeDuckNotification = extern struct {
    vtable: *const IAudioVolumeDuckNotificationVtbl,
};
