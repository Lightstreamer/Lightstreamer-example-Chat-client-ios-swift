# Lightstreamer - Basic Chat Demo - iOS Client - Swift

<!-- START DESCRIPTION lightstreamer-example-Chat-client-ios-swift -->

This project contains an example of an application for iPhone that employs the [Lightstreamer iOS Client library](http://www.lightstreamer.com/docs/client_ios_api/index.html).

## Live Demo


[![screenshot](screenshot_large.png)]()

###[![](http://demos.lightstreamer.com/site/img/play.png) View live demo]()

** Note: The Live Demo is currently not available, but will be available soon on [iTunes App Store](https://itunes.apple.com/us/genre/ios/id36?mt=8)**

## Details

This app, compatible with iPhone, is a Swift version of the [Chat Demos](https://github.com/Weswit/Lightstreamer-example-Chat-client-javascript).<br>

This app uses the <b>iOS Client API for Lightstreamer</b> to handle the communications with Lightstreamer Server. A simple user interface is implemented to display the real-time messages received from Lightstreamer Server.<br>

## Build

Binaries for the application are not provided, but a full Xcode 6.0 project specification, ready for a compilation of the demo sources is provided. Please recall that you need a valid iOS Developer Program membership in order to debug or deploy your app on a test device.
Before you can build this demo you should complete this project with the Lighstreamer iOS Client library. Please:

* drop into the `Lightstreamer client for iOS/lib` folder of this project the libLightstreamer_iOS_client_64.a file from the `/DOCS-SDKs/sdk_client_ios/lib` of [latest Lightstreamer distribution](http://www.lightstreamer.com/download).
* drop into the `Lightstreamer client for iOS/include` folder of this project all the include files from the `/DOCS-SDKs/sdk_client_ios/include` of [latest Lightstreamer distribution](http://www.lightstreamer.com/download).

### Deploy

With the current settings, the demo tries to connect to the demo server currently running on Lightstreamer website.
The demo can be reconfigured and recompiled in order to connect to the local installation of Lightstreamer Server. You just have to change SERVER_URL, as defined in `SwiftChat/ViewController.swift`; a ":port" part can also be added.
The example requires that the [QUOTE_ADAPTER](https://github.com/Weswit/Lightstreamer-example-Stocklist-adapter-java) and [LiteralBasedProvider](https://github.com/Weswit/Lightstreamer-example-ReusableMetadata-adapter-java) have to be deployed in your local Lightstreamer server instance. The factory configuration of Lightstreamer server already provides this adapter deployed.<br>

## See Also

### Lightstreamer Adapters needed by this demo client

* [Lightstreamer - Stock- List Demo - Java Adapter](https://github.com/Weswit/Lightstreamer-example-Stocklist-adapter-java)
* [Lightstreamer - Reusable Metadata Adapters- Java Adapter](https://github.com/Weswit/Lightstreamer-example-ReusableMetadata-adapter-java)

### Similar demo clients that may interest you

* [Lightstreamer - Basic Chat Demo - HTML Client](https://github.com/Weswit/Lightstreamer-example-Chat-client-javascript)

## Lightstreamer Compatibility Notes

* Compatible with Lightstreamer iOS Client Library version 1.2 or newer.
* For Lightstreamer Allegro (+ iOS Client API support), Presto, Vivace.
