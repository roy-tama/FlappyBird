//
//  GameScene.swift
//  FlappyBird
//
//  Created by 牧野達也 on 2023/01/06.
//

//import UIKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    var scrollNode: SKNode!
    var wallNode: SKNode!
    var starNode: SKNode! // 星追加
    var bird: SKSpriteNode!
    var starEx: SKSpriteNode!
        
    // 衝突判定カテゴリ（識別ID）
    // 「<<」はビットをずらす符号（右側の数値分ビットをずらしている）
    let birdCategory: UInt32 = 1 << 0       // 0...00001
    let groundCategory: UInt32 = 1 << 1     // 0...00010
    let wallCategory: UInt32 = 1 << 2       // 0...00100
    let scoreCategory: UInt32 = 1 << 3      // 0...01000
    let itemCategory: UInt32 = 1 << 4       // 0...10000

    // スコア用
    var score = 0
    var scoreLabelNode: SKLabelNode!
    var bestScoreLabelNode: SKLabelNode!
    // アイテムスコア用
    var itemScore = 0
    var itemScoreLabelNode: SKLabelNode!
    var bestItemScoreLabelNode: SKLabelNode!
    let userDefaults:UserDefaults = UserDefaults.standard

    // SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {

        // 重力を設定
        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        physicsWorld.contactDelegate = self
        
        // 背景色の設定
        backgroundColor = UIColor(red: 0.15, green: 0.75, blue: 0.90, alpha: 1)
        
        // スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        starNode = SKNode()
        scrollNode.addChild(starNode)
        // 各種スプライトの生成
        setupGround()
        setupCloud()
        setupWall()
//        setupStar_exsample()
        setupStar()
        setupBird()
        // スコア表示ラベルの設定
        setupScoreLabel()
        
    }

/*
    func setupStar_exsample() {

        let starTexture = SKTexture(imageNamed: "star")
        starTexture.filteringMode = .linear

        //starのスプライトを配置
        starEx = SKSpriteNode(texture: starTexture)
        starEx.position = CGPoint(x: self.frame.size.width * 0.7, y: self.frame.size.height * 0.4)

        // 移動する距離を計算
        let movingDistance = self.frame.size.width + starTexture.size().width

        // 画面外まで移動するアクションを作成
        let moveStar = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        // 自身を取り除くアクションを作成
        let removeStar = SKAction.removeFromParent()

        // 2つのアニメーションを順に実行するアクションを作成
        let starAnimation = SKAction.sequence([moveStar,removeStar])

        // アニメーション設定
        starEx.run(starAnimation)
        
        // スプライトを追加する
        addChild(starEx)
        
    }
*/
    func setupStar() {
        // 星のテクスチャを読み込む
        let starTexture = SKTexture(imageNamed: "star")
        starTexture.filteringMode = .linear
        
        // 移動する距離を計算
        let movingDistance = self.frame.size.width + starTexture.size().width

        // 画面外まで移動するアクションを作成
        let moveStar = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        // 自身を取り除くアクションを作成
        let removeStar = SKAction.removeFromParent()

        // 2つのアニメーションを順に実行するアクションを作成
        let starAnimation = SKAction.sequence([moveStar,removeStar])

        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 鳥が通り抜ける隙間の大きさを鳥のサイズの４倍とする
        let slit_length = birdSize.height * 2
        
        // 隙間位置の上下の振れ幅を50ptとする
        let random_y_range: CGFloat = 50

        // 空の中央位置（y座標）を取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        let sky_center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2

        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")

        // 空の中央位置を基準にして下側の壁の中央位置を取得
        let under_wall_center_y = sky_center_y - slit_length / 2 - wallTexture.size().height / 2

        // 星を生成するアクションを作成
        let createStarAnimation = SKAction.run({
            // 星をまとめるノードを作成
            let starCollection = SKNode()
            starCollection.position = CGPoint(x: self.frame.size.width + starTexture.size().width / 2, y: 0)

            // 地面・壁より奥、雲より前
            starCollection.zPosition = -60
            
            // 下側の壁の中央位置にランダム値を足して、下側の壁の表示位置を決定する
            // 星の表示位置を決定する（フレームの高さの中央値にランダム値を足す）
            let random_y = CGFloat.random(in: -random_y_range...random_y_range)
            let under_wall_y = self.frame.size.height / 2 + random_y

            //starのスプライトを配置
            let star = SKSpriteNode(texture: starTexture)
            // 下壁＋スリット/2の中央をy軸にする
            star.position = CGPoint(x: 0, y: under_wall_y + slit_length / 2)

            // 下側の壁に物理体を設定
//            star.physicsBody = SKPhysicsBody(rectangleOf: star.size)
            star.physicsBody = SKPhysicsBody(circleOfRadius: star.size.height / 2)
            star.physicsBody?.categoryBitMask = self.itemCategory
            star.physicsBody?.isDynamic = false
//            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
//            under.physicsBody?.categoryBitMask = self.wallCategory
//            under.physicsBody?.isDynamic = false

            
            // 星をまとめるノードに星を追加
            starCollection.addChild(star)
                        
            // 星をまとめるノードにアニメーションを追加
            starCollection.run(starAnimation)
            
            // 壁を表示するノードに今回作成した壁を追加
            self.starNode.addChild(starCollection)
        })
       
        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 「壁を作成->時間まち->壁を作成」を無制限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createStarAnimation,waitAnimation]))
        
        // 壁を表示するノードに壁の作成を無限に繰り返すアクションを設定
        starNode.run(repeatForeverAnimation)

    }

    /// 地面のセッティングを行う
    ///  - return : なし
    func setupGround() {
        // 地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)

        // 元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
        
        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,resetGround]))
        
        // groundのスプライトを配置する
        for i in 0..<needNumber {

            // テクスチャを指定してスプライトを作成する
            let sprite = SKSpriteNode(texture: groundTexture)

            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width / 2 + groundTexture.size().width * CGFloat(i),
                y: groundTexture.size().height / 2
            )

            // スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            // スプライトに物理体を設定（地面に対して長方形）
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())

            // 衝突のカテゴリを設定
            sprite.physicsBody?.categoryBitMask = self.groundCategory
            
            // 衝突の時に動かないように設定する。
            sprite.physicsBody?.isDynamic = false
            
            // シーンにスプライトを追加する
            addChild(sprite)
        }
    }
    
    func setupCloud() {
        // 雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        // スクロールするアクションを作成
        // 左方向に画像一枚分スクロールさせるアクション
        let movecloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20)

        // 元の位置に戻すアクション
        let resetcloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0)

        // 左にスクロール->元の位置->左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([movecloud,resetcloud]))

        // cloudのスプライトを配置する
        for i in 0..<needNumber {

            // テクスチャを指定してスプライトを作成する
            let sprite = SKSpriteNode(texture: cloudTexture)
            // 一番後ろになるように設定
            sprite.zPosition = -100
            
            // スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: cloudTexture.size().width / 2 + cloudTexture.size().width * CGFloat(i),
                y: self.size.height - cloudTexture.size().height / 2
            )

            // スプライトにアクションを設定する
            sprite.run(repeatScrollCloud)

            // シーンにスプライトを追加する
            addChild(sprite)
        }
    }
    
    func setupWall() {
        // 壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear // 当たり判定を行うスプライトなので画質優先に。
                
        // 移動する距離を計算
        let movingDistance = self.frame.size.width + wallTexture.size().width
        
        // 画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance, y: 0, duration: 4)
        
        // 自身を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        // 2つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall,removeWall])
        
        // 鳥の画像サイズを取得
        let birdSize = SKTexture(imageNamed: "bird_a").size()
        
        // 鳥が通り抜ける隙間の大きさを鳥のサイズの４倍とする
        let slit_length = birdSize.height * 4
        
        // 隙間位置の上下の振れ幅を60ptとする
        let random_y_range: CGFloat = 60

        // 空の中央位置（y座標）をを取得
        let groundSize = SKTexture(imageNamed: "ground").size()
        let sky_center_y = groundSize.height + (self.frame.size.height - groundSize.height) / 2
        
        // 空の中央位置を基準にして下側の壁の中央位置を取得
        let under_wall_center_y = sky_center_y - slit_length / 2 - wallTexture.size().height / 2
        
        // 壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            // 壁をまとめるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0)
            // 雲より手前、地面より奥
            wall.zPosition = -50
            // 下側の壁の中央位置にランダム値を足して、下側の壁の表示位置を決定する
            let random_y = CGFloat.random(in: -random_y_range...random_y_range)
            let under_wall_y = under_wall_center_y + random_y

            // 下側の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x: 0, y: under_wall_y)
            
            // 下側の壁に物理体を設定
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            under.physicsBody?.isDynamic = false
            
            // 壁をまとめるノードに下側の壁を追加
            wall.addChild(under)
            
            // 上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            // 上側の壁に物理体を設定
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            upper.physicsBody?.isDynamic = false
            
            // 壁をまとめるノードに上側の壁を追加
            wall.addChild(upper)
                        
            // スコアカウント用の透明な壁を作成
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: under.size.width + birdSize.width / 2, y: self.frame.size.height)
            // 透明な壁に物理体を設定（壁と同じで長方形）
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.isDynamic = false
            
            // 壁をまとめるノードに透明な壁を追加
            wall.addChild(scoreNode)
            
            // 壁をまとめるノードにアニメーションを追加
            wall.run(wallAnimation)
            
            // 壁を表示するノードに今回作成した壁を追加
            self.wallNode.addChild(wall)
        })
        
        // 次の壁作成までの時間待ちのアクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        // 「壁を作成->時間まち->壁を作成」を無制限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation,waitAnimation]))
        
        // 壁を表示するノードに壁の作成を無限に繰り返すアクションを設定
        wallNode.run(repeatForeverAnimation)
        
    }
    

    func setupBird() {
        // 鳥の画像を２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        // ２種類のテクスチャを交互に変更するアニメーションを作成
        let textureAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(textureAnimation)
        
        // スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        
        // 物理体を作成（鳥画像の半径を指定した円形）
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.frame.size.height / 2 )
        
        // カテゴリを設定
        bird.physicsBody?.categoryBitMask = self.birdCategory
        // 当たった時に跳ね返る動作をする相手(壁と地面)を設定
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        // 衝突判定の対象となるカテゴリの指定
        // 地面や壁と衝突した場合はゲームオーバーとなり、スコアカウント用の透明な壁と衝突した場合はスコアアップするから
        // この3つのカテゴリを衝突判定対象として指定
//        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | scoreCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | scoreCategory | itemCategory

        // 衝突した時に物理回転させない
        bird.physicsBody?.allowsRotation = false
        
        // アニメーション設定
        bird.run(flap)
        
        // スプライトを追加する
        addChild(bird)
    }
    
    // 画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        if scrollNode.speed > 0 {
            // 鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            // 鳥に縦方向の動きを与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))

        } else if scrollNode.speed == 0 {
            restart()
        }
        
    }
    
    // SKPhysicsContactDelegateのメソッド。衝突した時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        // ゲームオーバーの時は何もしない
        if scrollNode.speed <= 0 {
            return
        }
/*
        if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory
            || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
*/
        if ((contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory
            || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory)
                || ((contact.bodyA.categoryBitMask & itemCategory) == itemCategory
                    || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory) {

            if (contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory
                || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
                
                // スコアカウント用の透明な壁と衝突した
                print("ScoreUp")
                score += 1
                scoreLabelNode.text = "Score:\(score)"
                
                // ベストスコア更新か確認する
                var bestScore = userDefaults.integer(forKey: "BEST")
                if score > bestScore {
                    bestScore = score
                    bestScoreLabelNode.text = "Best Score:\(bestScore)"
                    userDefaults.set(bestScore, forKey: "BEST")
                    userDefaults.synchronize()
                }
            }
            if (contact.bodyA.categoryBitMask & itemCategory) == itemCategory
                        || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
                print("rootA:itemScoreUp")
                
                itemScore += 1
                itemScoreLabelNode.text = "Item Score:\(itemScore)"
                print(itemScore)

                // ベストスコア更新か確認する
                var bestScore = userDefaults.integer(forKey: "BEST_ITEM")
                if itemScore > bestScore {
                    bestScore = itemScore
                    bestItemScoreLabelNode.text = "Best ItemScore:\(bestScore)"
                    userDefaults.set(bestScore, forKey: "BEST_ITEM")
                    userDefaults.synchronize()
                }

                // アイテムをゲットしたら消える
                contact.bodyB.node?.removeFromParent()

            }
        } else {
            // 壁か地面と衝突した
            print("GameOver")
            // スクロールを停止
            scrollNode.speed = 0
            
            // 衝突後は地面と反発するのみとする（リスタートするまで壁と反発させない）
            bird.physicsBody?.collisionBitMask = groundCategory
            
            // 衝突後１秒間は鳥をくるくる回転させる
            let roll = SKAction.rotate(
                byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration: 1)
            bird.run(roll, completion: {
                self.bird.speed = 0
            })
        }
    }
    
    func restart() {
        // スコアをリセット
        score = 0
        scoreLabelNode.text = "Score:\(score)"
        itemScore = 0
        itemScoreLabelNode.text = "Item Score:\(itemScore)"
        
        // 鳥を初期位置に戻す
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y: self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        // 壁と地面の両方に反発するように戻す
        bird.physicsBody?.collisionBitMask = wallCategory | groundCategory
        bird.zPosition = 0
        
        // 全ての壁を取り除く
        wallNode.removeAllChildren()
        // 全ての星を取り除く
        starNode.removeAllChildren()

        // 鳥の羽ばたきを戻す
        bird.speed = 1
        
        // スクロールを再開する
        scrollNode.speed = 1
        
    }
    
    func setupScoreLabel() {
        // スコア表示を作成
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontSize = CGFloat(20)
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100 // 一番手前に表示
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        // ベストスコア表示を作成
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontSize = CGFloat(20)
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100 // 一番手前に表示
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        // アイテムスコア表示ラベルの設定
        itemScore = 0
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontSize = CGFloat(20)
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 120)
        itemScoreLabelNode.zPosition = 100 // 一番手前に表示
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Item Score:\(itemScore)"
        self.addChild(itemScoreLabelNode)
        
        // ベストアイテムスコア表示を作成
        let bestItemScore = userDefaults.integer(forKey: "BEST_ITEM")
        bestItemScoreLabelNode = SKLabelNode()
        bestItemScoreLabelNode.fontSize = CGFloat(20)
        bestItemScoreLabelNode.fontColor = UIColor.black
        bestItemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 150)
        bestItemScoreLabelNode.zPosition = 100 // 一番手前に表示
        bestItemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        bestItemScoreLabelNode.text = "Best ItemScore:\(bestItemScore)"
        self.addChild(bestItemScoreLabelNode)


    }
}
