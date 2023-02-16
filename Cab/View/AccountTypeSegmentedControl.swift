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
        
        backgroundColor = .backgroundColor
        
        layer.cornerRadius = radius
        layer.masksToBounds = true

        let selectedImageViewIndex = numberOfSegments
        if let selectedImageView = subviews[selectedImageViewIndex] as? UIImageView {
            selectedImageView.backgroundColor = UIColor(white: 0.8, alpha: 1)
            selectedImageView.image = nil

            selectedImageView.bounds = selectedImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)

            selectedImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            selectedImageView.layer.cornerRadius = radius
            selectedImageView.layer.masksToBounds = true
            
            selectedImageView.layer.removeAnimation(forKey: "SelectionBounds")
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



//import UIKit
//
//class CustomizableSegmentControl: UISegmentedControl {
//
//    private(set) lazy var radius:CGFloat = bounds.height / 2
//
//    /// Configure selected segment inset, can't be zero or size will error when click segment
//    private var segmentInset: CGFloat = 0.1{
//        didSet{
//            if segmentInset == 0{
//                segmentInset = 0.1
//            }
//        }
//    }
//
//    override init(items: [Any]?) {
//        super.init(items: items)
//        selectedSegmentIndex = 0
//    }
//
//    required init?(coder: NSCoder) {
////        fatalError("init(coder:) has not been implemented")
//        super.init(coder: coder)
//    }
//
//
//    override func layoutSubviews(){
//        super.layoutSubviews()
//        self.backgroundColor = .orange
//
//        //MARK: - Configure Background Radius
//        self.layer.cornerRadius = self.radius
//        self.layer.masksToBounds = true
//
//        //MARK: - Find selectedImageView
//        let selectedImageViewIndex = numberOfSegments
//        if let selectedImageView = subviews[selectedImageViewIndex] as? UIImageView
//        {
//            //MARK: - Configure selectedImageView Color
//            selectedImageView.backgroundColor = .green
//            selectedImageView.image = nil
//
//            //MARK: - Configure selectedImageView Inset with SegmentControl
//            selectedImageView.bounds = selectedImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
//
//            //MARK: - Configure selectedImageView cornerRadius
//            selectedImageView.layer.masksToBounds = true
//            selectedImageView.layer.cornerRadius = self.radius
//
//            selectedImageView.layer.removeAnimation(forKey: "SelectionBounds")
//
//        }
//
//    }
//
//}
