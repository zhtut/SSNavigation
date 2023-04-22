//
//  UIBarAlpha.swift
//  SSNavigation
//
//  Created by zhtg on 2023/4/19.
//

import Foundation

public extension UINavigationBar {
    func configureAlpha(_ alpha: CGFloat) {
        self.alpha = alpha
        subviews.forEach({ $0.alpha = alpha })
    }
}

public extension UIToolbar {
    func configureAlpha(_ alpha: CGFloat) {
        self.alpha = alpha
        subviews.forEach({ $0.alpha = alpha })
    }
}
