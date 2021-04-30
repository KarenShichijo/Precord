//
//  Com.swift
//  Precord
//
//  Created by Karen Shichijo on 2021/01/03.
//  Copyright © 2021 Karen Shichijo. All rights reserved.
//

import Foundation
import RealmSwift

class Com: Object {
    
    // 初期設定
    static let realm = try! Realm()
    @objc dynamic private var id = 0
    
    @objc dynamic var text = ""
    @objc dynamic var createDateText = ""
//    @objc dynamic var commentedDB = DB()
//    let db = LinkingObjects(fromType: DB.self, property: "comments")
    
    // 初期設定
    override static func primaryKey() -> String? {
        return "id"
    }
    static func lastId() -> Int {
        if let object = realm.objects(Com.self).last {
            return object.id + 1
        } else {
            return 1
        }
    }
    
    // 作成(Create)のためのコード
    static func create() -> Com {
        let com = Com()
        com.id = lastId()
        return com
    }
    
    // データを保存するためのコード
    func save() {
        try! Com.realm.write {
            Com.realm.add(self)
        }
    }
    
    // 保存したものを探す(Read)ためのコード
    static func search() -> [Com] {
        
        let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < 1) {
            }
        })
        Realm.Configuration.defaultConfiguration = config
        
        if realm.objects(Com.self).isEmpty == false {
            let objects = realm.objects(Com.self)
            var ComArray: [Com] = []
            for object in objects {
                //                    print(object)
                ComArray.append(object)
            }
            return ComArray
        } else {
            return []
        }
    }
    
    // データを更新(Update)するためのコード
    static func update(id: Int, afterCom: Com) {
        let objects = realm.objects(Com.self).filter("id == \(id)")
        try! realm.write {
            objects.setValue(afterCom.text, forKey: "text")
            objects.setValue(afterCom.createDateText, forKey: "createDateText")
        }
    }
    
    // データを削除(Delete)するためのコード
    static func delete(deleateCom: Com) {
        try! realm.write {
            realm.delete(deleateCom)
        }
    }
    
    static func getToday() -> String {
        let dt = Date()
        
        //表示の仕方　2020/07/2 の形式に
        let f = DateFormatter()
        f.timeStyle = .none
        f.dateStyle = .medium
        f.locale = Locale(identifier: "ja_JP")
        let createComDateText = f.string(from: dt)
        
        return createComDateText
    }
    
}
