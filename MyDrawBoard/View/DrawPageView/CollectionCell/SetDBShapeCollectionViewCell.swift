//
//  SetDBShapeCollectionViewCell.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2021/1/24.
//

import UIKit

class SetDBShapeCollectionViewCell: UICollectionViewCell {
    
    private let cellRadius: CGFloat = 22.5
    
    private lazy var imgBackView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 22.5
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.shadowColor = UIColor.systemGray3.cgColor
        view.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        view.layer.shadowOpacity = 1
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 22.5
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var press: (()->())?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setUI() {
        imgBackView.addSubview(imageView)
        imageView.fillSuperview()
        
        contentView.addSubview(imgBackView)
        imgBackView.fillSuperview()
        
        imgBackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(setPress)))
    }
    
    func setImg(img: UIImage?) {
        self.imageView.image = img
    }
    
    @objc func setPress() {
        press?()
    }
    
}
