
import UIKit
import FirebaseDatabase
var userid:String=""
var accessname:String="wait_time"
var id_change=false

class EnterViewController: UIViewController {
    //データベースの参照先
    var ref:DatabaseReference!
    var wc=WaitController()
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var id: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var register: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //データベース参照
        ref=Database.database().reference()
    }
    @IBAction func touchRegister(_ sender: Any) {
        performSegue(withIdentifier: "goRegister", sender: nil)
    }
    @IBAction func touchLogin(_ sender: Any) {
        userid=id.text!
        ref.child("users/"+userid+"/username").observe(.value) { (snap: DataSnapshot) in accessname=(snap.value! as AnyObject).description
        }
        wc.wait( { return accessname=="wait_time" }){
            print("finish")
            print(userid)
            print(accessname)
            if(accessname=="<null>"){
                self.name.placeholder="No UserID"
                accessname="wait_time"
            }else if(accessname==self.name.text){
                self.name.placeholder="Success"
                self.performSegue(withIdentifier: "LoginSuccess", sender: nil)
            }else{
                self.name.placeholder="Name is wrong"
                accessname="wait_time"
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
