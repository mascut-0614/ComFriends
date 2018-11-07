//
//  AvatarViewController.swift
//  ComFriends_sample
//
//  Created by KOUYA IWASE on 2018/11/07.
//  Copyright © 2018年 KOUYA IWASE. All rights reserved.
//

import UIKit
import FirebaseDatabase

class AvatarViewController:UIViewController{
    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Back: UIButton!
    @IBOutlet weak var char1: UIImageView!
    @IBOutlet weak var char2: UIImageView!
    @IBOutlet weak var char3: UIImageView!
    @IBOutlet weak var char4: UIImageView!
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref=Database.database().reference()
        LabelDBset(data: "username", obj: Name)
        ImageDBset(data: "char1", obj: char1)
        ImageDBset(data: "char2", obj: char2)
        ImageDBset(data: "char3", obj: char3)
        ImageDBset(data: "char4", obj: char4)
    }
    
    func LabelDBset(data:String,obj:UILabel){
        ref.child("users/"+avatarid+"/"+data).observe(.value) { (snap: DataSnapshot) in  obj.text=(snap.value! as AnyObject).description
        }
    }
    
    func ImageDBset(data:String,obj:UIImageView){
        var imagename:String="wait"
        ref.child("users/"+avatarid+"/"+data).observe(.value) { (snap: DataSnapshot) in  imagename=(snap.value! as AnyObject).description
        }
        wait({return imagename=="wait"}){
            obj.image=UIImage(named: imagename)
        }
    }
    
    @IBAction func touchBack(_ sender: Any) {
        self.performSegue(withIdentifier: "goTalking", sender: nil)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
