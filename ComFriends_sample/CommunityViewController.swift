
import Foundation
import UIKit
import Firebase

class CommunityViewController:UIViewController,UIPickerViewDelegate,UIPickerViewDataSource{
    
    var ref:DatabaseReference!
    let pickerView=UIPickerView()
    var vi=UIView()
    var grade:Int=0
    var secret:Int=0
    var array=["---","政治経済学部","政治経済学術院","法学部","法学術院","文化構想学部","文学部","文学学術院","教育学部","教育・総合科学学術院","商学部","商学学術院","基幹理工学部","創造理工学部","先進理工学部","理工学術院","社会科学部","社会科学総合学術院","人間科学部","人間科学学術院","スポーツ科学部","スポーツ科学学術院","国際教養学部","国際学術院"]
    
    @IBOutlet weak var Department: UIButton!
    @IBOutlet weak var Club: UITextField!
    @IBOutlet weak var Attention2: UIImageView!
    @IBOutlet weak var Start: UIButton!
    @IBOutlet weak var Grade: UISegmentedControl!
    @IBOutlet weak var Secret: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref=Database.database().reference()
        Attention2.image=UIImage(named: "attention")
        Attention2.isHidden=true
    }
    
    
    @IBAction func touchDepartment(_ sender: Any) {
        PickerPush()
    }
    
    @IBAction func touchStart(_ sender: Any) {
        if(Department.titleLabel!.text! != "---"){
            Attention2.isHidden=true
            grade=Grade.selectedSegmentIndex
            secret=Secret.selectedSegmentIndex
            ref.child("users/"+num.description+"/community").setValue(["grade":Grade.titleForSegment(at: grade),"department":Department.titleLabel!.text!,"club":Club.text!,"range":Secret.titleForSegment(at: secret)])
            ref.child("users/sum").setValue(num.description)
            //self.performSegue(withIdentifier: "ResisterFinish", sender: nil)
            let alert:UIAlertController=UIAlertController(title: "Your ID = "+num.description, message: "Please Remember!", preferredStyle: UIAlertControllerStyle.alert)
            let defaultAction:UIAlertAction=UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:{
                (ACTION:UIAlertAction!)->Void in
                    self.performSegue(withIdentifier: "ResisterFinish", sender: nil)
            })
            alert.addAction(defaultAction)
            present(alert, animated: true, completion: nil)
        }else{
            if(Department.titleLabel!.text!  == "---"){
                Attention2.isHidden=false
            }else{
                Attention2.isHidden=true
            }
        }
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
        Department.setTitle(array[row], for: .normal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
