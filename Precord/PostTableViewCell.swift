//
//  PostTableViewCell.swift
//  Precord
//
//  Created by Karen Shichijo on 2020/06/23.
//  Copyright © 2020 Karen Shichijo. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    @IBOutlet var postedMovieImageView: UIImageView!
    @IBOutlet var postTitleLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
