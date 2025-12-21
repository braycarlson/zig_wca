const std = @import("std");
const windows = std.os.windows;
const GUID = @import("guid.zig").GUID;
const types = @import("types.zig");
const HRESULT = types.HRESULT;

pub const COINIT_APARTMENTTHREADED = 0x2;
pub const COINIT_MULTITHREADED = 0x0;
pub const COINIT_DISABLE_OLE1DDE = 0x4;
pub const COINIT_SPEED_OVER_MEMORY = 0x8;

pub const CLSCTX_INPROC_SERVER: u32 = 0x1;
pub const CLSCTX_INPROC_HANDLER: u32 = 0x2;
pub const CLSCTX_LOCAL_SERVER: u32 = 0x4;
pub const CLSCTX_REMOTE_SERVER: u32 = 0x10;
pub const CLSCTX_ALL: u32 = CLSCTX_INPROC_SERVER | CLSCTX_INPROC_HANDLER | CLSCTX_LOCAL_SERVER | CLSCTX_REMOTE_SERVER;

pub const IUnknownVtbl = extern struct {
    QueryInterface: *const fn (*IUnknown, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT,
    AddRef: *const fn (*IUnknown) callconv(.winapi) u32,
    Release: *const fn (*IUnknown) callconv(.winapi) u32,
};

pub const IUnknown = extern struct {
    vtable: *const IUnknownVtbl,

    pub fn queryInterface(self: *IUnknown, riid: *const GUID, ppv: *?*anyopaque) HRESULT {
        return self.vtable.QueryInterface(self, riid, ppv);
    }

    pub fn addRef(self: *IUnknown) u32 {
        return self.vtable.AddRef(self);
    }

    pub fn release(self: *IUnknown) u32 {
        return self.vtable.Release(self);
    }
};

extern "ole32" fn CoInitializeEx(reserved: ?*anyopaque, coinit: u32) callconv(.winapi) HRESULT;
extern "ole32" fn CoUninitialize() callconv(.winapi) void;
extern "ole32" fn CoCreateInstance(
    rclsid: *const GUID,
    punk_outer: ?*IUnknown,
    cls_context: u32,
    riid: *const GUID,
    ppv: *?*anyopaque,
) callconv(.winapi) HRESULT;
extern "ole32" fn CoTaskMemFree(pv: ?*anyopaque) callconv(.winapi) void;

extern "kernel32" fn CreateEventExW(
    security_attributes: ?*anyopaque,
    name: ?[*:0]const u16,
    flags: u32,
    desired_access: u32,
) callconv(.winapi) ?windows.HANDLE;
extern "kernel32" fn CloseHandle(handle: windows.HANDLE) callconv(.winapi) windows.BOOL;
extern "kernel32" fn WaitForSingleObject(handle: windows.HANDLE, milliseconds: u32) callconv(.winapi) u32;

pub const CREATE_EVENT_MANUAL_RESET: u32 = 0x00000001;
pub const CREATE_EVENT_INITIAL_SET: u32 = 0x00000002;
pub const EVENT_MODIFY_STATE: u32 = 0x0002;
pub const SYNCHRONIZE: u32 = 0x00100000;
pub const WAIT_OBJECT_0: u32 = 0x00000000;
pub const WAIT_TIMEOUT: u32 = 0x00000102;
pub const WAIT_FAILED: u32 = 0xFFFFFFFF;
pub const INFINITE: u32 = 0xFFFFFFFF;

pub fn initialize(coinit: u32) !void {
    const hr = CoInitializeEx(null, coinit);

    if (hr < 0) {
        return error.ComInitFailed;
    }
}

pub fn uninitialize() void {
    CoUninitialize();
}

pub fn createInstance(
    comptime T: type,
    clsid: *const GUID,
    iid: *const GUID,
) !*T {
    var obj: ?*anyopaque = null;
    const hr = CoCreateInstance(clsid, null, CLSCTX_ALL, iid, &obj);

    if (hr < 0 or obj == null) {
        return error.CreateInstanceFailed;
    }

    return @ptrCast(@alignCast(obj.?));
}

pub fn taskMemFree(ptr: ?*anyopaque) void {
    CoTaskMemFree(ptr);
}

pub fn createEvent(manual_reset: bool, initial_state: bool) ?windows.HANDLE {
    var flags: u32 = 0;
    if (manual_reset) flags |= CREATE_EVENT_MANUAL_RESET;
    if (initial_state) flags |= CREATE_EVENT_INITIAL_SET;

    return CreateEventExW(null, null, flags, EVENT_MODIFY_STATE | SYNCHRONIZE);
}

pub fn closeHandle(handle: windows.HANDLE) bool {
    return CloseHandle(handle) != 0;
}

pub fn waitForSingleObject(handle: windows.HANDLE, milliseconds: u32) u32 {
    return WaitForSingleObject(handle, milliseconds);
}
