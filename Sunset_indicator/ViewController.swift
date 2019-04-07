//
//  ViewController.swift
//  Sunset_indicator
//
//  Created by Daniel Thalman on 4/6/19.
//  Copyright © 2019 Daniel Thalman. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var timeZoneChooser: NSComboBox!
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func applyClosePrefences(_ sender: Any) {
        applyPrefences(sender)
        cancelPrefences(sender)
    }
    @IBAction func applyPrefences(_ sender: Any) {
        NSLog("applying prefences")
    }
    @IBAction func cancelPrefences(_ sender: Any) {
        self.view.window?.close()
    }
    
}

