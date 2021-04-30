//
//  AppDelegate.swift
//  Precord
//
//  Created by Karen Shichijo on 2020/06/21.
//  Copyright © 2020 Karen Shichijo. All rights reserved.
//

import UIKit
import NCMB
import IQKeyboardManagerSwift
import PKHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        NCMB.setApplicationKey("b4d8fade73cce1c6784ccac31bf636f4b26b0f4d946e308f396e0a11111516b5", clientKey: "5b732515f8fdf42060a3b68a30bae863310e54cfff0b8a5799edec57aa0c5916")
        
        // 匿名ユーザの自動生成を有効化
        NCMBUser.enableAutomaticUser()
        if NCMBAnonymousUtils.isLinked(with: NCMBUser.current()) {
            // 匿名ユーザーでログインしている時の処理
        }else{
            NCMBAnonymousUtils.logIn { (NCMBUser, error) in
                if error != nil {
                    //エラー時にアラートを出す
                    PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "アプリの起動に失敗しました。", subtitle: error?.localizedDescription)
                    PKHUD.sharedHUD.show()
                    PKHUD.sharedHUD.hide(afterDelay: 2.0)
                } else {
                    
                }
            }
        }

        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

