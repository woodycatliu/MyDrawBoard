//
//  BrushInputView.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2020/10/28.
//

import UIKit

class BrushInputView: UIView {
    private let screenBounds: CGRect = UIScreen.main.bounds
    
    private let itemetweenSpacing: CGFloat = 8.5
    private let commonTopSpacing: CGFloat = 5
    
    private let cvSpacing: CGFloat = 3
    private let cvScale: CGFloat = 1
    private let cvItemScale: CGFloat = 0.09
    
    
    private let leadingSpacing: CGFloat = 15
    private let trailSpacing: CGFloat = 10
    
    private let sliderScale: CGFloat = 0.7
    
    private var bspheightLayout: NSLayoutConstraint!
    
    public var reply: BrushViewControllerToDrawBoard?
    
    public var value : Float {
        set {
            DispatchQueue.main.async {
                self.slider.value = newValue
                self.bspheightLayout.constant = CGFloat(newValue)
                self.brushSizePreview.layer.cornerRadius = CGFloat(newValue / 2)
            }
        }
        get {
            return self.slider.value
        }
    }
    
    public var color: UIColor = .white
    
    
    let slider : UISlider = {
        let slider = UISlider()
        slider.minimumValue = 5
        slider.maximumValue = 30
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.value = 5
        return slider
    }()
    
    var cv: UICollectionView!
    private let cvFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    private let bSPContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    public let brushSizePreview: UIView = {
        let view  = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.darkGray.cgColor
        return view
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func configureItems(){
        configureCollection()
        configureConstraint()
        configureBrushPreview()
        setupButtonTarget()
    }
    
    private func configureCollection(){
        let width = self.screenBounds.width * cvScale
        cvFlowLayout.scrollDirection = .horizontal
        cvFlowLayout.estimatedItemSize = CGSize(width: width * cvItemScale, height: width * cvItemScale)
        cvFlowLayout.footerReferenceSize = .zero
        cvFlowLayout.headerReferenceSize = .zero
        cvFlowLayout.minimumInteritemSpacing = cvSpacing
        cvFlowLayout.minimumLineSpacing = 0
        
        cv = UICollectionView(frame: .zero, collectionViewLayout: self.cvFlowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemGray
        
    }
    
    private func configureConstraint(){
        let width = self.screenBounds.width
        
        self.addSubview(self.cv)
        self.addSubview(self.bSPContainer)
        self.addSubview(self.slider)
        
        
        cv.topAnchor.constraint(equalTo: self.topAnchor, constant: commonTopSpacing).isActive = true
        cv.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingSpacing).isActive = true
        cv.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -trailSpacing).isActive = true
        cv.heightAnchor.constraint(equalToConstant: width * cvScale * cvItemScale).isActive = true
        
        bSPContainer.topAnchor.constraint(equalTo: self.cv.bottomAnchor, constant: 0).isActive = true
        bSPContainer.widthAnchor.constraint(equalTo: self.bSPContainer.heightAnchor, multiplier: 1).isActive = true
        bSPContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        slider.centerYAnchor.constraint(equalTo: self.bSPContainer.centerYAnchor).isActive = true
        slider.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: leadingSpacing).isActive = true
        slider.trailingAnchor.constraint(equalTo: self.bSPContainer.leadingAnchor, constant: 0).isActive = true
        slider.widthAnchor.constraint(equalToConstant: width * sliderScale).isActive = true
    }
    
    
    private func configureBrushPreview(){
        bSPContainer.addSubview(brushSizePreview)
        
        brushSizePreview.centerXAnchor.constraint(equalTo: self.bSPContainer.centerXAnchor).isActive = true
        brushSizePreview.centerYAnchor.constraint(equalTo: self.bSPContainer.centerYAnchor).isActive = true
        brushSizePreview.widthAnchor.constraint(equalTo: self.brushSizePreview.heightAnchor).isActive = true
        bspheightLayout = brushSizePreview.heightAnchor.constraint(equalToConstant: 5)
        bspheightLayout.isActive = true
        self.brushSizePreview.layer.cornerRadius = 2.5
    }
    
    private func setupButtonTarget(){
        slider.addTarget(self, action: #selector(changeBSPPreview(_:)), for: .valueChanged)
    }
    
    @objc func changeBSPPreview(_ sender: UISlider){
        bspheightLayout.constant = CGFloat(sender.value)
        brushSizePreview.layer.cornerRadius = brushSizePreview.frame.height / 2
        
        self.reply?.replyBrush(color: self.color, lineWine: CGFloat(sender.value))
    }
    
}


//MARK: 回傳slider/Color 新值 To DrawBoard
protocol BrushViewControllerToDrawBoard {
    func replyBrush(color: UIColor,lineWine: CGFloat)
}
