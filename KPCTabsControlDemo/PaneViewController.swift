//
//  ViewController.swift
//  KPCTabsControlDemo
//
//  Created by Cédric Foellmi on 15/07/16.
//  Licensed under the MIT License (see LICENSE file)
//

import Cocoa
import KPCTabsControl

// We need a class (rather than a struct or a tuple, which would be nice, because TabsControlDelegate has
// @optional methods. To have such optionaling, we need to mark the protocol as @objc. With such marking,
// we can't have pure-Swift 'Any' return object or argument. Buh...

class Item {
    var title: String = ""
    var icon: NSImage?
    var menu: NSMenu?
    
    init(title: String, icon: NSImage?, menu: NSMenu?) {
        self.title = title
        self.icon = icon
        self.menu = menu
    }
}

class PaneViewController: NSViewController, TabsControlDataSource, TabsControlDelegate {

    @IBOutlet weak var tabsBar: TabsControl?
    @IBOutlet weak var useFullWidthTabsCheckButton: NSButton?
    @IBOutlet weak var tabWidthsLabel: NSTextField?

    var items: Array<Item> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabsBar?.dataSource = self
        self.tabsBar?.delegate = self
        
        let labelString = NSString(format:"min %.0f < %.0f < %.0f max", self.tabsBar!.minTabWidth, self.tabsBar!.currentTabWidth(), self.tabsBar!.maxTabWidth)

        self.tabWidthsLabel?.stringValue = labelString as String
        
        self.tabsBar!.preferFullWidthTabs(self.useFullWidthTabsCheckButton!.state == NSOnState)
        self.tabsBar!.reloadTabs()
    }

    @IBAction func toggleFullWidthTabs(sender: AnyObject) {
        self.tabsBar!.preferFullWidthTabs(self.useFullWidthTabsCheckButton!.state == NSOnState, animated: true)
    }
    
    override func mouseDown(theEvent: NSEvent) {
    
        super.mouseDown(theEvent)
    
        let sendNotification = (self.tabsBar?.highlighted == false)
//        self.tabsBar?.highlight(true)
        
        if (sendNotification) {
            NSNotificationCenter.defaultCenter().postNotificationName("PaneSelectionDidChangeNotification", object: self)
        }
    }
    
    func updateUponPaneSelectionDidChange(notif: NSNotification) {
//        if notif.object != self {
//            self.tabsBar?.highlight(false)
//        }
    }
    
    func updateLabelsUponReframe(notif: NSNotification) {
    
        let labelString = NSString(format:"min %.0f < %.0f < %.0f max", self.tabsBar!.minTabWidth, self.tabsBar!.currentTabWidth(), self.tabsBar!.maxTabWidth)
    
        self.tabWidthsLabel?.stringValue = labelString as String
    }

    // MARK: TabsControlDataSource
    
    func tabsControlNumberOfTabs(control: TabsControl) -> Int {
        return self.items.count
    }
    
    func tabsControl(control: TabsControl, itemAtIndex index: Int) -> AnyObject {
        return self.items[index]
    }
    
    func tabsControl(control: TabsControl, titleForItem item: AnyObject) -> String {
        return (item as! Item).title
    }
    
    // MARK: TabsControlDataSource : Optionals
    
    func tabsControl(control: TabsControl, menuForItem item: AnyObject) -> NSMenu? {
        return (item as! Item).menu
    }
    
    func tabsControl(control: TabsControl, iconForItem item: AnyObject) -> NSImage? {
        return (item as! Item).icon
    }

    // MARK: TabsControlDelegate
    
    func tabsControl(control: TabsControl, canReorderItem item: AnyObject) -> Bool {
        return true
    }
    
    func tabsControl(control: TabsControl, didReorderItems items: [AnyObject]) {
        self.items = items.map { $0 as! Item }
    }
    
    func tabsControl(control: TabsControl, canEditTitleOfItem: AnyObject) -> Bool {
        return true
    }
    
    func tabsControl(control: TabsControl, setTitle newTitle: String, forItem item: AnyObject) {
        let typedItem = item as! Item
        let titles = self.items.map { $0.title }
        let index = titles.indexOf(typedItem.title)!

        let newItem = Item(title: newTitle, icon: typedItem.icon, menu: typedItem.menu)
        let range = index..<index+1
        self.items.replaceRange(range, with: [newItem])
    }
}

