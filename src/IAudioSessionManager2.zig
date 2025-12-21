const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");
const IAudioSessionManager = @import("IAudioSessionManager.zig").IAudioSessionManager;
const IAudioSessionControl = @import("IAudioSessionControl.zig").IAudioSessionControl;
const IAudioSessionEnumerator = @import("IAudioSessionEnumerator.zig").IAudioSessionEnumerator;
const ISimpleAudioVolume = @import("ISimpleAudioVolume.zig").ISimpleAudioVolume;

const GUID = guid.GUID;
const HRESULT = types.HRESULT;
const IAudioSessionManagerVtbl = @import("IAudioSessionManager.zig").IAudioSessionManagerVtbl;

pub const IAudioSessionManager2Vtbl = extern struct {
    base: IAudioSessionManagerVtbl,
    GetSessionEnumerator: *const fn (*IAudioSessionManager2, *?*IAudioSessionEnumerator) callconv(.winapi) HRESULT,
    RegisterSessionNotification: *const fn (*IAudioSessionManager2, ?*anyopaque) callconv(.winapi) HRESULT,
    UnregisterSessionNotification: *const fn (*IAudioSessionManager2, ?*anyopaque) callconv(.winapi) HRESULT,
    RegisterDuckNotification: *const fn (*IAudioSessionManager2, ?[*:0]const u16, ?*anyopaque) callconv(.winapi) HRESULT,
    UnregisterDuckNotification: *const fn (*IAudioSessionManager2, ?*anyopaque) callconv(.winapi) HRESULT,
};

pub const IAudioSessionManager2 = extern struct {
    vtable: *const IAudioSessionManager2Vtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn asSessionManager(self: *Self) *IAudioSessionManager {
        return @ptrCast(self);
    }

    pub fn getAudioSessionControl(
        self: *Self,
        session_guid: ?*const GUID,
        stream_flags: u32,
    ) wca.Error!*IAudioSessionControl {
        return self.asSessionManager().getAudioSessionControl(session_guid, stream_flags);
    }

    pub fn getSimpleAudioVolume(
        self: *Self,
        session_guid: ?*const GUID,
        stream_flags: u32,
    ) wca.Error!*ISimpleAudioVolume {
        return self.asSessionManager().getSimpleAudioVolume(session_guid, stream_flags);
    }

    pub fn getSessionEnumerator(self: *Self) wca.Error!*IAudioSessionEnumerator {
        var enumerator: ?*IAudioSessionEnumerator = null;
        const hr = self.vtable.GetSessionEnumerator(self, &enumerator);
        try wca.hresultToError(hr);

        return enumerator orelse return wca.Error.Unexpected;
    }

    pub fn registerSessionNotification(self: *Self, notification: ?*anyopaque) wca.Error!void {
        const hr = self.vtable.RegisterSessionNotification(self, notification);
        try wca.hresultToError(hr);
    }

    pub fn unregisterSessionNotification(self: *Self, notification: ?*anyopaque) wca.Error!void {
        const hr = self.vtable.UnregisterSessionNotification(self, notification);
        try wca.hresultToError(hr);
    }

    pub fn registerDuckNotification(self: *Self, session_id: ?[*:0]const u16, notification: ?*anyopaque) wca.Error!void {
        const hr = self.vtable.RegisterDuckNotification(self, session_id, notification);
        try wca.hresultToError(hr);
    }

    pub fn unregisterDuckNotification(self: *Self, notification: ?*anyopaque) wca.Error!void {
        const hr = self.vtable.UnregisterDuckNotification(self, notification);
        try wca.hresultToError(hr);
    }
};
