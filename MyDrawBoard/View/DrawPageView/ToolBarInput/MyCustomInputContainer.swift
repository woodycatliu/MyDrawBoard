//
//  InputSubstitute.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2020/10/27.
//

import UIKit

class MyCustomInputContainer: UIButton {
    let screenBounds: CGRect = UIScreen.main.bounds
    private var newView: UIView = UIView()
    private var toolView: UIView = UIView()
    
    var target: UIViewController?
    
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
        self.configureDefaultToolView()
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
    
    private func configureDefaultToolView(){
        self.toolView.frame = CGRect(x: 0, y: 0, width: self.screenBounds.width, height: 30)
        self.toolView.addSubview(cancelButton)
        self.toolView.backgroundColor = .systemGray5
        self.cancelButton.topAnchor.constraint(equalTo: self.toolView.topAnchor, constant: 0).isActive = true
        self.cancelButton.leadingAnchor.constraint(equalTo: self.toolView.leadingAnchor, constant: 10).isActive = true
        self.cancelButton.bottomAnchor.constraint(equalTo: self.toolView.bottomAnchor, constant: 0).isActive = true
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
