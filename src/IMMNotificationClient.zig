const std = @import("std");
const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const property = @import("property.zig");

const GUID = guid.GUID;
const HRESULT = types.HRESULT;
const EDataFlow = types.EDataFlow;
const ERole = types.ERole;
const PROPERTYKEY = property.PROPERTYKEY;

pub const IMMNotificationClientCallback = struct {
    onDeviceStateChanged: ?*const fn (device_id: []const u8, new_state: u32) anyerror!void = null,
    onDeviceAdded: ?*const fn (device_id: []const u8) anyerror!void = null,
    onDeviceRemoved: ?*const fn (device_id: []const u8) anyerror!void = null,
    onDefaultDeviceChanged: ?*const fn (flow: EDataFlow, role: ERole, device_id: []const u8) anyerror!void = null,
    onPropertyValueChanged: ?*const fn (device_id: []const u8, key: PROPERTYKEY) anyerror!void = null,
    user_data: ?*anyopaque = null,
};

pub const IMMNotificationClientVtbl = extern struct {
    QueryInterface: *const fn (*IMMNotificationClient, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT,
    AddRef: *const fn (*IMMNotificationClient) callconv(.winapi) u32,
    Release: *const fn (*IMMNotificationClient) callconv(.winapi) u32,
    OnDeviceStateChanged: *const fn (*IMMNotificationClient, ?[*:0]const u16, u32) callconv(.winapi) HRESULT,
    OnDeviceAdded: *const fn (*IMMNotificationClient, ?[*:0]const u16) callconv(.winapi) HRESULT,
    OnDeviceRemoved: *const fn (*IMMNotificationClient, ?[*:0]const u16) callconv(.winapi) HRESULT,
    OnDefaultDeviceChanged: *const fn (*IMMNotificationClient, EDataFlow, ERole, ?[*:0]const u16) callconv(.winapi) HRESULT,
    OnPropertyValueChanged: *const fn (*IMMNotificationClient, ?[*:0]const u16, PROPERTYKEY) callconv(.winapi) HRESULT,
};

pub const IMMNotificationClient = extern struct {
    vtable: *const IMMNotificationClientVtbl,
    ref_count: i32 = 1,
    callback: *IMMNotificationClientCallback,
    allocator: *std.mem.Allocator,

    const Self = @This();

    pub fn create(allocator: std.mem.Allocator, callback: IMMNotificationClientCallback) !*Self {
        const alloc_ptr = try allocator.create(std.mem.Allocator);
        alloc_ptr.* = allocator;

        const callback_ptr = try allocator.create(IMMNotificationClientCallback);
        callback_ptr.* = callback;

        const client = try allocator.create(Self);
        client.* = .{
            .vtable = &vtable_instance,
            .ref_count = 1,
            .callback = callback_ptr,
            .allocator = alloc_ptr,
        };

        return client;
    }

    fn queryInterface(self: *Self, riid: *const GUID, ppv: *?*anyopaque) callconv(.winapi) HRESULT {
        if (riid.eql(guid.IID_IUnknown) or riid.eql(guid.IID_IMMNotificationClient)) {
            ppv.* = self;
            _ = self.vtable.AddRef(self);

            return 0;
        }

        ppv.* = null;
        return @bitCast(@as(u32, 0x80004002));
    }

    fn addRef(self: *Self) callconv(.winapi) u32 {
        self.ref_count += 1;
        return @intCast(self.ref_count);
    }

    fn release(self: *Self) callconv(.winapi) u32 {
        self.ref_count -= 1;
        const count = self.ref_count;

        if (count == 0) {
            const allocator = self.allocator.*;
            allocator.destroy(self.callback);
            allocator.destroy(self.allocator);
            allocator.destroy(self);
        }

        return @intCast(count);
    }

    fn onDeviceStateChanged(self: *Self, device_id: ?[*:0]const u16, new_state: u32) callconv(.winapi) HRESULT {
        if (self.callback.onDeviceStateChanged) |cb| {
            const id = wideToUtf8(device_id) catch return 0;
            defer std.heap.page_allocator.free(id);
            cb(id, new_state) catch return @bitCast(@as(u32, 0x80004005));
        }

        return 0;
    }

    fn onDeviceAdded(self: *Self, device_id: ?[*:0]const u16) callconv(.winapi) HRESULT {
        if (self.callback.onDeviceAdded) |cb| {
            const id = wideToUtf8(device_id) catch return 0;
            defer std.heap.page_allocator.free(id);
            cb(id) catch return @bitCast(@as(u32, 0x80004005));
        }

        return 0;
    }

    fn onDeviceRemoved(self: *Self, device_id: ?[*:0]const u16) callconv(.winapi) HRESULT {
        if (self.callback.onDeviceRemoved) |cb| {
            const id = wideToUtf8(device_id) catch return 0;
            defer std.heap.page_allocator.free(id);
            cb(id) catch return @bitCast(@as(u32, 0x80004005));
        }

        return 0;
    }

    fn onDefaultDeviceChanged(self: *Self, flow: EDataFlow, role: ERole, device_id: ?[*:0]const u16) callconv(.winapi) HRESULT {
        if (self.callback.onDefaultDeviceChanged) |cb| {
            const id = wideToUtf8(device_id) catch return 0;
            defer std.heap.page_allocator.free(id);
            cb(flow, role, id) catch return @bitCast(@as(u32, 0x80004005));
        }

        return 0;
    }

    fn onPropertyValueChanged(self: *Self, device_id: ?[*:0]const u16, key: PROPERTYKEY) callconv(.winapi) HRESULT {
        if (self.callback.onPropertyValueChanged) |cb| {
            const id = wideToUtf8(device_id) catch return 0;
            defer std.heap.page_allocator.free(id);
            cb(id, key) catch return @bitCast(@as(u32, 0x80004005));
        }

        return 0;
    }

    fn wideToUtf8(wide: ?[*:0]const u16) ![]u8 {
        if (wide == null) return std.heap.page_allocator.dupe(u8, "");

        const ptr = wide.?;
        var len: usize = 0;

        while (ptr[len] != 0) : (len += 1) {}

        return std.unicode.utf16LeToUtf8Alloc(std.heap.page_allocator, ptr[0..len]);
    }

    const vtable_instance = IMMNotificationClientVtbl{
        .QueryInterface = @ptrCast(&queryInterface),
        .AddRef = @ptrCast(&addRef),
        .Release = @ptrCast(&release),
        .OnDeviceStateChanged = @ptrCast(&onDeviceStateChanged),
        .OnDeviceAdded = @ptrCast(&onDeviceAdded),
        .OnDeviceRemoved = @ptrCast(&onDeviceRemoved),
        .OnDefaultDeviceChanged = @ptrCast(&onDefaultDeviceChanged),
        .OnPropertyValueChanged = @ptrCast(&onPropertyValueChanged),
    };
};
