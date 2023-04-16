//
//  File.swift
//  
//
//  Created by zhtg on 2023/4/16.
//

import UIKit

private var UINavigationItemViewControllerKey = 0

extension UINavigationItem {

    class WeakObject {
        weak var object: AnyObject?
    }

    /// 保存一个View的指针
    var viewController: UIViewController? {
        get {
            let weakObject = objc_getAssociatedObject(self, &UINavigationItemViewControllerKey) as? WeakObject
            return weakObject?.object as? UIViewController
        }
        set {
            let weakObject = WeakObject()
            weakObject.object = newValue
            objc_setAssociatedObject(self, &UINavigationItemViewControllerKey, weakObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
