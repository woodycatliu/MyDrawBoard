//
//  InputSubstitute.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2020/10/27.
//

import UIKit

class MyCustomInputContainer: UIButton {
    let screenBounds: CGRect = UIScreen.main.bounds
    private lazy var newView: UIView = UIView()
    private lazy var toolView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.systemGray5.cgColor
        view.layer.shadowOpacity = 0.8
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        return view
    }()
    
    private lazy var backView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    weak var target: UIViewController?
    
    private var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.setTitle("Done", for: .highlighted)
        button.setTitleColor(.systemRed, for: .normal)
        button.setTitleColor(.systemGray3, for: .highlighted)
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setDefaultToolView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var inputView: UIView {
        get {
            return self.newView
        }
        set {
            self.newView = newValue
        }
    }
    
    override var inputAccessoryView: UIView {
        get {
            return self.toolView
        }
        set {
            self.toolView = newValue
        }
    }
    
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    private func setDefaultToolView(){
        self.toolView.frame = CGRect(x: 0, y: 0, width: self.screenBounds.width, height: 30)
        self.toolView.addSubview(backView)
        backView.fillSuperview()
        self.backView.addSubview(cancelButton)
        self.cancelButton.topAnchor.constraint(equalTo: self.backView.topAnchor, constant: 0).isActive = true
        self.cancelButton.trailingAnchor.constraint(equalTo: self.backView.trailingAnchor, constant: -10).isActive = true
        self.cancelButton.bottomAnchor.constraint(equalTo: self.backView.bottomAnchor, constant: 0).isActive = true
        self.cancelButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.cancelButton.addTarget(self, action: #selector(leaveFirstResponder), for: .touchUpInside)
    }
    
    @objc func leaveFirstResponder(){
        self.resignFirstResponder()
        if let target = self.target{
            target.navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    
}
