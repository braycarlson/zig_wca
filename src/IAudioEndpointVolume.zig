const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");

const GUID = guid.GUID;
const HRESULT = types.HRESULT;

const IAudioEndpointVolumeVtbl = extern struct {
    base: com.IUnknownVtbl,
    RegisterControlChangeNotify: *const fn (*IAudioEndpointVolume, ?*anyopaque) callconv(.winapi) HRESULT,
    UnregisterControlChangeNotify: *const fn (*IAudioEndpointVolume, ?*anyopaque) callconv(.winapi) HRESULT,
    GetChannelCount: *const fn (*IAudioEndpointVolume, *u32) callconv(.winapi) HRESULT,
    SetMasterVolumeLevel: *const fn (*IAudioEndpointVolume, f32, ?*const GUID) callconv(.winapi) HRESULT,
    SetMasterVolumeLevelScalar: *const fn (*IAudioEndpointVolume, f32, ?*const GUID) callconv(.winapi) HRESULT,
    GetMasterVolumeLevel: *const fn (*IAudioEndpointVolume, *f32) callconv(.winapi) HRESULT,
    GetMasterVolumeLevelScalar: *const fn (*IAudioEndpointVolume, *f32) callconv(.winapi) HRESULT,
    SetChannelVolumeLevel: *const fn (*IAudioEndpointVolume, u32, f32, ?*const GUID) callconv(.winapi) HRESULT,
    SetChannelVolumeLevelScalar: *const fn (*IAudioEndpointVolume, u32, f32, ?*const GUID) callconv(.winapi) HRESULT,
    GetChannelVolumeLevel: *const fn (*IAudioEndpointVolume, u32, *f32) callconv(.winapi) HRESULT,
    GetChannelVolumeLevelScalar: *const fn (*IAudioEndpointVolume, u32, *f32) callconv(.winapi) HRESULT,
    SetMute: *const fn (*IAudioEndpointVolume, i32, ?*const GUID) callconv(.winapi) HRESULT,
    GetMute: *const fn (*IAudioEndpointVolume, *i32) callconv(.winapi) HRESULT,
    GetVolumeStepInfo: *const fn (*IAudioEndpointVolume, *u32, *u32) callconv(.winapi) HRESULT,
    VolumeStepUp: *const fn (*IAudioEndpointVolume, ?*const GUID) callconv(.winapi) HRESULT,
    VolumeStepDown: *const fn (*IAudioEndpointVolume, ?*const GUID) callconv(.winapi) HRESULT,
    QueryHardwareSupport: *const fn (*IAudioEndpointVolume, *u32) callconv(.winapi) HRESULT,
    GetVolumeRange: *const fn (*IAudioEndpointVolume, *f32, *f32, *f32) callconv(.winapi) HRESULT,
};

pub const IAudioEndpointVolume = extern struct {
    vtable: *const IAudioEndpointVolumeVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn getChannelCount(self: *Self) wca.Error!u32 {
        var count: u32 = 0;
        const hr = self.vtable.GetChannelCount(self, &count);
        try wca.hresultToError(hr);

        return count;
    }

    pub fn setMasterVolumeLevel(self: *Self, level_db: f32, context: ?*const GUID) wca.Error!void {
        const hr = self.vtable.SetMasterVolumeLevel(self, level_db, context);
        try wca.hresultToError(hr);
    }

    pub fn setMasterVolumeLevelScalar(self: *Self, level: f32, context: ?*const GUID) wca.Error!void {
        const hr = self.vtable.SetMasterVolumeLevelScalar(self, level, context);
        try wca.hresultToError(hr);
    }

    pub fn getMasterVolumeLevel(self: *Self) wca.Error!f32 {
        var level: f32 = 0;
        const hr = self.vtable.GetMasterVolumeLevel(self, &level);
        try wca.hresultToError(hr);

        return level;
    }

    pub fn getMasterVolumeLevelScalar(self: *Self) wca.Error!f32 {
        var level: f32 = 0;
        const hr = self.vtable.GetMasterVolumeLevelScalar(self, &level);
        try wca.hresultToError(hr);

        return level;
    }

    pub fn setChannelVolumeLevel(self: *Self, channel: u32, level_db: f32, context: ?*const GUID) wca.Error!void {
        const hr = self.vtable.SetChannelVolumeLevel(self, channel, level_db, context);
        try wca.hresultToError(hr);
    }

    pub fn setChannelVolumeLevelScalar(self: *Self, channel: u32, level: f32, context: ?*const GUID) wca.Error!void {
        const hr = self.vtable.SetChannelVolumeLevelScalar(self, channel, level, context);
        try wca.hresultToError(hr);
    }

    pub fn getChannelVolumeLevel(self: *Self, channel: u32) wca.Error!f32 {
        var level: f32 = 0;
        const hr = self.vtable.GetChannelVolumeLevel(self, channel, &level);
        try wca.hresultToError(hr);

        return level;
    }

    pub fn getChannelVolumeLevelScalar(self: *Self, channel: u32) wca.Error!f32 {
        var level: f32 = 0;
        const hr = self.vtable.GetChannelVolumeLevelScalar(self, channel, &level);
        try wca.hresultToError(hr);

        return level;
    }

    pub fn setMute(self: *Self, mute: bool, context: ?*const GUID) wca.Error!void {
        const hr = self.vtable.SetMute(self, if (mute) 1 else 0, context);
        try wca.hresultToError(hr);
    }

    pub fn getMute(self: *Self) wca.Error!bool {
        var mute: i32 = 0;
        const hr = self.vtable.GetMute(self, &mute);
        try wca.hresultToError(hr);

        return mute != 0;
    }

    pub fn getVolumeStepInfo(self: *Self) wca.Error!struct { step: u32, step_count: u32 } {
        var step: u32 = 0;
        var count: u32 = 0;
        const hr = self.vtable.GetVolumeStepInfo(self, &step, &count);
        try wca.hresultToError(hr);

        return .{ .step = step, .step_count = count };
    }

    pub fn volumeStepUp(self: *Self, context: ?*const GUID) wca.Error!void {
        const hr = self.vtable.VolumeStepUp(self, context);
        try wca.hresultToError(hr);
    }

    pub fn volumeStepDown(self: *Self, context: ?*const GUID) wca.Error!void {
        const hr = self.vtable.VolumeStepDown(self, context);
        try wca.hresultToError(hr);
    }

    pub fn queryHardwareSupport(self: *Self) wca.Error!u32 {
        var mask: u32 = 0;
        const hr = self.vtable.QueryHardwareSupport(self, &mask);
        try wca.hresultToError(hr);

        return mask;
    }

    pub fn getVolumeRange(self: *Self) wca.Error!struct { min_db: f32, max_db: f32, increment_db: f32 } {
        var min: f32 = 0;
        var max: f32 = 0;
        var inc: f32 = 0;
        const hr = self.vtable.GetVolumeRange(self, &min, &max, &inc);
        try wca.hresultToError(hr);

        return .{ .min_db = min, .max_db = max, .increment_db = inc };
    }
};
