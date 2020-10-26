//
//  CAShapeLayerNode.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2020/10/26.
//

import Foundation
import UIKit


class LayerNode {
    var nodeClose: Bool = false
    var pre: LayerNode?
    var next: LayerNode?
    
    var layerIde: String
    
    init(pre node: LayerNode? , layerIde: String) {
        if node != nil { self.pre = node }
        self.layerIde = layerIde
    }
    
    deinit { self.removeAllNode() }
    
    
    
    func addNode(ide: String){
        guard let next = self.next else{
            let node = LayerNode(pre: self, layerIde: ide)
            self.next = node
            return
        }
        next.addNode(ide: ide)
    }
    
    
    
    func getLayerIdentifer() -> [String]{
        let res: [String] = [self.layerIde]
        guard let next = self.next else{
            return res }
      
        return res + next.getLayerIdentifer()
    }
    
    
    func removeAllNode(){
        guard let next = self.next else{
            self.pre = nil
            return }
        self.pre = nil
        next.removeAllNode()
    }
}
