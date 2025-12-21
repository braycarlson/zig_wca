pub const GUID = extern struct {
    data1: u32,
    data2: u16,
    data3: u16,
    data4: [8]u8,

    pub fn eql(self: GUID, other: GUID) bool {
        return self.data1 == other.data1 and
            self.data2 == other.data2 and
            self.data3 == other.data3 and
            @as(u64, @bitCast(self.data4)) == @as(u64, @bitCast(other.data4));
    }
};

fn parseGuid(comptime str: []const u8) GUID {
    comptime {
        if (str.len != 36 and str.len != 38) @compileError("Invalid GUID string length");
        const s = if (str[0] == '{') str[1..37] else str[0..36];

        return GUID{
            .data1 = parseHex(u32, s[0..8]),
            .data2 = parseHex(u16, s[9..13]),
            .data3 = parseHex(u16, s[14..18]),
            .data4 = .{
                parseHex(u8, s[19..21]),
                parseHex(u8, s[21..23]),
                parseHex(u8, s[24..26]),
                parseHex(u8, s[26..28]),
                parseHex(u8, s[28..30]),
                parseHex(u8, s[30..32]),
                parseHex(u8, s[32..34]),
                parseHex(u8, s[34..36]),
            },
        };
    }
}

fn parseHex(comptime T: type, comptime str: []const u8) T {
    comptime {
        var result: T = 0;

        for (str) |c| {
            const digit: T = switch (c) {
                '0'...'9' => c - '0',
                'a'...'f' => c - 'a' + 10,
                'A'...'F' => c - 'A' + 10,
                else => @compileError("Invalid hex character"),
            };

            result = result * 16 + digit;
        }

        return result;
    }
}

pub const CLSID_MMDeviceEnumerator = parseGuid("{BCDE0395-E52F-467C-8E3D-C4579291692E}");

pub const IID_IUnknown = parseGuid("{00000000-0000-0000-C000-000000000046}");
pub const IID_IMMNotificationClient = parseGuid("{7991EEC9-7E89-4D85-8390-6C703CEC60C0}");
pub const IID_IMMDevice = parseGuid("{D666063F-1587-4E43-81F1-B948E807363F}");
pub const IID_IMMDeviceCollection = parseGuid("{0BD7A1BE-7A1A-44DB-8397-CC5392387B5E}");
pub const IID_IMMEndpoint = parseGuid("{1BE09788-6894-4089-8586-9A2A6C265AC5}");
pub const IID_IMMDeviceEnumerator = parseGuid("{A95664D2-9614-4F35-A746-DE8DB63617E6}");

pub const IID_IAudioClient = parseGuid("{1CB9AD4C-DBFA-4c32-B178-C2F568A703B2}");
pub const IID_IAudioClient2 = parseGuid("{726778CD-F60A-4eda-82DE-E47610CD78AA}");
pub const IID_IAudioClient3 = parseGuid("{7ED4EE07-8E67-4CD4-8C1A-2B7A5987AD42}");
pub const IID_IAudioRenderClient = parseGuid("{F294ACFC-3146-4483-A7BF-ADDCA7C260E2}");
pub const IID_IAudioCaptureClient = parseGuid("{C8ADBD64-E71E-48a0-A4DE-185C395CD317}");
pub const IID_IAudioClock = parseGuid("{CD63314F-3FBA-4a1b-812C-EF96358728E7}");
pub const IID_IAudioClock2 = parseGuid("{6f49ff73-6727-49ac-a008-d98cf5e70048}");
pub const IID_IAudioClockAdjustment = parseGuid("{f6e4c0a0-46d9-4fb8-be21-57a3ef2b626c}");
pub const IID_ISimpleAudioVolume = parseGuid("{87CE5498-68D6-44E5-9215-6DA47EF883D8}");
pub const IID_IAudioStreamVolume = parseGuid("{93014887-242D-4068-8A15-CF5E93B90FE3}");
pub const IID_IChannelAudioVolume = parseGuid("{1C158861-B533-4B30-B1CF-E853E51C59B8}");

pub const IID_IAudioSessionEvents = parseGuid("{24918ACC-64B3-37C1-8CA9-74A66E9957A8}");
pub const IID_IAudioSessionControl = parseGuid("{F4B1A599-7266-4319-A8CA-E70ACB11E8CD}");
pub const IID_IAudioSessionControl2 = parseGuid("{bfb7ff88-7239-4fc9-8fa2-07c950be9c6d}");
pub const IID_IAudioSessionManager = parseGuid("{BFA971F1-4D5E-40BB-935E-967039BFBEE4}");
pub const IID_IAudioSessionManager2 = parseGuid("{77AA99A0-1BD6-484F-8BC7-2C654C9A9B6F}");
pub const IID_IAudioSessionEnumerator = parseGuid("{E2F5BB11-0570-40CA-ACDD-3AA01277DEE8}");
pub const IID_IAudioVolumeDuckNotification = parseGuid("{C3B284D4-6D39-4359-B3CF-B56DDB3BB39C}");
pub const IID_IAudioSessionNotification = parseGuid("{641DD20B-4D41-49CC-ABA3-174B9477BB08}");

pub const IID_IAudioEndpointVolume = parseGuid("{5CDF2C82-841E-4546-9722-0CF74078229A}");
pub const IID_IAudioMeterInformation = parseGuid("{C02216F6-8C67-4B5B-9D00-D008E73E0064}");
pub const IID_IAudioEndpointVolumeCallback = parseGuid("{657804FA-D6AD-4496-8A60-352752AF4F89}");

pub const IID_IPropertyStore = parseGuid("{886d8eeb-8cf2-4446-8d02-cdba1dbdcf99}");

pub const IID_IDeviceTopology = parseGuid("{2A07407E-6497-4A18-9787-32F79BD0D98F}");
pub const IID_IPart = parseGuid("{AE2DE0E4-5BCA-4F2D-AA46-5D13F8FDB3A9}");
pub const IID_IPartsList = parseGuid("{6DAA848C-5EB0-45CC-AEA5-998A2CDA1FFB}");
pub const IID_IConnector = parseGuid("{9c2c4058-23f5-41de-877a-df3af236a09e}");
pub const IID_ISubunit = parseGuid("{82149A85-DBA6-4487-86BB-EA8F7FEFCC71}");
pub const IID_IControlInterface = parseGuid("{45d37c3f-5140-444a-ae24-400789f3cbf3}");
pub const IID_IControlChangeNotify = parseGuid("{A09513ED-C709-4d21-BD7B-5F34C47F3947}");
pub const IID_IKsControl = parseGuid("{28F54685-06FD-11D2-B27A-00A0C9223196}");
pub const IID_IPerChannelDbLevel = parseGuid("{C2F8E001-F205-4BC9-99BC-C13B1E048CCB}");
pub const IID_IAudioVolumeLevel = parseGuid("{7FB7B48F-531D-44A2-BCB3-5AD5A134B3DC}");
pub const IID_IAudioChannelConfig = parseGuid("{BB11C46F-EC28-493C-B88A-5DB88062CE98}");
pub const IID_IAudioLoudness = parseGuid("{7D8B1437-DD53-4350-9C1B-1EE2890BD938}");
pub const IID_IAudioInputSelector = parseGuid("{4F03DC02-5E6E-4653-8F72-A030C123D598}");
pub const IID_IAudioOutputSelector = parseGuid("{BB515F69-94A7-429e-8B9C-271B3F11A3AB}");
pub const IID_IAudioMute = parseGuid("{DF45AEEA-B74A-4B6B-AFAD-2366B6AA012E}");
pub const IID_IAudioBass = parseGuid("{A2B1A1D9-4DB3-425D-A2B2-BD335CB3E2E5}");
pub const IID_IAudioMidrange = parseGuid("{5E54B6D7-B44B-40D9-9A9E-E691D9CE6EDF}");
pub const IID_IAudioTreble = parseGuid("{0A717812-694E-4907-B74B-BAFA5CFDCA7B}");
pub const IID_IAudioAutoGainControl = parseGuid("{85401FD4-6DE4-4b9d-9869-2D6753A82F3C}");
pub const IID_IAudioPeakMeter = parseGuid("{DD79923C-0599-45e0-B8B6-C8DF7DB6E796}");
pub const IID_IDeviceSpecificProperty = parseGuid("{3B22BCBF-2586-4af0-8583-205D391B807C}");
pub const IID_IKsFormatSupport = parseGuid("{3CB4A69D-BB6F-4D2B-95B7-452D2C155DB5}");
pub const IID_IKsJackDescription = parseGuid("{4509F757-2D46-4637-8E62-CE7DB944F57B}");
pub const IID_IKsJackDescription2 = parseGuid("{478F3A9B-E0C9-4827-9228-6F5505FFE76A}");
pub const IID_IKsJackSinkInformation = parseGuid("{D9BD72ED-290F-4581-9FF3-61027A8FE532}");

pub const CLSID_DeviceTopology = parseGuid("{1DF639D0-5EC1-47AA-9379-828DC1AA8C59}");
