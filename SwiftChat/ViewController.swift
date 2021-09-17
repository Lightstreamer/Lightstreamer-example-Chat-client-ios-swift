//
//  ViewController.swift
//  SwiftChat
//
// Copyright (c) Lightstreamer Srl
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import LightstreamerClient

// Configuration for local installation
let SERVER_URL = "http://192.168.43.35:8080"
let ADAPTER_SET = "DEMO"
let DATA_ADAPTER = "CHAT_ROOM"

/* Configuration for online demo server
let SERVER_URL = "https://push.lightstreamer.com"
let ADAPTER_SET = "DEMO"
let DATA_ADAPTER = "CHAT_ROOM"
 */

let CHAT_SUBVIEW_TAG = 101
let TEXT_FIELD_TAG = 102

let AVERAGE_LINE_LENGTH = 40
let TOP_BORDER_HEIGHT: CGFloat = 13.0
let BOTTOM_BORDER_HEIGHT: CGFloat = 30.0
let LINE_HEIGHT: CGFloat = 20.0
let DEFAULT_CELL_HEIGHT: CGFloat = 77.0


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ClientDelegate, SubscriptionDelegate, MPNDeviceDelegate, MPNSubscriptionDelegate {
	var _rows = [[String: String]]() // Array<Dictionary<String, String>>
	var _colors = [String: UIColor]() // Dictionary<String, UIColor>

	let _client = LightstreamerClient(serverAddress: SERVER_URL, adapterSet: ADAPTER_SET)
    let _subscription = Subscription(subscriptionMode: .DISTINCT, item: "chat_room", fields: ["message", "raw_timestamp", "IP"])
	
	let _formatter = DateFormatter()
	
	var _keyboardShown = false
	var _snapshotEnded = false
	
	@IBOutlet var _tableView: UITableView?
	@IBOutlet var _textField: UITextField?
	@IBOutlet var _sendButton: UIButton?

	@IBOutlet var _waitView: UIView?
	
	
	// ////////////////////////////////////////////////////////////////////////
	// Constructor
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        
        // Uncomment to enable detailed logging
//        LightstreamerClient.setLoggerProvider(ConsoleLoggerProvider(level: .debug))
        _client.connectionOptions.sessionRecoveryTimeout = 0

		// Initialize the timestamp formatter
		_formatter.dateFormat = "dd/MM/YYYY HH:mm:ss"
		
		// Log the lib version
        NSLog("ViewController: LS Client lib version: \(LightstreamerClient.LIB_VERSION)");
	}

	
	// ////////////////////////////////////////////////////////////////////////
	// Methods of UIViewController

	override func viewWillAppear(_ animated: Bool) {
		
		// Register for keyboard notifications
		NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

		NSLog("ViewController: connecting...")
		
		// Add delegate
		self._client.addDelegate(self)
		
		// Start LS connection (executes in background)
		self._client.connect()
		
		// Start real-time subscription (executes in background)
		self._subscription.dataAdapter = DATA_ADAPTER
        self._subscription.requestedSnapshot = .yes
		self._subscription.addDelegate(self)
        
		self._client.subscribe(_subscription)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		
		// Unregister for keyboard notifications while not visible
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	
	// ////////////////////////////////////////////////////////////////////////
	// Action methods
	
	@IBAction func sendTapped() {
        if ((_textField!.text == nil) || (_textField!.text! == "")) {
            return
        }
        
        // Get the message text
        let message : String = _textField!.text!
        _textField!.text = ""
        
        NSLog("ViewController: sending message \"\(message)\"...")
        
        // Send the message (executes in background)
        self._client.sendMessage("CHAT|" + message)
	}
	
	@IBAction func logoTapped() {
		NSLog("ViewController: opening Lightstreamer home page URL...")
		
		// Open the LS page
		let url = URL(string: "http://www.lightstreamer.com/")
		UIApplication.shared.openURL(url!)
	}
	
	
	// ////////////////////////////////////////////////////////////////////////
	// Methods of UITableViewDataSource
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		// Synchronize access to row list
		objc_sync_enter(self)

		let rowCount = _rows.count
		
		objc_sync_exit(self)
		
		return rowCount
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as? ChatCell
		if cell == nil {
			cell = ChatCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ChatCell")
		}
		
		// Synchronize access to row list
		objc_sync_enter(self)
		
		let row = _rows[(indexPath as NSIndexPath).row]
		
		objc_sync_exit(self)
		
		// Compose cell content
		let message = row["message"]
		let timestamp = row["timestamp"]
		let address = row["address"]
		
		if message != nil {
			cell!.messageTextView!.text = message
		}
		
		if (timestamp != nil) && (address != nil) {
			cell!.originLabel!.text = "From \(address!) at \(timestamp!)"
		}
		
		return cell!
	}
	
	
	// ////////////////////////////////////////////////////////////////////////
	// Methods of UITableViewDelegate
	
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {

		// No selection allowed
		return nil
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
		// Synchronize access to row list
		objc_sync_enter(self)
		
		let row = _rows[(indexPath as NSIndexPath).row]
		
		objc_sync_exit(self)
		
		// Get cell address
		let address = row["address"]
		
		var color = UIColor.white

		if address != nil {
			
			// Synchronize access to color list
			objc_sync_enter(self)
			
			color = _colors[address!]!
			
			objc_sync_exit(self)
		}
		
		cell.backgroundColor = color
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

		// Synchronize access to row list
		objc_sync_enter(self)
		
		let row = _rows[(indexPath as NSIndexPath).row]
		
		objc_sync_exit(self)
		
		let message = row["message"]
		if message != nil {
			
			// Compute approximate cell height, we can't
			// do better than this with APIs available in beta 3
			let length = (message!).count

			var lines = (length / AVERAGE_LINE_LENGTH)
			if length % AVERAGE_LINE_LENGTH > 0 {
				lines += 1
			}
			
			let height = TOP_BORDER_HEIGHT + LINE_HEIGHT * CGFloat(lines) + BOTTOM_BORDER_HEIGHT
			
			return CGFloat(height)
		
		} else {
			return CGFloat(DEFAULT_CELL_HEIGHT)
		}
	}
	
	
	// ////////////////////////////////////////////////////////////////////////
	// Methods of ClientDelegate
    
    func clientDidRemoveDelegate(_ client: LightstreamerClient) {}
    func clientDidAddDelegate(_ client: LightstreamerClient) {}
    func client(_ client: LightstreamerClient, didChangeStatus status: LightstreamerClient.Status) {}
	
	func client(_ client: LightstreamerClient, didChangeProperty property: String) {
        // This method is always called from a background thread
        
		NSLog("ViewController: LS Client property did change (property: \(property))")
	}
	
	func client(_ client: LightstreamerClient, didChangeStatus status: String) {
        // This method is always called from a background thread

        NSLog("ViewController: LS Client connection status did change (status: \(status))")

		if (status.hasPrefix("DISCONNECTED")) {
			
			// Handle transient connection failure
			self.handleDisconnection()
			
			if (status == "DISCONNECTED") {
				
				// Restart LS connection (executes in background)
				self._client.connect()
			}
		}
	}
	
	func client(_ client: LightstreamerClient, didReceiveServerError errorCode: Int, withMessage errorMessage: String) {
        // This method is always called from a background thread

        NSLog("ViewController: LS Client connection did receive server error (code: \(errorCode), message: \(errorMessage))")
	}
	
	
    // ////////////////////////////////////////////////////////////////////////
	// Disconnection handling

	func handleDisconnection() {
        // This method is always called from a background thread

        DispatchQueue.main.sync {
			
			// Show wait view
			self._waitView!.isHidden = false
		}

		// Clear snapshot status
		_snapshotEnded = false
		
		// Synchronize access to row list
		objc_sync_enter(self)
		
		_rows.removeAll()
		
		objc_sync_exit(self)
	}
	

    // ////////////////////////////////////////////////////////////////////////
    // MPN registration handling
    
    func deviceTokenAvailable(_ deviceToken: String) {
        
        // Register the MPN device (executes in background)
        let mpnDevice = MPNDevice(deviceToken: deviceToken)
        mpnDevice.addDelegate(self)
        
        _client.register(forMPN: mpnDevice)
        
        // Prepare the notification format
        let builder = MPNBuilder()
            .title("Message from ${IP}")
            .subtitle("Received at ${timestamp}")
            .body("${message}")
            .sound("Default")
            .badge(with: "AUTO")

        // Prepare and activate the MPN subscription (executes in background)
        let mpnSubscription = MPNSubscription(subscriptionMode: .DISTINCT, item: "chat_room", fields: ["message", "timestamp", "IP"])
        mpnSubscription.dataAdapter = DATA_ADAPTER
        mpnSubscription.notificationFormat = builder.build()
        mpnSubscription.addDelegate(self)
        
        _client.subscribeMPN(mpnSubscription, coalescing: true)
    }

    
	// ////////////////////////////////////////////////////////////////////////
	// Methods of SubscriptionDelegate
    
    func subscription(_ subscription: Subscription, didLoseUpdates lostUpdates: UInt, forCommandSecondLevelItemWithKey key: String) {}
    func subscription(_ subscription: Subscription, didFailWithErrorCode code: Int, message: String?, forCommandSecondLevelItemWithKey key: String) {}
    func subscriptionDidRemoveDelegate(_ subscription: Subscription) {}
    func subscriptionDidAddDelegate(_ subscription: Subscription) {}
    func subscription(_ subscription: Subscription, didReceiveRealFrequency frequency: RealMaxFrequency?) {}
	
	func subscription(_ subscription: Subscription, didClearSnapshotForItemName itemName: String?, itemPos: UInt) {
        // This method is always called from a background thread

        // Nothing to do, for now
    }
	
	func subscription(_ subscription: Subscription, didEndSnapshotForItemName itemName: String?, itemPos: UInt) {
        // This method is always called from a background thread

        NSLog("ViewController: LS Subscription snapshot did end")
		
		_snapshotEnded = true
		
		DispatchQueue.main.async {
			
			// Synchronize access to row list
			objc_sync_enter(self)
			
			// Notify table view to reload cells
			self._tableView!.reloadData()
			
			let rowCount = self._rows.count
			
			objc_sync_exit(self)
			
			// Scroll to bottom
			if rowCount > 0 {
				self._tableView!.scrollToRow(at: IndexPath(row: rowCount-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: false)
			}
			
			// Hide wait view
			self._waitView!.isHidden = true
		}
	}
	
	func subscription(_ subscription: Subscription, didUpdateItem itemUpdate: ItemUpdate) {
        // This method is always called from a background thread

        let message = itemUpdate.value(withFieldName: "message")
		let rawTimestamp = itemUpdate.value(withFieldName: "raw_timestamp")
		let address = itemUpdate.value(withFieldName: "IP")
		
		if (message == nil) || (rawTimestamp == nil) || (address == nil) {
			NSLog("ViewController: discarding incomplete message")
			return
		}
		
		// Format the timestamp
		let timeInterval = (rawTimestamp! as NSString).doubleValue / 1000.0
		let date = Date(timeIntervalSince1970: timeInterval)
		let timestamp = _formatter.string(from: date)
		
		NSLog("ViewController: received message from \(address!) at \(timestamp)")
		
		// Synchronize access to color list
		objc_sync_enter(self)
		
		if _colors[address!] == nil {
			
			// Generate color from address
			var addr = in_addr(s_addr: 0)
			inet_aton((address! as NSString).utf8String, &addr)
			
			let b1 = UInt32(addr.s_addr) >> 24
			let b2 = (UInt32(addr.s_addr) & 0x00ff0000) >> 16
			let b3 = (UInt32(addr.s_addr) & 0x0000ff00) >>  8
			let b4 = UInt32(addr.s_addr) & 0x000000ff
			
			let hue = CGFloat(UInt((b4 << 8) + b2)) / 65535.0
			let saturation = (CGFloat(UInt((b3 << 8) + b1)) / 65535.0) / 5.0 + 0.1
			
			let color = UIColor(hue: hue, saturation: saturation, brightness: 1.0, alpha: 1.0)
			_colors[address!] = color
		}
		
		objc_sync_exit(self)
		
		let row = ["message": message!, "timestamp": timestamp, "address": address!]
		
		// Synchronize access to row list
		objc_sync_enter(self)
		
		_rows.append(row)
		
		objc_sync_exit(self)
		
		if _snapshotEnded {
			DispatchQueue.main.async {
				
				// Synchronize access to row list
				objc_sync_enter(self)
				
				// Notify table view to reload cells
				self._tableView!.reloadData()
				
				let rowCount = self._rows.count
				
				objc_sync_exit(self)
				
				// If the table is positioned on last row, scroll with new message
				let visibleRows = self._tableView!.indexPathsForVisibleRows 
				if (visibleRows != nil) && visibleRows!.count > 0 {
					let lastIndexPath = visibleRows![visibleRows!.count-1] as IndexPath
					if (lastIndexPath as NSIndexPath).row == rowCount-2 {
						self._tableView!.scrollToRow(at: IndexPath(row: rowCount-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
					}
				}
			}
		}
	}
	
	func subscription(_ subscription: Subscription, didFailWithErrorCode code: Int, message: String?) {
        // This method is always called from a background thread

        NSLog("ViewController: LS Subscription did fail with error (code: \(code), message: \(message ?? "nil")")
	}
	
	func subscription(_ subscription: Subscription, didLoseUpdates lostUpdates: UInt, forItemName itemName: String?, itemPos: UInt) {
        // This method is always called from a background thread

        NSLog("ViewController: LS Subscription did lose updates (lost updates: \(lostUpdates), item name: \(itemName ?? "nil"), item pos: \(itemPos)")
	}
	
	func subscriptionDidSubscribe(_ subscription: Subscription) {
        // This method is always called from a background thread

        NSLog("ViewController: LS Subscription did susbcribe")
	}
	
	func subscriptionDidUnsubscribe(_ subscription: Subscription) {
        // This method is always called from a background thread

        NSLog("ViewController: LS Subscription did unsusbcribe")
	}
	
	
    // ////////////////////////////////////////////////////////////////////////
    // Methods of MPNDeviceDelegate
    
    func mpnDeviceDidAddDelegate(_ device: MPNDevice) {}
    func mpnDeviceDidRemoveDelegate(_ device: MPNDevice) {}
    func mpnDeviceDidSuspend(_ device: MPNDevice) {}
    func mpnDeviceDidResume(_ device: MPNDevice) {}
    func mpnDevice(_ device: MPNDevice, didChangeStatus status: MPNDevice.Status, timestamp: Int64) {}
    
    func mpnDeviceDidRegister(_ device: MPNDevice) {
        // This method is always called from a background thread

        NSLog("ViewController: LS MPN Device registered")
        
        // Reset the badge
        _client.resetMPNBadge()
    }
    
    func mpnDevice(_ device: MPNDevice, didFailRegistrationWithErrorCode code: Int, message: String?) {
        // This method is always called from a background thread

        NSLog("ViewController: LS MPN Device registration error: \(code) - \(message ?? "null")")
    }
    
    func mpnDeviceDidUpdateSubscriptions(_ device: MPNDevice) {
        // This method is always called from a background thread

        NSLog("ViewController: LS MPN Device subscriptions updated")
    }
    
    func mpnDeviceDidResetBadge(_ device: MPNDevice) {
        // This method is always called from a background thread

        NSLog("ViewController: LS MPN Device badge reset")
    }
    
    func mpnDevice(_ device: MPNDevice, didFailBadgeResetWithErrorCode code: Int, message: String?) {
        // This method is always called from a background thread

        NSLog("ViewController: LS MPN Device badge reset error: \(code) - \(message ?? "null")")
    }

    
    // ////////////////////////////////////////////////////////////////////////
    // Methods of MPNSubscriptionDelegate
    
    func mpnSubscriptionDidAddDelegate(_ subscription: MPNSubscription) {}
    func mpnSubscriptionDidRemoveDelegate(_ subscription: MPNSubscription) {}
    func mpnSubscriptionDidUnsubscribe(_ subscription: MPNSubscription) {}
    func mpnSubscriptionDidTrigger(_ subscription: MPNSubscription) {}
    func mpnSubscription(_ subscription: MPNSubscription, didChangeStatus status: MPNSubscription.Status, timestamp: Int64) {}
    func mpnSubscription(_ subscription: MPNSubscription, didChangeProperty property: String) {}
    func mpnSubscription(_ subscription: MPNSubscription, didFailUnsubscriptionWithErrorCode code: Int, message: String?) {}
    func mpnSubscription(_ subscription: MPNSubscription, didFailModificationWithErrorCode code: Int, message: String?, property: String) {}

    func mpnSubscriptionDidSubscribe(_ subscription: MPNSubscription) {
        NSLog("ViewController: LS MPN Subscription activation succeeded");
    }
    
    func mpnSubscription(_ subscription: MPNSubscription, didFailSubscriptionWithErrorCode code: Int, message: String?) {
        NSLog("ViewController: LS MPN Subscription activation error: \(code) - \(message ?? "null")")
    }

    
	// ////////////////////////////////////////////////////////////////////////
	// Methods of UITextFieldDelegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if ((textField.text == nil) || (textField.text! == "")) {
            return false
        }
		
		// Get the message text
        let message : String = textField.text!
		textField.text = ""
		
		NSLog("ViewController: sending message \"\(message)\"...")

		// Send the message (executes in background)
		self._client.sendMessage("CHAT|" + message)
		
		// No linefeeds allowed inside the message
		return false
	}
	
	
	// ////////////////////////////////////////////////////////////////////////
	// Keyboard hide/show notifications
	
    @objc func keyboardWillShow(_ notification: Notification) {

		// Check for double invocation
		if _keyboardShown {
			return
		}
		
		_keyboardShown = true

		// Reducing size of table
		let baseView = self.view.viewWithTag(CHAT_SUBVIEW_TAG)
		
		let keyboardFrame = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue
		let keyboardDuration = ((notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
		
		let visibleRows = _tableView!.indexPathsForVisibleRows 
		var lastIndexPath : IndexPath? = nil

		if (visibleRows != nil) && visibleRows!.count > 0 {
			lastIndexPath = visibleRows![visibleRows!.count-1] as IndexPath
		}
		
		UIView.animate(withDuration: keyboardDuration!, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
			baseView!.frame = CGRect(x: baseView!.frame.origin.x, y: baseView!.frame.origin.y, width: baseView!.frame.size.width, height: baseView!.frame.size.height - (keyboardFrame?.size.height)!)
		
		}, completion: {
			(finished: Bool) in

			if lastIndexPath != nil {
	
				// Scroll down the table so that the last
				// visible row remains visible
				self._tableView!.scrollToRow(at: lastIndexPath!, at: UITableView.ScrollPosition.bottom, animated: true)
			}
		})
	}
	
    @objc func keyboardWillHide(_ notification: Notification) {

		// Check for double invocation
		if !_keyboardShown {
			return
		}
		
		_keyboardShown = false
		
		// Expanding size of table
		let baseView = self.view.viewWithTag(CHAT_SUBVIEW_TAG)
		
		let keyboardFrame = ((notification as NSNotification).userInfo![UIResponder.keyboardFrameBeginUserInfoKey]! as AnyObject).cgRectValue
		let keyboardDuration = ((notification as NSNotification).userInfo![UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
		
		UIView.animate(withDuration: keyboardDuration!, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
			baseView!.frame = CGRect(x: baseView!.frame.origin.x, y: baseView!.frame.origin.y, width: baseView!.frame.size.width, height: baseView!.frame.size.height + (keyboardFrame?.size.height)!)

		}, completion: nil)
	}
}

