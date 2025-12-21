const com = @import("com.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");

const HRESULT = types.HRESULT;

const IAudioStreamVolumeVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetChannelCount: *const fn (*IAudioStreamVolume, *u32) callconv(.winapi) HRESULT,
    SetChannelVolume: *const fn (*IAudioStreamVolume, u32, f32) callconv(.winapi) HRESULT,
    GetChannelVolume: *const fn (*IAudioStreamVolume, u32, *f32) callconv(.winapi) HRESULT,
    SetAllVolumes: *const fn (*IAudioStreamVolume, u32, [*]const f32) callconv(.winapi) HRESULT,
    GetAllVolumes: *const fn (*IAudioStreamVolume, u32, [*]f32) callconv(.winapi) HRESULT,
};

pub const IAudioStreamVolume = extern struct {
    vtable: *const IAudioStreamVolumeVtbl,

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

    pub fn setChannelVolume(self: *Self, channel: u32, level: f32) wca.Error!void {
        const hr = self.vtable.SetChannelVolume(self, channel, level);
        try wca.hresultToError(hr);
    }

    pub fn getChannelVolume(self: *Self, channel: u32) wca.Error!f32 {
        var level: f32 = 0;
        const hr = self.vtable.GetChannelVolume(self, channel, &level);
        try wca.hresultToError(hr);

        return level;
    }

    pub fn setAllVolumes(self: *Self, levels: []const f32) wca.Error!void {
        const hr = self.vtable.SetAllVolumes(self, @intCast(levels.len), levels.ptr);
        try wca.hresultToError(hr);
    }

    pub fn getAllVolumes(self: *Self, levels: []f32) wca.Error!void {
        const hr = self.vtable.GetAllVolumes(self, @intCast(levels.len), levels.ptr);
        try wca.hresultToError(hr);
    }
};
