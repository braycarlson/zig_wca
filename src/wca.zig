pub const com = @import("com.zig");
pub const guid = @import("guid.zig");
pub const types = @import("types.zig");
pub const constants = @import("constants.zig");
pub const property = @import("property.zig");

pub const IMMDeviceEnumerator = @import("IMMDeviceEnumerator.zig").IMMDeviceEnumerator;
pub const IMMDevice = @import("IMMDevice.zig").IMMDevice;
pub const IMMDeviceCollection = @import("IMMDeviceCollection.zig").IMMDeviceCollection;
pub const IMMEndpoint = @import("IMMEndpoint.zig").IMMEndpoint;
pub const IMMNotificationClient = @import("IMMNotificationClient.zig").IMMNotificationClient;
pub const IMMNotificationClientCallback = @import("IMMNotificationClient.zig").IMMNotificationClientCallback;
pub const IPropertyStore = @import("IPropertyStore.zig").IPropertyStore;

pub const IAudioClient = @import("IAudioClient.zig").IAudioClient;
pub const IAudioClient2 = @import("IAudioClient2.zig").IAudioClient2;
pub const IAudioClient3 = @import("IAudioClient3.zig").IAudioClient3;
pub const IAudioRenderClient = @import("IAudioRenderClient.zig").IAudioRenderClient;
pub const IAudioCaptureClient = @import("IAudioCaptureClient.zig").IAudioCaptureClient;
pub const CaptureBuffer = @import("IAudioCaptureClient.zig").CaptureBuffer;
pub const IAudioClock = @import("IAudioClock.zig").IAudioClock;
pub const IAudioClock2 = @import("IAudioClock2.zig").IAudioClock2;
pub const IAudioClockAdjustment = @import("IAudioClockAdjustment.zig").IAudioClockAdjustment;

pub const IAudioEndpointVolume = @import("IAudioEndpointVolume.zig").IAudioEndpointVolume;
pub const IAudioEndpointVolumeCallback = @import("IAudioEndpointVolumeCallback.zig").IAudioEndpointVolumeCallback;
pub const AUDIO_VOLUME_NOTIFICATION_DATA = @import("IAudioEndpointVolumeCallback.zig").AUDIO_VOLUME_NOTIFICATION_DATA;
pub const IAudioMeterInformation = @import("IAudioMeterInformation.zig").IAudioMeterInformation;
pub const ISimpleAudioVolume = @import("ISimpleAudioVolume.zig").ISimpleAudioVolume;
pub const IChannelAudioVolume = @import("IChannelAudioVolume.zig").IChannelAudioVolume;
pub const IAudioStreamVolume = @import("IAudioStreamVolume.zig").IAudioStreamVolume;

pub const IAudioSessionControl = @import("IAudioSessionControl.zig").IAudioSessionControl;
pub const IAudioSessionControl2 = @import("IAudioSessionControl2.zig").IAudioSessionControl2;
pub const IAudioSessionManager = @import("IAudioSessionManager.zig").IAudioSessionManager;
pub const IAudioSessionManager2 = @import("IAudioSessionManager2.zig").IAudioSessionManager2;
pub const IAudioSessionEnumerator = @import("IAudioSessionEnumerator.zig").IAudioSessionEnumerator;
pub const IAudioSessionEvents = @import("IAudioSessionEvents.zig").IAudioSessionEvents;
pub const AudioSessionDisconnectReason = @import("IAudioSessionEvents.zig").AudioSessionDisconnectReason;
pub const IAudioSessionNotification = @import("IAudioSessionNotification.zig").IAudioSessionNotification;
pub const IAudioVolumeDuckNotification = @import("IAudioVolumeDuckNotification.zig").IAudioVolumeDuckNotification;

pub const IPolicyConfigVista = @import("IPolicyConfig.zig").IPolicyConfigVista;
pub const CLSID_PolicyConfigVista = @import("IPolicyConfig.zig").CLSID_PolicyConfigVista;
pub const IID_IPolicyConfigVista = @import("IPolicyConfig.zig").IID_IPolicyConfigVista;

pub const GUID = guid.GUID;
pub const HRESULT = types.HRESULT;
pub const REFERENCE_TIME = types.REFERENCE_TIME;
pub const WAVEFORMATEX = types.WAVEFORMATEX;
pub const WAVEFORMATEXTENSIBLE = types.WAVEFORMATEXTENSIBLE;
pub const EDataFlow = types.EDataFlow;
pub const ERole = types.ERole;
pub const AudioSessionState = types.AudioSessionState;
pub const DeviceState = types.DeviceState;
pub const PROPVARIANT = property.PROPVARIANT;
pub const PROPERTYKEY = property.PROPERTYKEY;

pub const ShareMode = constants.ShareMode;
pub const StreamFlags = constants.StreamFlags;
pub const BufferFlags = constants.BufferFlags;
pub const StorageMode = constants.StorageMode;

pub const Error = error{
    NotInitialized,
    AlreadyInitialized,
    WrongEndpointType,
    DeviceInvalidated,
    NotStopped,
    BufferTooLarge,
    OutOfOrder,
    UnsupportedFormat,
    InvalidSize,
    DeviceInUse,
    BufferOperationPending,
    ThreadNotRegistered,
    ExclusiveModeNotAllowed,
    EndpointCreateFailed,
    ServiceNotRunning,
    EventHandleNotExpected,
    ExclusiveModeOnly,
    BufferDurationPeriodNotEqual,
    EventHandleNotSet,
    IncorrectBufferSize,
    BufferSizeError,
    CpuUsageExceeded,
    BufferError,
    BufferSizeNotAligned,
    InvalidDevicePeriod,
    InvalidPointer,
    NoInterface,
    Unexpected,
    CreateInstanceFailed,
};

pub fn hresultToError(hr: HRESULT) Error!void {
    if (hr >= 0) return;
    return switch (@as(u32, @bitCast(hr))) {
        0x88890001 => Error.NotInitialized,
        0x88890002 => Error.AlreadyInitialized,
        0x88890003 => Error.WrongEndpointType,
        0x88890004 => Error.DeviceInvalidated,
        0x88890005 => Error.NotStopped,
        0x88890006 => Error.BufferTooLarge,
        0x88890007 => Error.OutOfOrder,
        0x88890008 => Error.UnsupportedFormat,
        0x88890009 => Error.InvalidSize,
        0x8889000A => Error.DeviceInUse,
        0x8889000B => Error.BufferOperationPending,
        0x8889000C => Error.ThreadNotRegistered,
        0x8889000E => Error.ExclusiveModeNotAllowed,
        0x8889000F => Error.EndpointCreateFailed,
        0x88890010 => Error.ServiceNotRunning,
        0x88890011 => Error.EventHandleNotExpected,
        0x88890012 => Error.ExclusiveModeOnly,
        0x88890013 => Error.BufferDurationPeriodNotEqual,
        0x88890014 => Error.EventHandleNotSet,
        0x88890015 => Error.IncorrectBufferSize,
        0x88890016 => Error.BufferSizeError,
        0x88890017 => Error.CpuUsageExceeded,
        0x88890018 => Error.BufferError,
        0x88890019 => Error.BufferSizeNotAligned,
        0x88890020 => Error.InvalidDevicePeriod,
        0x80004003 => Error.InvalidPointer,
        0x80004002 => Error.NoInterface,
        else => Error.Unexpected,
    };
}

pub fn succeeded(hr: HRESULT) bool {
    return hr >= 0;
}

pub fn failed(hr: HRESULT) bool {
    return hr < 0;
}

pub fn referenceTimeToNs(rt: REFERENCE_TIME) i64 {
    return constants.referenceTimeToNs(rt);
}

pub fn nsToReferenceTime(ns: i64) REFERENCE_TIME {
    return constants.nsToReferenceTime(ns);
}

pub fn referenceTimeToMs(rt: REFERENCE_TIME) i64 {
    return constants.referenceTimeToMs(rt);
}

pub fn msToReferenceTime(ms: i64) REFERENCE_TIME {
    return constants.msToReferenceTime(ms);
}
