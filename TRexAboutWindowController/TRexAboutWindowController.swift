//
//  TRexAboutWindowController.swift
//  T-Rex
//
//  Created by David Ehlen on 24.07.15.
//  Copyright © 2015 David Ehlen. All rights reserved.
//

import Cocoa

open class TRexAboutWindowController: NSWindowController {
    open var appName = ""
    open var appVersion = ""
    
    open var appCopyright = NSAttributedString()
    open var appCredits = NSAttributedString()
    open var appEULA = NSAttributedString()
    
    open var appURL: URL?
    
    open var windowShouldHaveShadow: Bool = true {
        didSet {
            window?.hasShadow = windowShouldHaveShadow
        }
    }
    
    @IBOutlet public var infoView: NSView!
    @IBOutlet public var textField: NSTextView!
    @IBOutlet public var visitWebsiteButton: NSButton!
    @IBOutlet public var EULAButton: NSButton!
    @IBOutlet public var creditsButton: NSButton!
    @IBOutlet public var versionLabel: NSTextField!
    
    public convenience init() {
        self.init(windowNibName: "PFAboutWindow")
    }
    
    override open func windowDidLoad() {
        super.windowDidLoad()
        
        infoView.wantsLayer = true
        infoView.layer?.cornerRadius = 10.0
        infoView.layer?.backgroundColor = NSColor.white.cgColor
        
        window?.backgroundColor = NSColor.white
        window?.hasShadow = windowShouldHaveShadow
        
        if appName.isEmpty {
            appName = valueFromInfoDict("CFBundleName")
        }
        
        if appVersion.isEmpty {
            let version = valueFromInfoDict("CFBundleVersion")
            let shortVersion = valueFromInfoDict("CFBundleShortVersionString")
            appVersion = "Version \(shortVersion) (Build \(version))"
            versionLabel.stringValue = appVersion
        }
        
        if appCopyright.string.isEmpty {
            let color: NSColor
            if #available(macOS 10.10, *) {
                color = NSColor.tertiaryLabelColor
            } else {
                color = NSColor.lightGray
            }
            let font = NSFont(name: "HelveticaNeue", size: 11.0) ?? NSFont.systemFont(ofSize: 11)
            let attribs: [String: Any] = [NSForegroundColorAttributeName: color,
                                          NSFontAttributeName: font]
            appCopyright = NSAttributedString(string: valueFromInfoDict("NSHumanReadableCopyright"), attributes:attribs)
        }
        
        if appCredits.string.isEmpty {
            if let creditsRTF = Bundle.main.path(forResource: "Credits", ofType: "rtf"),
                let credits = NSAttributedString(path: creditsRTF, documentAttributes: nil) {
                appCredits = credits
            } else {
                creditsButton.isHidden = true
                #if DEBUG
                    print("Credits not found in bundle or file is invalid. Hiding Credits Button.")
                #endif
            }
        }
        
        if appEULA.string.isEmpty {
            if let eulaRTF = Bundle.main.path(forResource: "EULA", ofType: "rtf"),
                let eula = NSAttributedString(path: eulaRTF, documentAttributes: nil) {
                appEULA = eula
            } else {
                EULAButton.isHidden = true
                #if DEBUG
                    print("EULA not found in bundle or file is invalid. Hiding EULA Button.")
                #endif
            }
        }
        
        textField.textStorage?.setAttributedString(appCopyright)
        creditsButton.title = NSLocalizedString("Credits", comment: "TRexAboutWindowController")
        EULAButton.title = NSLocalizedString("EULA", comment: "TRexAboutWindowController")
    }
    
    @IBAction func visitWebsite(_ sender: Any) {
        guard let url = appURL else { return }
        
        NSWorkspace.shared().open(url)
    }
    
    @IBAction func showCredits(_ sender: Any) {
        expandWindow()
        textField.textStorage?.setAttributedString(appCredits)
    }
    
    @IBAction func showEULA(_ sender: Any) {
        expandWindow()
        textField.textStorage?.setAttributedString(appEULA)
    }
    
    @IBAction func showCopyright(_ sender: Any) {
        collapseWindow()
        textField.textStorage?.setAttributedString(appCopyright)
    }
    
    open func windowShouldClose(_ sender: Any) -> Bool {
        showCopyright(sender)
        return true
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
