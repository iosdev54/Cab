//
//  UIViewController+Extension.swift
//  Cab
//
//  Created by Dmytro Grytsenko on 18.02.2023.
//

import UIKit

extension UIViewController {
    
    func presentAlertController(withTitle title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func shouldPresentLoadingView(_ present: Bool, message: String? = nil) {
        if present {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .black
            loadingView.alpha = 0
            loadingView.tag = 1
            
            let indicator = UIActivityIndicatorView()
            indicator.style = .large
            indicator.color = .white
            indicator.center = loadingView.center
            
            let label = UILabel()
            label.text = message
            label.textColor = UIColor(white: 1, alpha: 0.87)
            label.font = UIFont.systemFont(ofSize: 20)
            label.textAlignment = .center
            
            loadingView.addSubview(indicator)
            loadingView.addSubview(label)
            view.addSubview(loadingView)
            
            label.centerX(inView: loadingView)
            label.anchor(top: indicator.bottomAnchor, paddingTop: 32)
            
            indicator.startAnimating()
            
            UIView.animate(withDuration: 0.3) {
                loadingView.alpha = 0.7
            }
        } else {
            view.subviews.forEach { subview in
                if subview.tag == 1 {
                    UIView.animate(withDuration: 0.3) {
                        subview.alpha = 0
                    } completion: { _ in
                        subview.removeFromSuperview()
                    }
                }
            }
        }
    }
}
