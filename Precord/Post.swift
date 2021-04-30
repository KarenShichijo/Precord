//
//  Post.swift
//  Precord
//
//  Created by Karen Shichijo on 2020/06/25.
//  Copyright © 2020 Karen Shichijo. All rights reserved.
//

import UIKit

class Post: NSObject {
    
    var postId: String
    var year: Int
    var movieUrl: String
    var postTitle: String
    var lastCommentDate: Date?
    var memo: String?
    
    init(postId: String, year: Int, movieUrl: String, postTitle: String){
        self.postId = postId
        self.year = year
        self.movieUrl = movieUrl
        self.postTitle = postTitle
    }

}
