//
//  ViewController.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2020/10/26.
//

import UIKit

class ViewController: UIViewController {
    private var bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? .zero
    
    
    private lazy var viewModel: DrawBoardViewModel = {
        let drawBoardViewModel = DrawBoardViewModel()
        return drawBoardViewModel
    }()
    
    private lazy var board : DrawBoard = {
        let board = viewModel.getDrawBoard
        board.style = .fullScreen
        board.backgroundColor = .black
        return board
    }()
    
    private let space: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    private let brushInput : MyCustomInputContainer = MyCustomInputContainer()
    private let shapeInput : MyCustomInputContainer = MyCustomInputContainer()
    
    private let brushInputView: BrushInputView = {
        let brush = BrushInputView()
        brush.backgroundColor = .white
        return brush
    }()
    
   private let brushButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.setBackgroundImage(UIImage(systemName: "pencil.tip.crop.circle"), for: .normal)
        button.setImage(UIImage(systemName: "pencil.tip.crop.circle"),for: .highlighted)
        button.tintColor = .darkGray
        return button
    }()
    
    
    // 畫布大小 - 形狀
   private let shapeButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.setBackgroundImage(UIImage(systemName: "square"), for: .normal)
        button.setImage(UIImage(systemName: "square"),for: .highlighted)
        button.tintColor = .darkGray
        return button
    }()

    /// 更改畫布形狀
    private lazy var shapeInputCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 45, height: 45)
        layout.scrollDirection = .vertical
        layout.headerReferenceSize = .zero
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentInset = .init(top: 10, left: 14, bottom: 10, right: 10)
        cv.allowsSelection = false
        cv.dataSource = viewModel.getShapeDataSource
        cv.register(SetDBShapeCollectionViewCell.self, forCellWithReuseIdentifier: "shapeCellIdentifier")
        cv.backgroundColor = .white
        return cv
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
    }
    
    
    private func setUI(){
        self.setTooBar()
        self.setButtonTarget()
        self.setNavigationBar() 
        self.setInputView()
        self.setDrawBoard()
    }
    
    private func setNavigationBar() {
        let barButton = UIBarButtonItem(image: UIImage(systemName: "trash"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(cleanDrawBoard))
        
        self.navigationItem.rightBarButtonItem = barButton
        
        let previouButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.left"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(previousStep))
        let nextButton = UIBarButtonItem(image: UIImage(systemName: "arrowshape.turn.up.right"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(nextStep))
        self.navigationItem.leftBarButtonItems = [previouButton, nextButton]
        
    }
    
    
    
    private func setTooBar(){
        self.navigationController?.isToolbarHidden = false
        let brush : UIBarButtonItem = UIBarButtonItem(customView: brushButton)
        let shape : UIBarButtonItem = UIBarButtonItem(customView: shapeButton)
        
        let array = [space,brush,space,shape,space]
        self.toolbarItems = array
        
    }
    
    private func setButtonTarget(){
        self.brushButton.addTarget(self, action: #selector(brushInput(_:)), for: .touchUpInside)
        self.shapeButton.addTarget(self, action: #selector(shapeInput(_:)), for: .touchUpInside)
    }
    
    
    
    //MARK: 安裝input View
    private func setInputView(){
        self.view.addSubview(self.brushInput)
        self.view.addSubview(self.shapeInput)
        self.brushInput.target = self
        self.shapeInput.target = self
        
        if let window = UIApplication.shared.windows.first {
            bottomInset = window.safeAreaInsets.bottom
        }
        
        self.brushInputView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: bottomInset + 50 +  self.view.frame.width * 0.1 + 10 )
        self.brushInput.inputView = self.brushInputView
        self.brushInputView.delegate = self
        
        self.shapeInputCollectionView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: bottomInset + 70)
        self.shapeInput.inputView = self.shapeInputCollectionView
        
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
    
    @objc func cleanDrawBoard() {
        board.clearAll()
    }
    
    @objc func previousStep() {
        board.previousStep()
    }
    
    @objc func nextStep() {
        board.backToNextStep()
    }
    
}


//MARK: 安裝DrawBoard

extension ViewController {
    
    private func setDrawBoard(){
        self.view.addSubview(self.board)
        self.board.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        self.board.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
    }
    
}


extension ViewController : BrushViewDelegate {
    func closeInputView() {
        brushInput.leaveFirstResponder()
    }
    
    func replyBrush(color: UIColor, lineWine: CGFloat) {
        board.color = color
        if color == .clear { board.color = board.eraserColor}
        board.lineWidth = lineWine
    }
}
