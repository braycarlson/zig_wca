const com = @import("com.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");

const HRESULT = types.HRESULT;

const IAudioClock2Vtbl = extern struct {
    base: com.IUnknownVtbl,
    GetDevicePosition: *const fn (*IAudioClock2, *u64, *u64) callconv(.winapi) HRESULT,
};

pub const IAudioClock2 = extern struct {
    vtable: *const IAudioClock2Vtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn getDevicePosition(self: *Self) wca.Error!struct { position: u64, qpc_position: u64 } {
        var pos: u64 = 0;
        var qpc: u64 = 0;
        const hr = self.vtable.GetDevicePosition(self, &pos, &qpc);

        try wca.hresultToError(hr);

        return .{ .position = pos, .qpc_position = qpc };
    }
};
