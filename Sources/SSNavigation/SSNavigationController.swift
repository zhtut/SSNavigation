//
//  File.swift
//  
//
//  Created by zhtg on 2023/4/16.
//

import UIKit

/// 自定义的view
open class SSNavigationController: UINavigationController {

    /// 推进到子类的时候，自动设置子类的hidesBottomBar为yes
    open var hidesBottomBarWhenPushToSubView: Bool = true

    open override func viewDidLoad() {
        super.viewDidLoad()

        // 重刷一下方向
        view.semanticContentAttribute = UIView.appearance().semanticContentAttribute
        if let top = topViewController {
            self.setNavigationBarHidden(top.navi.isNavigationBarHidden, animated: false)
        }
    }

    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0, hidesBottomBarWhenPushToSubView {
            viewController.hidesBottomBarWhenPushed = true
        } else {
            viewController.hidesBottomBarWhenPushed = false
        }
        viewController.setupHookMethods()
        super.pushViewController(viewController, animated: animated)
        setNavigationBarHidden(viewController.navi.isNavigationBarHidden, animated: animated)
    }
}

extension SSNavigationController {
    // 手势是否允许触发，如果子类重写了leftItem则无法触发，这里强制开启触发
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            return viewControllers.count > 1
        }
        if let top = topViewController {
            let navi = top.navi
            if !navi.canGoBack {
                return false
            }
            if !navi.canSwipeGoBack {
                return false
            }
        }
        return true
    }
}

extension SSNavigationController {

    open override func popViewController(animated: Bool) -> UIViewController? {
        if let ss = topViewController {
            // 这里保存一个变量，用于下面返回的时候判断，如果正在返回，则使用系统的方法，否则容易引起无法返回的问题
            ss.willPop = true
        }
        let pop = super.popViewController(animated: animated)
        if let ss = pop {
            ss.willGoBack()
        }
        if let top = topViewController {
            setNavigationBarHidden(top.navi.isNavigationBarHidden, animated: animated)
        }
        return pop
    }

    func defaultPopView() -> Bool {
        return true
    }

    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        guard let topViewController = item.viewController else {
            return defaultPopView()
        }

        if topViewController.responds(to: Selector(("backButtonDidClick"))) {
            topViewController.backButtonDidClick()
        }

        // 点击按钮是否需要返回
        if !topViewController.navi.canGoBack {
            for view in navigationBar.subviews {
                if view.alpha < 1.0 {
                    UIView.animate(withDuration: 0.25, animations: {
                        view.alpha = 1.0
                    })
                }
            }
            return false
        }

        return true
    }
}

extension SSNavigationController {
    // status的颜色，优先交给顶部的控制，然后交给子类控制
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if let presented = presentedViewController {
            return presented.preferredStatusBarStyle
        }
        if let top = topViewController {
            return top.statusBarStyle
        }
        return super.preferredStatusBarStyle
    }
}
