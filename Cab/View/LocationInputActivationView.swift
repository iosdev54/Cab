//
//  LocationInputActivationView.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 23.01.2023.
//

import UIKit

protocol LocationInputActivationViewDelegate: AnyObject {
    func presentLocationInputView()
}

class LocationInputActivationView: UIView {
    
    //MARK: - Properties
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainGreenTint
        return view
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Where to?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()
    
    weak var delegate: LocationInputActivationViewDelegate?
    
    //MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .mainWhiteTint
        makeCorner(cornerRadius: 5)
        applyShadow()
        
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorView.setDimensions(height: 8, width: 8)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 16)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        indicatorView.makeCorner(cornerRadius: indicatorView.frame.size.height / 2)
    }
    
    //MARK: - Selectors
    @objc private func presentLocationInputView() {
        delegate?.presentLocationInputView()
    }
    
}
