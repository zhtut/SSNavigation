//
//  File.swift
//  
//
//  Created by zhtg on 2023/4/16.
//

import UIKit
import ObjectiveC

/// 自定义的View，为了保证添加view的时候，不把navigationBar挡住，把navigationBar拿到最上面来
extension UIView {

    static let hookHandler = UIView(hook: true)

    convenience init(hook: Bool) {
        self.init(frame: .zero)
        hookChangeSubviews()
    }

    func exchangeInstanceMethod(sel1: Selector, sel2: Selector) {
        let cls = Self.self
        guard let method1 = class_getInstanceMethod(cls, sel1),
              let method2 = class_getInstanceMethod(cls, sel2) else {
            return
        }
        method_exchangeImplementations(method1, method2)
    }

    func hookChangeSubviews() {
        exchangeInstanceMethod(sel1: #selector(bringSubviewToFront(_:)),
                               sel2: #selector(__bringSubviewToFront(_:)))
        exchangeInstanceMethod(sel1: #selector(didAddSubview(_:)),
                               sel2: #selector(__didAddSubview(_:)))
        exchangeInstanceMethod(sel1: #selector(exchangeSubview(at:withSubviewAt:)),
                               sel2: #selector(__exchangeSubview(at:withSubviewAt:)))
    }

    var navigationBar: SSNavigationBar? {
        subviews.first(where: { $0 is SSNavigationBar}) as? SSNavigationBar
    }

    @objc func __bringSubviewToFront(_ view: UIView) {
        __bringSubviewToFront(view)
        if !(view is SSNavigationBar) {
            bringNavigationBarToFront()
        }
    }

    @objc func __didAddSubview(_ subview: UIView) {
        __didAddSubview(subview)
        if !(subview is SSNavigationBar) {
            bringNavigationBarToFront()
        }
    }

    @objc func __exchangeSubview(at index1: Int, withSubviewAt index2: Int) {
        __exchangeSubview(at: index1, withSubviewAt: index2)
        bringNavigationBarToFront()
    }

    func bringNavigationBarToFront() {
        if let navigationBar {
            __bringSubviewToFront(navigationBar)
        }
    }
}
