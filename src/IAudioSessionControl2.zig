const std = @import("std");
const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");
const IAudioSessionControl = @import("IAudioSessionControl.zig").IAudioSessionControl;

const GUID = guid.GUID;
const HRESULT = types.HRESULT;
const AudioSessionState = types.AudioSessionState;
const IAudioSessionControlVtbl = @import("IAudioSessionControl.zig").IAudioSessionControlVtbl;

pub const IAudioSessionControl2Vtbl = extern struct {
    base: IAudioSessionControlVtbl,
    GetSessionIdentifier: *const fn (*IAudioSessionControl2, *?[*:0]u16) callconv(.winapi) HRESULT,
    GetSessionInstanceIdentifier: *const fn (*IAudioSessionControl2, *?[*:0]u16) callconv(.winapi) HRESULT,
    GetProcessId: *const fn (*IAudioSessionControl2, *u32) callconv(.winapi) HRESULT,
    IsSystemSoundsSession: *const fn (*IAudioSessionControl2) callconv(.winapi) HRESULT,
    SetDuckingPreference: *const fn (*IAudioSessionControl2, i32) callconv(.winapi) HRESULT,
};

pub const IAudioSessionControl2 = extern struct {
    vtable: *const IAudioSessionControl2Vtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn asSessionControl(self: *Self) *IAudioSessionControl {
        return @ptrCast(self);
    }

    pub fn getState(self: *Self) wca.Error!AudioSessionState {
        return self.asSessionControl().getState();
    }

    pub fn getDisplayName(self: *Self, allocator: std.mem.Allocator) wca.Error!?[]u8 {
        return self.asSessionControl().getDisplayName(allocator);
    }

    pub fn getIconPath(self: *Self, allocator: std.mem.Allocator) wca.Error!?[]u8 {
        return self.asSessionControl().getIconPath(allocator);
    }

    pub fn getGroupingParam(self: *Self) wca.Error!GUID {
        return self.asSessionControl().getGroupingParam();
    }

    pub fn getSessionIdentifier(self: *Self, allocator: std.mem.Allocator) wca.Error!?[]u8 {
        var id_ptr: ?[*:0]u16 = null;
        const hr = self.vtable.GetSessionIdentifier(self, &id_ptr);

        try wca.hresultToError(hr);

        if (id_ptr) |ptr| {
            defer com.taskMemFree(@ptrCast(ptr));

            var len: usize = 0;
            while (ptr[len] != 0) : (len += 1) {}
            return std.unicode.utf16LeToUtf8Alloc(allocator, ptr[0..len]) catch return wca.Error.Unexpected;
        }

        return null;
    }

    pub fn getSessionInstanceIdentifier(self: *Self, allocator: std.mem.Allocator) wca.Error!?[]u8 {
        var id_ptr: ?[*:0]u16 = null;
        const hr = self.vtable.GetSessionInstanceIdentifier(self, &id_ptr);

        try wca.hresultToError(hr);

        if (id_ptr) |ptr| {
            defer com.taskMemFree(@ptrCast(ptr));

            var len: usize = 0;
            while (ptr[len] != 0) : (len += 1) {}
            return std.unicode.utf16LeToUtf8Alloc(allocator, ptr[0..len]) catch return wca.Error.Unexpected;
        }

        return null;
    }

    pub fn getProcessId(self: *Self) wca.Error!u32 {
        var pid: u32 = 0;
        const hr = self.vtable.GetProcessId(self, &pid);
        try wca.hresultToError(hr);

        return pid;
    }

    pub fn isSystemSoundsSession(self: *Self) wca.Error!bool {
        const hr = self.vtable.IsSystemSoundsSession(self);
        if (hr == 0) return true;
        if (hr == 1) return false;
        try wca.hresultToError(hr);

        return false;
    }

    pub fn setDuckingPreference(self: *Self, opt_out: bool) wca.Error!void {
        const hr = self.vtable.SetDuckingPreference(self, if (opt_out) 1 else 0);
        try wca.hresultToError(hr);
    }
};
