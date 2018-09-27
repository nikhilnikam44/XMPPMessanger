//
//  MessageTableviewCell.swift
//  Messanger
//
//  Created by Nikhil on 9/25/18.
//

import UIKit

class MessageTableviewCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel : UILabel!
    @IBOutlet weak var labelLeadingConstraint : NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpUI(messageLabelFrame : CGRect, message : String) {
        let messageLabel = UILabel(frame: messageLabelFrame)
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.text = message
        messageLabel.textColor = UIColor.white
        messageLabel.font = UIFont.systemFont(ofSize: 12)
        
        var xValue : CGFloat = 10
        
        let containerView = UIView()
        
        xValue = self.contentView.frame.size.width - messageLabelFrame.size.width - 30
        containerView.backgroundColor = UIColor.lightGray
        
        containerView.frame = CGRect(x: xValue , y: 10.0, width: messageLabelFrame.size.width + 20, height: messageLabelFrame.size.height + 10)
        containerView.layer.cornerRadius = 8.0
        containerView.addSubview(messageLabel)
        self.contentView.addSubview(containerView)
    }
}
