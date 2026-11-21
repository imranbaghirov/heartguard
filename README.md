# heartguard: Sensors Live (iPhone)

A SwiftUI iPhone app that shows **live readings from every sensor iOS lets an app read**, with real-time charts.

| Section | Sensor | What you see |
|---|---|---|
| Motion | Accelerometer | Raw X/Y/Z in g, magnitude, live chart |
| | Gyroscope | Raw rotation rate (rad/s), live chart |
| | Magnetometer | Raw magnetic field (µT), live chart |
| | Attitude (sensor fusion) | Roll / pitch / yaw, quaternion, magnetic heading, spirit-level bubble |
| | Device motion | User acceleration (gravity removed), gravity vector, bias-free rotation, calibrated magnetic field and its accuracy |
| Environment | Barometer | Pressure (hPa / kPa), relative altitude, absolute altitude with accuracy/precision, chart |
| | Microphone | Live RMS and peak level (dBFS), rough loudness estimate, chart (analysed in memory, never recorded) |
| Location | GPS | Lat/long, horizontal and vertical accuracy, MSL and ellipsoidal altitude, speed, course, floor, fix time |
| | Compass | Magnetic and true heading, accuracy, raw geomagnetic vector, rotating compass dial |
| Activity | Pedometer | Today's steps, distance, floors up/down, pace, cadence |
| | Motion activity | Stationary / walking / running / cycling / automotive with confidence |
| Device | Proximity | Near/far (toggle; iOS blanks the screen while covered) |
| | Battery & power | Level, charging state, Low Power Mode, thermal state |
| | Display | Screen brightness (driven by the ambient light sensor when Auto-Brightness is on), orientation |

Toolbar: **pause/resume** all sensors, **motion sample rate** (10 / 30 / 60 / 100 Hz), **keep screen awake**.

## Run it on your iPhone

1. You need a Mac with **Xcode 16 or newer** and an iPhone running **iOS 17+**.
2. Open `SensorLive.xcodeproj`.
3. Select the **SensorLive** target › *Signing & Capabilities* › choose your **Team** (a free Apple ID works).
   If the bundle ID is taken, change `com.example.SensorLive` to something unique.
4. Plug in your iPhone (or pair it over Wi-Fi), select it as the run destination, and press **Run**.
   On first launch, enable *Developer Mode* on the phone if asked, and trust the developer profile under
   *Settings › General › VPN & Device Management*.
5. Allow Motion & Fitness, Location and (when you tap *Start microphone*) Microphone access.

The iOS Simulator has almost none of these sensors, so use a real device.

## What iOS doesn't expose

Public iOS APIs don't give apps the raw **ambient light sensor** value, the **Face ID / LiDAR depth** stream
outside camera sessions, **heart rate** (that needs Apple Watch and HealthKit), or **raw temperature**. The app shows the
closest public signals instead: screen brightness and thermal state.

## Project layout

```
SensorLive/
  SensorLiveApp.swift, ContentView.swift
  Sensors/   one @Observable class per sensor group plus SensorHub that starts and stops them
  Views/     cards for each sensor plus shared components (charts, compass, level)
  Support/   Vector3, rolling TimeSeries and formatting helpers
```

CI (`.github/workflows/ios-build.yml`) builds the app for the simulator on every push.
