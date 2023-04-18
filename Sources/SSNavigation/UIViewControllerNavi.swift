//
//  File.swift
//
//
//  Created by zhtg on 2023/4/16.
//

import UIKit

open class SSNavigationBarConfig: NSObject {

    open weak var view: UIViewController?

    public init(view: UIViewController) {
        super.init()
        self.view = view
    }

    /// 是否隐藏导航条
    open var isNavigationBarHidden = false

    /// 返回默认的颜色
    private var statusBarDefault: Bool {
        if #available(iOS 12.0, *) {
            let userInterfaceStyle = view?.traitCollection.userInterfaceStyle
            if userInterfaceStyle == .dark {
                return false
            } else {
                return true
            }
        } else {
            return true
        }
    }

    fileprivate var _isBlackStatusBar: Bool?

    /// 状态栏的颜色是否为黑色，如果设定为NO，则为q白色，默认为系统的颜色的相反颜色
    /// 暗黑为false，淡色为true
    open var isBlackStatusBar: Bool {
        get {
            _isBlackStatusBar ?? statusBarDefault
        }
        set {
            _isBlackStatusBar = newValue
            view?.setNeedsStatusBarAppearanceUpdate()
        }
    }

    /// 是否允许返回，点击返回的时候，触发查询判断，默认返回YES，如果返回NO，则点击返回按钮不能返回，右滑返回手势会被禁用
    /// 子类如果不允许返回，也在这个方法中实现，点击的时候即会返回
    /// @return 返回是否允许返回
    open var canGoBack: Bool = true

    /// 是否允许滑动返回，如果canGoBack为NO，则canSwipeGoBack设置无效，直接为NO，如果仅canSwipeGoBack返回NO，则右滑返回无响应，点击左上角返回按钮可返回
    /// @return 返回是否允许滑动返回
    open var canSwipeGoBack: Bool = true
}

private var SSNavigationBarConfigKey = "SSNavigationBarConfigKey"
private var UIViewControllerWillPopKey = "UIViewControllerWillPopKey"

/// 自定义的view
public extension UIViewController {

    /// 即将退出的时候，置为YES
    var willPop: Bool {
        get {
            objc_getAssociatedObject(self, &UIViewControllerWillPopKey) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &UIViewControllerWillPopKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    open var navi: SSNavigationBarConfig {
        get {
            if let config = objc_getAssociatedObject(self, &SSNavigationBarConfigKey) as? SSNavigationBarConfig {
                return config
            }
            let newConfig = SSNavigationBarConfig(view: self)
            objc_setAssociatedObject(self, &SSNavigationBarConfigKey, newConfig, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return newConfig
        }
        set {
            objc_setAssociatedObject(self, &SSNavigationBarConfigKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func setupHookMethods() {
        
        // 保存一个引用给NavigationItem，方便需要的时候调用
        navigationItem.viewController = self

        // hook addSubView等方法，使添加navigationBar一直保持在最上面
        UIViewController.hookMethods()
    }
}

extension UIViewController {
    static func exchangeInstanceMethod(sel1: Selector, sel2: Selector) {
        let cls = Self.self
        guard let method1 = class_getInstanceMethod(cls, sel1),
              let method2 = class_getInstanceMethod(cls, sel2) else {
            return
        }
        method_exchangeImplementations(method1, method2)
    }

    static var didHookViewController = false

    static func hookMethods() {
        guard !didHookViewController else {
            return
        }
        // hook addSubView等方法，使添加navigationBar一直保持在最上面
        hookViewControllerSomeMethods()
        didHookViewController = true
    }

    static func hookViewControllerSomeMethods() {
        exchangeInstanceMethod(sel1: #selector(traitCollectionDidChange(_:)),
                               sel2: #selector(__traitCollectionDidChange(_:)))
        exchangeInstanceMethod(sel1: #selector(didMove(toParent:)),
                               sel2: #selector(__didMove(toParent:)))
    }

    @objc func __traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        __traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 12.0, *) {
            if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
               navi._isBlackStatusBar == nil {
                setNeedsStatusBarAppearanceUpdate()
            }
        }
    }

    open var statusBarStyle: UIStatusBarStyle {
        if navi.isBlackStatusBar {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        } else {
            return .lightContent
        }
    }

    @objc func __didMove(toParent parent: UIViewController?) {
        __didMove(toParent: parent)
        if parent == nil {
            didGoBack()
        }
    }
}

public extension UIViewController {

    /// 返回按钮按下的方法，这里不管能否返回，都会调用
    @objc func backButtonDidClick() {

    }

    /// 滑动手势触发，这里不管能否返回，都会调用
    @objc func swipeGestureTrigger() {

    }

    /// 回调，子类有时候可以在这个方法做些事情，即将回去的方法，在点击左上角的默认返回按钮时会触发，用户滑动页面，即将开始滑动时也会进这个方法
    @objc func willGoBack() {

    }

    /// 回调，完成回上级页面的方法
    @objc func didGoBack() {

    }
}
