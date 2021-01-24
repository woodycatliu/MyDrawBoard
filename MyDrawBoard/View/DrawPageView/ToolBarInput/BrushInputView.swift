//
//  BrushInputView.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2020/10/28.
//

import UIKit


protocol BrushViewDelegate {
    func replyBrush(color: UIColor, lineWine: CGFloat)
    func closeInputView()
}


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
    
    public var delegate: BrushViewDelegate?
    
    private lazy var viewModel: BrushViewModel = {
        let viewModel = BrushViewModel()
        viewModel.delegate = self
        return viewModel
    }()
    
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
    
    private(set) lazy var collectionView: UICollectionView = {
        let width = self.screenBounds.width * cvScale
        let cvFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        cvFlowLayout.scrollDirection = .horizontal
        cvFlowLayout.itemSize = CGSize(width: width * cvItemScale, height: width * cvItemScale)
        cvFlowLayout.footerReferenceSize = .zero
        cvFlowLayout.headerReferenceSize = .zero
        cvFlowLayout.minimumInteritemSpacing = cvSpacing
        cvFlowLayout.minimumLineSpacing = 5
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: cvFlowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor.systemGray6.withAlphaComponent(0.5)
        cv.register(BrushCollectionViewCell.self, forCellWithReuseIdentifier: viewModel.getDataSource().identifer)
        cv.dataSource = viewModel.getDataSource()
        cv.delegate = viewModel.getDataSource()
        cv.layer.cornerRadius = 22.5
        return cv
    }()
    
    
    
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
        self.setItems()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func setItems(){
        setUI()
        configureBrushPreview()
        setupButtonTarget()
    }
    
    
    private func setUI(){
        let width = self.screenBounds.width
        
        self.addSubview(collectionView)
        self.addSubview(bSPContainer)
        self.addSubview(slider)
        
        
        collectionView.topAnchor.constraint(equalTo: topAnchor, constant: commonTopSpacing).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingSpacing).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -trailSpacing).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: width * cvScale * cvItemScale).isActive = true
        
        bSPContainer.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 0).isActive = true
        bSPContainer.widthAnchor.constraint(equalTo: bSPContainer.heightAnchor, multiplier: 1).isActive = true
        bSPContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        slider.centerYAnchor.constraint(equalTo: bSPContainer.centerYAnchor).isActive = true
        slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leadingSpacing).isActive = true
        slider.trailingAnchor.constraint(equalTo: bSPContainer.leadingAnchor, constant: 0).isActive = true
        slider.widthAnchor.constraint(equalToConstant: width * sliderScale).isActive = true
    }
    
    
    private func configureBrushPreview(){
        bSPContainer.addSubview(brushSizePreview)
        
        brushSizePreview.centerXAnchor.constraint(equalTo: bSPContainer.centerXAnchor).isActive = true
        brushSizePreview.centerYAnchor.constraint(equalTo: bSPContainer.centerYAnchor).isActive = true
        brushSizePreview.widthAnchor.constraint(equalTo: brushSizePreview.heightAnchor).isActive = true
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
        
        self.delegate?.replyBrush(color: color, lineWine: CGFloat(sender.value))
    }
    
}



extension BrushInputView: BrushViewModelDelegate {
    func changeColor(_ color: UIColor) {
        self.color = color
        delegate?.replyBrush(color: color, lineWine: CGFloat(value))
        delegate?.closeInputView()
        
    }
}
