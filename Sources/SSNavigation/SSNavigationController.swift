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

        // 把NavigationBar设置为透明，view自带navigationBar作为背景，更易于控制
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.shadowColor = nil
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.standardAppearance = appearance
            navigationBar.compactAppearance = appearance
        } else {
            // Fallback on earlier versions
            navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationBar.setBackgroundImage(UIImage(), for: .compact)
            navigationBar.setBackgroundImage(UIImage(), for: .defaultPrompt)
            navigationBar.setBackgroundImage(UIImage(), for: .compactPrompt)
            navigationBar.shadowImage = UIImage()
        }
    }

    open override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0, hidesBottomBarWhenPushToSubView {
            viewController.hidesBottomBarWhenPushed = true
        } else {
            viewController.hidesBottomBarWhenPushed = false
        }
        super.pushViewController(viewController, animated: animated)
    }
}

extension SSNavigationController {
    // 手势是否允许触发，如果子类重写了leftItem则无法触发，这里强制开启触发
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            return viewControllers.count > 1
        }
        if let top = topViewController as? SSViewController {
            if !top.canGoBack {
                return false
            }
            if !top.canSwipeGoBack {
                return false
            }
        }
        return true
    }
}

extension SSNavigationController {

    open override func popViewController(animated: Bool) -> UIViewController? {
        if let ss = topViewController as? SSViewController {
            // 这里保存一个变量，用于下面返回的时候判断，如果正在返回，则使用系统的方法，否则容易引起无法返回的问题
            ss.willPop = true
        }
        let pop = super.popViewController(animated: animated)
        if let ss = pop as? SSViewController {
            ss.willGoBack()
        }
        return pop
    }

    func defaultPopView() -> Bool {
        return true
    }

    func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        guard let topViewController = item.viewController as? SSViewController else {
            return defaultPopView()
        }

        if topViewController.responds(to: Selector(("backButtonDidClick"))) {
            topViewController.backButtonDidClick()
        }

        // 点击按钮是否需要返回
        if !topViewController.canGoBack {
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
            return top.preferredStatusBarStyle
        }
        return super.preferredStatusBarStyle
    }
}
