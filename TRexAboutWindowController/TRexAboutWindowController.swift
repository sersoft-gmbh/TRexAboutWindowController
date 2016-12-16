//
//  TRexAboutWindowController.swift
//  T-Rex
//
//  Created by David Ehlen on 24.07.15.
//  Copyright © 2015 David Ehlen. All rights reserved.
//

import Foundation
import Cocoa

open class TRexAboutWindowController: NSWindowController, NSWindowDelegate {
    dynamic public var appName = ""
    dynamic public var appVersion = ""
    
    dynamic public var appCopyright: NSAttributedString? = nil
    dynamic public var appEULA: NSAttributedString? = nil
    dynamic public var appCredits: NSAttributedString? = nil
    
    open var appURL: URL?
    
    @IBOutlet public var contentView: NSView!
    @IBOutlet public var visitWebsiteButton: NSButton!
    @IBOutlet public var appNameLabel: NSTextField!
    @IBOutlet public var versionLabel: NSTextField!
    @IBOutlet public var textView: NSTextView!
    @IBOutlet public var copyrightButton: NSButton!
    @IBOutlet public var eulaButton: NSButton!
    @IBOutlet public var creditsButton: NSButton!
    
    dynamic internal var currentText: NSAttributedString?
    
    public convenience init() {
        self.init(windowNibName: "PFAboutWindow")
    }
    
    override open func windowDidLoad() {
        super.windowDidLoad()
        
        window?.backgroundColor = NSColor.white
        contentView.layer?.cornerRadius = 10.0
        contentView.layer?.backgroundColor = NSColor.white.cgColor
        
        if appName.isEmpty {
            appName = valueFromInfoDict("CFBundleName")
        }
        
        if appVersion.isEmpty {
            let version = valueFromInfoDict("CFBundleVersion")
            let shortVersion = valueFromInfoDict("CFBundleShortVersionString")
            appVersion = "Version \(shortVersion) (Build \(version))"
        }
        
        if appCopyright == nil {
            let color: NSColor
            if #available(macOS 10.10, *) {
                color = NSColor.tertiaryLabelColor
            } else {
                color = NSColor.lightGray
            }
            let font = NSFont.systemFont(ofSize: 11)
            let attribs: [String: Any] = [NSForegroundColorAttributeName: color,
                                          NSFontAttributeName: font]
            appCopyright = NSAttributedString(string: valueFromInfoDict("NSHumanReadableCopyright"), attributes:attribs)
        }
        
        if appCredits == nil {
            let creditsRTF = Bundle.main.path(forResource: "Credits", ofType: "rtf")
            appCredits = creditsRTF.flatMap { NSAttributedString(path: $0, documentAttributes: nil) }
        }
        
        if appEULA == nil {
            let eulaRTF = Bundle.main.path(forResource: "EULA", ofType: "rtf")
            appEULA = eulaRTF.flatMap { NSAttributedString(path: $0, documentAttributes: nil) }
        }
        
        currentText = appCopyright
        
        copyrightButton.title = NSLocalizedString("Copyright", comment: "TRexAboutWindowController")
        eulaButton.title = NSLocalizedString("EULA", comment: "TRexAboutWindowController")
        creditsButton.title = NSLocalizedString("Credits", comment: "TRexAboutWindowController")
    }
    
    open func windowWillClose(_ notification: Notification) {
        showCopyright(notification)
    }
    
    // Actions
    @IBAction func visitWebsite(_ sender: Any) {
        guard let url = appURL else { return }
        NSWorkspace.shared().open(url)
    }
    
    @IBAction func showCopyright(_ sender: Any) {
        collapseWindow()
        currentText = appCopyright
    }
    
    @IBAction func showEULA(_ sender: Any) {
        expandWindow()
        currentText = appEULA
    }
    
    @IBAction func showCredits(_ sender: Any) {
        expandWindow()
        currentText = appCredits
    }
    
    //Private
    private var isWindowExpanded = false
    
    private func valueFromInfoDict(_ string: String) -> String {
        let dictionary = Bundle.main.infoDictionary
        let result = dictionary?[string] as? String
        return result ?? String()
    }
    
    private func expandWindow() {
        guard !isWindowExpanded else { return }
        changeWindowHeight(by: 100)
        isWindowExpanded = true
    }
    
    private func collapseWindow() {
        guard isWindowExpanded else { return }
        changeWindowHeight(by: -100)
        isWindowExpanded = false
    }
    
    private func changeWindowHeight(by difference: CGFloat, animated: Bool = true) {
        guard let window = window else { return }
        var oldFrame = window.frame
        oldFrame.size.height += difference
        oldFrame.origin.y -= difference
        window.setFrame(oldFrame, display: true, animate: animated)
    }
}
