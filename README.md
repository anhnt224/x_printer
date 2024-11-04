## Introduction

XPrinter is a printer plugin for Flutter, a mobile SDK to help developers build bluetooth thermal printer apps or features for both iOS and Android.

## Features

| Feature                |      Android       |        iOS         | Description                                                |
| :--------------------- | :----------------: | :----------------: | :--------------------------------------------------------- |
| Scan                   | :white_check_mark: | :white_check_mark: | Starts scanning for Bluetooth devices.                     |
| Connect                | :white_check_mark: | :white_check_mark: | Establishes a connection to the Bluetooth printer.         |
| Disconnect             | :white_check_mark: | :white_check_mark: | Cancels an active or pending connection to the printer.    |
| State                  | :white_check_mark: | :white_check_mark: | Stream of state changes for the Bluetooth device.          |
| Print Text             | :white_check_mark: | :white_check_mark: | Prints text with various formatting options.               |
| Print QR Code          | :white_check_mark: | :white_check_mark: | Prints a QR code with specified data and error correction. |
| Print Barcode          | :white_check_mark: | :white_check_mark: | Prints a barcode with specified type and content.          |
| Print Image            | :white_check_mark: | :white_check_mark: | Prints images from base64 encoded strings.                 |
| Cut Paper              | :white_check_mark: | :white_check_mark: | Sends a command to the printer to cut the paper.           |
| Monitor Printer Status | :white_check_mark: | :white_check_mark: | Streams updates on printer status and peripherals.         |
| Is Scanning Stream     | :white_check_mark: | :white_check_mark: | Streams the scanning status of the printer.                |
| Is Connected           | :white_check_mark: | :white_check_mark: | Checks if the printer is currently connected.              |

## Getting Started

To use this plugin:

- add dependency to your pubspec.yaml file.

```yaml
dependencies:
  flutter:
    sdk: flutter
  x_printer:
```

### Add permissions for Bluetooth

We need to add permission to use Bluetooth and access location:

#### **iOS**

In the **ios/Runner/Info.plist** let’s add:

```dart
	<dict>
	    <key>NSBluetoothAlwaysUsageDescription</key>
	    <string>Need BLE permission</string>
	    <key>NSBluetoothPeripheralUsageDescription</key>
	    <string>Need BLE permission</string>
	    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
	    <string>Need Location permission</string>
	    <key>NSLocationAlwaysUsageDescription</key>
	    <string>Need Location permission</string>
	    <key>NSLocationWhenInUseUsageDescription</key>
	    <string>Need Location permission</string>
```

## Usage

Init a XPrinter instance

```dart
final plugin = XPrinter();
```

scan

```dart
// start scan
plugin.startScan();

// get peripherals
ListView.builder(
    itemBuilder: (context, index) {
        final peripheral = peripherals[index];
        return ListTile(
            title: Text(peripheral.name ?? ''),
            subtitle: Text(peripheral.uuid ?? ''),
        );
    },
    itemCount: peripherals.length,
)
```

connect

```dart
plugin.connect(peripheral.uuid!);
```

disconnect

```dart
plugin.disconnect();
```

print text

```dart
plugin.printText('=======================================');
plugin.printText("Left");
plugin.printText(
    "Center",
    align: PTextAlign.center,
);
plugin.printText(
    "Right",
    align: PTextAlign.right,
);

plugin.printText('=======================================');
plugin.printText("FontB", attribute: PTextAttribute.fontB);
plugin.printText("Bold", attribute: PTextAttribute.bold);
plugin.printText(
    "Underline",
    attribute: PTextAttribute.underline,
);
plugin.printText(
    "Underline2",
    attribute: PTextAttribute.underline2,
);
plugin.printText('=======================================');
plugin.printText(
    "W1",
    width: PTextW.w2,
    height: PTextH.h2,
);
plugin.printText(
    "W2",
    width: PTextW.w2,
    height: PTextH.h2,
);
plugin.printText(
    "W3",
    width: PTextW.w3,
    height: PTextH.h3,
);
plugin.printText(
    "W4",
    width: PTextW.w4,
    height: PTextH.h4,
);
```

print image

> "You should resize the image to fit each type of printer. For some models, printing an image that is too wide may result in errors."

```dart
plugin.printImage(base64Image);
```

cut paper

```dart
plugin.cutPaper();
```
