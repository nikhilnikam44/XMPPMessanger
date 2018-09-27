//
//  ViewController.swift
//  Messanger
//
//  Created by Nikhil on 9/25/18.
//

import UIKit
import XMPPFramework

class ViewController: UIViewController {
    
    //Outlets
    @IBOutlet weak var contentTextview : UITextView!
    @IBOutlet weak var sendButton : UIButton!
    @IBOutlet weak var conversationTableview : UITableView!
    @IBOutlet weak var editorView : UIView!

    //Datasource
    var messageArray = [String]()
    
    let maxMessageBoxLength : CGFloat = 150.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.conversationTableview.register(UINib(nibName: "MessageTableviewCell", bundle: nil), forCellReuseIdentifier: "Test")
        
        self.conversationTableview.tableFooterView = UIView(frame: CGRect.zero)
        
        self.contentTextview.delegate = self
        
        setupUI()
    }
    
    //Setting UI customizations
    private func setupUI() {
        self.navigationItem.title = "Chat"
        
        //Setting layer properties
        self.contentTextview.layer.cornerRadius = self.contentTextview.bounds.height / 2
        self.contentTextview.layer.borderWidth = 0.5
        self.contentTextview.layer.borderColor = UIColor.lightGray.cgColor
        self.sendButton.layer.cornerRadius = 5.0
        self.sendButton.layer.borderColor = UIColor.lightGray.cgColor
        self.sendButton.layer.borderWidth = 0.5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(gesture:)))
        self.conversationTableview.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTapGesture(gesture : UITapGestureRecognizer) {
        self.handleEditorViewPosition(shouldMoveUp: false)
    }
    
    //Send button tap action
    @IBAction func sendMessage(_ sender : UIButton) {
        
        //Creating new message object to send
        let message = self.contentTextview.text
        let receiverID = XMPPJID(string: "nikhil@localhost")
        let msg = XMPPMessage(type: "chat", to: receiverID)
        
        msg.addBody(message!)
        (UIApplication.shared.delegate as! AppDelegate).xmppStream.send(msg)
        
        //Adding new message in list
        self.conversationTableview.beginUpdates()
        self.messageArray.append(message!)
        self.conversationTableview.insertRows(at: [IndexPath(row: messageArray.count - 1, section: 0)], with: .none)
        self.conversationTableview.endUpdates()
        
        self.handleEditorViewPosition(shouldMoveUp: false)
    }
    
    //Calculate dynamic height for the message to be shown in tableviewcell
    func calculateHeightForString(inString:String) -> CGSize {
        let messageString = inString
        let attributes : [NSAttributedStringKey : Any] = [(kCTFontAttributeName as NSString) as NSAttributedStringKey: UIFont.systemFont(ofSize: 12)]
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes as [NSAttributedStringKey : Any])
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: maxMessageBoxLength, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize:CGRect = rect
        return requredSize.size
    }
}

//MARK:- Tableview datasource methods

extension ViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
}

//MARK:- Tableview delegate methods

extension ViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row < messageArray.count {
            let message = messageArray[indexPath.row]
            
            let height:CGFloat = self.calculateHeightForString(inString: message).height
            return height + 30
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.conversationTableview.dequeueReusableCell(withIdentifier: "Test", for: indexPath) as! MessageTableviewCell
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        var frame = CGRect(x: 10, y: 5, width: maxMessageBoxLength, height: 40)
        
        if indexPath.row < messageArray.count {            
            let stringSizeAsText : CGSize = calculateHeightForString(inString: messageArray[indexPath.row])
            
            //Each line will approximately take up the original label's height
            frame.size = stringSizeAsText
            
            if frame.size.width < 100 {
                frame.size.width = 100
            }
            
            frame.size.height = stringSizeAsText.height
            
            cell.setUpUI(messageLabelFrame : frame, message : messageArray[indexPath.row])
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
}

//MARK:- Textview delegate methods
extension ViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.handleEditorViewPosition(shouldMoveUp: true)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.handleEditorViewPosition(shouldMoveUp: false)
    }
    
    //Move editir view up and down depending on keyboard
    private func handleEditorViewPosition(shouldMoveUp : Bool) {
        var editorViewFrame = self.editorView.frame
        if shouldMoveUp {
            editorViewFrame.origin.y = UIScreen.main.bounds.height / 2
        } else {
            editorViewFrame.origin.y = UIScreen.main.bounds.height - editorViewFrame.height
            self.view.endEditing(true)
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.editorView.frame = editorViewFrame
        })
    }
}



