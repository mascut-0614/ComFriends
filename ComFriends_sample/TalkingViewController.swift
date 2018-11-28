
import UIKit
import FirebaseDatabase
import JSQMessagesViewController

class TalkingViewController:JSQMessagesViewController {
    var messages:[JSQMessage]?
    
    var incomingBubble:JSQMessagesBubbleImage!
    var outgoingBubble:JSQMessagesBubbleImage!
    var incomingAvatar:JSQMessagesAvatarImage!
    var outgoingAvatar:JSQMessagesAvatarImage!
    
    var ref:DatabaseReference!
    var input_status:String="no"
    var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref=Database.database().reference()
        //Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TalkingViewController.inputCheck), userInfo: nil, repeats: true)
        self.navigationItem.title=avatarname
        setupFirebase()
        setupChatUI()
        self.senderDisplayName=userid
        self.messages=[]
    }
    //入力状態の確認開始
    override func viewWillAppear(_ animated: Bool) {
        timer=Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(TalkingViewController.inputCheck), userInfo: nil, repeats: true)
    }
    //確認終了
    override func viewWillDisappear(_ animated: Bool) {
        print("timer stop")
        timer.invalidate()
    }
    @objc func inputCheck(){
        if(inputToolbar.contentView.textView.text! == ""){
            ref.child(talkAdress+"/"+userid).setValue("no")
        }else{
            ref.child(talkAdress+"/"+userid).setValue("yes")
        }
        ref.child(talkAdress+"/"+avatarid).observe(.value) { (snap: DataSnapshot) in  self.input_status=(snap.value! as AnyObject).description
        }
        if(input_status=="yes"){
            print(avatarid+" is typing now")
            self.navigationController?.navigationBar.titleTextAttributes=[.foregroundColor:UIColor.yellow]
        }else{
            print(avatarid+" is not typing now")
            self.navigationController?.navigationBar.titleTextAttributes=[.foregroundColor:UIColor.white]
        }
    }
    
    @IBAction func Profile(_ sender: Any) {
        self.performSegue(withIdentifier: "goAvatar", sender: nil)
    }
    
    func setupFirebase(){
        let rootRef = Database.database().reference()
        rootRef.child(talkAdress+"/content").queryLimited(toLast: 100).observe(DataEventType.childAdded, with: { (snapshot) in
            let valueDic=snapshot.value as? NSDictionary
            let text = valueDic?["text"] as? String ?? ""
            let sender = valueDic?["from"] as? String ?? ""
            let name = valueDic?["name"] as? String ?? ""
            let message = JSQMessage(senderId: sender, displayName: name, text: text)
            self.messages?.append(message!)
            self.finishReceivingMessage()
        })
    }
    
    func setupChatUI(){
        //JSQMessage関連の設定
        inputToolbar!.contentView!.leftBarButtonItem = nil
        automaticallyScrollsToMostRecentMessage = true
        //自分のID、アイコン、相手のアイコンの設定
        self.senderId = accessname
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"you")!,diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "me")!, diameter: 64)
        //BubbleImageの生成
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        //通信相手の発言
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleGreen())
        //自分の発言
        self.outgoingBubble = bubbleFactory?.outgoingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleBlue())
    }
    
    //メッセージの送信
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        self.finishSendingMessage(animated: true)
        //sendTextToDb(text: text)
        let rootRef = Database.database().reference()
        let post = ["from": senderId,
                    "name": senderDisplayName,
                    "text": text]
        let postRef = rootRef.child(talkAdress+"/content").childByAutoId()
        postRef.setValue(post)
    }
    @IBAction func BackButton(_ sender: Any) {
        self.performSegue(withIdentifier: "BackMessage", sender: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        collectionView.frame=CGRect(x:0,y:70,width:375,height:600)
        return (self.messages?[indexPath.item])!
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource{
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath) -> JSQMessageAvatarImageDataSource {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.messages?.count)!
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
