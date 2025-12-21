const com = @import("com.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");

const HRESULT = types.HRESULT;

const IAudioClockAdjustmentVtbl = extern struct {
    base: com.IUnknownVtbl,
    SetSampleRate: *const fn (*IAudioClockAdjustment, f32) callconv(.winapi) HRESULT,
};

pub const IAudioClockAdjustment = extern struct {
    vtable: *const IAudioClockAdjustmentVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn setSampleRate(self: *Self, sample_rate: f32) wca.Error!void {
        const hr = self.vtable.SetSampleRate(self, sample_rate);
        try wca.hresultToError(hr);
    }
};
