const com = @import("com.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");

const HRESULT = types.HRESULT;

const IAudioCaptureClientVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetBuffer: *const fn (
        *IAudioCaptureClient,
        *?[*]u8,
        *u32,
        *u32,
        ?*u64,
        ?*u64,
    ) callconv(.winapi) HRESULT,
    ReleaseBuffer: *const fn (*IAudioCaptureClient, u32) callconv(.winapi) HRESULT,
    GetNextPacketSize: *const fn (*IAudioCaptureClient, *u32) callconv(.winapi) HRESULT,
};

pub const CaptureBuffer = struct {
    data: [*]u8,
    num_frames: u32,
    flags: u32,
    device_position: u64,
    qpc_position: u64,

    pub fn slice(self: CaptureBuffer, block_align: u16) []const u8 {
        const byte_count = self.num_frames * @as(u32, block_align);
        return self.data[0..byte_count];
    }

    pub fn isSilent(self: CaptureBuffer) bool {
        return (self.flags & 0x2) != 0;
    }

    pub fn hasDiscontinuity(self: CaptureBuffer) bool {
        return (self.flags & 0x1) != 0;
    }

    pub fn hasTimestampError(self: CaptureBuffer) bool {
        return (self.flags & 0x4) != 0;
    }
};

pub const IAudioCaptureClient = extern struct {
    vtable: *const IAudioCaptureClientVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn getBuffer(self: *Self) wca.Error!CaptureBuffer {
        var data: ?[*]u8 = null;
        var num_frames: u32 = 0;
        var flags: u32 = 0;
        var device_pos: u64 = 0;
        var qpc_pos: u64 = 0;

        const hr = self.vtable.GetBuffer(self, &data, &num_frames, &flags, &device_pos, &qpc_pos);
        try wca.hresultToError(hr);

        return .{
            .data = data orelse return wca.Error.Unexpected,
            .num_frames = num_frames,
            .flags = flags,
            .device_position = device_pos,
            .qpc_position = qpc_pos,
        };
    }

    pub fn releaseBuffer(self: *Self, num_frames_read: u32) wca.Error!void {
        const hr = self.vtable.ReleaseBuffer(self, num_frames_read);
        try wca.hresultToError(hr);
    }

    pub fn getNextPacketSize(self: *Self) wca.Error!u32 {
        var size: u32 = 0;
        const hr = self.vtable.GetNextPacketSize(self, &size);
        try wca.hresultToError(hr);

        return size;
    }
};
