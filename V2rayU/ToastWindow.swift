//
//  ToastWindowController.swift
//  ShadowsocksX-NG
//
//  Created by 邱宇舟 on 2017/3/20.
//  Copyright © 2017年 qiuyuzhou. All rights reserved.
//

import Cocoa

var toastWindow =  ToastWindowController()

func makeToast(message: String, displayDuration: Double? = 3) {
    // UI 更新需要在主线程上执行
    DispatchQueue.main.async {
        print("makeToast", message)
        toastWindow.close()
        toastWindow = ToastWindowController()
        toastWindow.message = message
        toastWindow.showWindow(Any.self)
        toastWindow.fadeInHud(displayDuration)
        
        NSApp.activate(ignoringOtherApps: true)
    }
}

func alertDialog(title: String, message: String) {
    DispatchQueue.main.async {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            print("OK clicked")
        } else {
            print("Cancel clicked")
        }
    }
}

class ToastWindowController: NSWindowController {

    override var windowNibName: String? {
        return "ToastWindow" // no extension .xib here
    }

    var message: String = ""

    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var panelView: NSView!

    let kHudFadeInDuration: Double = 0.35
    let kHudFadeOutDuration: Double = 0.35
    var kHudDisplayDuration: Double = 2

    let kHudAlphaValue: CGFloat = 0.75
    let kHudCornerRadius: CGFloat = 18.0
    let kHudHorizontalMargin: CGFloat = 30
    let kHudHeight: CGFloat = 90.0

    var timerToFadeOut: Timer? = nil
    var fadingOut: Bool = false
    
    var isShow: Bool = false

    override func windowDidLoad() {
        super.windowDidLoad()

        self.shouldCascadeWindows = false

        let viewLayer: CALayer = CALayer()
        viewLayer.backgroundColor = CGColor.init(red: 0.05, green: 0.05, blue: 0.05, alpha: kHudAlphaValue)
        viewLayer.cornerRadius = kHudCornerRadius
        panelView.wantsLayer = true
        panelView.layer = viewLayer
        panelView.layer?.opacity = 0.0

        self.titleTextField.stringValue = self.message

        setupHud()
    }

    func setupHud() -> Void {
        titleTextField.sizeToFit()

        var labelFrame: CGRect = titleTextField.frame
        var hudWindowFrame: CGRect = self.window!.frame
        hudWindowFrame.size.width = labelFrame.size.width + kHudHorizontalMargin * 2
        hudWindowFrame.size.height = kHudHeight
        if NSScreen.screens.count == 0 {
            return
        }
        let screenRect: NSRect = NSScreen.screens[0].visibleFrame
        hudWindowFrame.origin.x = (screenRect.size.width - hudWindowFrame.size.width) / 2
        hudWindowFrame.origin.y = (screenRect.size.height - hudWindowFrame.size.height) / 2
        self.window!.setFrame(hudWindowFrame, display: true)

        var viewFrame: NSRect = hudWindowFrame;
        viewFrame.origin.x = 0
        viewFrame.origin.y = 0
        panelView.frame = viewFrame

        labelFrame.origin.x = kHudHorizontalMargin
        labelFrame.origin.y = (hudWindowFrame.size.height - labelFrame.size.height) / 2
        titleTextField.frame = labelFrame
    }

    func fadeInHud(_ displayDuration: Double?) -> Void {
        if timerToFadeOut != nil {
            timerToFadeOut?.invalidate()
            timerToFadeOut = nil
        }

        // set time to display
        if displayDuration != nil {
            kHudDisplayDuration = displayDuration!
        }

        fadingOut = false

        CATransaction.begin()
        CATransaction.setAnimationDuration(kHudFadeInDuration)
        CATransaction.setCompletionBlock {
            self.didFadeIn()
        }
        panelView.layer?.opacity = 1.0
        CATransaction.commit()
    }

    func didFadeIn() -> Void {
        timerToFadeOut = Timer.scheduledTimer(
                timeInterval: kHudDisplayDuration,
                target: self,
                selector: #selector(fadeOutHud),
                userInfo: nil,
                repeats: false)
    }

    @objc func fadeOutHud() -> Void {
        fadingOut = true

        CATransaction.begin()
        CATransaction.setAnimationDuration(kHudFadeOutDuration)
        CATransaction.setCompletionBlock {
            self.didFadeOut()
        }
        panelView.layer?.opacity = 0.0
        CATransaction.commit()
    }

    func didFadeOut() -> Void {
        if fadingOut {
            self.window?.orderOut(self)
        }
        fadingOut = false
    }
}
