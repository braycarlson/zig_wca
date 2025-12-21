const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");
const IMMDevice = @import("IMMDevice.zig").IMMDevice;
const IMMDeviceCollection = @import("IMMDeviceCollection.zig").IMMDeviceCollection;

const GUID = guid.GUID;
const HRESULT = types.HRESULT;
const EDataFlow = types.EDataFlow;
const ERole = types.ERole;

const IMMDeviceEnumeratorVtbl = extern struct {
    base: com.IUnknownVtbl,
    EnumAudioEndpoints: *const fn (
        *IMMDeviceEnumerator,
        EDataFlow,
        u32,
        *?*IMMDeviceCollection,
    ) callconv(.winapi) HRESULT,
    GetDefaultAudioEndpoint: *const fn (
        *IMMDeviceEnumerator,
        EDataFlow,
        ERole,
        *?*IMMDevice,
    ) callconv(.winapi) HRESULT,
    GetDevice: *const fn (
        *IMMDeviceEnumerator,
        ?[*:0]const u16,
        *?*IMMDevice,
    ) callconv(.winapi) HRESULT,
    RegisterEndpointNotificationCallback: *const fn (
        *IMMDeviceEnumerator,
        ?*anyopaque,
    ) callconv(.winapi) HRESULT,
    UnregisterEndpointNotificationCallback: *const fn (
        *IMMDeviceEnumerator,
        ?*anyopaque,
    ) callconv(.winapi) HRESULT,
};

pub const IMMDeviceEnumerator = extern struct {
    vtable: *const IMMDeviceEnumeratorVtbl,

    const Self = @This();

    pub fn create() !*Self {
        return com.createInstance(
            Self,
            &guid.CLSID_MMDeviceEnumerator,
            &guid.IID_IMMDeviceEnumerator,
        );
    }

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn enumAudioEndpoints(
        self: *Self,
        data_flow: EDataFlow,
        state_mask: u32,
    ) wca.Error!*IMMDeviceCollection {
        var collection: ?*IMMDeviceCollection = null;
        const hr = self.vtable.EnumAudioEndpoints(self, data_flow, state_mask, &collection);
        try wca.hresultToError(hr);

        return collection orelse return wca.Error.Unexpected;
    }

    pub fn getDefaultAudioEndpoint(
        self: *Self,
        data_flow: EDataFlow,
        role: ERole,
    ) wca.Error!*IMMDevice {
        var device: ?*IMMDevice = null;
        const hr = self.vtable.GetDefaultAudioEndpoint(self, data_flow, role, &device);
        try wca.hresultToError(hr);

        return device orelse return wca.Error.Unexpected;
    }

    pub fn getDevice(self: *Self, device_id: [*:0]const u16) wca.Error!*IMMDevice {
        var device: ?*IMMDevice = null;
        const hr = self.vtable.GetDevice(self, device_id, &device);
        try wca.hresultToError(hr);

        return device orelse return wca.Error.Unexpected;
    }

    pub fn registerEndpointNotificationCallback(self: *Self, client: *anyopaque) wca.Error!void {
        const hr = self.vtable.RegisterEndpointNotificationCallback(self, client);
        try wca.hresultToError(hr);
    }

    pub fn unregisterEndpointNotificationCallback(self: *Self, client: *anyopaque) wca.Error!void {
        const hr = self.vtable.UnregisterEndpointNotificationCallback(self, client);
        try wca.hresultToError(hr);
    }
};
