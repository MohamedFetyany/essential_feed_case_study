//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Mohamed Ibrahim on 24/07/2023.
//

import UIKit

public final class ErrorView: UIButton {
        
    public var message: String? {
        get { isVisible ? configuration?.title : nil }
        set { setMessageAnimated(newValue) }
    }
    
    public var onHide: (() -> Void)?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        guard let size = titleLabel?.intrinsicContentSize,
              let insets = configuration?.contentInsets
        else {
            return super.intrinsicContentSize
        }
        
        return CGSize(width: size.width + insets.leading + insets.trailing, height: size.height + insets.top + insets.bottom)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if let insets = configuration?.contentInsets {
            titleLabel?.preferredMaxLayoutWidth = bounds.size.width - insets.leading - insets.trailing
        }
    }
    
    private var titleAttributes: AttributeContainer {
        let paragrphStyle = NSMutableParagraphStyle()
        paragrphStyle.alignment = NSTextAlignment.center
        
        return AttributeContainer([
            .paragraphStyle: paragrphStyle,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ])
    }
    
    private func configure() {
        var configuration = Configuration.plain()
        configuration.titlePadding = 0
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .errorBackgroundColor
        configuration.background.cornerRadius = 0
        self.configuration = configuration
        
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
       
        hideMessage()
    }
    
    private var isVisible: Bool {
        alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        configuration?.attributedTitle = AttributedString(message,attributes: titleAttributes)
        configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0},
            completion: { [weak self] completed in
                if completed {
                    self?.hideMessage()
                }
            })
    }
    
    private func hideMessage() {
        configuration?.attributedTitle = nil
        configuration?.contentInsets = .zero
        alpha = 0
        onHide?()
    }
}

extension UIColor {
    static var errorBackgroundColor: UIColor {
        .init(red: 0.996078431372549, green: 0.411764705882353, blue: 0.411764705882353, alpha: 1)
    }
}
