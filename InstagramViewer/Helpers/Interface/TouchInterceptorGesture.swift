//
//  TouchInterceptorGesture.swift
//  InstagramViewer
//
//  Created by Cochioras Bogdan Ionut on 4/8/22.
//

import Foundation
import UIKit

/// Intercept touches without conflicting with other gestures.
final class TouchInterceptorGesture: UIGestureRecognizer {
    
    /// Callback called when touches began is called.
    var touchesBeganCallback: ((Set<UITouch>, UIEvent) -> Void)?
    
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        // prevent canceling other user interactions
        cancelsTouchesInView = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        touchesBeganCallback?(touches, event)
    }
    
    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
