//
//  SecondViewController.swift
//  ComFriends_sample
//
//  Created by KOUYA IWASE on 2018/10/23.
//  Copyright © 2018年 KOUYA IWASE. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    //特性のイラスト読み込み
    var first_illust=UIImage(named:"guitar")!
    var second_illust=UIImage(named: "game")!
    var third_illust=UIImage(named: "computer")!
    var fourth_illust=UIImage(named: "student")!
    //画面サイズを把握
    let screenWidth:CGFloat=UIScreen.main.bounds.size.width
    let screenHeight:CGFloat=UIScreen.main.bounds.size.height
    //画面内のイメージと結びつけ
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var char1: UIImageView!
    @IBOutlet weak var char2: UIImageView!
    @IBOutlet weak var char3: UIImageView!
    @IBOutlet weak var char4: UIImageView!
    @IBOutlet weak var action: UIImageView!
    //画面ロード時の処理
    override func viewDidLoad() {
        super.viewDidLoad()
        //ネームラベルの初期設定
        name.isUserInteractionEnabled=true
        name.frame=CGRect(x:0,y:0,width:128,height:64)
        name.center=CGPoint(x:screenWidth/2,y:screenHeight/2)
        reset_location()
        //イラストを対応
        char1.image=first_illust
        char2.image=second_illust
        char3.image=third_illust
        char4.image=fourth_illust
        action.isHidden=true
        action.center=CGPoint(x:screenWidth/2,y:screenHeight/2)
    }
    //画面タッチ時の処理
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchEvent=touches.first!
        //直前のタッチ場所を記憶
        let preDx=touchEvent.previousLocation(in: self.view).x
        let preDy=touchEvent.previousLocation(in: self.view).y
        //新しいタッチ場所を記憶
        let newDx=touchEvent.location(in: self.view).x
        let newDy=touchEvent.location(in: self.view).y
        //移動距離を計算
        let dx=newDx-preDx
        let dy=newDy-preDy
        //ラベル、イラストをタッチに合わせて移動
        var viewFrame:CGRect=name.frame
        viewFrame.origin.x+=dx
        viewFrame.origin.y+=dy
        name.frame=viewFrame
        reset_location()
    }
    //タッチ終了時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(name.frame.origin.y<100){
            action.image=UIImage(named: "not_interest")
            reaction_animation(check: false)
        }else if(name.frame.origin.y>500){
            action.image=UIImage(named:"interest")
            reaction_animation(check: true)
        }else{
            //ラベル、イラストを中央へ戻す
            name.center=CGPoint(x:screenWidth/2,y:screenHeight/2)
            reset_location()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
            }
    //ラベルと関連づけてイラストを移動させる関数
    func reset_location(){
        var viewFrame:CGRect=name.frame
        viewFrame.origin.x+=64
        viewFrame.origin.y+=32
        //char1
        viewFrame.origin.x-=80
        viewFrame.origin.y-=118
        char1.center=CGPoint(x:viewFrame.origin.x,y:viewFrame.origin.y)
        //char2
        viewFrame.origin.x+=160
        char2.center=CGPoint(x:viewFrame.origin.x,y:viewFrame.origin.y)
        //char3
        viewFrame.origin.y+=236
        char3.center=CGPoint(x:viewFrame.origin.x,y:viewFrame.origin.y)
        //char4
        viewFrame.origin.x-=160
        char4.center=CGPoint(x:viewFrame.origin.x,y:viewFrame.origin.y)
    }
    //リアクション後のアニメーション
    func reaction_animation(check:Bool){
        //タッチ操作を一時拒否
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.char1.isHidden=true
        self.char2.isHidden=true
        self.char3.isHidden=true
        self.char4.isHidden=true
        UIView.animate(withDuration: 1.0, delay: 0.0, animations: {
            if(check==true){
                self.name.center.y += 200.0
            }else{
                self.name.center.y-=200.0
            }
        }){_ in
            //ラベル、イラストを初期状態に
            self.name.isHidden=true
            self.name.center=CGPoint(x:self.screenWidth/2,y:self.screenHeight/2)
            self.reset_location()
            UIView.transition(with: self.action, duration: 2.0, options: [.transitionCrossDissolve,.autoreverse], animations: {
                self.action.isHidden = false
            }) { _ in
                self.action.isHidden = true
            }
        }
    }
}

