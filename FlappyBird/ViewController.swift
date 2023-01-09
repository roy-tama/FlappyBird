//
//  ViewController.swift
//  FlappyBird
//
//  Created by 牧野達也 on 2023/01/06.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // SKView型に型変換する
        let skView = self.view as! SKView
        
        // FPSを表示する
        skView.showsFPS = true
        
        // ノードの数を表示
        skView.showsNodeCount = true
        
        // ビューと同じサイズでシーンを作成する
        let scene = GameScene(size:skView.frame.size)
        
        // ビューに表示する
        skView.presentScene(scene)
    }

    // ステータスバーを消す
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

