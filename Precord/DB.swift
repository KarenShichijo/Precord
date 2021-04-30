//
//  DB.swift
//  Precord
//
//  Created by Karen Shichijo on 2020/09/11.
//  Copyright © 2020 Karen Shichijo. All rights reserved.
//

import Foundation
import RealmSwift

class DB: Object {
    
    // 初期設定
    static let realm = try! Realm()
    @objc dynamic var id = 0
    
    @objc dynamic var pictureUrl = ""
    @objc dynamic var title = ""
    @objc dynamic var year = 0
    @objc dynamic var memo = ""
    @objc dynamic var isImage = false
    let comments = List<Com>()
//    let comments = LinkingObjects(fromType: Com.self, property: "commentedDB")
    @objc dynamic var lastCommentDateText = ""
    
    // 初期設定
    override static func primaryKey() -> String? {
        return "id"
    }
    static func lastId() -> Int {
        if let object = realm.objects(DB.self).last {
            return object.id + 1
        } else {
            return 1
        }
    }
    
    // 作成(Create)のためのコード
    static func create() -> DB {
        let db = DB()
        db.id = lastId()
        return db
    }
    
    // データを保存するためのコード
    func save() {
        try! DB.realm.write {
            DB.realm.add(self)
        }
    }
    
    // 保存したものを探す(Read)ためのコード
    static func search() -> [DB] {
        
        let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
            }
        })
        Realm.Configuration.defaultConfiguration = config
        
        if realm.objects(DB.self).isEmpty == false {
            let objects = realm.objects(DB.self)
            var dbArray: [DB] = []
            for object in objects {
                //                    print(object)
                dbArray.append(object)
            }
            return dbArray
        } else {
            return []
        }
    }
    
    // データを更新(Update)するためのコード
    static func update(id: Int, afterDB: DB) {
        let object = realm.objects(DB.self).filter("id == \(id)")
        try! realm.write {
            object.setValue(afterDB.pictureUrl, forKey: "pictureUrl")
            object.setValue(afterDB.title, forKey: "title")
            object.setValue(afterDB.year, forKey: "year")
            object.setValue(afterDB.memo, forKey: "memo")
            object.setValue(afterDB.isImage, forKey: "isImage")
        }
    }
    
    // データを削除(Delete)するためのコード
    static func delete(thisDB: DB) {
//        let object = realm.objects(DB.self).filter("id == \(id)")
        try! realm.write {
            realm.delete(thisDB.comments)
            realm.delete(thisDB)
        }
    }
    
    //年別にデータを並び替えて取得
    static func sortByYear() -> [Int:[DB]] {
        let objects = realm.objects(DB.self)
        let sortedObjects = objects.sorted(byKeyPath: "year", ascending: false)
        var sortYear = 0
        var sortedDB: [Int:[DB]] = [:]
        var thisYearDB: [DB] = []
        for object in sortedObjects {
            if sortYear == object.year {
                thisYearDB.append(object)
            } else {
                if sortYear != 0 {
                    sortedDB[sortYear] = thisYearDB
                    thisYearDB = []
                }
                sortYear = object.year
                thisYearDB.append(object)
            }
        }
        if thisYearDB != [] {
            sortedDB[sortYear] = thisYearDB
        }
        print(sortedDB)
        return sortedDB
    }
    
    static func addComment(thisDB: DB, commentText: String){
        let comment = Com.create()
        comment.text = commentText
        comment.createDateText = Com.getToday()
        thisDB.comments.append(comment)
        thisDB.lastCommentDateText = comment.createDateText
        try! realm.write() {
        realm.add(thisDB, update: .all)
        }
    }  
}
