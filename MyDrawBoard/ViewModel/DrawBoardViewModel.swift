//
//  DrawBoardViewModel.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2021/1/24.
//

import Foundation
import UIKit




class DrawBoardViewModel {
    
    private lazy var drawBoard: DrawBoard = DrawBoard()
    
    private lazy var dbShapeDataSource: ShapeDataSource = {
        let dataSource = ShapeDataSource(styles: [.fullScreen, .circle, .rectangleWidget, .squareWidget])
        dataSource.delegate = self
        return dataSource
    }()
    
    var getDrawBoard: DrawBoard {
        return drawBoard
    }
    
    var getShapeDataSource: UICollectionViewDataSource {
        return dbShapeDataSource
    }
    
    
    final func setDBShape(style: DrawBoardStyle)-> Void {
        return self.drawBoard.setDrawBoardShape(style: style)
    }
    
    
    
    
    
    
    
}


// MARK: ShapeDataSourceDelegate
extension DrawBoardViewModel: ShapeDataSourceDelegate {
    
    /// 更改畫布樣式
    internal func cellPress(style: DrawBoardStyle) {
        drawBoard.setDrawBoardShape(style: style)
    }
    
    
}
