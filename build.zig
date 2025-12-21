const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const wca_module = b.addModule("wca", .{
        .root_source_file = b.path("src/wca.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = "zig-wca",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/wca.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    b.installArtifact(lib);

    const examples = [_]struct { name: []const u8, path: []const u8 }{
        .{ .name = "render_shared", .path = "examples/render_shared.zig" },
        .{ .name = "capture_shared", .path = "examples/capture_shared.zig" },
        .{ .name = "loopback_capture", .path = "examples/loopback_capture.zig" },
        .{ .name = "enumerate_devices", .path = "examples/enumerate_devices.zig" },
        .{ .name = "enumerate_sessions", .path = "examples/enumerate_sessions.zig" },
        .{ .name = "endpoint_volume", .path = "examples/endpoint_volume.zig" },
        .{ .name = "device_events", .path = "examples/device_events.zig" },
    };

    for (examples) |example| {
        const exe = b.addExecutable(.{
            .name = example.name,
            .root_module = b.createModule(.{
                .root_source_file = b.path(example.path),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "wca", .module = wca_module },
                },
            }),
        });

        b.installArtifact(exe);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step(example.name, b.fmt("Run the {s} example", .{example.name}));
        run_step.dependOn(&run_cmd.step);
    }

    const unit_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/wca.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
