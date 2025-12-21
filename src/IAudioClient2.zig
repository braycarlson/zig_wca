const std = @import("std");
const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const constants = @import("constants.zig");
const wca = @import("wca.zig");
const IAudioClient = @import("IAudioClient.zig").IAudioClient;
const IAudioRenderClient = @import("IAudioRenderClient.zig").IAudioRenderClient;
const IAudioCaptureClient = @import("IAudioCaptureClient.zig").IAudioCaptureClient;
const IAudioClock = @import("IAudioClock.zig").IAudioClock;
const ISimpleAudioVolume = @import("ISimpleAudioVolume.zig").ISimpleAudioVolume;

const GUID = guid.GUID;
const HRESULT = types.HRESULT;
const REFERENCE_TIME = types.REFERENCE_TIME;
const WAVEFORMATEX = types.WAVEFORMATEX;
const AudioClientProperties = types.AudioClientProperties;
const ShareMode = constants.ShareMode;
const IAudioClientVtbl = @import("IAudioClient.zig").IAudioClientVtbl;

pub const IAudioClient2Vtbl = extern struct {
    base: IAudioClientVtbl,
    IsOffloadCapable: *const fn (*IAudioClient2, u32, *i32) callconv(.winapi) HRESULT,
    SetClientProperties: *const fn (*IAudioClient2, *const AudioClientProperties) callconv(.winapi) HRESULT,
    GetBufferSizeLimits: *const fn (
        *IAudioClient2,
        *const WAVEFORMATEX,
        i32,
        *REFERENCE_TIME,
        *REFERENCE_TIME,
    ) callconv(.winapi) HRESULT,
};

pub const IAudioClient2 = extern struct {
    vtable: *const IAudioClient2Vtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn asAudioClient(self: *Self) *IAudioClient {
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

    pub fn isOffloadCapable(self: *Self, category: u32) wca.Error!bool {
        var capable: i32 = 0;
        const hr = self.vtable.IsOffloadCapable(self, category, &capable);
        try wca.hresultToError(hr);

        return capable != 0;
    }

    pub fn setClientProperties(self: *Self, properties: *const AudioClientProperties) wca.Error!void {
        const hr = self.vtable.SetClientProperties(self, properties);
        try wca.hresultToError(hr);
    }

    pub fn getBufferSizeLimits(
        self: *Self,
        format: *const WAVEFORMATEX,
        event_driven: bool,
    ) wca.Error!struct { min: REFERENCE_TIME, max: REFERENCE_TIME } {
        var min: REFERENCE_TIME = 0;
        var max: REFERENCE_TIME = 0;

        const hr = self.vtable.GetBufferSizeLimits(
            self,
            format,
            if (event_driven) 1 else 0,
            &min,
            &max,
        );

        try wca.hresultToError(hr);

        return .{ .min = min, .max = max };
    }
};
