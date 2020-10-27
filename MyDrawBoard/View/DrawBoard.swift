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
    
    public var eraserColor : UIColor {
        get {
            return self.backgroundColor ?? .black
        }
    }
    
    
    
    public var style: BoardFrame = .squareWidget {
        willSet {
            DispatchQueue.main.async {
                self.changeContraints(style: newValue)
            }
        }
    }
    
    private var isOutOfBounds: Bool = false
    
    private let screenBounds: CGRect = UIScreen.main.bounds
    private var heightContraint: NSLayoutConstraint!
    private var widthContraint: NSLayoutConstraint!
    
    private var shapelayers: [String :CAShapeLayer] = [:] //shapeLayer 總池
    private var startPoint: CGPoint = .zero //繪圖開始起點
    
    private var isBacktrack: Bool = false  //是否有回復過
    private var layerNodes : [LayerNode] = [] //layer ide 池
    private var backtrackPool: [LayerNode] = [] //ide 池副本
    private var removePool: [LayerNode] = [] //最近移除layer 池
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthContraint = self.widthAnchor.constraint(equalToConstant: self.screenBounds.width * 0.95)
        self.heightContraint = self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1)
        print(self.frame.maxY)
        print(self.frame.minY)
        self.widthContraint.isActive = true
        self.heightContraint.isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.startPoint = (touches.first?.location(in: self))!
        let path = UIBezierPath(ovalIn: CGRect(x: self.startPoint.x - self.lineWidth / 4 , y: self.startPoint.y -  self.lineWidth / 4, width:  self.lineWidth / 2, height:  self.lineWidth / 2))
        self.drawDot(path: path, color: self.color)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isOutOfBounds else{ return }
        guard var point = touches.first?.location(in: self) else{ return }
        point = self.fixPoint(point: point)
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
        self.isOutOfBounds = false
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
        self.removeLayerNode()
        //        self.layerNodes.removeAll()
        //        self.removePool.removeAll()
        //        self.backtrackPool.removeAll()
        self.isBacktrack = false
        
        self.layer.sublayers = nil
        self.setNeedsDisplay()
    }
    
    private func removeLayerNode(){
        self.layerNodes.forEach{
            $0.removeAllNode()
        }
        self.layerNodes.removeAll()
        
        self.backtrackPool.forEach{
            $0.removeAllNode()
        }
        self.backtrackPool.removeAll()
        
        self.removePool.forEach{
            $0.removeAllNode()
        }
        self.removePool.removeAll()
    }
}


extension DrawBoard {
    //修正touch point 避免超過畫布
    private func fixPoint(point: CGPoint) -> CGPoint {
        guard self.style != .circle else{ return self.fixPointAtCircle(point: point)}
        var point = point
        
        if point.x > self.bounds.maxX - lineWidth / 2{
            point.x = self.bounds.maxX - lineWidth / 2
            self.isOutOfBounds = true
        }else if point.x < self.bounds.minX + lineWidth / 2{
            point.x = self.bounds.minX + lineWidth / 2
            self.isOutOfBounds = true
        }
        
        if point.y > self.bounds.maxY - lineWidth / 2{
            point.y = self.bounds.maxY - lineWidth / 2
            self.isOutOfBounds = true
        }else if point.y < self.bounds.minY + lineWidth / 2{
            point.y = self.bounds.minY + lineWidth / 2
            self.isOutOfBounds = true
        }
        return point
    }
    
    private func fixPointAtCircle(point: CGPoint) -> CGPoint{
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
        
        var point = point

        let r: Float = hypotf(Float(point.x - center.x), Float(point.y - center.y))
        let oR: Float = Float(self.bounds.width / 2 - lineWidth / 2)
        
        if r > oR {
            point.x = CGFloat(Float(point.x - center.x) * oR / r) + center.x
            point.y =  CGFloat(Float(point.y - center.y) * oR / r) + center.y
            self.isOutOfBounds = true
        }
        return point
    }
    
    
    private func changeContraints(style: BoardFrame){
        let array: [NSLayoutConstraint] = [self.heightContraint,self.widthContraint]
        array.forEach{ $0.isActive = false }
        
        switch style {
        case .circle:
            self.forSquareWidget()
            self.layer.cornerRadius = self.frame.width / 2
            
        case .fullScreen: break
            
        case .rectangleWidget:
            self.forRW()
        case .squareWidget:
            self.forSquareWidget()
        }
    }
    private func forRW(){
        self.heightContraint = self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5)
        self.widthContraint = self.widthAnchor.constraint(equalToConstant: self.screenBounds.width * 0.95)
        self.heightContraint.isActive = true
        self.widthContraint.isActive = true
    }
    
    private func forSquareWidget(){
        self.heightContraint = self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1)
        self.widthContraint = self.widthAnchor.constraint(equalToConstant: self.screenBounds.width * 0.95)
        self.heightContraint.isActive = true
        self.widthContraint.isActive = true
    }
    
    
    enum BoardFrame {
        case circle
        case squareWidget
        case rectangleWidget
        case fullScreen
    }
}
