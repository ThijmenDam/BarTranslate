//
//  ApplicationPopover.swift
//  BarTranslate
//
//  Created by Thijmen Dam on 26/05/2023.
//

import Foundation
import SwiftUI

class ApplicationPopover: NSObject {
    let popover = NSResponder()
    
    func createPopover() -> NSResponder {
        let contentView = ContentView()
        
        let topView = NSHostingController(rootView: contentView)
        topView.view.frame.size = CGSize(width: 400, height: 500)
        
        let customMenuItem = NSMenuItem()
        customMenuItem.view = topView.view
            
        menu.addItem(customMenuItem)
        menu.addItem(NSMenuItem.separator())
        
        return popover
    }
}
