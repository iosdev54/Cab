//
//  AccountTypeSegmentedControl.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 16.02.2023.
//

import UIKit

class AccountTypeSegmentedControl: UISegmentedControl {

    //MARK: - Properties
    private lazy var radius: CGFloat = 5
    
        private var segmentInset: CGFloat = 0.1 {
            didSet{
                if segmentInset == 0 {
                    segmentInset = 0.1
                }
            }
        }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .clear
        
        layer.cornerRadius = radius
        layer.masksToBounds = true

        let selectedImageViewIndex = numberOfSegments
        if let selectedImageView = subviews[selectedImageViewIndex] as? UIImageView {
            selectedImageView.backgroundColor = UIColor(white: 0.8, alpha: 1)
            selectedImageView.image = nil

            selectedImageView.bounds = selectedImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)

            selectedImageView.layer.cornerRadius = radius
            selectedImageView.layer.masksToBounds = true
            
            selectedImageView.layer.removeAnimation(forKey: "SelectionBounds")
        }
        for i in 0 ..< (self.numberOfSegments)  {
            let backgroundSegmentView = self.subviews[i]
            backgroundSegmentView.isHidden = true
        }
    }

   //MARK: - Lifecycle

    override init(items: [Any]?) {
        super.init(items: items)
        
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    //MARK: - Helper Functions
    func configure() {
        selectedSegmentIndex = 0
        setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 16),
                                                 .foregroundColor: UIColor.lightGray], for: .normal)
        setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 16),
                                                 .foregroundColor: UIColor.black], for: .selected)
        layer.borderWidth = 0.75
        layer.borderColor = UIColor.borderColor

        anchor(height: 40)
    }

}
