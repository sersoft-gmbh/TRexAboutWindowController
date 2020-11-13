//
//  TRexAboutWindowController.swift
//  T-Rex
//
//  Created by David Ehlen on 24.07.15.
//  Copyright © 2015 David Ehlen. All rights reserved.
//

import Foundation
import Cocoa

#if !swift(>=4.2)
fileprivate extension NSAttributedString {
    typealias Key = NSAttributedStringKey
}
#endif

open class TRexAboutWindowController: NSWindowController, NSWindowDelegate {
    @objc dynamic public var appName = ""
    @objc dynamic public var appVersion = ""

    @objc dynamic public var supportEmail: String?

    @objc dynamic public var appCopyright: NSAttributedString? = nil
    @objc dynamic public var appEULA: NSAttributedString? = nil
    @objc dynamic public var appCredits: NSAttributedString? = nil
    
    open var appURL: URL?
    
    @IBOutlet public var contentView: NSBox!
    @IBOutlet public var visitWebsiteButton: NSButton!
    @IBOutlet public var supportButton: NSButton!
    @IBOutlet public var appNameLabel: NSTextField!
    @IBOutlet public var versionLabel: NSTextField!
    @IBOutlet public var textView: NSTextView!
    @IBOutlet public var copyrightButton: NSButton!
    @IBOutlet public var eulaButton: NSButton!
    @IBOutlet public var creditsButton: NSButton!
    
    @objc dynamic var currentText: NSAttributedString?
    private var currentButton: NSButton? {
        willSet { currentButton?.state = .off }
        didSet { currentButton?.state = .on }
    }
    
    public convenience init() {
        #if swift(>=4.2)
        self.init(windowNibName: "PFAboutWindow")
        #else
        self.init(windowNibName: .init(rawValue: "PFAboutWindow"))
        #endif
    }
    
    override open func windowDidLoad() {
        super.windowDidLoad()

        if #available(macOS 10.14, *) {
            window?.backgroundColor = .windowBackgroundColor
            contentView.fillColor = .windowBackgroundColor
        } else {
            window?.backgroundColor = .white
            contentView.fillColor = .white
        }
        contentView.cornerRadius = 10
        
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
                color = .tertiaryLabelColor
            } else {
                color = .lightGray
            }
            let font = NSFont.systemFont(ofSize: 11)
            let attribs: [NSAttributedString.Key: Any] = [.foregroundColor: color, .font: font]
            appCopyright = NSAttributedString(string: valueFromInfoDict("NSHumanReadableCopyright"), attributes: attribs)
        }
        
        if appCredits == nil {
            appCredits = loadRTFAttributedString(named: "Credits")
        }
        
        if appEULA == nil {
            appEULA = loadRTFAttributedString(named: "EULA")
        }

        currentButton = copyrightButton
        currentText = appCopyright

        supportButton.title = NSLocalizedString("Support", comment: "TRexAboutWindowController")
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
        NSWorkspace.shared.open(url)
    }

    @IBAction func sendSupportMail(_ sender: Any) {
        guard let url = supportEmail.flatMap({ URL(string: "mailto:\($0)") }) else { return }
        NSWorkspace.shared.open(url)
    }

    @IBAction func showCopyright(_ sender: Any) {
        currentButton = copyrightButton
        collapseWindow()
        currentText = appCopyright
    }
    
    @IBAction func showEULA(_ sender: Any) {
        currentButton = eulaButton
        expandWindow()
        currentText = appEULA
    }
    
    @IBAction func showCredits(_ sender: Any) {
        currentButton = creditsButton
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

    private func loadRTFAttributedString(named name: String) -> NSAttributedString? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "rtf") else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any]
        if #available(macOS 10.14, *) {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.textColor
            ]
            options = [.defaultAttributes: attributes]
        } else {
            options = [:]
        }
        return try? NSAttributedString(url: url, options: options, documentAttributes: nil)
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
