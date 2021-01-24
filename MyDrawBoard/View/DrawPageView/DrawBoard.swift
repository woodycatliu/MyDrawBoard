//
//  DrawBoard.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2020/10/26.
//

import UIKit

class DrawBoard: UIControl {
    public var color: UIColor = .systemGray6
    public var lineWidth: CGFloat = 10
    
    public var eraserColor : UIColor {
        get {
            return self.backgroundColor ?? .black
        }
    }
    
    public var backgriundImage: UIImage?
    
    public var style: DrawBoardStyle = .squareWidget {
        willSet {
            DispatchQueue.main.async {
                self.changeContraints(style: newValue)
            }
        }
    }
    
    var isEraser:Bool = false {
        willSet {
            if newValue != isEraser && newValue {
            }
        }
    }
    var int = 0
    private var isOutOfBounds: Bool = false
    private var isContinuous: Bool = false
    
    private let screenBounds: CGRect = UIScreen.main.bounds
    private var heightContraint: NSLayoutConstraint!
    private var widthContraint: NSLayoutConstraint!
    
    private var shapelayers: [String :CAShapeLayer] = [:] //shapeLayer 總池
    private var startPoint: CGPoint = .zero //繪圖開始起點
    private var isContinued: Bool = false
    
    private var isBacktrack: Bool = false  //是否有回復過
    private var pointPool: [CGPoint] = [] //point 池
    private var layerNodes : [LayerNode] = [] //layer ide 池
    private var backtrackPool: [LayerNode] = [] //ide 池副本
    private var removePool: [LayerNode] = [] //最近移除layer 池
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthContraint = self.widthAnchor.constraint(equalToConstant: self.screenBounds.width * 0.95)
        self.heightContraint = self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1)
        self.widthContraint.isActive = true
        self.heightContraint.isActive = true
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.systemGray4.cgColor
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: touch方法
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        self.startPoint = touch.location(in: self)
        let path = UIBezierPath(ovalIn: CGRect(x: self.startPoint.x - self.lineWidth / 4 , y: self.startPoint.y -  self.lineWidth / 4, width:  self.lineWidth / 2, height:  self.lineWidth / 2))
        self.drawDot(path: path, color: self.color)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard !isOutOfBounds else{ return }
        guard let touch = touches.first else { return }
        guard let touches = event?.coalescedTouches(for: touch) else{ return }
        drawBetter(touches: touches)
    }
    
    private func drawBetter(touches: [UITouch]){
        for touch in touches {
            let point = touch.location(in: self)

            self.pointPool.append(point)
            if self.pointPool.count == 4 {
                self.drawCurve()
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let node = self.layerNodes.last else {  return }
        node.addNode(ide: "close")
        node.nodeClose = true
        self.isOutOfBounds = false
        self.isContinued = false
        self.pointPool = []
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
    // 0 1 2 3 4
    private func drawCurve(){
        let x1 = pointPool[1].x
        let y1 = pointPool[1].y
        
        let x2 = pointPool[3].x
        let y2 = pointPool[3].y
        pointPool[2] = CGPoint(x: (x1 + x2) / 2, y: (y1 + y2) / 2)
        
        
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addCurve(to: pointPool[2], controlPoint1: pointPool[0], controlPoint2: pointPool[1])
        
        let dotPath = UIBezierPath(ovalIn: CGRect(x: pointPool[2].x - self.lineWidth / 4 , y: pointPool[2].y - self.lineWidth / 4, width: self.lineWidth / 2 , height: self.lineWidth / 2))
        
        
        let point1 = pointPool[2]
        let point2 = pointPool[3]
        pointPool.removeAll()
        startPoint = point1
        pointPool.append(point2)
        observedBacktrack(false)
        
        let shapelayer = CAShapeLayer()
        let identifer = ObjectIdentifier(shapelayer).debugDescription
        shapelayer.path = path.cgPath
        shapelayer.strokeColor = color.cgColor
        shapelayer.lineWidth = self.lineWidth
        shapelayer.fillColor = UIColor.clear.cgColor
        
        self.layer.addSublayer(shapelayer)
        self.drawDot(path: dotPath, color: color)
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
    
    
    public func previousStep(){
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
    
    
    /// 修正touch point 避免超過畫布
    /// 先暫定移除，使用layer.maskToClip 可解決匯出畫布
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
        }else{
            self.isOutOfBounds = false
        }
        return point
    }
    
    
    private func changeContraints(style: DrawBoardStyle){
        let array: [NSLayoutConstraint] = [self.heightContraint,self.widthContraint]
        array.forEach{ $0.isActive = false }
        
        switch style {
        case .circle:
            self.forSquareWidget()
            self.layer.cornerRadius = self.frame.width / 2
            
        case .fullScreen:
            self.forFullScreen()
        case .rectangleWidget:
            self.forRW()
        case .squareWidget:
            self.forSquareWidget()
        }
    }
    private func forRW(){
        self.heightContraint.isActive = false
        self.widthContraint.isActive = false
        self.heightContraint = self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5)
        self.widthContraint = self.widthAnchor.constraint(equalToConstant: self.screenBounds.width * 0.95)
        self.heightContraint.isActive = true
        self.widthContraint.isActive = true
        
        self.layer.cornerRadius = self.frame.height == 0 ? self.screenBounds.width * 0.5 * 0.95 / 6 : self.screenBounds.width * 0.5 * 0.95 / 6
    }
    
    private func forSquareWidget(){
        self.heightContraint.isActive = false
        self.widthContraint.isActive = false
        self.heightContraint = self.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1)
        self.widthContraint = self.widthAnchor.constraint(equalToConstant: self.screenBounds.width * 0.95)
        self.heightContraint.isActive = true
        self.widthContraint.isActive = true
        
        self.layer.cornerRadius = self.frame.width == 0 ? self.screenBounds.width * 0.95 / 6 : self.screenBounds.width * 0.95 / 6
    }
    
    private func forFullScreen() {
        guard let superView = self.superview else { return }
        self.heightContraint.isActive = false
        self.widthContraint.isActive = false
        
        self.heightContraint = self.heightAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.heightAnchor)
        self.widthContraint = self.widthAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.widthAnchor)
        self.layer.cornerRadius = 0
        self.heightContraint.isActive = true
        self.widthContraint.isActive = true
    }
    
    
    
    final func setDrawBoardShape(style: DrawBoardStyle) {
        switch style {
        case .circle:
            self.forSquareWidget()
            self.layer.cornerRadius = self.frame.width / 2
            
        case .fullScreen:
            self.forFullScreen()
        case .rectangleWidget:
            self.forRW()
        case .squareWidget:
            self.forSquareWidget()
        }
    }
}



//MARK: 橡皮擦
extension DrawBoard {
    
    private func setBackgroudColor(){
        guard let image = self.backgriundImage, let cgimage = image.cgImage else{
            self.color = self.eraserColor
            return
        }
        UIGraphicsBeginImageContext(self.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else{ return }
        context.draw(cgimage, in: self.bounds)
        guard let imageComplete = UIGraphicsGetImageFromCurrentImageContext() else{
            return
        }
        self.backgroundColor = UIColor(patternImage: imageComplete)
        self.color = self.eraserColor
        UIGraphicsEndImageContext()
    }
    
}
