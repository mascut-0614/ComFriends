
import Foundation
import UIKit
import Firebase

class DetailViewController:UIViewController{
    
    var ref:DatabaseReference!
    var detail_id:String!
    var wc=WaitController()
    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var Gender: UILabel!
    @IBOutlet weak var Department: UILabel!
    @IBOutlet weak var Grade: UILabel!
    @IBOutlet weak var Club: UILabel!
    @IBOutlet weak var Char1: UILabel!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Char2: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Char3: UILabel!
    @IBOutlet weak var Label3: UILabel!
    @IBOutlet weak var Char4: UILabel!
    @IBOutlet weak var Label4: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref=Database.database().reference()
        var range:String="wait_time"
        ref.child("users/"+detail_id+"/community/range").observe(.value) { (snap: DataSnapshot) in  range=(snap.value! as AnyObject).description
        }
        wc.wait({return range=="wait_time"}){
            if(range=="公開"){
                self.LabelDBset(data: "community/department", obj: self.Department)
                self.LabelDBset(data: "community/grade", obj: self.Grade)
                self.LabelDBset(data: "community/club", obj: self.Club)
            }else{
                self.Department.text="- secret -"
                self.Grade.text="- secret -"
                self.Club.text="- secret -"
            }
        }
        LabelDBset(data: "username", obj: Name)
        LabelDBset(data: "gender", obj: Gender)
        //LabelDBset(data: "community/department", obj: Department)
        //LabelDBset(data: "community/grade", obj: Grade)
        //LabelDBset(data: "community/club", obj: Club)
        LabelDBset(data: "chars/1/content", obj: Char1)
        LabelDBset(data: "chars/1/detail", obj: Label1)
        LabelDBset(data: "chars/2/content", obj: Char2)
        LabelDBset(data: "chars/2/detail", obj: Label2)
        LabelDBset(data: "chars/3/content", obj: Char3)
        LabelDBset(data: "chars/3/detail", obj: Label3)
        LabelDBset(data: "chars/4/content", obj: Char4)
        LabelDBset(data: "chars/4/detail", obj: Label4)
    }
    
    @IBAction func touchBack(_ sender: Any) {
        tab_change=true
        self.performSegue(withIdentifier: "BackExpand", sender: nil)
    }
    
    func LabelDBset(data:String,obj:UILabel){
        ref.child("users/"+detail_id+"/"+data).observe(.value) { (snap: DataSnapshot) in  obj.text=(snap.value! as AnyObject).description
        }
    }
}
