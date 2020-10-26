//
//  DrawBoard.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2020/10/26.
//

import UIKit

class DrawBoard: UIControl {
    public var color: UIColor = .systemGray6
    public var lineWidth: CGFloat = 2
    
    private var eraserColor : UIColor {
        get {
            return self.backgroundColor ?? .black
        }
    }
    
    
    private var shapelayers: [String :CAShapeLayer] = [:] //shapeLayer 總池
    private var startPoint: CGPoint = .zero //繪圖開始起點
    
    private var isBacktrack: Bool = false  //是否有回復過
    private var layerNodes : [LayerNode] = [] //layer ide 池
    private var backtrackPool: [LayerNode] = [] //ide 池副本
    private var removePool: [LayerNode] = [] //最近移除layer 池
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.startPoint = (touches.first?.location(in: self))!
        let path = UIBezierPath(ovalIn: CGRect(x: self.startPoint.x - self.lineWidth / 4 , y: self.startPoint.y -  self.lineWidth / 4, width:  self.lineWidth / 2, height:  self.lineWidth / 2))
        self.drawDot(path: path, color: self.color)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else{ return }
        let path = UIBezierPath()
        path.move(to: self.startPoint)
        path.addLine(to: point)
        
        self.startPoint = point
        self.drawStroke(path: path ,color: self.color)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = self.layerNodes.last else {  return }
        node.addNode(ide: "close")
        node.nodeClose = true
    }
    
    
    private func observedBacktrack(_ bool:Bool) {
        if isBacktrack && !bool {
            self.layerNodes = self.backtrackPool
            self.backtrackPool = []
            self.removePool = []
            self.isBacktrack = false
            self.removeFromShapelayers()
        }
        if bool && !isBacktrack{
            self.backtrackPool = self.layerNodes
            self.isBacktrack = true
        }
    }
    
    private func removeFromShapelayers(){
        self.removePool.forEach{
            let ideS = $0.getLayerIdentifer()
            for ide in ideS {
                if self.shapelayers[ide] != nil {
                    self.shapelayers.removeValue(forKey: ide)
                }
            }
        }
        self.removePool = []
    }
    
    private func drawStroke(path: UIBezierPath ,color: UIColor){
        observedBacktrack(false)
        
        let shapelayer = CAShapeLayer()
        let identifer = ObjectIdentifier(shapelayer).debugDescription
        shapelayer.path = path.cgPath
        shapelayer.strokeColor = color.cgColor
        shapelayer.lineWidth = self.lineWidth
        shapelayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(shapelayer)
        let path = UIBezierPath(ovalIn: CGRect(x: self.startPoint.x - self.lineWidth / 4 , y: self.startPoint.y - self.lineWidth / 4, width: self.lineWidth / 2 , height: self.lineWidth / 2))
        self.drawDot(path: path, color: self.color)
        self.setNeedsDisplay()
        
        self.shapelayers[identifer] = shapelayer
        self.addLayerNodes(ide: identifer)
    }
    
    private func drawDot(path: UIBezierPath , color: UIColor){
        self.observedBacktrack(false)
        
        let shapelayer = CAShapeLayer()
        let identifer = ObjectIdentifier(shapelayer).debugDescription
        shapelayer.path = path.cgPath
        shapelayer.strokeColor = color.cgColor
        shapelayer.lineWidth = self.lineWidth / 2
        shapelayer.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shapelayer)
        self.setNeedsDisplay()
        
        self.shapelayers[identifer] = shapelayer
        self.addLayerNodes(ide: identifer)
    }
    
    private func addLayerNodes(ide: String){
        guard let lastNode = self.layerNodes.last else{
            let node = LayerNode(pre: nil, layerIde: ide)
            self.layerNodes.append(node)
            return
        }
        guard !lastNode.nodeClose else{
            let node = LayerNode(pre: nil, layerIde: ide)
            self.layerNodes.append(node)
            return
        }
        
        lastNode.addNode(ide: ide)
    }
    
    
    public func backToPreStep(){
        self.backtrackAction()
    }
    
    public func backToNextStep(){
        self.forwardNext()
    }
    
    private func backtrackAction(){
        self.observedBacktrack(true)
        guard let lastNode = self.layerNodes.last else {
            return }
        let ideS = lastNode.getLayerIdentifer()
        DispatchQueue.main.async {
            ideS.forEach{
                if let shapelayer = self.shapelayers[$0]{
                    shapelayer.removeFromSuperlayer()
                }
            }
            self.setNeedsDisplay()
        }
        
        self.removePool.append(lastNode)
        self.layerNodes.removeLast()
    }
    
    private func forwardNext(){
        guard let lastNode = self.removePool.last else { return }
        let ideS = lastNode.getLayerIdentifer()
        DispatchQueue.main.async {
            ideS.forEach{
                if let shapelayer = self.shapelayers[$0]{
                    self.layer.addSublayer(shapelayer)
                }
            }
            self.setNeedsDisplay()
        }
        self.layerNodes.append(lastNode)
        self.removePool.removeLast()
    }
    
}



extension DrawBoard {
    
    public func clearAll(){
        
        self.shapelayers.removeAll()
        self.layerNodes.removeAll()
        self.removePool.removeAll()
        self.backtrackPool.removeAll()
        self.isBacktrack = false
        
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
}
