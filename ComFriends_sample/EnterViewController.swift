//
//  EnterViewController.swift
//  ComFriends_sample
//
//  Created by KOUYA IWASE on 2018/10/28.
//  Copyright © 2018年 KOUYA IWASE. All rights reserved.
//

import UIKit
import FirebaseDatabase
var userid:String=""

class EnterViewController: UIViewController {
    //データベースの参照先
    var ref:DatabaseReference!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var login: UIButton!
    
    var accessname:String="wait"
    override func viewDidLoad() {
        super.viewDidLoad()
        //データベース参照
        ref=Database.database().reference()
    }
    @IBAction func touchLogin(_ sender: Any) {
        userid=id.text!
        ref.child("users/"+userid+"/username").observe(.value) { (snap: DataSnapshot) in self.accessname=(snap.value! as AnyObject).description
        }
        wait( { return self.accessname=="wait" }){
            print("finish")
            print(userid)
            print(self.accessname)
            if(self.accessname=="<null>"){
                self.name.placeholder="No UserID"
                self.accessname="wait"
            }else if(self.accessname==self.name.text){
                self.name.placeholder="Success"
                self.performSegue(withIdentifier: "LoginSuccess", sender: nil)
            }else{
                self.name.placeholder="Name is wrong"
                self.accessname="wait"
            }
        }
    }
    //同期処理用wait関数
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
