//
//  ShapeDataSource.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2021/1/24.
//

import UIKit

protocol ShapeDataSourceDelegate: class {
    func cellPress(style: DrawBoardStyle)
}

class ShapeDataSource: NSObject, UICollectionViewDataSource {
    
    private lazy var identifer: String = "shapeCellIdentifier"
    
    var styles: [DrawBoardStyle]
  
    weak var delegate: ShapeDataSourceDelegate?
    
    init(styles: [DrawBoardStyle]) {
        self.styles = styles
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return styles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifer, for: indexPath) as! SetDBShapeCollectionViewCell
        let style = self.styles[indexPath.row]
        cell.press =  {
            [weak self] in
            guard let self = self else { return }
            self.delegate?.cellPress(style: style)
        }
        
        cell.setImg(img: UIImage(systemName: style.rawValue))
        
        
        return cell
    }
    

}
