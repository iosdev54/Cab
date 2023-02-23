//
//  LocationCell.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 24.01.2023.
//

import UIKit
import MapKit

class LocationCell: UITableViewCell {
    
    //MARK: - Properties
    var placemark: MKPlacemark? {
        didSet {
            titleLabel.text = placemark?.name
            addressLabel.text = placemark?.address
        }
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    //MARK: - Lifececle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helper Functions
    func setupCell() {
        selectedBackgroundView = UIView().selectedBackgroundView
        backgroundColor = .clear
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fillEqually
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: layoutMarginsGuide.leftAnchor, rightAnchor: rightAnchor, paddingRight: 16)
    }
    
}
