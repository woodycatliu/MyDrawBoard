//
//  ViewController.swift
//  MyDrawBoard
//
//  Created by Woody Liu on 2020/10/26.
//

import UIKit

class ViewController: UIViewController {
    
    let board : DrawBoard = {
        let board = DrawBoard()
        board.translatesAutoresizingMaskIntoConstraints = false
        board.backgroundColor = .black
        return board
    }()
    
    let backButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("back", for: .normal)
        button.setTitle("back", for: .highlighted)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.backgroundColor = .yellow
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("next", for: .normal)
        button.setTitle("next", for: .highlighted)
        button.setTitleColor(.blue, for: .normal)
        button.setTitleColor(.blue, for: .highlighted)
        button.backgroundColor = .yellow
        return button
    }()
    
    let colors : [UIColor] = [.systemRed,.systemBlue,.systemPink,.systemYellow]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(board)
        self.view.addSubview(backButton)
        self.view.addSubview(nextButton)
        
        NSLayoutConstraint.activate([
            self.board.topAnchor.constraint(equalTo: self.view.topAnchor,constant: self.view.safeAreaInsets.top),
            self.board.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.board.bottomAnchor.constraint(equalTo: self.backButton.topAnchor,constant: 0),
            self.board.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            
//            self.backButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.backButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier:  0.2),
            self.backButton.heightAnchor.constraint(equalToConstant: 50),
            self.backButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: 0),
            
            self.nextButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier:  0.2),
            self.nextButton.heightAnchor.constraint(equalToConstant: 50),
            self.nextButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: 0),
            self.nextButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            
        ])
        
        self.backButton.addTarget(self, action: #selector(backStep), for: .touchUpInside)
        self.nextButton.addTarget(self, action: #selector(nextStep), for: .touchUpInside)

    }

    
    @objc func changeColor(){
        let randomInt = Int.random(in: 0...1000)
        let color = self.colors[randomInt % self.colors.count]
        self.board.color = color
    }
    
    @objc func nextStep(){
        self.board.backToNextStep()
    }
    
    @objc func backStep(){
        self.board.clearAll()
    }

}

