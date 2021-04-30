//
//  Comment.swift
//  Precord
//
//  Created by Karen Shichijo on 2020/06/28.
//  Copyright © 2020 Karen Shichijo. All rights reserved.
//

import UIKit

class Comment: NSObject {
    
    var commentId: String
    var commentText: String
    var createDate: Date

 
    init(commentId: String, commentText: String, createDate: Date){
        self.commentId = commentId
        self.commentText = commentText
        self.createDate = createDate
    }
}
