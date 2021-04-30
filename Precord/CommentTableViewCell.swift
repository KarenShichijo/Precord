//
//  CommentTableViewCell.swift
//  Precord
//
//  Created by Karen Shichijo on 2020/06/23.
//  Copyright © 2020 Karen Shichijo. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet var timeLabel: UILabel!
//    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var commentLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        // 枠を角丸にする
//        commentTextView.layer.cornerRadius = 13.0
//        commentTextView.layer.masksToBounds = true
        
        commentLabel.layer.cornerRadius = 13.0
        commentLabel.layer.masksToBounds = true
        
        timeLabel.layer.cornerRadius = 5
        timeLabel.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
