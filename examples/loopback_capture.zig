const std = @import("std");
const wca = @import("wca");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try wca.com.initialize(wca.com.COINIT_APARTMENTTHREADED);
    defer wca.com.uninitialize();

    const enumerator = try wca.IMMDeviceEnumerator.create();
    defer _ = enumerator.release();

    const device = try enumerator.getDefaultAudioEndpoint(.Render, .Console);
    defer _ = device.release();

    const property_store = try device.openPropertyStore(wca.constants.StorageMode.Read);
    defer _ = property_store.release();

    if (try property_store.getStringValue(&wca.property.PKEY_Device_FriendlyName, allocator)) |name| {
        defer allocator.free(name);
        std.debug.print("Loopback capture from: {s}\n", .{name});
    }

    const audio_client = try device.activateAudioClient();
    defer _ = audio_client.release();

    const mix_format = try audio_client.getMixFormat();
    defer wca.com.taskMemFree(@ptrCast(mix_format));

    std.debug.print("Format: {d} channels, {d} Hz, {d} bits\n", .{
        mix_format.channels,
        mix_format.samples_per_sec,
        mix_format.bits_per_sample,
    });

    const period = try audio_client.getDevicePeriod();
    const latency_ns = wca.constants.referenceTimeToNs(period.default);

    try audio_client.initialize(
        .Shared,
        wca.constants.StreamFlags.Loopback,
        wca.constants.msToReferenceTime(400),
        0,
        mix_format,
        null,
    );

    const buffer_size = try audio_client.getBufferSize();
    std.debug.print("Buffer size: {d} frames\n", .{buffer_size});

    const capture_client = try audio_client.getCaptureClient();
    defer _ = capture_client.release();

    try audio_client.start();
    defer audio_client.stop() catch {};

    std.debug.print("Capturing system audio for 5 seconds...\n", .{});

    var frames_captured: u64 = 0;
    const target_frames = mix_format.samples_per_sec * 5;
    var peak_level: f32 = 0;

    while (frames_captured < target_frames) {
        const packet_size = try capture_client.getNextPacketSize();

        if (packet_size > 0) {
            const buffer = try capture_client.getBuffer();
            defer capture_client.releaseBuffer(buffer.num_frames) catch {};

            if (!buffer.isSilent()) {
                const data_slice = buffer.slice(mix_format.block_align);
                const samples: []const i16 = @alignCast(std.mem.bytesAsSlice(i16, data_slice));
                for (samples) |sample| {
                    const level = @abs(@as(f32, @floatFromInt(sample)) / 32768.0);
                    if (level > peak_level) peak_level = level;
                }
            }

            frames_captured += buffer.num_frames;
        } else {
            std.Thread.sleep(@intCast(@divTrunc(latency_ns, 2)));
        }
    }

    std.debug.print("Peak level: {d:.2}%\n", .{peak_level * 100});
    std.debug.print("Done.\n", .{});
}
