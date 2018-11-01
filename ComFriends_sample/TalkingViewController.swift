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
        rootRef.queryLimited(toLast: 100).observe(DataEventType.childAdded, with: { (snapshot) in
            var valueDic=snapshot.value as? NSDictionary
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
        self.senderId = "user1"
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"profile")!,diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "guitar")!, diameter: 64)
        //BubbleImageの生成
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        //通信相手の発言
        self.incomingBubble = bubbleFactory?.incomingMessagesBubbleImage(
            with: UIColor.jsq_messageBubbleLightGray())
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
        let postRef = rootRef.childByAutoId()
        postRef.setValue(post)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView, messageDataForItemAt indexPath: IndexPath) -> JSQMessageData {
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
