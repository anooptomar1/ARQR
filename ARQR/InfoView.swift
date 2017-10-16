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
    var closeButton: UIButton!
    var imageView: UIImageView!
    var infoLabels: [UILabel]!
    var stackView: UIStackView!
    var descriptionView: UITextView!
    
    var information: VirtualObjectNodeInformation

    init(information: VirtualObjectNodeInformation) {
        
        self.information = information
        super.init(effect: nil)
        
        setupSubview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubview() {
        
        titleLabel = UILabel()
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.text = information.name
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        closeButton = UIButton()
        closeButton.setImage(#imageLiteral(resourceName: "x"), for: .normal)
        closeButton.addTarget(self, action: #selector(self.closeButtonPressed), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(closeButton)
        
        imageView = UIImageView(image: #imageLiteral(resourceName: "earth"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        
        
        infoLabels = [UILabel]()
        
        for key in information.information.keys {
            
            let label = UILabel()
            label.textColor = UIColor.white
            label.text = "\(key): \(information.information[key]!)"
            label.translatesAutoresizingMaskIntoConstraints = false
            infoLabels.append(label)
        }
        
        stackView = UIStackView(arrangedSubviews: infoLabels)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(stackView)
        
        descriptionView = UITextView()
        descriptionView.textColor = UIColor.white
        descriptionView.backgroundColor = UIColor.clear
        descriptionView.isEditable = false
        descriptionView.font = UIFont.systemFont(ofSize: 16)
        descriptionView.text = "Earth is the third planet from the Sun and the only object in the Universe known to harbor life. According to radiometric dating and other sources of evidence, Earth formed over 4 billion years ago. Earth's gravity interacts with other objects in space, especially the Sun and the Moon, Earth's only natural satellite. Earth revolves around the Sun in 365.26 days, a period known as an Earth year. During this time, Earth rotates about its axis about 366.26 times."
        descriptionView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionView)
        
        let textWidthConstraint = descriptionView.widthAnchor.constraint(equalToConstant: 500)
        textWidthConstraint.priority = .defaultLow
        let textMaxWidthConstraint = descriptionView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.9)
        
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            closeButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20),
            closeButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            closeButton.widthAnchor.constraint(equalToConstant: 20),
            
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 300),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            descriptionView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
            descriptionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            descriptionView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            textWidthConstraint,
            textMaxWidthConstraint,
            
//            stackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 15),
//            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
//            stackView.widthAnchor.constraint(equalToConstant: 300),
//            stackView.heightAnchor.constraint(equalToConstant: CGFloat(infoLabels.count * 30))
            
            ])
    }
    
    @objc
    func closeButtonPressed(sender: UIButton){
        
        UIView.animate(withDuration: 0.3, animations: {
            self.effect = nil
            self.alpha = 0
            }, completion: { _ in
                self.removeFromSuperview()
                })
        
        
    }
    
}
