# zig_wca

[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](LICENSE)

Zig bindings for the Windows Core Audio API.

## Features

- Render audio in shared mode
- Capture audio in shared mode
- Loopback capture
- Control master and channel volume
- Enumerate audio devices and sessions
- Monitor device events

## Requirements

- Zig 0.15.0 or later
- Windows 10 or later

## Usage

```zig
const std = @import("std");
const wca = @import("wca");

pub fn main() !void {
    try wca.com.initialize(wca.com.COINIT_APARTMENTTHREADED);
    defer wca.com.uninitialize();

    const enumerator = try wca.IMMDeviceEnumerator.create();
    defer _ = enumerator.release();

    const device = try enumerator.getDefaultAudioEndpoint(.Render, .Console);
    defer _ = device.release();

    const volume = try device.activateEndpointVolume();
    defer _ = volume.release();

    const level = try volume.getMasterVolumeLevelScalar();
    std.debug.print("Volume: {d:.0}%\n", .{level * 100});
}
```

## Examples

Examples are located in the `examples` directory:

| Example | Description |
|---------|-------------|
| `enumerate_devices` | List all audio devices |
| `enumerate_sessions` | List all audio sessions |
| `endpoint_volume` | Get and set device volume |
| `device_events` | Monitor device changes |
| `render_shared` | Render audio in shared mode |
| `capture_shared` | Capture microphone audio |
| `loopback_capture` | Capture system audio |

Run an example:

```console
zig build enumerate_devices
```

## Documentation

This library wraps the native Windows Core Audio COM interfaces. Refer to the Microsoft documentation for details:

### MMDevice API

- [IMMDevice](https://learn.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdevice)
- [IMMDeviceCollection](https://learn.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdevicecollection)
- [IMMDeviceEnumerator](https://learn.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immdeviceenumerator)
- [IMMEndpoint](https://learn.microsoft.com/en-us/windows/win32/api/mmdeviceapi/nn-mmdeviceapi-immendpoint)

### Windows Audio Session API

- [IAudioClient](https://learn.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-iaudioclient)
- [IAudioClient2](https://learn.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-iaudioclient2)
- [IAudioClient3](https://learn.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-iaudioclient3)
- [IAudioRenderClient](https://learn.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-iaudiorenderclient)
- [IAudioCaptureClient](https://learn.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-iaudiocaptureclient)
- [IAudioEndpointVolume](https://learn.microsoft.com/en-us/windows/win32/api/endpointvolume/nn-endpointvolume-iaudioendpointvolume)
- [IAudioSessionManager2](https://learn.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessionmanager2)
- [IAudioSessionControl](https://learn.microsoft.com/en-us/windows/win32/api/audiopolicy/nn-audiopolicy-iaudiosessioncontrol)
- [ISimpleAudioVolume](https://learn.microsoft.com/en-us/windows/win32/api/audioclient/nn-audioclient-isimpleaudiovolume)

## Acknowledgments

This project is a Zig port of [go-wca](https://github.com/moutend/go-wca) by Yoshiyuki Koyanagi.

## License

[MIT](LICENSE)
