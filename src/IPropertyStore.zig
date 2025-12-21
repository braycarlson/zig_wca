const std = @import("std");
const com = @import("com.zig");
const types = @import("types.zig");
const property = @import("property.zig");
const wca = @import("wca.zig");

const HRESULT = types.HRESULT;
const PROPERTYKEY = property.PROPERTYKEY;
const PROPVARIANT = property.PROPVARIANT;

const IPropertyStoreVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetCount: *const fn (*IPropertyStore, *u32) callconv(.winapi) HRESULT,
    GetAt: *const fn (*IPropertyStore, u32, *PROPERTYKEY) callconv(.winapi) HRESULT,
    GetValue: *const fn (*IPropertyStore, *const PROPERTYKEY, *PROPVARIANT) callconv(.winapi) HRESULT,
    SetValue: *const fn (*IPropertyStore, *const PROPERTYKEY, *const PROPVARIANT) callconv(.winapi) HRESULT,
    Commit: *const fn (*IPropertyStore) callconv(.winapi) HRESULT,
};

pub const IPropertyStore = extern struct {
    vtable: *const IPropertyStoreVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn getCount(self: *Self) wca.Error!u32 {
        var count: u32 = 0;
        const hr = self.vtable.GetCount(self, &count);
        try wca.hresultToError(hr);

        return count;
    }

    pub fn getAt(self: *Self, index: u32) wca.Error!PROPERTYKEY {
        var key: PROPERTYKEY = undefined;
        const hr = self.vtable.GetAt(self, index, &key);
        try wca.hresultToError(hr);

        return key;
    }

    pub fn getValue(self: *Self, key: *const PROPERTYKEY) wca.Error!PROPVARIANT {
        var pv: PROPVARIANT = std.mem.zeroes(PROPVARIANT);
        const hr = self.vtable.GetValue(self, key, &pv);
        try wca.hresultToError(hr);

        return pv;
    }

    pub fn getStringValue(
        self: *Self,
        key: *const PROPERTYKEY,
        allocator: std.mem.Allocator,
    ) wca.Error!?[]u8 {
        var pv = try self.getValue(key);
        defer pv.clear();

        return pv.getString(allocator) catch return wca.Error.Unexpected;
    }
};
