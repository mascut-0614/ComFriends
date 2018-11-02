//
//  RegisterViewController.swift
//  ComFriends_sample
//
//  Created by KOUYA IWASE on 2018/11/02.
//  Copyright © 2018年 KOUYA IWASE. All rights reserved.
//

import UIKit
import FirebaseDatabase

class RegisterViewController:UIViewController{
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var Input: UITextField!
    @IBOutlet weak var Button: UIButton!
    
    var ref:DatabaseReference!
    var check:Bool=false
    var temp:Int=0
    
    override func viewDidLoad() {
        ref=Database.database().reference()
        super.viewDidLoad()
    }
    
    @IBAction func touchButton(_ sender: Any) {
        if(check==false){
            check=true
            ref.child("users/sum").observe(.value) { (snap: DataSnapshot) in  let st_temp:String=(snap.value! as AnyObject).description
                self.temp=Int(st_temp)!+1
            }
            wait({return self.temp==0}){
                let name:String=self.Input.text!
                self.Input.text=""
                self.ref.child("users/sum").setValue(self.temp.description)
                self.ref.child("users/"+self.temp.description).setValue(["username":name,"char1":"hatena","char2":"hatena","char3":"hatena","char4":"hatena"])
                self.ref.child("users/"+self.temp.description+"/interest").setValue(["0":"yes"])
                self.ref.child("users/"+self.temp.description+"/talkroom").setValue(["sum":"0"])
                self.label.text="Your ID is "+self.temp.description
                self.Input.isHidden=true
            }
        }else{
            if(temp != 0){
                performSegue(withIdentifier: "goEnter", sender: nil)
            }
        }
    }
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
