
import UIKit
import FirebaseDatabase

var num:Int!
class RegisterViewController:UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    var ref:DatabaseReference!
    var wc=WaitController()
    var vi=UIView()
    var resisternumber:String!

    @IBOutlet weak var Gender: UIButton!
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var Attention1: UIImageView!
    @IBOutlet weak var Attention2: UIImageView!
    @IBOutlet weak var Next: UIButton!
    
    let pickerView = UIPickerView()
    var array = ["---","male", "female"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref=Database.database().reference()
        Attention1.image=UIImage(named: "attention")
        Attention2.image=UIImage(named:"attention")
        Attention1.isHidden=true
        Attention2.isHidden=true
        ref.child("users/sum").observe(.value) { (snap: DataSnapshot) in self.resisternumber=(snap.value! as AnyObject).description
        }
    }
    
    @IBAction func TouchGender(_ sender: Any) {
        self.view.endEditing(true)
        PickerPush()
    }
    
    func PickerPush(){
        pickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: pickerView.bounds.size.height)
        // Connect data:
        pickerView.delegate   = self
        pickerView.dataSource = self
        vi = UIView(frame: pickerView.bounds)
        vi.backgroundColor = UIColor.white
        vi.addSubview(pickerView)
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        let doneButton   = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(donePressed))
        let spaceButton  = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        vi.addSubview(toolBar)
        view.addSubview(vi)
        let screenSize = UIScreen.main.bounds.size
        vi.frame.origin.y = screenSize.height
        UIView.animate(withDuration: 0.3) {
            self.vi.frame.origin.y = screenSize.height - self.vi.bounds.size.height
        }
    }
    
    // Done
    @objc func donePressed() {
        vi.removeFromSuperview()
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return array[row]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Gender.setTitle(array[row], for: .normal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        vi.removeFromSuperview()
    }
    
    @IBAction func touchNext(_ sender: Any) {
        if(Name.text != ""&&Gender.titleLabel!.text != "---"){
            Attention1.isHidden=true
            Attention2.isHidden=true
            print("name="+Name.text!)
            print("gender="+Gender.titleLabel!.text!)
            num=Int(resisternumber)!+1
            ref.child("users/"+num.description).setValue(["username":Name.text!,"gender":Gender.titleLabel?.text!,"icon":"me"]);
            ref.child("users/"+num.description+"/interest/0").setValue("yes")
            ref.child("users/"+num.description+"/talkroom/sum").setValue("0")
            self.performSegue(withIdentifier: "goCharSetting", sender: nil)
        }else{
            if(Name.text==""){
                Attention1.isHidden=false
            }else{
                Attention1.isHidden=true
            }
            if(Gender.titleLabel!.text=="---"){
                Attention2.isHidden=false
            }else{
                Attention2.isHidden=true
            }
        }
    }
    
}
