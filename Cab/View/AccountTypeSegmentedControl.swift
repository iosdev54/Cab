//
//  AccountTypeSegmentedControl.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 16.02.2023.
//

import UIKit

class AccountTypeSegmentedControl: UISegmentedControl {
    
    //MARK: - Properties
    private var radius: CGFloat = 5
    
    private var segmentInset: CGFloat = 0.1 {
        didSet{
            if segmentInset == 0 {
                segmentInset = 0.1
            }
        }
    }
    
    //MARK: - Lifecycle
    override init(items: [Any]?) {
        super.init(items: items)
        
        configureSegmentedControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundColor = .clear
        
        layer.cornerRadius = radius
        layer.masksToBounds = true
        
        let selectedImageViewIndex = numberOfSegments
        if let selectedImageView = subviews[selectedImageViewIndex] as? UIImageView {
            selectedImageView.backgroundColor = UIColor.mainWhiteTint
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
    
    //MARK: - Helper Functions
    private func configureSegmentedControl() {
        selectedSegmentIndex = 0
        setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 16),
                                .foregroundColor: UIColor.mainWhiteTint], for: .normal)
        setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 16),
                                .foregroundColor: UIColor.black], for: .selected)
        layer.borderWidth = 0.75
        layer.borderColor = UIColor.borderTint
        anchor(height: 40)
    }
    
}
