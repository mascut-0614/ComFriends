
import UIKit
import FirebaseDatabase

var now:Int=0
class ExpandViewController: UIViewController {
    
    //データベースの参照先
    var ref:DatabaseReference!
    var wc=WaitController()
    //DB参照時のID
    var search_id:[String]=[]
    var gender:String!
    //画面サイズを把握
    let screenWidth:CGFloat=UIScreen.main.bounds.size.width
    let screenHeight:CGFloat=UIScreen.main.bounds.size.height
    //画面内のイメージと結びつけ
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var char1: UIImageView!
    @IBOutlet weak var char2: UIImageView!
    @IBOutlet weak var char3: UIImageView!
    @IBOutlet weak var char4: UIImageView!
    @IBOutlet weak var action: UIImageView!
    @IBOutlet weak var GoLeft: UIButton!
    @IBOutlet weak var GoRight: UIButton!
    
    //画面ロード時の処理
    override func viewDidLoad() {
        super.viewDidLoad()
        //データベース参照
        ref=Database.database().reference()
        //ネームラベルの初期設定
        name.isUserInteractionEnabled=true
        name.frame=CGRect(x:0,y:0,width:128,height:64)
        name.center=CGPoint(x:screenWidth/2,y:screenHeight/2)
        reset_location()
        AllChange(show: true)
        GoLeft.isHidden=true
        GoRight.isHidden=true
        //イラストを対応
        action.isHidden=true
        action.center=CGPoint(x:screenWidth/2,y:screenHeight/2)
        //プロフィールのinterest読み取り
        var sum:String="wait_time"
        ref.child("users/sum").observe(.value) { (snap: DataSnapshot) in sum=(snap.value! as AnyObject).description
        }
        wc.wait({return sum=="wait_time"}){
            var check:Int=1
            for count in 1...Int(sum)!{
                print("count="+count.description)
                if(userid != count.description){
                    var interest:String="wait_time"
                    self.wc.wait({return count>check}){
                        print(count.description+"is loaded!")
                        self.ref.child("users/"+userid+"/interest/"+count.description).observe(.value) { (snap: DataSnapshot) in interest=(snap.value! as AnyObject).description
                        }
                    }
                    self.wc.wait({return interest=="wait_time"}){
                        if(interest != "yes"){
                            self.search_id.append(count.description)
                            print(count.description+" is appended!")
                        }
                        if(userid==sum){
                            if(count==Int(sum)!-1){
                                print("Setting is finished")
                                self.friends_reset()
                            }
                        }else{
                            if(count==Int(sum)!){
                                print("Setting is finished")
                                self.friends_reset()
                            }
                        }
                        check+=1
                    }
                }else{
                    check+=1
                }
            }
            
        }
    }
    @IBAction func touchLeft(_ sender: Any) {
        now-=1
        friends_reset()
    }
    @IBAction func touchRight(_ sender: Any) {
        now+=1
        friends_reset()
    }
    @IBAction func touchLogout(_ sender: Any) {
        self.performSegue(withIdentifier: "logout_from_expand", sender: nil)
    }
    @IBAction func touchDetail(_ sender: Any) {
        
        self.performSegue(withIdentifier: "goDetail", sender: search_id[now])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goDetail" {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.detail_id = sender as? String
        }
    }
    
    //画面タッチ時の処理
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchEvent=touches.first!
        //直前のタッチ場所を記憶
        let preDx=touchEvent.previousLocation(in: self.view).x
        let preDy=touchEvent.previousLocation(in: self.view).y
        //新しいタッチ場所を記憶
        let newDx=touchEvent.location(in: self.view).x
        let newDy=touchEvent.location(in: self.view).y
        //移動距離を計算
        let dx=newDx-preDx
        let dy=newDy-preDy
        //ラベル、イラストをタッチに合わせて移動
        var viewFrame:CGRect=name.frame
        viewFrame.origin.x+=dx
        viewFrame.origin.y+=dy
        name.frame=viewFrame
        reset_location()
    }
    //タッチ終了時の処理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(name.frame.origin.y>500){
            var check:String="wait_time"
            action.image=UIImage(named:"interest")
            ref.child("users/"+userid+"/interest/"+search_id[now]).setValue("yes")
            ref.child("users/"+search_id[now]+"/interest/"+userid).observe(.value) { (snap: DataSnapshot) in  check=(snap.value! as AnyObject).description
            }
            wc.wait({return check=="wait_time"}){
                print("check="+check)
                if(check=="yes"){
                    //相手側のトークルーム数を変更
                    var you_temp:String="wait_time"
                    var you_int:Int!
                    var me_temp:String="wait_time"
                    var me_int:Int!
                    var check:Bool=true
                    self.ref.child("users/"+self.search_id[now]+"/talkroom/sum").observe(.value) { (snap: DataSnapshot) in  you_temp=(snap.value! as AnyObject).description
                    }
                    self.ref.child("users/"+userid+"/talkroom/sum").observe(.value) { (snap: DataSnapshot) in  me_temp=(snap.value! as AnyObject).description
                    }
                    self.wc.wait({return (you_temp=="wait_time"||me_temp=="wait_time")}){
                        you_int=Int(you_temp)!+1
                        me_int=Int(me_temp)!+1
                        self.ref.child("users/"+self.search_id[now]+"/talkroom/sum").setValue(you_int.description)
                        self.ref.child("users/"+userid+"/talkroom/sum").setValue(me_int.description)
                        check=false
                    }
                    //トークルームの生成
                    self.wc.wait({return check}){
                        let address:String="messages/talk"+userid+"_"+self.search_id[now]
                        self.ref.child(address).setValue("hello")
                        self.ref.child("users/"+self.search_id[now]+"/talkroom/"+you_int.description).setValue(["oppid":userid,"name":accessname,"room":address])
                        self.ref.child("users/"+userid+"/talkroom/"+me_int.description).setValue(["oppid":self.search_id[now],"name":self.name.text,"room":address])
                    }
                }
            }
            reaction_animation()
        }else{
            //ラベル、イラストを中央へ戻す
            name.center=CGPoint(x:screenWidth/2,y:screenHeight/2)
            reset_location()
        }
    }
    
    //ラベルと関連づけてイラストを移動させる関数
    func reset_location(){
        var viewFrame:CGRect=name.frame
        viewFrame.origin.x+=64
        viewFrame.origin.y+=32
        //char1
        viewFrame.origin.x-=80
        viewFrame.origin.y-=118
        char1.center=CGPoint(x:viewFrame.origin.x,y:viewFrame.origin.y)
        //char2
        viewFrame.origin.x+=160
        char2.center=CGPoint(x:viewFrame.origin.x,y:viewFrame.origin.y)
        //char3
        viewFrame.origin.y+=236
        char3.center=CGPoint(x:viewFrame.origin.x,y:viewFrame.origin.y)
        //char4
        viewFrame.origin.x-=160
        char4.center=CGPoint(x:viewFrame.origin.x,y:viewFrame.origin.y)
    }
    //リアクション後のアニメーション
    func reaction_animation(){
        //タッチ操作を一時拒否
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.char1.isHidden=true
        self.char2.isHidden=true
        self.char3.isHidden=true
        self.char4.isHidden=true
        UIView.animate(withDuration: 1.0, delay: 0.0, animations: {
            self.name.center.y += 200.0
        }){_ in
            //ラベル、イラストを初期状態に
            self.name.isHidden=true
            self.name.center=CGPoint(x:self.screenWidth/2,y:self.screenHeight/2)
            self.reset_location()
            self.action.isHidden=false
            self.search_id.remove(at: now)
            if(self.search_id.count==now){
                now-=1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.action.isHidden=true
                self.friends_reset()
            }
        }
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    //リアクション後の表示プロフィールの変更
    func friends_reset(){
        if(search_id.isEmpty){
            AllChange(show: true)
            GoRight.isHidden=true
            GoLeft.isHidden=true
            print("No Member!")
            return
        }
        if(now==0){
            GoLeft.isHidden=true
        }else{
            GoLeft.isHidden=false
        }
        if(now==search_id.count-1){
            GoRight.isHidden=true
        }else{
            GoRight.isHidden=false
        }
        var readname:String="wait_time"
        gender="wait_time"
        print(search_id[now]+" is proposed!")
        ref.child("users/"+search_id[now]+"/username").observe(.value) { (snap: DataSnapshot) in  readname=(snap.value! as AnyObject).description
        }
        ref.child("users/"+search_id[now]+"/gender").observe(.value) { (snap: DataSnapshot) in  self.gender=(snap.value! as AnyObject).description
        }
        wc.wait({return (readname=="wait_time"||self.gender=="wait_time")}){
            print(readname)
            if(self.gender=="male"){
                self.name.backgroundColor=UIColor(red: 55/255, green: 65/255, blue: 73/255, alpha: 1)
            }else{
                
                self.name.backgroundColor=UIColor(red: 239/255, green: 88/255, blue: 76/255, alpha: 1)
            }
            self.name.text=readname
            self.ImageDBset(data: "1", obj: self.char1)
            self.ImageDBset(data: "2", obj: self.char2)
            self.ImageDBset(data: "3", obj: self.char3)
            self.ImageDBset(data: "4", obj: self.char4)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.AllChange(show: false)
            }
        }
    }
    func AllChange(show:Bool){
        char1.isHidden=show
        char2.isHidden=show
        char3.isHidden=show
        char4.isHidden=show
        name.isHidden=show
    }
    //プロフィールに表示する画像の設定
    func ImageDBset(data:String,obj:UIImageView){
        var imagename:String="wait_time"
        ref.child("users/"+search_id[now]+"/chars/"+data+"/content").observe(.value) { (snap: DataSnapshot) in  imagename=(snap.value! as AnyObject).description
        }
        wc.wait({return imagename=="wait_time"}){
            obj.image=UIImage(named: imagename+"_"+self.gender)
        }
    }
    
}
