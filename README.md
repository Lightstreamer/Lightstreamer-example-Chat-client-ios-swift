# Lightstreamer - Basic Chat Demo - iOS Client - Swift

<!-- START DESCRIPTION lightstreamer-example-Chat-client-ios-swift -->

The *Chat Demo* is a very simple chat application based on Lightstreamer.

This project contains an example of an application for iPhone that employs the [Lightstreamer iOS Client library](http://www.lightstreamer.com/docs/client_ios_api/index.html).

## Live Demo

![screenshot](screenshot_large.png)

###![](http://demos.lightstreamer.com/site/img/play.png) View live demo

**Note: the Live Demo is currently not available, but will be available soon on the App Store.**

## Details

This app, compatible with iPhone, is a Swift version of the [Lightstreamer - Basic Chat Demo - HTML Client](https://github.com/Weswit/Lightstreamer-example-Chat-client-javascript).

This app uses the **iOS Client API for Lightstreamer** to handle the communications with Lightstreamer Server. A simple user interface is implemented to display the real-time messages received from Lightstreamer Server.

Further details about developing Swift Apps on iOS with Lightstreamer are discussed in [this blog post](http://blog.lightstreamer.com/2014/07/developing-swift-apps-on-ios-with.html).

## Install

Binaries for the application are not provided. A downloadable version will be available on the App Store soon.

## Build

Binaries for the application are not provided, but a full Xcode 6.0 project specification, ready for a compilation of the demo sources is provided. Please recall that you need a valid iOS Developer Program membership to debug or deploy your app on a test device.

### Getting Started

Before you can build this demo, you should complete this project with the Lighstreamer iOS Client library. Follow these steps:

* Drop into the `Lightstreamer client for iOS/lib` folder of this project the libLightstreamer_iOS_client_64.a file from the `/DOCS-SDKs/sdk_client_ios/lib` of [latest Lightstreamer distribution](http://www.lightstreamer.com/download).
* Drop into the `Lightstreamer client for iOS/include` folder of this project all the include files from the `/DOCS-SDKs/sdk_client_ios/include` of [latest Lightstreamer distribution](http://www.lightstreamer.com/download).

Done this, the project should compile with no errors.

### Compile and Run

* Create an *app ID* on the [Apple Developer Center](https://developer.apple.com/membercenter/index.action).
* Create and install an appropriate provisioning profile for the app ID above and your test device, on the Apple Developer Center.
* Set the app ID above as the *Bundle Identifier* of the Xcode project of the app.
* Set the IP address of your local Lightstreamer Server in the constant `SERVER_URL`, defined in `SwiftChat/ViewController.swift`; a ":port" part can also be added.
* Follow the installation instructions for the Data and Metadata adapters required by the demo, detailed in the [Lightstreamer - Basic Chat Demo - Java Adapter](https://github.com/Weswit/Lightstreamer-example-Chat-adapter-java) project.

Done this, the app should run correctly on your test device and connect to your server.

## See Also

### Lightstreamer Adapters Needed by This Demo Client

* [Lightstreamer - Basic Chat Demo - Java Adapter](https://github.com/Weswit/Lightstreamer-example-Chat-adapter-java)

### More informations on developing Lightstreamer apps with Swift

* [Developing Swift Apps on iOS with Lightstreamer](http://blog.lightstreamer.com/2014/07/developing-swift-apps-on-ios-with.html)

### Related Projects

* [Lightstreamer - Basic Chat Demo - HTML Client](https://github.com/Weswit/Lightstreamer-example-Chat-client-javascript)
* [Lightstreamer - Stock-List Demo - iOS Client](https://github.com/Weswit/Lightstreamer-example-StockList-client-ios)
* [Lightstreamer - Stock-List Demo with APNs Push Notifications- iOS Client](https://github.com/Weswit/Lightstreamer-example-MPNStockList-client-ios)

## Lightstreamer Compatibility Notes

* Compatible with Lightstreamer iOS Client Library version 1.2 or newer.
* For Lightstreamer Allegro (+ iOS Client API support), Presto, Vivace.
