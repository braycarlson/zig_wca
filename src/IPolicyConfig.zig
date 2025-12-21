const std = @import("std");
const com = @import("com.zig");
const guid = @import("guid.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");

const GUID = guid.GUID;
const HRESULT = types.HRESULT;
const ERole = types.ERole;

pub const CLSID_PolicyConfigVista = GUID{
    .data1 = 0x294935CE,
    .data2 = 0xF637,
    .data3 = 0x4E7C,
    .data4 = .{ 0xA4, 0x1B, 0xAB, 0x25, 0x54, 0x60, 0xB8, 0x62 },
};

pub const IID_IPolicyConfigVista = GUID{
    .data1 = 0x568b9108,
    .data2 = 0x44bf,
    .data3 = 0x40b4,
    .data4 = .{ 0x90, 0x06, 0x86, 0xaf, 0xe5, 0xb5, 0xa6, 0x20 },
};

const IPolicyConfigVistaVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetMixFormat: *const fn (*IPolicyConfigVista, ?[*:0]const u16, *?*types.WAVEFORMATEX) callconv(.winapi) HRESULT,
    GetDeviceFormat: *const fn (*IPolicyConfigVista, ?[*:0]const u16, i32, *?*types.WAVEFORMATEX) callconv(.winapi) HRESULT,
    ResetDeviceFormat: *const fn (*IPolicyConfigVista, ?[*:0]const u16) callconv(.winapi) HRESULT,
    SetDeviceFormat: *const fn (*IPolicyConfigVista, ?[*:0]const u16, *types.WAVEFORMATEX, *types.WAVEFORMATEX) callconv(.winapi) HRESULT,
    GetProcessingPeriod: *const fn (*IPolicyConfigVista, ?[*:0]const u16, i32, *i64, *i64) callconv(.winapi) HRESULT,
    SetProcessingPeriod: *const fn (*IPolicyConfigVista, ?[*:0]const u16, *i64) callconv(.winapi) HRESULT,
    GetShareMode: *const fn (*IPolicyConfigVista, ?[*:0]const u16, *u32) callconv(.winapi) HRESULT,
    SetShareMode: *const fn (*IPolicyConfigVista, ?[*:0]const u16, *u32) callconv(.winapi) HRESULT,
    GetPropertyValue: *const fn (*IPolicyConfigVista, ?[*:0]const u16, i32, *const GUID, u32, *anyopaque) callconv(.winapi) HRESULT,
    SetPropertyValue: *const fn (*IPolicyConfigVista, ?[*:0]const u16, i32, *const GUID, u32, *anyopaque) callconv(.winapi) HRESULT,
    SetDefaultEndpoint: *const fn (*IPolicyConfigVista, ?[*:0]const u16, ERole) callconv(.winapi) HRESULT,
    SetEndpointVisibility: *const fn (*IPolicyConfigVista, ?[*:0]const u16, i32) callconv(.winapi) HRESULT,
};

pub const IPolicyConfigVista = extern struct {
    vtable: *const IPolicyConfigVistaVtbl,

    const Self = @This();

    pub fn create() wca.Error!*Self {
        return com.createInstance(
            Self,
            &CLSID_PolicyConfigVista,
            &IID_IPolicyConfigVista,
        );
    }

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn setDefaultEndpoint(self: *Self, device_id: [*:0]const u16, role: ERole) wca.Error!void {
        const hr = self.vtable.SetDefaultEndpoint(self, device_id, role);
        try wca.hresultToError(hr);
    }

    pub fn setDefaultEndpointAllRoles(self: *Self, device_id: [*:0]const u16) wca.Error!void {
        try self.setDefaultEndpoint(device_id, .Console);
        try self.setDefaultEndpoint(device_id, .Multimedia);
        try self.setDefaultEndpoint(device_id, .Communications);
    }
};
