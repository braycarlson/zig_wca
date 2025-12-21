const com = @import("com.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");

const HRESULT = types.HRESULT;

const IAudioRenderClientVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetBuffer: *const fn (*IAudioRenderClient, u32, *?[*]u8) callconv(.winapi) HRESULT,
    ReleaseBuffer: *const fn (*IAudioRenderClient, u32, u32) callconv(.winapi) HRESULT,
};

pub const IAudioRenderClient = extern struct {
    vtable: *const IAudioRenderClientVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn getBuffer(self: *Self, num_frames_requested: u32) wca.Error![*]u8 {
        var data: ?[*]u8 = null;
        const hr = self.vtable.GetBuffer(self, num_frames_requested, &data);
        try wca.hresultToError(hr);

        return data orelse return wca.Error.Unexpected;
    }

    pub fn releaseBuffer(self: *Self, num_frames_written: u32, flags: u32) wca.Error!void {
        const hr = self.vtable.ReleaseBuffer(self, num_frames_written, flags);
        try wca.hresultToError(hr);
    }

    pub fn getBufferSlice(
        self: *Self,
        num_frames_requested: u32,
        block_align: u16,
    ) wca.Error![]u8 {
        const data = try self.getBuffer(num_frames_requested);
        const byte_count = num_frames_requested * @as(u32, block_align);

        return data[0..byte_count];
    }
};
