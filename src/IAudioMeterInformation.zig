const com = @import("com.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");

const HRESULT = types.HRESULT;

const IAudioMeterInformationVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetPeakValue: *const fn (*IAudioMeterInformation, *f32) callconv(.winapi) HRESULT,
    GetMeteringChannelCount: *const fn (*IAudioMeterInformation, *u32) callconv(.winapi) HRESULT,
    GetChannelsPeakValues: *const fn (*IAudioMeterInformation, u32, [*]f32) callconv(.winapi) HRESULT,
    QueryHardwareSupport: *const fn (*IAudioMeterInformation, *u32) callconv(.winapi) HRESULT,
};

pub const IAudioMeterInformation = extern struct {
    vtable: *const IAudioMeterInformationVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn getPeakValue(self: *Self) wca.Error!f32 {
        var peak: f32 = 0;
        const hr = self.vtable.GetPeakValue(self, &peak);
        try wca.hresultToError(hr);

        return peak;
    }

    pub fn getMeteringChannelCount(self: *Self) wca.Error!u32 {
        var count: u32 = 0;
        const hr = self.vtable.GetMeteringChannelCount(self, &count);
        try wca.hresultToError(hr);

        return count;
    }

    pub fn getChannelsPeakValues(self: *Self, buffer: []f32) wca.Error!void {
        const hr = self.vtable.GetChannelsPeakValues(self, @intCast(buffer.len), buffer.ptr);
        try wca.hresultToError(hr);
    }

    pub fn queryHardwareSupport(self: *Self) wca.Error!u32 {
        var mask: u32 = 0;
        const hr = self.vtable.QueryHardwareSupport(self, &mask);
        try wca.hresultToError(hr);

        return mask;
    }
};
