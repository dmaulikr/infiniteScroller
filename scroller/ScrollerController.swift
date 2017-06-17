//
//  ScrollerController.swift
//  scroller
//
//  Created by tim knapen on 18/04/17.
//  Copyright © 2017 tim knapen. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

//FUNCTIES OPROEPEN

class ScrollerController : UIViewController, UIScrollViewDelegate, BLEDelegate{
	
	var bleShield : BLE!
	var bleTimer: Timer!
	
	//@IBOutlet : Interface builder - defined to nothing
	@IBOutlet var scrollView : UIScrollView!
	@IBOutlet var cmLabel : UILabel!
	@IBOutlet var contentView : UIView!
	@IBOutlet var pxLabel : UILabel!
	@IBOutlet var batteryLabel: UILabel!
	
	var timer : Timer!
	var needsMoreScroll = false
	let pixelsToCm = Float(8.8 / 568.0) //omrekenen pixels tot centimeters
	
	
	
	var activityTimer: Timer! // create in viewDidLoad()!
	var lastActivityTime: TimeInterval = Date().timeIntervalSince1970
	
	func updateActivityTimer(){
		let maxSecondsOfInactivity = 3.0 // pas dit aan naar hoeveel seconden je wil wachten!
		let now = Date().timeIntervalSince1970
		if( now - lastActivityTime > maxSecondsOfInactivity){
			// we have crossed the threshold!
			lastActivityTime = Date().timeIntervalSince1970
			
			// ACTIVATE SCROLL HERE!
			scrollView.contentOffset.y = 0.0
			print("SCROLL BACK!!")
		}
	}
	
	func resetActivityTimer(){
		lastActivityTime = Date().timeIntervalSince1970
	}
	
	func setupActivityTimer(){
		activityTimer = Timer.scheduledTimer(withTimeInterval: 1,
		                                     repeats: true,
		                                     block: {
			(timer) -> Void in
			self.updateActivityTimer();
		}
		)
	}
	
	// HET BEGIN VAN DE CODE, DE START
	
	override func viewDidLoad() {
		super.viewDidLoad()
		scrollView.delegate = self
		scrollView.contentSize.height = self.view.frame.size.height * 2
		
		scrollView.indicatorStyle = .black
		scrollView.layer.borderColor = UIColor(white: 0.9, alpha: 1).cgColor
		scrollView.layer.borderWidth = 1
		
		// enables the tracking of the devices battery level
		UIDevice.current.isBatteryMonitoringEnabled = true
		batteryLabel.text = "\( Int(UIDevice.current.batteryLevel * 100))%"
		
		// start kleur achtergrond
		
		if UIDevice.current.batteryLevel * 100 > 0.0 && UIDevice.current.batteryLevel * 100 < 10.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.21, blue:0.21, alpha:1.0)}
			
			// 10 to 20 procent
		else if UIDevice.current.batteryLevel * 100 > 10.0 && UIDevice.current.batteryLevel * 100 < 20.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.42, blue:0.30, alpha:1.0)}
			
			// 20 to 30 procent
		else if UIDevice.current.batteryLevel * 100 > 20.0 && UIDevice.current.batteryLevel * 100 < 30.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.56, blue:0.36, alpha:1.0)}
			
			// 30 to 40 procent
		else if UIDevice.current.batteryLevel * 100 > 30.0 && UIDevice.current.batteryLevel * 100 < 40.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.70, blue:0.42, alpha:1.0)}
			
			// 40 to 50 procent
		else if UIDevice.current.batteryLevel * 100 > 40.0 && UIDevice.current.batteryLevel * 100 < 50.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.82, blue:0.46, alpha:1.0)}
			
			// 50 to 60 procent
		else if UIDevice.current.batteryLevel * 100 > 50.0 && UIDevice.current.batteryLevel * 100 < 60.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.94, blue:0.51, alpha:1.0)}
			
			// 60 to 70 procent
		else if UIDevice.current.batteryLevel * 100 > 60.0 && UIDevice.current.batteryLevel * 100 < 70.0 {contentView.backgroundColor = UIColor(red:0.78, green:0.95, blue:0.47, alpha:1.0)}
			
			// 70 to 80 procent
		else if UIDevice.current.batteryLevel * 100 > 70.0 && UIDevice.current.batteryLevel * 100 < 80.0 {contentView.backgroundColor = UIColor(red:0.65, green:0.95, blue:0.45, alpha:1.0)}
			
			// 80 to 90 procent
		else if UIDevice.current.batteryLevel * 100 > 80.0 && UIDevice.current.batteryLevel * 100 < 90.0 {contentView.backgroundColor = UIColor(red:0.50, green:0.95, blue:0.42, alpha:1.0)}
			
			// 90 to 100 procent
		else if UIDevice.current.batteryLevel * 100 > 90.0 && UIDevice.current.batteryLevel * 100 < 101.0 {contentView.backgroundColor = UIColor(red:0.40, green:0.95, blue:0.40, alpha:1.0)}
		
		bleSetup()
		
		print ("\(UIDevice.current.batteryLevel * 100)")
		cmLabel.text = "0cm"
		pxLabel.text = "0px"
		
		
		setupActivityTimer()
	}
	
	
	// DE LOOP, HERHALING VAN DE CODE
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		resetActivityTimer()
		
		let currentScroll = scrollView.contentOffset.y
		let maxScroll = scrollView.contentSize.height - scrollView.frame.size.height
		// (scrollView.contentSize.height - self.view.frame.size.height)
		print("Scroll is at : \( Int(currentScroll) )")
		//print("\( Int(UIDevice.current.batteryLevel * 100) )")
		
		if(contentView.frame.origin.y + contentView.frame.size.height < scrollView.contentOffset.y ){
			contentView.frame.origin.y +=  scrollView.bounds.height +  contentView.frame.height
		}
		
		if(contentView.frame.origin.y > scrollView.contentOffset.y + scrollView.bounds.height ){
			contentView.frame.origin.y -=  scrollView.bounds.height + contentView.frame.height
		}
		
		
		
		cmLabel.text = "\(Int(Float(currentScroll)*pixelsToCm))cm"
		pxLabel.text = "\(Int(currentScroll))px"
		batteryLabel.text = "\( Int(UIDevice.current.batteryLevel * 100))%"
		
		// 0 tot 10 procent
		if UIDevice.current.batteryLevel * 100 > 0.0 && UIDevice.current.batteryLevel * 100 < 10.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.21, blue:0.21, alpha:1.0)}
			
			// 10 to 20 procent
		else if UIDevice.current.batteryLevel * 100 > 10.0 && UIDevice.current.batteryLevel * 100 < 20.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.42, blue:0.30, alpha:1.0)}
			
			// 20 to 30 procent
		else if UIDevice.current.batteryLevel * 100 > 20.0 && UIDevice.current.batteryLevel * 100 < 30.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.56, blue:0.36, alpha:1.0)}
			
			// 30 to 40 procent
		else if UIDevice.current.batteryLevel * 100 > 30.0 && UIDevice.current.batteryLevel * 100 < 40.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.70, blue:0.42, alpha:1.0)}
			
			// 40 to 50 procent
		else if UIDevice.current.batteryLevel * 100 > 40.0 && UIDevice.current.batteryLevel * 100 < 50.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.82, blue:0.46, alpha:1.0)}
			
			// 50 to 60 procent
		else if UIDevice.current.batteryLevel * 100 > 50.0 && UIDevice.current.batteryLevel * 100 < 60.0 {contentView.backgroundColor = UIColor(red:1.00, green:0.94, blue:0.51, alpha:1.0)}
			
			// 60 to 70 procent
		else if UIDevice.current.batteryLevel * 100 > 60.0 && UIDevice.current.batteryLevel * 100 < 70.0 {contentView.backgroundColor = UIColor(red:0.78, green:0.95, blue:0.47, alpha:1.0)}
			
			// 70 to 80 procent
		else if UIDevice.current.batteryLevel * 100 > 70.0 && UIDevice.current.batteryLevel * 100 < 80.0 {contentView.backgroundColor = UIColor(red:0.65, green:0.95, blue:0.45, alpha:1.0)}
			
			// 80 to 90 procent
		else if UIDevice.current.batteryLevel * 100 > 80.0 && UIDevice.current.batteryLevel * 100 < 90.0 {contentView.backgroundColor = UIColor(red:0.50, green:0.95, blue:0.42, alpha:1.0)}
			
			// 90 to 100 procent
		else if UIDevice.current.batteryLevel * 100 > 90.0 && UIDevice.current.batteryLevel * 100 < 101.0 {contentView.backgroundColor = UIColor(red:0.40, green:0.95, blue:0.40, alpha:1.0)}
		
		/*
		if(contentView.frame.origin.y > scrollView.contentOffset.y + scrollView.bounds.height - contentView.frame.height  &&
		contentView.frame.origin.y < scrollView.contentOffset.y + scrollView.bounds.height
		){
		// nothing
		}else
		*/
		
		if currentScroll > maxScroll - 50 && !needsMoreScroll{
			
			needsMoreScroll = true
			if(timer != nil){
				timer.invalidate()
			}
			
			Timer.scheduledTimer(timeInterval: 0, //0.05 //laten wachten
				target:self,
				selector:#selector(ScrollerController.addScroll(_:)),
				userInfo:nil,
				repeats:false)
		}
	}
	
	func addScroll(_ timer: Timer){
		if(needsMoreScroll){
			var size = scrollView.contentSize
			size.height = size.height  + 3 * self.view.frame.size.height
			scrollView.contentSize = size
			needsMoreScroll = false
			scrollView.flashScrollIndicators()
		}
	}
	
	//MARK: - BLE stuffz
	
	func bleSetup(){
		bleShield = BLE()
		bleShield.delegate = self
	}
	
	func bleMakeConnection(){
		if bleShield.peripherals.count > 0 {
			print("BLE found \(bleShield.peripherals.count) peripherals")
			bleShield.connectToPeripheral(peripheral: bleShield.peripherals[0])
		}else{
			print("BLE has found 0 peripherals. Will retry in 5 sec")
			bleShield.startScanning(timeout: 3)
			bleTimer = Timer.scheduledTimer(withTimeInterval: 3,
			                                repeats: false,
			                                block: {
												(timer) in
												timer.invalidate()
												self.bleMakeConnection()
			}
			)
		}
	}
	
	
	//MARK:- BLEDelegate
	
	func bleDidUpdateState(){ // this gets called when bluetooth wakes up...
		bleShield.startScanning(timeout: 3) // scan 5 sec
		bleTimer = Timer.scheduledTimer(withTimeInterval: 3,
		                                repeats: false,
		                                block: {
											(timer) in
											timer.invalidate()
											self.bleMakeConnection()
		}
		)
		
	}
	
	func bleDidConnectToPeripheral(){
		print("BLE connected to peripheral")
		// send some bs
		bleShield.write(data: "Hello Kidz".data(using: .utf8)!)
	}
	
	func bleDidDisconnectFromPeripheral(){
		
	}
	
	func bleDidReceiveData(data: Data?){
		if let data = data,
			let input = String.init(data: data, encoding: .utf8){
			print("BLE received \(input)")
			bleShield.write(data: "'\(input)'".data(using: .utf8)!)
		}else{
			print("BLE received bad data")
		}
	}
	
	
}
