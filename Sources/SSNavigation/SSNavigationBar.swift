//
//  File.swift
//  
//
//  Created by zhtg on 2023/4/16.
//

import UIKit

open class SSNavigationBar: UIView {

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            // Fallback on earlier versions
            backgroundColor = .white
        }
    }

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view is UIControl {
            return view
        }
        // 返回nil，防止自己接收了点击事件
        return nil
    }
}
