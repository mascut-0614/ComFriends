//
//  TalkingViewController.swift
//  ComFriends_sample
//
//  Created by KOUYA IWASE on 2018/11/01.
//  Copyright © 2018年 KOUYA IWASE. All rights reserved.
//
import UIKit
import FirebaseDatabase
import JSQMessagesViewController

class TalkingViewController:JSQMessagesViewController {
    var messages:[JSQMessage]?
    
    var incomingBubble:JSQMessagesBubbleImage!
    var outgoingBubble:JSQMessagesBubbleImage!
    var incomingAvatar:JSQMessagesAvatarImage!
    var outgoingAvatar:JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirebase()
        setupChatUI()
        self.senderDisplayName=userid
        self.messages=[]
    }
    
    func setupFirebase(){
        let rootRef = Database.database().reference()
        rootRef.child(talkAdress).queryLimited(toLast: 100).observe(DataEventType.childAdded, with: { (snapshot) in
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
        let postRef = rootRef.child(talkAdress).childByAutoId()
        postRef.setValue(post)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
        collectionView.frame=CGRect(x:0,y:200,width:375,height:600)
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
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        if(messages![indexPath.row].senderId != senderId){
            let avatarImageTap = UITapGestureRecognizer(target: self, action:#selector(tappedAvatar(_sender:)))
            cell.avatarImageView?.isUserInteractionEnabled = true
            cell.avatarImageView?.addGestureRecognizer(avatarImageTap)
        }
        return cell
    }
    
    @objc func tappedAvatar(_sender:UITapGestureRecognizer) {
        print("tapped user avatar")
        self.performSegue(withIdentifier: "goAvatar", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
