const std = @import("std");
const wca = @import("wca");

extern "kernel32" fn Sleep(dwMilliseconds: u32) callconv(.winapi) void;

fn onDefaultDeviceChanged(flow: wca.EDataFlow, role: wca.ERole, device_id: []const u8) anyerror!void {
    std.debug.print("Default device changed: flow={}, role={}, id={s}\n", .{ flow, role, device_id });
}

fn onDeviceAdded(device_id: []const u8) anyerror!void {
    std.debug.print("Device added: {s}\n", .{device_id});
}

fn onDeviceRemoved(device_id: []const u8) anyerror!void {
    std.debug.print("Device removed: {s}\n", .{device_id});
}

fn onDeviceStateChanged(device_id: []const u8, new_state: u32) anyerror!void {
    std.debug.print("Device state changed: {s}, state={d}\n", .{ device_id, new_state });
}

fn onPropertyValueChanged(device_id: []const u8, key: wca.property.PROPERTYKEY) anyerror!void {
    _ = key;
    std.debug.print("Property changed: {s}\n", .{device_id});
}

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try wca.com.initialize(wca.com.COINIT_APARTMENTTHREADED);
    defer wca.com.uninitialize();

    const enumerator = try wca.IMMDeviceEnumerator.create();
    defer _ = enumerator.release();

    const notification_client = try wca.IMMNotificationClient.create(allocator, .{
        .onDefaultDeviceChanged = &onDefaultDeviceChanged,
        .onDeviceAdded = &onDeviceAdded,
        .onDeviceRemoved = &onDeviceRemoved,
        .onDeviceStateChanged = &onDeviceStateChanged,
        .onPropertyValueChanged = &onPropertyValueChanged,
    });

    defer _ = notification_client.vtable.Release(notification_client);

    try enumerator.registerEndpointNotificationCallback(@ptrCast(notification_client));

    std.debug.print("Listening for device events for 60 seconds...\n", .{});
    std.debug.print("Try plugging/unplugging audio devices or changing default device.\n", .{});

    Sleep(60000);

    try enumerator.unregisterEndpointNotificationCallback(@ptrCast(notification_client));

    std.debug.print("Done.\n", .{});
}
