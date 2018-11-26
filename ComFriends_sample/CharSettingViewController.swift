
import UIKit
import Firebase

class CharSettingViewController:UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    var ref:DatabaseReference!
    var wc=WaitController()
    let pickerView=UIPickerView()
    var vi=UIView()
    var array=["---","astronomy","baseball","bowling","camera","computer","cooking","diving","drawing","drinking","driving","dvd","fighting_sports","fishing","football","game","golf","guitar","movie","music","piano","pingpong","radio","ramen","singing","skiing","swimming","tennis","training","trip","volleyball","youtube"]
    var input_num:Int!
    
    @IBOutlet weak var Char: UIButton!
    @IBOutlet weak var Detail: UITextField!
    @IBOutlet weak var CharLabel: UILabel!
    @IBOutlet weak var OK: UIButton!
    @IBOutlet weak var Attention: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref=Database.database().reference()
        input_num=1
        Attention.image=UIImage(named: "attention")
        Attention.isHidden=true
    }
    
    @IBAction func touchChar(_ sender: Any) {
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
        Char.setTitle(array[row], for: .normal)
    }
    
    @IBAction func touchOK(_ sender: Any) {
        if(Detail.text!.count>20){
            Attention.isHidden=false
        }else{
            print(Detail.text!.count.description)
            Attention.isHidden=true
            print(input_num.description+"="+Char.titleLabel!.text!)
            ref.child("users/"+num.description+"/chars/"+input_num.description).setValue(["content":Char.titleLabel!.text!,"detail":Detail.text!])
            input_num+=1
            if(input_num<=4){
                CharLabel.text="Char"+input_num.description+"/4"
                if(input_num==4){
                    OK.setTitle("Next", for: .normal)
                }
                Char.setTitle("---", for: .normal)
                Detail.text=""
            }else{
                Char.setTitle("---", for: .normal)
                Detail.text=""
                self.performSegue(withIdentifier: "goCommunity", sender: nil)
                print("finish")
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
