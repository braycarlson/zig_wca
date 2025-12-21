const com = @import("com.zig");
const types = @import("types.zig");
const wca = @import("wca.zig");

const HRESULT = types.HRESULT;
const EDataFlow = types.EDataFlow;

const IMMEndpointVtbl = extern struct {
    base: com.IUnknownVtbl,
    GetDataFlow: *const fn (*IMMEndpoint, *EDataFlow) callconv(.winapi) HRESULT,
};

pub const IMMEndpoint = extern struct {
    vtable: *const IMMEndpointVtbl,

    const Self = @This();

    pub fn release(self: *Self) u32 {
        return @as(*com.IUnknown, @ptrCast(self)).release();
    }

    pub fn getDataFlow(self: *Self) wca.Error!EDataFlow {
        var data_flow: EDataFlow = .Render;
        const hr = self.vtable.GetDataFlow(self, &data_flow);
        try wca.hresultToError(hr);

        return data_flow;
    }
};
