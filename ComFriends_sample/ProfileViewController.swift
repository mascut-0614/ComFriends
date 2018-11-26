
import UIKit
import FirebaseDatabase

class ProfileViewController:UIViewController{
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Char1: UIImageView!
    @IBOutlet weak var Char2: UIImageView!
    @IBOutlet weak var Char3: UIImageView!
    @IBOutlet weak var Char4: UIImageView!
    
    var ref:DatabaseReference!
    var wc=WaitController()
    var gender:String="wait_time"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //データベース参照
        ref=Database.database().reference()
        Name.isHidden=true
        ref.child("users/"+userid+"/gender").observe(.value) { (snap: DataSnapshot) in  self.gender=(snap.value! as AnyObject).description
        }
        self.wc.wait({return self.gender=="wait_time"}){
            if(self.gender=="male"){
                self.Name.backgroundColor=UIColor(red: 55/255, green: 65/255, blue: 73/255, alpha: 1)
            }else{
                
                self.Name.backgroundColor=UIColor(red: 239/255, green: 88/255, blue: 76/255, alpha: 1)
            }
            self.Name.isHidden=false
            self.LabelDBset(data: "username", obj: self.Name)
            self.ImageDBset(data: "1", obj: self.Char1)
            self.ImageDBset(data: "2", obj: self.Char2)
            self.ImageDBset(data: "3", obj: self.Char3)
            self.ImageDBset(data: "4", obj: self.Char4)
        }
    }
    @IBAction func logoutButton(_ sender: Any) {
        self.performSegue(withIdentifier: "logout_from_profile", sender: nil)
    }
    
    //プロフィールに表示するニックネームの設定
    func LabelDBset(data:String,obj:UILabel){
        ref.child("users/"+userid+"/"+data).observe(.value) { (snap: DataSnapshot) in  obj.text=(snap.value! as AnyObject).description
        }
    }
    //プロフィールに表示する画像の設定
    func ImageDBset(data:String,obj:UIImageView){
        var imagename:String="wait"
        ref.child("users/"+userid+"/chars/"+data+"/content").observe(.value) { (snap: DataSnapshot) in  imagename=(snap.value! as AnyObject).description
        }
        wc.wait({return imagename=="wait"}){
            obj.image=UIImage(named: imagename+"_"+self.gender)
        }
    }
}
