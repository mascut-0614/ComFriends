
import UIKit
import FirebaseDatabase

var talkAdress:String=""
var avatarid:String=""
var avatarname:String=""
var tab_change:Bool=false

class MessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var TableView: UITableView!
    
    var ref:DatabaseReference!
    var wc=WaitController()
    var sum:Int=0
    
    
    override func viewDidLoad() {
        ref=Database.database().reference()
        var temp:String="wait_time"
        self.ref.child("users/"+userid+"/talkroom/sum").observe(.value) { (snap: DataSnapshot) in  temp=(snap.value! as AnyObject).description
        }
        wc.wait({return temp=="wait_time"}){
            self.sum=Int(temp)!
            self.TableView.reloadData()
            super.viewDidLoad()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(tab_change==false){
            var temp:String="wait_time"
            self.ref.child("users/"+userid+"/talkroom/sum").observe(.value) { (snap: DataSnapshot) in  temp=(snap.value! as AnyObject).description
            }
            wc.wait({return temp=="wait_time"}){
                self.sum=Int(temp)!
                self.TableView.reloadData()
            }
        }else{
            tab_change=false
            self.tabBarController?.selectedIndex=1
        }
    }
    
    @IBAction func LogoutButton(_ sender: Any) {
        self.performSegue(withIdentifier: "logout_from_message", sender: nil)
        id_change=true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sum
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell=tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        let name=cell.viewWithTag(1) as! UILabel
        let address=cell.viewWithTag(2) as! UILabel
        let id=cell.viewWithTag(3) as! UILabel
        name.text=""
        address.isHidden=true
        id.isHidden=true
        self.ref.child("users/"+userid+"/talkroom/"+(indexPath.row+1).description+"/oppid").observe(.value) { (snap: DataSnapshot) in  id.text=(snap.value! as AnyObject).description
        }
        self.ref.child("users/"+userid+"/talkroom/"+(indexPath.row+1).description+"/name").observe(.value) { (snap: DataSnapshot) in  name.text=(snap.value! as AnyObject).description
        }
        self.ref.child("users/"+userid+"/talkroom/"+(indexPath.row+1).description+"/room").observe(.value){
            (snap: DataSnapshot) in  address.text=(snap.value! as AnyObject).description
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell:UITableViewCell=tableView.cellForRow(at: indexPath)!
        let name=cell.viewWithTag(1) as! UILabel
        let address=cell.viewWithTag(2) as! UILabel
        let id=cell.viewWithTag(3) as! UILabel
        avatarid=id.text!
        talkAdress=address.text!
        avatarname=name.text!
        self.performSegue(withIdentifier: "goTalking", sender: nil)
    }
    
    func tableView(_ table: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
}
