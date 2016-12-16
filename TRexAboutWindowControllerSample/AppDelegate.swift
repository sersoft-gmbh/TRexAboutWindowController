//
//  AppDelegate.swift
//  TRexAboutWindowController
//
//  Created by David Ehlen on 25.07.15.
//  Copyright © 2015 David Ehlen. All rights reserved.
//

import Cocoa
import TRexAboutWindowController

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private lazy var aboutWindowController = TRexAboutWindowController()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @IBAction func showAboutWindow(_ sender: Any) {
        guard let url = URL(string:"https://github.com/T-Rex-Editor/") else {
            print("Could not create URL!")
            return
        }
        aboutWindowController.appURL = url
        aboutWindowController.appName = "TRex-Editor"
        
        let font = NSFont(name: "HelveticaNeue", size: 11.0)
        let color = NSColor.tertiaryLabelColor
        let attribs = [
            NSForegroundColorAttributeName: color,
            NSFontAttributeName: font!
        ]
        aboutWindowController.appCopyright = NSAttributedString(string: "Copyright (c) 2015 David Ehlen", attributes: attribs)
        
        aboutWindowController.windowShouldHaveShadow = true
        aboutWindowController.showWindow(sender)
    }
}

