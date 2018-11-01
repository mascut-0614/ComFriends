//
//  MessageViewController.swift
//  ComFriends_sample
//
//  Created by KOUYA IWASE on 2018/10/28.
//  Copyright © 2018年 KOUYA IWASE. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell=tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        let img=UIImage(named:"profile")
        let imageView=cell.viewWithTag(1) as! UIImageView
        imageView.image=img
        let name=cell.viewWithTag(2) as! UILabel
        name.text="User"+String(indexPath.row+1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goTalking", sender: nil)
    }
    
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    override func didReceiveMemoryWarning() {
     super.didReceiveMemoryWarning()
     // Dispose of any resources that can be recreated.
    }
    
}
