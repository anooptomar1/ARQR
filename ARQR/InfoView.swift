//
//  InfoView.swift
//  ARQR
//
//  Created by Walter Nordström on 2017-10-12.
//  Copyright © 2017 Walter Nordström. All rights reserved.
//

import UIKit

class InfoView: UIVisualEffectView {

    var titleLabel: UILabel!
    var imageView: UIImageView!
    var infoLabels: [UILabel]!
    var stackView: UIStackView!
    
    var information: VirtualObjectNodeInformation

    init(information: VirtualObjectNodeInformation) {
        
        self.information = information
        super.init(effect: UIBlurEffect(style: .dark))
        
        setupSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubview() {
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18.0)
        titleLabel.text = information.Name
        addSubview(titleLabel)
        
        let stackView = UIStackView(arrangedSubviews: <#T##[UIView]#>)
        
        
    }
    
}
