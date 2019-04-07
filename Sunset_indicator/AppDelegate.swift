//
//  AppDelegate.swift
//  Sunset_indicator
//
//  Created by Daniel Thalman on 4/6/19.
//  Copyright © 2019 Daniel Thalman. All rights reserved.
//

import Cocoa
import CoreLocation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var locationDisplay = NSMenuItem(title: "Location: NA", action: nil, keyEquivalent: "")
    var sunsetDisplay = NSMenuItem(title: "Sunset: NA", action: nil, keyEquivalent: "")
    var sunriseDisplay = NSMenuItem(title: "Sunrise: NA", action: nil, keyEquivalent: "")
    var sunInfo: EDSunriseSet?
    var mode: Int = 0 // 0 = auto, 1 = always sunrise, 2 = always sunset
    var manager: CLLocationManager!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        manager = CLLocationManager()
        manager.delegate = self
        
        sunInfo = EDSunriseSet(timezone: TimeZone.autoupdatingCurrent, latitude: 41.1639, longitude: -87.884)
        
        constructMenu()
        updateLocation()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func printQuote(_ sender: Any?) {
        print("sample text")
    }
    
    @objc func updateSunset(_ sender: Any?) {
        if sunInfo == nil {
            sunInfo = EDSunriseSet(timezone: TimeZone.init(secondsFromGMT: 0), latitude: 0, longitude: 0)
        }
        sunInfo!.calculateSunriseSunset(Date())
        let calendar = Calendar.current
        let rise = sunInfo!.sunrise!
        let set = sunInfo!.sunset!
        var date: Date
        var prefix: String
        if(mode == 0) {
            if(rise.timeIntervalSinceNow < set.timeIntervalSinceNow && rise.timeIntervalSinceNow > 0 || set.timeIntervalSinceNow < 0) {
                date = rise
            } else {
                date = set
            }
        } else if(mode == 1) {
            date = rise
        } else if(mode == 2) {
            date = set
        } else {
            mode = 0
            updateSunset(sender)
            return;
        }
        if(date.timeIntervalSince(rise) == 0) {
            prefix = "Sunrise"
        } else {
            prefix = "Sunset"
        }
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        statusItem.button?.title = "\(prefix): \(hour):\(minutes)"
        sunriseDisplay.title = "Sunrise: \(calendar.component(.hour, from: rise)):\(calendar.component(.minute, from: rise))"
        sunsetDisplay.title = "Sunset: \(calendar.component(.hour, from: set)):\(calendar.component(.minute, from: set))"
        if(sender != nil ) {
            Timer.scheduledTimer(timeInterval: date.timeIntervalSinceNow, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: false)
        }
    }
    @objc func updateLocation() {
        manager.requestLocation()
        updateSunset(1)
    }
    
    @objc func autoMode() {
        mode = 0
        updateSunset(nil)
    }
    @objc func sunriseMode() {
        mode = 1
        updateSunset(nil)
    }
    @objc func sunsetMode() {
        mode = 2
        updateSunset(nil)
    }
    
    func constructMenu() {
        let menu = NSMenu()
        let menuShow = NSMenuItem(title: "Show", action: nil, keyEquivalent: "")
        
        menuShow.submenu = NSMenu()
        menuShow.submenu!.addItem(NSMenuItem(title: "Auto Sunset/Sunrise", action: #selector(autoMode), keyEquivalent: ""))
        menuShow.submenu!.addItem(NSMenuItem(title: "Always Show Sunrise", action: #selector(sunriseMode), keyEquivalent: ""))
        menuShow.submenu!.addItem(NSMenuItem(title: "Always Show Sunset", action: #selector(sunsetMode), keyEquivalent: ""))
        
        menu.addItem(locationDisplay)
        menu.addItem(sunriseDisplay)
        menu.addItem(sunsetDisplay)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(menuShow)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Sunset Indicator", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        NSLog("did find location")
        sunInfo = EDSunriseSet(timezone: TimeZone.autoupdatingCurrent, latitude: manager.location?.coordinate.latitude ?? 0.0, longitude: manager.location?.coordinate.longitude ?? 0.0)
        locationDisplay.title = "Location: \(manager.location?.coordinate.latitude ?? 0.0), \(manager.location?.coordinate.longitude ?? 0.0)"
        updateSunset(nil)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog(error.localizedDescription)
        manager.requestLocation()
    }
}

