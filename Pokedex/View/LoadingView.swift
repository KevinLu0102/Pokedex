//
//  LoadingView.swift
//  Pokedex
//
//  Created by Kevin Lu on 2024/6/3.
//

import Foundation
import UIKit

class LoadingView: UIView {
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .white
        activityIndicator.color = .gray
        activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
        addSubview(activityIndicator)
        activityIndicator.isHidden = false
    }
    
    func startLoading() {
        activityIndicator.startAnimating()
        self.isHidden = false
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()
        self.isHidden = true
    }
}
