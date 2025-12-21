const com = @import("com.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");
const IAudioSessionControl = @import("IAudioSessionControl.zig").IAudioSessionControl;

const HRESULT = types.HRESULT;

const IAudioSessionEnumeratorVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetCount: *const fn (*IAudioSessionEnumerator, *i32) callconv(.winapi) HRESULT,
    GetSession: *const fn (*IAudioSessionEnumerator, i32, *?*IAudioSessionControl) callconv(.winapi) HRESULT,
};

pub const IAudioSessionEnumerator = extern struct {
    vtable: *const IAudioSessionEnumeratorVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn getCount(self: *Self) wca.Error!i32 {
        var count: i32 = 0;
        const hr = self.vtable.GetCount(self, &count);
        try wca.hresultToError(hr);
        return count;
    }

    pub fn getSession(self: *Self, index: i32) wca.Error!*IAudioSessionControl {
        var session: ?*IAudioSessionControl = null;
        const hr = self.vtable.GetSession(self, index, &session);
        try wca.hresultToError(hr);
        return session orelse return wca.Error.Unexpected;
    }

    pub fn iterator(self: *Self) Iterator {
        return .{ .enumerator = self, .index = 0 };
    }

    pub const Iterator = struct {
        enumerator: *IAudioSessionEnumerator,
        index: i32,

        pub fn next(self: *Iterator) ?*IAudioSessionControl {
            const count = self.enumerator.getCount() catch return null;
            if (self.index >= count) return null;
            const session = self.enumerator.getSession(self.index) catch return null;
            self.index += 1;
            return session;
        }
    };
};
