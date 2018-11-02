//
//  ExpandViewController.swift
//  ComFriends_sample
//
//  Created by KOUYA IWASE on 2018/10/28.
//  Copyright © 2018年 KOUYA IWASE. All rights reserved.
//
import UIKit
import FirebaseDatabase

class ExpandViewController: UIViewController {
    
    //データベースの参照先
    var ref:DatabaseReference!
    //DB参照時のID
    var search_id:Int=1
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
        //データベース参照
        ref=Database.database().reference()
        //ネームラベルの初期設定
        name.isUserInteractionEnabled=true
        name.frame=CGRect(x:0,y:0,width:128,height:64)
        name.center=CGPoint(x:screenWidth/2,y:screenHeight/2)
        reset_location()
        //イラストを対応
        friends_reset()
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
            var check:String="wait_time"
            action.image=UIImage(named:"interest")
            ref.child("users/"+userid+"/interest/"+search_id.description).setValue("yes")
            ref.child("users/"+search_id.description+"/interest/"+userid).observe(.value) { (snap: DataSnapshot) in  check=(snap.value! as AnyObject).description
            }
            wait({return check=="wait_time"}){
                print("check="+check)
                if(check=="yes"){
                    //相手側のトークルーム数を変更
                    var you_temp:String=""
                    var you_int:Int=999
                    var you_check:Bool=true
                    self.ref.child("users/"+self.search_id.description+"/talkroom/sum").observe(.value) { (snap: DataSnapshot) in  you_temp=(snap.value! as AnyObject).description
                        you_int=Int(you_temp)!
                    }
                    self.wait({return you_int==999}){
                        print("before you="+you_int.description)
                        you_int+=1
                        print("after you="+you_int.description)
                        self.ref.child("users/"+self.search_id.description+"/talkroom/sum").setValue(you_int.description)
                        you_check=false
                    }
                    //自分側のトークルーム数を変更
                    var me_temp:String=""
                    var me_int:Int=999
                    var me_check:Bool=true
                    self.ref.child("users/"+userid+"/talkroom/sum").observe(.value) { (snap: DataSnapshot) in  me_temp=(snap.value! as AnyObject).description
                        me_int=Int(me_temp)!
                    }
                    self.wait({return me_int==999}){
                        print("before me="+me_int.description)
                        me_int+=1
                        print("after me="+me_int.description)
                        self.ref.child("users/"+userid+"/talkroom/sum").setValue(me_int.description)
                        me_check=false
                    }
                    //トークルームの生成
                    self.wait({return (me_check||you_check)}){
                        print("you="+you_int.description)
                        print("me="+me_int.description)
                        let address:String="messages/talk"+userid+"_"+self.search_id.description
                        self.ref.child(address).setValue("hello")
                        self.ref.child("users/"+self.search_id.description+"/talkroom/"+you_int.description).setValue(["name":accessname,"room":address])
                        self.ref.child("users/"+userid+"/talkroom/"+me_int.description).setValue(["name":self.name.text,"room":address])
                    }
                }
            }
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
            self.action.isHidden=false
            self.search_id+=1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.action.isHidden=true
                self.friends_reset()
            }
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    //リアクション後の表示プロフィールの変更
    func friends_reset(){
        var readname:String="wait_time"
        if(search_id.description==userid){
            search_id+=1
            print("this user is you")
        }
        print(search_id.description)
        ref.child("users/"+search_id.description+"/username").observe(.value) { (snap: DataSnapshot) in  readname=(snap.value! as AnyObject).description
        }
        wait({return readname=="wait_time"}){
            print(readname)
            if(readname=="<null>"){
                print("Finish!")
            }else{
                self.name.text=readname
                self.ImageDBset(data: "char1", obj: self.char1)
                self.ImageDBset(data: "char2", obj: self.char2)
                self.ImageDBset(data: "char3", obj: self.char3)
                self.ImageDBset(data: "char4", obj: self.char4)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.name.isHidden=false
                    self.char1.isHidden=false
                    self.char2.isHidden=false
                    self.char3.isHidden=false
                    self.char4.isHidden=false
                }
            }
        }
    }
    //プロフィールに表示する画像の設定
    func ImageDBset(data:String,obj:UIImageView){
        var imagename:String="wait_time"
        ref.child("users/"+self.search_id.description+"/"+data).observe(.value) { (snap: DataSnapshot) in  imagename=(snap.value! as AnyObject).description
        }
        wait({return imagename=="wait_time"}){
            obj.image=UIImage(named: imagename)
        }
    }
    //同期用wait関数
    func wait(_ waitContinuation: @escaping (()->Bool), compleation: @escaping (()->Void)) {
        var wait = waitContinuation()
        // 0.01秒周期で待機条件をクリアするまで待ちます。
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            while wait {
                DispatchQueue.main.async {
                    wait = waitContinuation()
                    semaphore.signal()
                }
                semaphore.wait()
                Thread.sleep(forTimeInterval: 0.01)
            }
            // 待機条件をクリアしたので通過後の処理を行います。
            DispatchQueue.main.async {
                compleation()
            }
        }
    }
}
