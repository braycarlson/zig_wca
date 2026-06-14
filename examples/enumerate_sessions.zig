const std = @import("std");
const wca = @import("wca");

pub fn main() !void {
    var gpa: std.heap.DebugAllocator(.{}) = .init;
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try wca.com.initialize(wca.com.COINIT_APARTMENTTHREADED);
    defer wca.com.uninitialize();

    const enumerator = try wca.IMMDeviceEnumerator.create();
    defer _ = enumerator.release();

    const device = try enumerator.getDefaultAudioEndpoint(.Render, .Console);
    defer _ = device.release();

    const session_manager = try device.activate(
        wca.IAudioSessionManager2,
        &wca.guid.IID_IAudioSessionManager2,
    );
    defer _ = session_manager.release();

    const session_enumerator = try session_manager.getSessionEnumerator();
    defer _ = session_enumerator.release();

    const count = try session_enumerator.getCount();
    std.debug.print("Found {d} audio sessions:\n", .{count});
    std.debug.print("----------------------------------------\n", .{});

    var i: i32 = 0;

    while (i < count) : (i += 1) {
        const session_control = try session_enumerator.getSession(i);
        defer _ = session_control.release();

        const state = try session_control.getState();

        if (try session_control.getDisplayName(allocator)) |name| {
            defer allocator.free(name);

            if (name.len > 0) {
                std.debug.print("Session {d}: {s} (state: {})\n", .{ i, name, state });
            } else {
                std.debug.print("Session {d}: <unnamed> (state: {})\n", .{ i, state });
            }
        } else {
            std.debug.print("Session {d}: <no name> (state: {})\n", .{ i, state });
        }
    }

    std.debug.print("----------------------------------------\n", .{});
    std.debug.print("Done.\n", .{});
}
