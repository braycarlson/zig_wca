const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");
const IAudioSessionControl = @import("IAudioSessionControl.zig").IAudioSessionControl;
const ISimpleAudioVolume = @import("ISimpleAudioVolume.zig").ISimpleAudioVolume;

const GUID = guid.GUID;
const HRESULT = types.HRESULT;

pub const IAudioSessionManagerVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetAudioSessionControl: *const fn (
        *IAudioSessionManager,
        ?*const GUID,
        u32,
        *?*IAudioSessionControl,
    ) callconv(.winapi) HRESULT,
    GetSimpleAudioVolume: *const fn (
        *IAudioSessionManager,
        ?*const GUID,
        u32,
        *?*ISimpleAudioVolume,
    ) callconv(.winapi) HRESULT,
};

pub const IAudioSessionManager = extern struct {
    vtable: *const IAudioSessionManagerVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn getAudioSessionControl(
        self: *Self,
        session_guid: ?*const GUID,
        stream_flags: u32,
    ) wca.Error!*IAudioSessionControl {
        var control: ?*IAudioSessionControl = null;
        const hr = self.vtable.GetAudioSessionControl(self, session_guid, stream_flags, &control);
        try wca.hresultToError(hr);

        return control orelse return wca.Error.Unexpected;
    }

    pub fn getSimpleAudioVolume(
        self: *Self,
        session_guid: ?*const GUID,
        stream_flags: u32,
    ) wca.Error!*ISimpleAudioVolume {
        var volume: ?*ISimpleAudioVolume = null;
        const hr = self.vtable.GetSimpleAudioVolume(self, session_guid, stream_flags, &volume);
        try wca.hresultToError(hr);

        return volume orelse return wca.Error.Unexpected;
    }
};
