//
//  BrushCollectionViewCell.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2021/1/24.
//

import UIKit

class BrushCollectionViewCell: UICollectionViewCell {
    
    lazy var colorView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFit
        imgV.clipsToBounds = true
        imgV.image = nil
        return imgV
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    private func setUI() {
        contentView.addSubview(colorView)
        colorView.fillSuperview()
        colorView.addSubview(imageView)
        imageView.fillSuperview()
    }

    
    
    
}


