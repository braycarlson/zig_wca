const std = @import("std");
const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");
const IPropertyStore = @import("IPropertyStore.zig").IPropertyStore;
const IAudioClient = @import("IAudioClient.zig").IAudioClient;
const IAudioClient2 = @import("IAudioClient2.zig").IAudioClient2;
const IAudioClient3 = @import("IAudioClient3.zig").IAudioClient3;
const IAudioEndpointVolume = @import("IAudioEndpointVolume.zig").IAudioEndpointVolume;

const GUID = guid.GUID;
const HRESULT = types.HRESULT;

const IMMDeviceVtbl = extern struct {
    base: com.IUnknownVtbl,
    Activate: *const fn (
        *IMMDevice,
        *const GUID,
        u32,
        ?*anyopaque,
        *?*anyopaque,
    ) callconv(.winapi) HRESULT,
    OpenPropertyStore: *const fn (
        *IMMDevice,
        u32,
        *?*IPropertyStore,
    ) callconv(.winapi) HRESULT,
    GetId: *const fn (
        *IMMDevice,
        *?[*:0]u16,
    ) callconv(.winapi) HRESULT,
    GetState: *const fn (
        *IMMDevice,
        *u32,
    ) callconv(.winapi) HRESULT,
};

pub const IMMDevice = extern struct {
    vtable: *const IMMDeviceVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn activate(
        self: *Self,
        comptime T: type,
        iid: *const GUID,
    ) wca.Error!*T {
        var obj: ?*anyopaque = null;
        const hr = self.vtable.Activate(self, iid, com.CLSCTX_ALL, null, &obj);
        try wca.hresultToError(hr);

        return @ptrCast(@alignCast(obj orelse return wca.Error.Unexpected));
    }

    pub fn activateAudioClient(self: *Self) wca.Error!*IAudioClient {
        return self.activate(IAudioClient, &guid.IID_IAudioClient);
    }

    pub fn activateAudioClient2(self: *Self) wca.Error!*IAudioClient2 {
        return self.activate(IAudioClient2, &guid.IID_IAudioClient2);
    }

    pub fn activateAudioClient3(self: *Self) wca.Error!*IAudioClient3 {
        return self.activate(IAudioClient3, &guid.IID_IAudioClient3);
    }

    pub fn activateEndpointVolume(self: *Self) wca.Error!*IAudioEndpointVolume {
        return self.activate(IAudioEndpointVolume, &guid.IID_IAudioEndpointVolume);
    }

    pub fn openPropertyStore(self: *Self, mode: u32) wca.Error!*IPropertyStore {
        var store: ?*IPropertyStore = null;
        const hr = self.vtable.OpenPropertyStore(self, mode, &store);
        try wca.hresultToError(hr);

        return store orelse return wca.Error.Unexpected;
    }

    pub fn getId(self: *Self, allocator: std.mem.Allocator) wca.Error![]u8 {
        var id_ptr: ?[*:0]u16 = null;
        const hr = self.vtable.GetId(self, &id_ptr);

        try wca.hresultToError(hr);

        if (id_ptr) |ptr| {
            defer com.taskMemFree(@ptrCast(ptr));

            var len: usize = 0;
            while (ptr[len] != 0) : (len += 1) {}
            return std.unicode.utf16LeToUtf8Alloc(allocator, ptr[0..len]) catch return wca.Error.Unexpected;
        }

        return wca.Error.Unexpected;
    }

    pub fn getState(self: *Self) wca.Error!u32 {
        var state: u32 = 0;
        const hr = self.vtable.GetState(self, &state);
        try wca.hresultToError(hr);

        return state;
    }
};
