//
//  RootViewController.swift
//  Messanger
//
//  Created by Nikhil on 9/25/18.
//

import UIKit

import XMPPFramework

class RootViewController: UIViewController, XMPPStreamDelegate {
    
    var stream:XMPPStream!
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster!
    
    //Outlets
    @IBOutlet weak var contentTextview : UITextView!
    @IBOutlet weak var sendButton : UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        
        stream = XMPPStream()
        stream.addDelegate(self, delegateQueue: DispatchQueue.main)
        xmppRoster.activate(stream)
        
        stream.myJID = XMPPJID(string: "user1@localhost")
        
        do {
            try stream.connect(withTimeout: 30)
        }
        catch {
            print("catch")
            
        }
    }
    
    private func setupUI() {
        self.contentTextview.layer.cornerRadius = self.contentTextview.bounds.height / 2
        self.contentTextview.layer.borderWidth = 0.5
        self.contentTextview.layer.borderColor = UIColor.lightGray.cgColor
        self.sendButton.layer.cornerRadius = self.sendButton.bounds.height / 2
        self.sendButton.layer.borderColor = UIColor.lightGray.cgColor
        self.sendButton.layer.borderWidth = 0.5
    }
    
    func connect() -> Bool {
        if !stream.isConnected {
            let jabberID = "user1@localhost"
            let myPassword = "12345"
            
            if !stream.isDisconnected {
                return true
            }
            if jabberID == nil && myPassword == nil {
                return false
            }
            
            stream.myJID = XMPPJID(string: jabberID)
            
            do {
                try stream.connect(withTimeout: XMPPStreamTimeoutNone)
                print("Connection success")
                return true
            } catch {
                print("Something went wrong!")
                return false
            }
        } else {
            return true
        }
    }
    
    @IBAction func sendMessage(_ sender : UIButton) {
        
        let message = self.contentTextview.text
        let senderJID = XMPPJID(string: "user3@localhost")
        let msg = XMPPMessage(type: "chat", to: senderJID)
        
        msg.addBody(message!)
        stream.send(msg)
    }
    
    
    func xmppStreamWillConnect(sender: XMPPStream!) {
        print("will connect")
    }
    
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream) {
        print("timeout:")
    }
    
    func xmppStreamDidConnect(sender: XMPPStream!) {
        print("connected")
        
        do {
            try sender.authenticate(withPassword: "123")
        }
        catch {
            print("catch")
            
        }
        
    }
    
    
    func xmppStreamDidAuthenticate(_ sender: XMPPStream) {
        print("auth done")
        sender.send(XMPPPresence())
    }
    
    
    func xmppStream(_ sender: XMPPStream, didNotAuthenticate error: DDXMLElement) {
        print("dint not auth")
        print(error)
    }
    
    func xmppStream(sender: XMPPStream!, didReceivePresence presence: XMPPPresence!) {
        print(presence)
        let presenceType = presence.type
        let username = sender.myJID?.user
        let presenceFromUser = presence.from?.user
        
        if presenceFromUser != username  {
            if presenceType == "available" {
                print("available")
            }
            else if presenceType == "subscribe" {
                self.xmppRoster.subscribePresence(toUser: presence.from!)
            }
            else {
                print(presenceType)
            }
        }
        
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
        print("sent")
    }
    
    private func xmppStream(_ sender: XMPPStream!, didFailToSend iq: XMPPIQ!, error: Error!) {
        print("error")
    }
    
    func xmppStream(_ sender: XMPPStream, didReceiveError error: DDXMLElement) {
        print("error")
    }
    
    func xmppStream(sender: XMPPStream!, didFailToSendMessage message: XMPPMessage!, error: Error!) {
        print("fail")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        print(message)
    }
}
