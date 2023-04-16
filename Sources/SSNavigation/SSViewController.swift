//
//  File.swift
//  
//
//  Created by zhtg on 2023/4/16.
//

import UIKit

/// 自定义的view
open class SSViewController: UIViewController {

    /// 导航条，就是一个View，``SSNavigationBar``，add在ViewController的View上面，
    /// 和原先的导航条一个高度，可以对这个View进行子类操作，添加子View，设定属性等
    open var navigationBar = SSNavigationBar()

    /// 导航条背景颜色，默认为系统背景颜色
    open var navigationBarColor: UIColor? {
        didSet {
            navigationBar.backgroundColor = navigationBarColor
        }
    }

    /// navigationBar的风格
    public enum NavigationBarStyle {
        /// 默认跟系统的导航条一样大小
        case `default`
        /// 缩小到电池高的高度
        case statusBar
        /// 完全不需要
        case hidden
    }

    private var navigationBarHeightLayout: NSLayoutConstraint?
    private var navigationBarBottomLayout: NSLayoutConstraint?

    /// 导航条是否隐藏，默认为NO，这里只隐藏白色条，不会隐藏返回按钮和title,及rightBarButtonItem等
    open var navigationBarStyle: NavigationBarStyle = .default {
        didSet {
            switch navigationBarStyle {
            case .default:
                navigationBarHeightLayout?.isActive = false
                navigationBarBottomLayout?.isActive = true
                navigationBar.isHidden = false
            case .statusBar:
                navigationBarHeightLayout?.isActive = true
                navigationBarBottomLayout?.isActive = false
                navigationBar.isHidden = false
            case .hidden:
                navigationBar.isHidden = true
            }
        }
    }

    /// 返回默认的颜色
    private var statusBarDefault: Bool {
        let userInterfaceStyle = view.traitCollection.userInterfaceStyle
        if userInterfaceStyle == .dark {
            return false
        } else {
            return true
        }
    }

    private var _isBlackStatusBar: Bool?

    /// 状态栏的颜色是否为黑色，如果设定为NO，则为q白色，默认为系统的颜色的相反颜色
    /// 暗黑为false，淡色为true
    open var isBlackStatusBar: Bool {
        get {
            _isBlackStatusBar ?? statusBarDefault
        }
        set {
            _isBlackStatusBar = newValue
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    /// 是否允许返回，点击返回的时候，触发查询判断，默认返回YES，如果返回NO，则点击返回按钮不能返回，右滑返回手势会被禁用
    /// 子类如果不允许返回，也在这个方法中实现，点击的时候即会返回
    /// @return 返回是否允许返回
    open var canGoBack: Bool = true

    /// 是否允许滑动返回，如果canGoBack为NO，则canSwipeGoBack设置无效，直接为NO，如果仅canSwipeGoBack返回NO，则右滑返回无响应，点击左上角返回按钮可返回
    /// @return 返回是否允许滑动返回
    open var canSwipeGoBack: Bool = true

    /// 即将退出的时候，置为YES
    var willPop: Bool = false

    open override func viewDidLoad() {
        super.viewDidLoad()

        // 重刷一下方向
        view.semanticContentAttribute = UIView.appearance().semanticContentAttribute
        
        // 添加navigationBar
        view.addSubview(navigationBar)
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        navigationBarBottomLayout = navigationBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        navigationBarBottomLayout?.isActive = true
        var statusBarHeight: CGFloat
        if #available(iOS 13.0, *) {
            statusBarHeight = view.window?.windowScene?.statusBarManager?.statusBarFrame.height ??
            UIApplication.shared.statusBarFrame.size.height
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        }
        navigationBarHeightLayout = navigationBar.heightAnchor.constraint(equalToConstant: statusBarHeight)
        navigationBarHeightLayout?.isActive = false

        // hook addSubView等方法，使添加navigationBar一直保持在最上面
        _ = UIView.hookHandler

        // 保存一个引用给NavigationItem，方便需要的时候调用
        navigationItem.viewController = self
    }

    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle,
           _isBlackStatusBar == nil {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}

extension SSViewController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        if isBlackStatusBar {
            if #available(iOS 13.0, *) {
                return .darkContent
            } else {
                return .default
            }
        } else {
            return .lightContent
        }
    }
}

public extension SSViewController {

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            didGoBack()
        }
    }

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
