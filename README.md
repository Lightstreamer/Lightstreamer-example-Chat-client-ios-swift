# Lightstreamer - Basic Chat Demo - iOS Client - Swift

<!-- START DESCRIPTION lightstreamer-example-chat-client-ios-swift -->

The *Chat Demo* is a very simple chat application based on Lightstreamer.

This project contains an example of an application for iPhone that employs the [Lightstreamer iOS Client library](http://www.lightstreamer.com/api/ls-ios-client/latest/), with use of mobile push notifications (MPN).

![screenshot](screenshot_large.png)

## Details

This app, compatible with iPhone, is a Swift version of the [Lightstreamer - Basic Chat Demo - HTML Client](https://github.com/Lightstreamer/Lightstreamer-example-Chat-client-javascript).

This app uses the **iOS Client API for Lightstreamer** to handle the communications with Lightstreamer Server. A simple user interface is implemented to display the real-time messages received from Lightstreamer Server. Additionally, the app is able to forward incoming messages via mobile push notifications to any registered client.

Further details about developing apps on iOS with Lightstreamer and MPNs are discussed in this blog post:

* [Mobile Push Notifications with Lightstreamer Server 7.0 and Client SDKs 4.0](http://blog.lightstreamer.com/2018/01/mobile-push-notifications-with.html)

## Install

Binaries for the application are not provided.

## Build

Binaries for the application are not provided, but a full Xcode project is provided. Please recall that you need a valid iOS Developer Program membership to debug or deploy your app on a test device.

### Compile and Run

A full local deploy of this app requires a Lightstreamer Server 7.0 or greater installation with appropriate Mobile Push Notifications (MPN) module configuration. A detailed step by step guide for setting up the server and configuring the client is available in the README of the following project:

* [Lightstreamer - MPN Chat Demo Metadata - Java Adapter](https://github.com/Lightstreamer/Lightstreamer-example-MPNChatMetadata-adapter-java)

## See Also

### Lightstreamer Adapters Needed by This Demo Client

* [Lightstreamer - Basic Chat Demo - Java Adapter](https://github.com/Lightstreamer/Lightstreamer-example-Chat-adapter-java)
* [Lightstreamer - MPN Chat Demo Metadata - Java Adapter](https://github.com/Lightstreamer/Lightstreamer-example-MPNChatMetadata-adapter-java)

### More information on developing Lightstreamer apps with iOS and MPN:

* [Mobile Push Notifications with Lightstreamer Server 7.0 and Client SDKs 4.0](http://blog.lightstreamer.com/2018/01/mobile-push-notifications-with.html)

### Related Projects

* [Lightstreamer - Basic Chat Demo - HTML Client](https://github.com/Lightstreamer/Lightstreamer-example-Chat-client-javascript)
* [Lightstreamer - Stock-List Demo - iOS Client](https://github.com/Lightstreamer/Lightstreamer-example-StockList-client-ios)
* [Lightstreamer - Stock-List Demo with APNs Push Notifications- iOS Client](https://github.com/Lightstreamer/Lightstreamer-example-MPNStockList-client-ios)

## Lightstreamer Compatibility Notes

* Compatible with Lightstreamer iOS Client Library version 4.0.0 or newer.
* For Lightstreamer Server version 7.0 or greater. Ensure that iOS Client API is supported by Lightstreamer Server license configuration.
* For a version of this example compatible with Lightstreamer iOS Client API version 4.0.0 up to 4.2.1, please refer to [this tag](https://github.com/Lightstreamer/Lightstreamer-example-Chat-client-ios-swift/tree/latest-for-cocoapods).
* For a version of this example compatible with Lightstreamer iOS Client API version 3.x and Server version 6.1, please refer to [this tag](https://github.com/Lightstreamer/Lightstreamer-example-Chat-client-ios-swift/tree/last-pre-MPN).
