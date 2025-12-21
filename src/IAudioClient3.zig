const std = @import("std");
const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const constants = @import("constants.zig");
const wca = @import("wca.zig");
const IAudioClient2 = @import("IAudioClient2.zig").IAudioClient2;
const IAudioClient = @import("IAudioClient.zig").IAudioClient;
const IAudioRenderClient = @import("IAudioRenderClient.zig").IAudioRenderClient;
const IAudioCaptureClient = @import("IAudioCaptureClient.zig").IAudioCaptureClient;
const IAudioClock = @import("IAudioClock.zig").IAudioClock;
const ISimpleAudioVolume = @import("ISimpleAudioVolume.zig").ISimpleAudioVolume;

const GUID = guid.GUID;
const HRESULT = types.HRESULT;
const REFERENCE_TIME = types.REFERENCE_TIME;
const WAVEFORMATEX = types.WAVEFORMATEX;
const ShareMode = constants.ShareMode;
const IAudioClient2Vtbl = @import("IAudioClient2.zig").IAudioClient2Vtbl;

pub const IAudioClient3Vtbl = extern struct {
    base: IAudioClient2Vtbl,
    GetSharedModeEnginePeriod: *const fn (
        *IAudioClient3,
        *const WAVEFORMATEX,
        *u32,
        *u32,
        *u32,
        *u32,
    ) callconv(.winapi) HRESULT,
    GetCurrentSharedModeEnginePeriod: *const fn (
        *IAudioClient3,
        *?*WAVEFORMATEX,
        *u32,
    ) callconv(.winapi) HRESULT,
    InitializeSharedAudioStream: *const fn (
        *IAudioClient3,
        u32,
        u32,
        *const WAVEFORMATEX,
        ?*const GUID,
    ) callconv(.winapi) HRESULT,
};

pub const IAudioClient3 = extern struct {
    vtable: *const IAudioClient3Vtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn asAudioClient(self: *Self) *IAudioClient {
        return @ptrCast(self);
    }

    pub fn asAudioClient2(self: *Self) *IAudioClient2 {
        return @ptrCast(self);
    }

    pub fn initialize(
        self: *Self,
        share_mode: ShareMode,
        stream_flags: u32,
        buffer_duration: REFERENCE_TIME,
        periodicity: REFERENCE_TIME,
        format: *const WAVEFORMATEX,
        session_guid: ?*const GUID,
    ) wca.Error!void {
        return self.asAudioClient().initialize(
            share_mode,
            stream_flags,
            buffer_duration,
            periodicity,
            format,
            session_guid,
        );
    }

    pub fn getBufferSize(self: *Self) wca.Error!u32 {
        return self.asAudioClient().getBufferSize();
    }

    pub fn getStreamLatency(self: *Self) wca.Error!REFERENCE_TIME {
        return self.asAudioClient().getStreamLatency();
    }

    pub fn getCurrentPadding(self: *Self) wca.Error!u32 {
        return self.asAudioClient().getCurrentPadding();
    }

    pub fn getMixFormat(self: *Self) wca.Error!*WAVEFORMATEX {
        return self.asAudioClient().getMixFormat();
    }

    pub fn getDevicePeriod(self: *Self) wca.Error!struct { default: REFERENCE_TIME, minimum: REFERENCE_TIME } {
        return self.asAudioClient().getDevicePeriod();
    }

    pub fn start(self: *Self) wca.Error!void {
        return self.asAudioClient().start();
    }

    pub fn stop(self: *Self) wca.Error!void {
        return self.asAudioClient().stop();
    }

    pub fn reset(self: *Self) wca.Error!void {
        return self.asAudioClient().reset();
    }

    pub fn setEventHandle(self: *Self, handle: std.os.windows.HANDLE) wca.Error!void {
        return self.asAudioClient().setEventHandle(handle);
    }

    pub fn getRenderClient(self: *Self) wca.Error!*IAudioRenderClient {
        return self.asAudioClient().getRenderClient();
    }

    pub fn getCaptureClient(self: *Self) wca.Error!*IAudioCaptureClient {
        return self.asAudioClient().getCaptureClient();
    }

    pub fn getClock(self: *Self) wca.Error!*IAudioClock {
        return self.asAudioClient().getClock();
    }

    pub fn getSimpleVolume(self: *Self) wca.Error!*ISimpleAudioVolume {
        return self.asAudioClient().getSimpleVolume();
    }

    pub fn getSharedModeEnginePeriod(
        self: *Self,
        format: *const WAVEFORMATEX,
    ) wca.Error!struct {
        default_period_frames: u32,
        fundamental_period_frames: u32,
        min_period_frames: u32,
        max_period_frames: u32,
    } {
        var default: u32 = 0;
        var fundamental: u32 = 0;
        var min: u32 = 0;
        var max: u32 = 0;

        const hr = self.vtable.GetSharedModeEnginePeriod(self, format, &default, &fundamental, &min, &max);

        try wca.hresultToError(hr);

        return .{
            .default_period_frames = default,
            .fundamental_period_frames = fundamental,
            .min_period_frames = min,
            .max_period_frames = max,
        };
    }

    pub fn getCurrentSharedModeEnginePeriod(self: *Self) wca.Error!struct {
        format: *WAVEFORMATEX,
        current_period_frames: u32,
    } {
        var format: ?*WAVEFORMATEX = null;
        var period: u32 = 0;
        const hr = self.vtable.GetCurrentSharedModeEnginePeriod(self, &format, &period);

        try wca.hresultToError(hr);

        return .{
            .format = format orelse return wca.Error.Unexpected,
            .current_period_frames = period,
        };
    }

    pub fn initializeSharedAudioStream(
        self: *Self,
        stream_flags: u32,
        period_in_frames: u32,
        format: *const WAVEFORMATEX,
        session_guid: ?*const GUID,
    ) wca.Error!void {
        const hr = self.vtable.InitializeSharedAudioStream(
            self,
            stream_flags,
            period_in_frames,
            format,
            session_guid,
        );

        try wca.hresultToError(hr);
    }
};
