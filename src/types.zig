const GUID = @import("guid.zig").GUID;

pub const HRESULT = i32;
pub const REFERENCE_TIME = i64;

pub const EDataFlow = enum(u32) {
    Render = 0,
    Capture = 1,
    All = 2,
};

pub const ERole = enum(u32) {
    Console = 0,
    Multimedia = 1,
    Communications = 2,
};

pub const WAVEFORMATEX = extern struct {
    format_tag: u16,
    channels: u16,
    samples_per_sec: u32,
    avg_bytes_per_sec: u32,
    block_align: u16,
    bits_per_sample: u16,
    cb_size: u16,

    pub fn init(
        channels: u16,
        samples_per_sec: u32,
        bits_per_sample: u16,
    ) WAVEFORMATEX {
        const block_align = (bits_per_sample / 8) * channels;
        return .{
            .format_tag = WAVE_FORMAT_PCM,
            .channels = channels,
            .samples_per_sec = samples_per_sec,
            .avg_bytes_per_sec = samples_per_sec * @as(u32, block_align),
            .block_align = block_align,
            .bits_per_sample = bits_per_sample,
            .cb_size = 0,
        };
    }
};

pub const WAVEFORMATEXTENSIBLE = extern struct {
    format: WAVEFORMATEX,
    samples: extern union {
        valid_bits_per_sample: u16,
        samples_per_block: u16,
        reserved: u16,
    },
    channel_mask: u32,
    sub_format: GUID,
};

pub const AudioClientProperties = extern struct {
    cb_size: u32,
    is_offload: i32,
    category: AudioStreamCategory,
    options: AudioClientStreamOptions,
};

pub const AudioStreamCategory = enum(u32) {
    Other = 0,
    ForegroundOnlyMedia = 1,
    Communications = 3,
    Alerts = 4,
    SoundEffects = 5,
    GameEffects = 6,
    GameMedia = 7,
    GameChat = 8,
    Speech = 9,
    Movie = 10,
    Media = 11,
    FarFieldSpeech = 12,
    UniformSpeech = 13,
    VoiceTyping = 14,
};

pub const AudioClientStreamOptions = enum(u32) {
    None = 0,
    Raw = 1,
    MatchFormat = 2,
    Ambisonics = 4,
};

pub const WAVE_FORMAT_PCM: u16 = 0x0001;
pub const WAVE_FORMAT_IEEE_FLOAT: u16 = 0x0003;
pub const WAVE_FORMAT_EXTENSIBLE: u16 = 0xFFFE;

pub const KSDATAFORMAT_SUBTYPE_PCM = GUID{
    .data1 = 0x00000001,
    .data2 = 0x0000,
    .data3 = 0x0010,
    .data4 = .{ 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71 },
};

pub const KSDATAFORMAT_SUBTYPE_IEEE_FLOAT = GUID{
    .data1 = 0x00000003,
    .data2 = 0x0000,
    .data3 = 0x0010,
    .data4 = .{ 0x80, 0x00, 0x00, 0xaa, 0x00, 0x38, 0x9b, 0x71 },
};

pub const AudioSessionState = enum(u32) {
    Inactive = 0,
    Active = 1,
    Expired = 2,
};

pub const DeviceState = struct {
    pub const Active: u32 = 0x00000001;
    pub const Disabled: u32 = 0x00000002;
    pub const NotPresent: u32 = 0x00000004;
    pub const Unplugged: u32 = 0x00000008;
    pub const All: u32 = 0x0000000F;
};
