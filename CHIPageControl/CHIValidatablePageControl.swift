//
//  CHIValidatablePageControl.swift
//  CHIPageControl
//
//  Created by Aliaksandr Mazurau on 10.05.22.
//  Copyright © 2022 chi.lv. All rights reserved.
//

import UIKit

open class CHIValidatablePageControl: CHIBasePageControl {
    public struct Images {
        let valid: UIImage
        let invalid: UIImage
        
        public init(valid: UIImage, invalid: UIImage) {
            self.valid = valid
            self.invalid = invalid
        }
    }

    @IBInspectable open var elementWidth: CGFloat = 13 {
        didSet {
            setNeedsLayout()
        }
    }

    @IBInspectable open var elementHeight: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var validPageIndexes = [Int]()

    fileprivate var inactive = [UIImageView]()
    fileprivate var active = UIImageView()
    
    private let images: Images
    
    public init(images: Images) {
        self.images = images
        
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateNumberOfPages(_ count: Int) {
        inactive.forEach { $0.removeFromSuperview() }
        inactive = (0..<count).map {_ in
            let imageView = UIImageView(frame: frame)
            imageView.contentMode = .scaleAspectFit
            addSubview(imageView)
            return imageView
        }

        active.contentMode = .scaleAspectFit
        addSubview(active)

        setNeedsLayout()
        self.invalidateIntrinsicContentSize()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let floatCount = CGFloat(inactive.count)
        let x = (self.bounds.size.width - self.elementWidth*floatCount - self.padding*(floatCount-1))*0.5
        let y = (self.bounds.size.height - self.elementHeight)*0.5
        var frame = CGRect(x: x, y: y, width: self.elementWidth, height: self.elementHeight)

        active.tintColor = self.currentPageTintColor ?? self.tintColor
        active.frame = frame

        inactive.enumerated().forEach() { index, imageView in
            imageView.frame = frame
            frame.origin.x += self.elementWidth + self.padding
        }
        update(for: progress)
    }

    override func update(for progress: Double) {
        guard let min = inactive.first?.frame,
              let max = inactive.last?.frame,
              progress >= 0 && progress <= Double(numberOfPages - 1),
              numberOfPages > 1 else {
                return
        }

        let total = Double(numberOfPages - 1)
        let dist = max.origin.x - min.origin.x
        let percent = CGFloat(progress / total)

        let offset = dist * percent
        active.frame.origin.x = min.origin.x + offset
        updateActiveImage()
    }

    override open var intrinsicContentSize: CGSize {
        return sizeThatFits(CGSize.zero)
    }

    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: CGFloat(inactive.count) * self.elementWidth + CGFloat(inactive.count - 1) * self.padding,
                      height: self.elementHeight)
    }
}

public extension CHIValidatablePageControl {
    func updateValidPages(validPageIndexes: [Int]) {
        self.validPageIndexes = validPageIndexes
        inactive.enumerated().forEach { index, imageView in
            let inactiveImage = validPageIndexes.contains(index) ? images.valid : images.invalid
            imageView.image = inactiveImage
        }
        updateActiveImage()
    }
}

private extension CHIValidatablePageControl {
    func updateActiveImage() {
        let activeImage = validPageIndexes.contains(currentPage) ? images.valid : images.invalid
        active.image = activeImage.withRenderingMode(.alwaysTemplate)
    }
}

