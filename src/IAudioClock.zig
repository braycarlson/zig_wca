const com = @import("com.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");

const HRESULT = types.HRESULT;

const IAudioClockVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetFrequency: *const fn (*IAudioClock, *u64) callconv(.winapi) HRESULT,
    GetPosition: *const fn (*IAudioClock, *u64, ?*u64) callconv(.winapi) HRESULT,
    GetCharacteristics: *const fn (*IAudioClock, *u32) callconv(.winapi) HRESULT,
};

pub const IAudioClock = extern struct {
    vtable: *const IAudioClockVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn getFrequency(self: *Self) wca.Error!u64 {
        var freq: u64 = 0;
        const hr = self.vtable.GetFrequency(self, &freq);
        try wca.hresultToError(hr);

        return freq;
    }

    pub fn getPosition(self: *Self) wca.Error!struct { position: u64, qpc_position: u64 } {
        var pos: u64 = 0;
        var qpc: u64 = 0;
        const hr = self.vtable.GetPosition(self, &pos, &qpc);
        try wca.hresultToError(hr);

        return .{ .position = pos, .qpc_position = qpc };
    }

    pub fn getCharacteristics(self: *Self) wca.Error!u32 {
        var chars: u32 = 0;
        const hr = self.vtable.GetCharacteristics(self, &chars);
        try wca.hresultToError(hr);

        return chars;
    }

    pub fn getPositionInSeconds(self: *Self) wca.Error!f64 {
        const freq = try self.getFrequency();
        const pos_info = try self.getPosition();
        if (freq == 0) return 0.0;

        return @as(f64, @floatFromInt(pos_info.position)) / @as(f64, @floatFromInt(freq));
    }
};
