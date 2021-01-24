//
//  ColorChangeCollectionViewDataSource.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2021/1/24.
//

import UIKit
protocol ColorChangeDelegate: class {
    func changeColor(_ color: UIColor)
}


class ColorChangeDataSource: NSObject, UICollectionViewDataSource {
    
    private(set) lazy var identifer: String = "colorChangeCellIdentifier"
    
    weak var delegate: ColorChangeDelegate?
    
    private lazy var colors: [UIColor] = {
        return [.red, .systemPink, .cyan, .yellow, .brown, .white, .green, .clear]
    }()
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifer, for: indexPath) as! BrushCollectionViewCell
        
        let color: UIColor = colors[indexPath.row]
        cell.colorView.backgroundColor = color
        if color == .clear {
            cell.imageView.image = UIImage(systemName: "pencil.slash")
            cell.colorView.layer.borderColor = UIColor.clear.cgColor
        } else {
            cell.imageView.image = nil
        }
        
        cell.colorView.layer.cornerRadius = cell.bounds.width / 2
        cell.imageView.layer.cornerRadius = cell.bounds.width / 2

        
        return cell
    }
    
}


extension ColorChangeDataSource: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BrushCollectionViewCell
        if let color = cell.colorView.backgroundColor {
        self.delegate?.changeColor(color)
        }
    }
    
}
