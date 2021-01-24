//
//  BrashViewModel.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2021/1/24.
//

import Foundation
import UIKit


protocol BrushViewModelDelegate: class {
    func changeColor(_ color: UIColor)
}


class BrushViewModel {
    
    weak var delegate: BrushViewModelDelegate?
    
    private lazy var brushDataSource: ColorChangeDataSource = {
        let dataSource = ColorChangeDataSource()
        dataSource.delegate = self
       return dataSource
    }()
    
    func getDataSource()-> ColorChangeDataSource {
        return brushDataSource
    }
    
}


// MARK: ColorChangeDelegate
extension BrushViewModel: ColorChangeDelegate {
    func changeColor(_ color: UIColor) {
        self.delegate?.changeColor(color)
    }
}
