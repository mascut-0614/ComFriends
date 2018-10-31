//
//  ProfileViewController.swift
//  ComFriends_sample
//
//  Created by KOUYA IWASE on 2018/10/28.
//  Copyright © 2018年 KOUYA IWASE. All rights reserved.
//
import UIKit
import FirebaseDatabase

class ProfileViewController:UIViewController{
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Char1: UIImageView!
    @IBOutlet weak var Char2: UIImageView!
    @IBOutlet weak var Char3: UIImageView!
    @IBOutlet weak var Char4: UIImageView!
    
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //データベース参照
        ref=Database.database().reference()
        LabelDBset(data: "username", obj: Name)
        ImageDBset(data: "char1", obj: Char1)
        ImageDBset(data: "char2", obj: Char2)
        ImageDBset(data: "char3", obj: Char3)
        ImageDBset(data: "char4", obj: Char4)
    }
    //プロフィールに表示するニックネームの設定
    func LabelDBset(data:String,obj:UILabel){
        ref.child("users/"+userid+"/"+data).observe(.value) { (snap: DataSnapshot) in  obj.text=(snap.value! as AnyObject).description
        }
    }
    //プロフィールに表示する画像の設定
    func ImageDBset(data:String,obj:UIImageView){
        var imagename:String="wait"
        ref.child("users/"+userid+"/"+data).observe(.value) { (snap: DataSnapshot) in  imagename=(snap.value! as AnyObject).description
        }
        wait({return imagename=="wait"}){
            obj.image=UIImage(named: imagename)
        }
    }
    //同期用のwait関数
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
