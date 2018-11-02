//
//  MessageViewController.swift
//  ComFriends_sample
//
//  Created by KOUYA IWASE on 2018/10/28.
//  Copyright © 2018年 KOUYA IWASE. All rights reserved.
//

import UIKit
import FirebaseDatabase

var talkAdress:String=""
class MessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var TableView: UITableView!
    @IBOutlet weak var Reload: UIButton!
    
    var ref:DatabaseReference!
    var sum:Int=0
    
    override func viewDidLoad() {
        ref=Database.database().reference()
        var temp:String="wait_time"
        self.ref.child("users/"+userid+"/talkroom/sum").observe(.value) { (snap: DataSnapshot) in  temp=(snap.value! as AnyObject).description
        }
        wait({return temp=="wait_time"}){
            self.sum=Int(temp)!
            self.TableView.reloadData()
            super.viewDidLoad()
        }
    }
    @IBAction func reloadTable(_ sender: Any) {
        var temp:String="wait_time"
        self.ref.child("users/"+userid+"/talkroom/sum").observe(.value) { (snap: DataSnapshot) in  temp=(snap.value! as AnyObject).description
        }
        wait({return temp=="wait_time"}){
            self.sum=Int(temp)!
            self.TableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell=tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        let name=cell.viewWithTag(1) as! UILabel
        let address=cell.viewWithTag(2) as! UILabel
        address.isHidden=true
        self.ref.child("users/"+userid+"/talkroom/"+(indexPath.row+1).description+"/name").observe(.value) { (snap: DataSnapshot) in  name.text=(snap.value! as AnyObject).description
        }
        self.ref.child("users/"+userid+"/talkroom/"+(indexPath.row+1).description+"/room").observe(.value){
            (snap: DataSnapshot) in  address.text=(snap.value! as AnyObject).description
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:UITableViewCell=tableView.cellForRow(at: indexPath)!
        let address=cell.viewWithTag(2) as! UILabel
        talkAdress=address.text!
        self.performSegue(withIdentifier: "goTalking", sender: nil)
    }
    
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
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
     // Dispose of any resources that can be recreated.
    }
    
}
