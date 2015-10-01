//
//  ViewController.swift
//  SwiftChat
//
// Copyright 2014 Weswit Srl
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

// Configuration for local installation
let SERVER_URL = "http://localhost:8080"
let ADAPTER_SET = "CHAT"
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


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, LSClientDelegate, LSSubscriptionDelegate {
	var _rows = [[String: String]]() // Array<Dictionary<String, String>>
	var _colors = [String: UIColor]() // Dictionary<String, UIColor>

	let _client = LSLightstreamerClient(serverAddress: SERVER_URL, adapterSet: ADAPTER_SET)
	let _subscription = LSSubscription(subscriptionMode: "DISTINCT", item: "chat_room", fields: ["message", "raw_timestamp", "IP"])
	
	let _formatter = NSDateFormatter()
	
	var _keyboardShown = false
	var _snapshotEnded = false
	
	@IBOutlet var _tableView: UITableView?
	@IBOutlet var _textField: UITextField?
	@IBOutlet var _sendButton: UIButton?

	@IBOutlet var _waitView: UIView?
	
	
	//////////////////////////////////////////////////////////////////////////
	// Constructor
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		// Initialize the timestamp formatter
		_formatter.dateFormat = "dd/MM/YYYY HH:mm:ss"
		
		// Log the lib version
		NSLog("LS Client lib version: \(LSLightstreamerClient.LIB_VERSION())");
	}

	
	//////////////////////////////////////////////////////////////////////////
	// Methods of UIViewController

	override func viewWillAppear(animated: Bool) {
		
		// Register for keyboard notifications
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

		NSLog("Connecting...")
		
		// Add delegate
		self._client.addDelegate(self)
		
		// Start LS connection (executes in background)
		self._client.connect()
		
		// Start subscription (executes in background)
		self._subscription.dataAdapter = DATA_ADAPTER
		self._subscription.requestedSnapshot = "yes"
		self._subscription.addDelegate(self)
		self._client.subscribe(_subscription)
		
	}
	
	override func viewWillDisappear(animated: Bool) {
		
		// Unregister for keyboard notifications while not visible
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
	
	
	//////////////////////////////////////////////////////////////////////////
	// Action methods
	
	@IBAction func sendTapped() {
        if ((_textField!.text == nil) || (_textField!.text! == "")) {
            return
        }
        
        // Get the message text
        let message : String = _textField!.text!
        _textField!.text = ""
        
        NSLog("Sending message \"\(message)\"...")
        
        // Send the message (executes in background)
        self._client.sendMessage("CHAT|" + message)
	}
	
	@IBAction func logoTapped() {
		NSLog("Opening Lightstreamer home page URL...")
		
		// Open the LS page
		let url = NSURL(string: "http://www.lightstreamer.com/")
		UIApplication.sharedApplication().openURL(url!)
	}
	
	
	//////////////////////////////////////////////////////////////////////////
	// Methods of UITableViewDataSource
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		// Synchronize access to row list
		objc_sync_enter(self)

		let rowCount = _rows.count
		
		objc_sync_exit(self)
		
		return rowCount
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell = tableView.dequeueReusableCellWithIdentifier("ChatCell") as? ChatCell
		if cell == nil {
			cell = ChatCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ChatCell")
		}
		
		// Synchronize access to row list
		objc_sync_enter(self)
		
		let row = _rows[indexPath.row]
		
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
	
	
	//////////////////////////////////////////////////////////////////////////
	// Methods of UITableViewDelegate
	
	func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {

		// No selection allowed
		return nil
	}
	
	func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		
		// Synchronize access to row list
		objc_sync_enter(self)
		
		let row = _rows[indexPath.row]
		
		objc_sync_exit(self)
		
		// Get cell address
		let address = row["address"]
		
		var color = UIColor.whiteColor()

		if address != nil {
			
			// Synchronize access to color list
			objc_sync_enter(self)
			
			color = _colors[address!]!
			
			objc_sync_exit(self)
		}
		
		cell.backgroundColor = color
	}
	
	func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

		// Synchronize access to row list
		objc_sync_enter(self)
		
		let row = _rows[indexPath.row]
		
		objc_sync_exit(self)
		
		let message = row["message"]
		if message != nil {
			
			// Compute approximate cell height, we can't
			// do better than this with APIs available in beta 3
			let length = (message!).characters.count

			var lines = (length / AVERAGE_LINE_LENGTH)
			if length % AVERAGE_LINE_LENGTH > 0 {
				lines++
			}
			
			let height = TOP_BORDER_HEIGHT + LINE_HEIGHT * CGFloat(lines) + BOTTOM_BORDER_HEIGHT
			
			return CGFloat(height)
		
		} else {
			return CGFloat(DEFAULT_CELL_HEIGHT)
		}
	}
	
	
	//////////////////////////////////////////////////////////////////////////
	// Methods of LSClientDelegate
	
	func client(client: LSLightstreamerClient, didChangeProperty property: String) {
		NSLog("LS Client property did change (property: \(property))")
	}
	
	func client(client: LSLightstreamerClient, didChangeStatus status: String) {
		NSLog("LS Client connection status did change (status: \(status))")

		if (status.hasPrefix("DISCONNECTED")) {
			
			// Handle transient connection failure
			self.handleDisconnection()
			
			if (status == "DISCONNECTED") {
				
				// Restart LS connection (executes in background)
				self._client.connect()
			}
		}
	}
	
	func client(client: LSLightstreamerClient, didReceiveServerError errorCode: Int, withMessage errorMessage: String?) {
		NSLog("LS Client connection did receive server error (code: \(errorCode), message: \(errorMessage))")
	}
	
	
	//////////////////////////////////////////////////////////////////////////
	// Disconnection handling

	func handleDisconnection() {
		dispatch_sync(dispatch_get_main_queue()) {
			
			// Show wait view
			self._waitView!.hidden = false
		}

		// Clear snapshot status
		_snapshotEnded = false
		
		// Synchronize access to row list
		objc_sync_enter(self)
		
		_rows.removeAll()
		
		objc_sync_exit(self)
	}
	

	//////////////////////////////////////////////////////////////////////////
	// Methods of LSSubscriptionDelegate
	
	func subscription(subscription: LSSubscription, didClearSnapshotForItemName itemName: String?, itemPos: UInt) {}
	
	func subscription(subscription: LSSubscription, didEndSnapshotForItemName itemName: String?, itemPos: UInt) {
		NSLog("LS Subscription snapshot did end")
		
		_snapshotEnded = true
		
		dispatch_async(dispatch_get_main_queue()) {
			
			// Synchronize access to row list
			objc_sync_enter(self)
			
			// Notify table view to reload cells
			self._tableView!.reloadData()
			
			let rowCount = self._rows.count
			
			objc_sync_exit(self)
			
			// Scroll to bottom
			if rowCount > 0 {
				self._tableView!.scrollToRowAtIndexPath(NSIndexPath(forRow: rowCount-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
			}
			
			// Hide wait view
			self._waitView!.hidden = true
		}
	}
	
	func subscription(subscription: LSSubscription, didUpdateItem itemUpdate: LSItemUpdate) {
		let message = itemUpdate.valueWithFieldName("message")
		let rawTimestamp = itemUpdate.valueWithFieldName("raw_timestamp")
		let address = itemUpdate.valueWithFieldName("IP")
		
		if (message == nil) || (rawTimestamp == nil) || (address == nil) {
			NSLog("Discarding incomplete message")
			return
		}
		
		// Format the timestamp
		let timeInterval = (rawTimestamp! as NSString).doubleValue / 1000.0
		let date = NSDate(timeIntervalSince1970: timeInterval)
		let timestamp = _formatter.stringFromDate(date)
		
		NSLog("Received message from \(address!) at \(timestamp)")
		
		// Synchronize access to color list
		objc_sync_enter(self)
		
		if _colors[address!] == nil {
			
			// Generate color from address
			var addr = in_addr(s_addr: 0)
			inet_aton((address! as NSString).UTF8String, &addr)
			
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
			dispatch_async(dispatch_get_main_queue()) {
				
				// Synchronize access to row list
				objc_sync_enter(self)
				
				// Notify table view to reload cells
				self._tableView!.reloadData()
				
				let rowCount = self._rows.count
				
				objc_sync_exit(self)
				
				// If the table is positioned on last row, scroll with new message
				let visibleRows = self._tableView!.indexPathsForVisibleRows 
				if (visibleRows != nil) && visibleRows!.count > 0 {
					let lastIndexPath = visibleRows![visibleRows!.count-1] as NSIndexPath
					if lastIndexPath.row == rowCount-2 {
						self._tableView!.scrollToRowAtIndexPath(NSIndexPath(forRow: rowCount-1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
					}
				}
			}
		}
	}
	
	func subscription(subscription: LSSubscription, didFailWithErrorCode code: Int, message: String?) {
		NSLog("LS Subscription did fail with error (code: \(code), message: \(message)")
	}
	
	func subscription(subscription: LSSubscription, didLoseUpdates lostUpdates: UInt, forItemName itemName: String?, itemPos: UInt) {
		NSLog("LS Subscription did lose updates (lost updates: \(lostUpdates), item name: \(itemName), item pos: \(itemPos)")
	}
	
	func subscriptionDidSubscribe(subscription: LSSubscription) {
		NSLog("LS Subscription did susbcribe")
	}
	
	func subscriptionDidUnsubscribe(subscription: LSSubscription) {
		NSLog("LS Subscription did unsusbcribe")
	}
	
	
	//////////////////////////////////////////////////////////////////////////
	// Methods of UITextFieldDelegate
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
        if ((textField.text == nil) || (textField.text! == "")) {
            return false
        }
		
		// Get the message text
        let message : String = textField.text!
		textField.text = ""
		
		NSLog("Sending message \"\(message)\"...")

		// Send the message (executes in background)
		self._client.sendMessage("CHAT|" + message)
		
		// No linefeeds allowed inside the message
		return false
	}
	
	
	//////////////////////////////////////////////////////////////////////////
	// Keyboard hide/show notifications
	
	func keyboardWillShow(notification: NSNotification) {

		// Check for double invocation
		if _keyboardShown {
			return
		}
		
		_keyboardShown = true

		// Reducing size of table
		let baseView = self.view.viewWithTag(CHAT_SUBVIEW_TAG)
		
		let keyboardFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
		let keyboardDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
		
		let visibleRows = _tableView!.indexPathsForVisibleRows 
		var lastIndexPath : NSIndexPath? = nil

		if (visibleRows != nil) && visibleRows!.count > 0 {
			lastIndexPath = visibleRows![visibleRows!.count-1] as NSIndexPath
		}
		
		UIView.animateWithDuration(keyboardDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
			baseView!.frame = CGRectMake(baseView!.frame.origin.x, baseView!.frame.origin.y, baseView!.frame.size.width, baseView!.frame.size.height - keyboardFrame.size.height)
		
		}, completion: {
			(finished: Bool) in

			if lastIndexPath != nil {
	
				// Scroll down the table so that the last
				// visible row remains visible
				self._tableView!.scrollToRowAtIndexPath(lastIndexPath!, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
			}
		})
	}
	
	func keyboardWillHide(notification: NSNotification) {

		// Check for double invocation
		if !_keyboardShown {
			return
		}
		
		_keyboardShown = false
		
		// Expanding size of table
		let baseView = self.view.viewWithTag(CHAT_SUBVIEW_TAG)
		
		let keyboardFrame = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue
		let keyboardDuration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
		
		UIView.animateWithDuration(keyboardDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
			baseView!.frame = CGRectMake(baseView!.frame.origin.x, baseView!.frame.origin.y, baseView!.frame.size.width, baseView!.frame.size.height + keyboardFrame.size.height)

		}, completion: nil)
	}
}

