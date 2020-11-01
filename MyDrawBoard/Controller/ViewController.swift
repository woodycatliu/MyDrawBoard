//
//  ViewController.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2020/10/26.
//

import UIKit

class ViewController: UIViewController {
    var bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? .zero
    
    let board : DrawBoard = {
        let board = DrawBoard()
        board.style = .squareWidget
        board.backgroundColor = .black
        return board
    }()
    
    let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    let brushInput : MyCustomInputContainer = MyCustomInputContainer()
    let shapeInput : MyCustomInputContainer = MyCustomInputContainer()
    
    let brushInputView: BrushInputView = {
        let brush = BrushInputView()
        brush.backgroundColor = .white
        return brush
    }()
    
    let brushButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.setBackgroundImage(UIImage(systemName: "pencil.tip.crop.circle"), for: .normal)
        button.setImage(UIImage(systemName: "pencil.tip.crop.circle"),for: .highlighted)
        button.tintColor = .darkGray
        return button
    }()
    let shapeButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "square"),for: .highlighted)
        button.tintColor = .darkGray
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureItems()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    
    private func configureItems(){
        self.configureToolBar()
        self.setupButtonMethod()
        self.configureInputView()
        self.configureDrawBoard()
    }
    
    private func configureToolBar(){
        self.navigationController?.isToolbarHidden = false
        let brush : UIBarButtonItem = UIBarButtonItem(customView: brushButton)
        let shape : UIBarButtonItem = UIBarButtonItem(customView: shapeButton)
        
        let array = [space,brush,space,shape,space]
        self.toolbarItems = array
        
    }
    
    private func setupButtonMethod(){
        self.brushButton.addTarget(self, action: #selector(brushInput(_:)), for: .touchUpInside)
        self.shapeButton.addTarget(self, action: #selector(shapeInput(_:)), for: .touchUpInside)
    }
    
    
    
    //MARK: 安裝input View
    private func configureInputView(){
        self.view.addSubview(self.brushInput)
        self.view.addSubview(self.shapeInput)
        self.brushInput.target = self
        self.shapeInput.target = self
        
        if let window = UIApplication.shared.windows.first {
            bottomInset = window.safeAreaInsets.bottom
        }
        
        self.brushInputView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: bottomInset + 50 +  self.view.frame.width * 0.1 + 10 )
        self.brushInput.inputView = self.brushInputView
        self.brushInputView.reply = self
    }
    
    @objc func brushInput(_ sender: UIButton){
        (self.brushInput.inputView as? BrushInputView)?.value = Float(self.board.lineWidth)
        self.brushInput.becomeFirstResponder()
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    @objc func shapeInput(_ sender: UIButton){
        self.shapeInput.becomeFirstResponder()
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
}


//MARK: 安裝DrawBoard

extension ViewController {
    
    private func configureDrawBoard(){
        self.view.addSubview(self.board)
        self.board.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.board.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    
}



extension ViewController : BrushViewControllerToDrawBoard {
    func replyBrush(color: UIColor, lineWine: CGFloat) {
        self.board.color = color
        self.board.lineWidth = lineWine
    }
}
