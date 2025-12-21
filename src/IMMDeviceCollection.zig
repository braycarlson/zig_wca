const com = @import("com.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");
const IMMDevice = @import("IMMDevice.zig").IMMDevice;

const HRESULT = types.HRESULT;

const IMMDeviceCollectionVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetCount: *const fn (*IMMDeviceCollection, *u32) callconv(.winapi) HRESULT,
    Item: *const fn (*IMMDeviceCollection, u32, *?*IMMDevice) callconv(.winapi) HRESULT,
};

pub const IMMDeviceCollection = extern struct {
    vtable: *const IMMDeviceCollectionVtbl,

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

    pub fn item(self: *Self, index: u32) wca.Error!*IMMDevice {
        var device: ?*IMMDevice = null;
        const hr = self.vtable.Item(self, index, &device);
        try wca.hresultToError(hr);

        return device orelse return wca.Error.Unexpected;
    }

    pub fn iterator(self: *Self) Iterator {
        return .{ .collection = self, .index = 0 };
    }

    pub const Iterator = struct {
        collection: *IMMDeviceCollection,
        index: u32,

        pub fn next(self: *Iterator) ?*IMMDevice {
            const count = self.collection.getCount() catch return null;
            if (self.index >= count) return null;

            const device = self.collection.item(self.index) catch return null;
            self.index += 1;

            return device;
        }
    };
};
