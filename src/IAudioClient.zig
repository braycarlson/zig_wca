const std = @import("std");
const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const constants = @import("constants.zig");
const wca = @import("wca.zig");
const IAudioRenderClient = @import("IAudioRenderClient.zig").IAudioRenderClient;
const IAudioCaptureClient = @import("IAudioCaptureClient.zig").IAudioCaptureClient;
const IAudioClock = @import("IAudioClock.zig").IAudioClock;
const ISimpleAudioVolume = @import("ISimpleAudioVolume.zig").ISimpleAudioVolume;

const GUID = guid.GUID;
const HRESULT = types.HRESULT;
const REFERENCE_TIME = types.REFERENCE_TIME;
const WAVEFORMATEX = types.WAVEFORMATEX;
const ShareMode = constants.ShareMode;

pub const IAudioClientVtbl = extern struct {
    base: com.IUnknownVtbl,
    Initialize: *const fn (
        *IAudioClient,
        ShareMode,
        u32,
        REFERENCE_TIME,
        REFERENCE_TIME,
        *const WAVEFORMATEX,
        ?*const GUID,
    ) callconv(.winapi) HRESULT,
    GetBufferSize: *const fn (*IAudioClient, *u32) callconv(.winapi) HRESULT,
    GetStreamLatency: *const fn (*IAudioClient, *REFERENCE_TIME) callconv(.winapi) HRESULT,
    GetCurrentPadding: *const fn (*IAudioClient, *u32) callconv(.winapi) HRESULT,
    IsFormatSupported: *const fn (
        *IAudioClient,
        ShareMode,
        *const WAVEFORMATEX,
        *?*WAVEFORMATEX,
    ) callconv(.winapi) HRESULT,
    GetMixFormat: *const fn (*IAudioClient, *?*WAVEFORMATEX) callconv(.winapi) HRESULT,
    GetDevicePeriod: *const fn (
        *IAudioClient,
        ?*REFERENCE_TIME,
        ?*REFERENCE_TIME,
    ) callconv(.winapi) HRESULT,
    Start: *const fn (*IAudioClient) callconv(.winapi) HRESULT,
    Stop: *const fn (*IAudioClient) callconv(.winapi) HRESULT,
    Reset: *const fn (*IAudioClient) callconv(.winapi) HRESULT,
    SetEventHandle: *const fn (*IAudioClient, std.os.windows.HANDLE) callconv(.winapi) HRESULT,
    GetService: *const fn (*IAudioClient, *const GUID, *?*anyopaque) callconv(.winapi) HRESULT,
};

pub const IAudioClient = extern struct {
    vtable: *const IAudioClientVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
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
        const hr = self.vtable.Initialize(
            self,
            share_mode,
            stream_flags,
            buffer_duration,
            periodicity,
            format,
            session_guid,
        );

        try wca.hresultToError(hr);
    }

    pub fn getBufferSize(self: *Self) wca.Error!u32 {
        var size: u32 = 0;
        const hr = self.vtable.GetBufferSize(self, &size);
        try wca.hresultToError(hr);

        return size;
    }

    pub fn getStreamLatency(self: *Self) wca.Error!REFERENCE_TIME {
        var latency: REFERENCE_TIME = 0;
        const hr = self.vtable.GetStreamLatency(self, &latency);
        try wca.hresultToError(hr);

        return latency;
    }

    pub fn getCurrentPadding(self: *Self) wca.Error!u32 {
        var padding: u32 = 0;
        const hr = self.vtable.GetCurrentPadding(self, &padding);
        try wca.hresultToError(hr);

        return padding;
    }

    pub fn isFormatSupported(
        self: *Self,
        share_mode: ShareMode,
        format: *const WAVEFORMATEX,
    ) wca.Error!?*WAVEFORMATEX {
        var closest: ?*WAVEFORMATEX = null;
        const hr = self.vtable.IsFormatSupported(self, share_mode, format, &closest);

        if (hr == 0) return null;
        if (hr == 1) return closest;

        try wca.hresultToError(hr);

        return null;
    }

    pub fn getMixFormat(self: *Self) wca.Error!*WAVEFORMATEX {
        var format: ?*WAVEFORMATEX = null;
        const hr = self.vtable.GetMixFormat(self, &format);
        try wca.hresultToError(hr);

        return format orelse return wca.Error.Unexpected;
    }

    pub fn getDevicePeriod(self: *Self) wca.Error!struct { default: REFERENCE_TIME, minimum: REFERENCE_TIME } {
        var default: REFERENCE_TIME = 0;
        var minimum: REFERENCE_TIME = 0;

        const hr = self.vtable.GetDevicePeriod(self, &default, &minimum);
        try wca.hresultToError(hr);

        return .{ .default = default, .minimum = minimum };
    }

    pub fn start(self: *Self) wca.Error!void {
        const hr = self.vtable.Start(self);
        try wca.hresultToError(hr);
    }

    pub fn stop(self: *Self) wca.Error!void {
        const hr = self.vtable.Stop(self);
        try wca.hresultToError(hr);
    }

    pub fn reset(self: *Self) wca.Error!void {
        const hr = self.vtable.Reset(self);
        try wca.hresultToError(hr);
    }

    pub fn setEventHandle(self: *Self, handle: std.os.windows.HANDLE) wca.Error!void {
        const hr = self.vtable.SetEventHandle(self, handle);
        try wca.hresultToError(hr);
    }

    pub fn getService(self: *Self, comptime T: type, iid: *const GUID) wca.Error!*T {
        var obj: ?*anyopaque = null;
        const hr = self.vtable.GetService(self, iid, &obj);
        try wca.hresultToError(hr);

        return @ptrCast(@alignCast(obj orelse return wca.Error.Unexpected));
    }

    pub fn getRenderClient(self: *Self) wca.Error!*IAudioRenderClient {
        return self.getService(IAudioRenderClient, &guid.IID_IAudioRenderClient);
    }

    pub fn getCaptureClient(self: *Self) wca.Error!*IAudioCaptureClient {
        return self.getService(IAudioCaptureClient, &guid.IID_IAudioCaptureClient);
    }

    pub fn getClock(self: *Self) wca.Error!*IAudioClock {
        return self.getService(IAudioClock, &guid.IID_IAudioClock);
    }

    pub fn getSimpleVolume(self: *Self) wca.Error!*ISimpleAudioVolume {
        return self.getService(ISimpleAudioVolume, &guid.IID_ISimpleAudioVolume);
    }
};
