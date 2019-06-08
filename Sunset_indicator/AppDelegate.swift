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
    var mode: Int = 0 // 0 = auto, 1 = always sunrise, 2 = always sunset, 3 = both rise/set
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
    
    @objc func updateSunset(_ source: Bool) {
        if sunInfo == nil {
            sunInfo = EDSunriseSet(timezone: TimeZone.init(secondsFromGMT: 0), latitude: 0, longitude: 0)
        }
        sunInfo!.calculateSunriseSunset(Date())
        let calendar = Calendar.current
        let rise = sunInfo!.sunrise!
        let set = sunInfo!.sunset!
        var date: Date
        var autoSun: Bool // true = rise, false = set
        
        let riseStr = "\(calendar.component(.hour, from: rise)):\(calendar.component(.minute, from: rise))"
        let setStr = "\(calendar.component(.hour, from: set)):\(calendar.component(.minute, from: set))"
        
        sunriseDisplay.title = "Sunrise: \(riseStr)"
        sunsetDisplay.title = "Sunset: \(setStr)"
        
        if(rise.timeIntervalSinceNow < set.timeIntervalSinceNow && rise.timeIntervalSinceNow > 0 || set.timeIntervalSinceNow < 0) {
            date = rise
            autoSun = true
        } else {
            date = set
            autoSun = false
        }
        
        if(mode == 1 || (autoSun && mode == 0)) {
            statusItem.button?.title = sunriseDisplay.title
        } else if(mode == 2 || (!autoSun && mode == 0)) {
            statusItem.button?.title = sunsetDisplay.title
        } else {
            mode = 0
            updateSunset(source)
            return;
        }
        
        if(source) {
            Timer.scheduledTimer(timeInterval: date.timeIntervalSinceNow, target: self, selector: #selector(updateLocation), userInfo: nil, repeats: false)
        }
    }
    @objc func updateLocation() {
        manager.requestLocation()
        updateSunset(true)
    }
    
    @objc func autoMode() {
        mode = 0
        updateSunset(false)
    }
    @objc func sunriseMode() {
        mode = 1
        updateSunset(false)
    }
    @objc func sunsetMode() {
        mode = 2
        updateSunset(false)
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
        updateSunset(false)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog(error.localizedDescription)
        manager.requestLocation()
    }
}

