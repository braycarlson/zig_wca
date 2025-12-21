pub const ShareMode = enum(u32) {
    Shared = 0,
    Exclusive = 1,
};

pub const StreamFlags = struct {
    pub const CrossProcess: u32 = 0x00010000;
    pub const Loopback: u32 = 0x00020000;
    pub const EventCallback: u32 = 0x00040000;
    pub const NoPersist: u32 = 0x00080000;
    pub const RateAdjust: u32 = 0x00100000;
    pub const AutoConvertPcm: u32 = 0x80000000;
    pub const SrcDefaultQuality: u32 = 0x08000000;
};

pub const BufferFlags = struct {
    pub const DataDiscontinuity: u32 = 0x1;
    pub const Silent: u32 = 0x2;
    pub const TimestampError: u32 = 0x4;
};

pub const StorageMode = struct {
    pub const Read: u32 = 0x0;
    pub const Write: u32 = 0x1;
    pub const ReadWrite: u32 = 0x2;
};

pub const EndpointFormFactor = enum(u32) {
    RemoteNetworkDevice = 0,
    Speakers = 1,
    LineLevel = 2,
    Headphones = 3,
    Microphone = 4,
    Headset = 5,
    Handset = 6,
    UnknownDigitalPassthrough = 7,
    SPDIF = 8,
    DigitalAudioDisplayDevice = 9,
    UnknownFormFactor = 10,
};

pub fn referenceTimeToNs(reference_time: i64) i64 {
    return reference_time * 100;
}

pub fn nsToReferenceTime(ns: i64) i64 {
    return @divFloor(ns, 100);
}

pub fn referenceTimeToMs(reference_time: i64) i64 {
    return @divFloor(reference_time, 10000);
}

pub fn msToReferenceTime(ms: i64) i64 {
    return ms * 10000;
}

pub fn referenceTimeToSeconds(reference_time: i64) f64 {
    return @as(f64, @floatFromInt(reference_time)) / 10_000_000.0;
}

pub fn secondsToReferenceTime(seconds: f64) i64 {
    return @intFromFloat(seconds * 10_000_000.0);
}
