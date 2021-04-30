//
//  ViewController.swift
//  Precord
//
//  Created by Karen Shichijo on 2020/06/21.
//  Copyright © 2020 Karen Shichijo. All rights reserved.
//

import UIKit
import NCMB
import AVKit
import PKHUD
import RealmSwift

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet var timelineTableView: UITableView!
    
    //userUserDefaultsの確保
//    let ud = UserDefaults.standard
    //udに保存したyearSectionを入れる配列
    var yearSection = [Int]()
    
    //セクション番号の配列
    var sectionName = [String]()
    //セクションわけした投稿を入れる
    var secPosts = [Int:[Post]]()
    
    //どの投稿が選択されたかを保存
//    var selectedPost: Post!
//    var selectedYear: String!
    
    //レルムver
    var sortedPosts = [Int:[DB]]()
    var selectedDB = DB()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        print(Realm.Configuration.defaultConfiguration.fileURL)
        
        //dataSourceとdelegateの設定
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        
        //カスタムセルの登録
        let nib = UINib(nibName: "PostTableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib, forCellReuseIdentifier: "PostCell")
        
        //tableViewのフッターの不要な線を消す
        timelineTableView.tableFooterView = UIView()
   
        // 引っ張って更新
        setRefreshControl()
        
        //セルの大きさ可変に
        timelineTableView.estimatedRowHeight = 500
        timelineTableView.rowHeight = UITableView.automaticDimension
        
        // 次の画面のBackボタンを「<」に変更
          self.navigationItem.backBarButtonItem = UIBarButtonItem(
              title:  "",
              style:  .plain,
              target: nil,
              action: nil
          )
        
//        //バックボタンの画像を変える
//        navigationController?.navigationBar.backIndicatorImage = UIImage(systemName: "arrow.uturn.left")
//        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(systemName: "arrow.uturn.left")
        
        //タイトルにロゴの表示
        let imageView = UIImageView(image: UIImage(named: "logo.png"))
        imageView.contentMode = .scaleAspectFit
        self.navigationItem.titleView = imageView
        
        //realmの保存先のPathの取得
//        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //初期化
        sectionName = []
        
//        //sectionのyearをudからとってくる
//        if ud.array(forKey: "yearSection") != nil {
//            yearSection = ud.array(forKey: "yearSection") as! [Int]
//        }
//
//        //セクションの作成
//        for i in yearSection {
//            let year = String(i + 2000)
//            sectionName.append(year)
//        }
        
        //        loadPost()
        
        loadFromRealm()
    }
    
    //詳細画面に情報送る
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail"{
            let detailViewController = segue.destination as! DetailViewController
            //postIdを詳細画面に送る
            detailViewController.receivedDB = selectedDB
//            detailViewController.postId = selectedPost.postId
//            detailViewController.movieName = selectedPost.movieUrl
//            detailViewController.titleText = selectedPost.postTitle
//            detailViewController.yearSec = selectedPost.year
        }
    }
    
    //セルがタップされたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        timelineTableView.deselectRow(at: indexPath, animated: true)
        //選択された投稿
        selectedDB = sortedPosts[yearSection[indexPath.section]]![indexPath.row]
        //画面遷移
        performSegue(withIdentifier: "toDetail", sender: nil)
    }
    
    func getSecNum() -> [Int] {
        var secNums = [Int](sortedPosts.keys)
        secNums.sort { $1 < $0 }
        return secNums
    }
    
    func getSecNumStr() -> [String] {
        let secNums = getSecNum()
        var secNumStr: [String] = []
        for secNum in secNums {
            secNumStr.append(String(secNum))
        }
        return secNumStr
    }
    
    //生成するセクションの数
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionName.count
    }

    //セクションの表示
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionName[section]
    }

    //生成するセルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if secPosts.count == sectionName.count {
//            //一つのセクションに入れるCellの数を指定する。
//            return secPosts[yearSection[section]]!.count
//        } else {
//            return 0
//        }
        
        return sortedPosts[yearSection[section]]!.count
    }
    
    //セルに入れる内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cellにカスタムセルを入れる
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostTableViewCell
        
        //        if secPosts.count == sectionName.count {
        //
        //            // DocumentフォルダのURL
        //            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //
        //            //サムネイル
        //            let movieName = secPosts[yearSection[indexPath.section]]![indexPath.row].movieUrl
        //            let movieUrl = documentsDirectoryURL.appendingPathComponent(movieName)
        //            let movieAVURLAsset = AVURLAsset(url:movieUrl)
        //            let generator = AVAssetImageGenerator(asset: movieAVURLAsset)
        //            generator.appliesPreferredTrackTransform = true
        //
        //            // 今回は00:00の部分を切り出し
        //            let thumbnail = try! generator.copyCGImage(at: .zero, actualTime: nil)
        //            //サムネイルを表示
        //            let UIImageThumbnail = UIImage(cgImage: thumbnail)
        //            //ファイルサイズダウン
        //            let resizedThumbnail = UIImageThumbnail.scale(byFactor: 0.3)
        //            cell.postedMovieImageView.image = resizedThumbnail
        //
        //            //タイトル
        //            cell.postTitleLabel.text = secPosts[yearSection[indexPath.section]]![indexPath.row].postTitle
        //
        //            //最終コメント日
        //            let lastCommentDate = secPosts[yearSection[indexPath.section]]![indexPath.row].lastCommentDate
        //            if lastCommentDate != nil {
        //                //表示の仕方　2020/7/2 の形式に
        //                let f = DateFormatter()
        //                f.timeStyle = .none
        //                f.dateStyle = .medium
        //                f.locale = Locale(identifier: "ja_JP")
        //                let lastCommentDateText = f.string(from: lastCommentDate!)
        //                cell.timeLabel.text = lastCommentDateText
        //            } else {
        //                cell.timeLabel.text = ""
        //            }
        //
        //        }
        
        
        // DocumentフォルダのURL
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let isImage = sortedPosts[yearSection[indexPath.section]]![indexPath.row].isImage
        let pictureUrl = sortedPosts[yearSection[indexPath.section]]![indexPath.row].pictureUrl
        let Url = documentsDirectoryURL.appendingPathComponent(pictureUrl)
        if isImage == false {
            //動画の場合
            //サムネイル表示
            let movieAVURLAsset = AVURLAsset(url:Url)
            let generator = AVAssetImageGenerator(asset: movieAVURLAsset)
            generator.appliesPreferredTrackTransform = true
            
            // 今回は00:00の部分を切り出し
            let thumbnail = try! generator.copyCGImage(at: .zero, actualTime: nil)
            //サムネイルを表示
            let UIImageThumbnail = UIImage(cgImage: thumbnail)
            //ファイルサイズダウン
            let resizedThumbnail = UIImageThumbnail.scale(byFactor: 0.3)
            cell.postedMovieImageView.image = resizedThumbnail
        } else {
            //写真の場合
            let uiImage = UIImage(contentsOfFile: Url.path)!.scale(byFactor: 0.3)
            cell.postedMovieImageView.image = uiImage
        }
        //タイトル
        cell.postTitleLabel.text = sortedPosts[yearSection[indexPath.section]]![indexPath.row].title
        
        //最終コメント日
        let lastCommentDateText = sortedPosts[yearSection[indexPath.section]]![indexPath.row].lastCommentDateText
        cell.timeLabel.text = lastCommentDateText
        
//        if lastCommentDate != nil {
//            //表示の仕方　2020/7/2 の形式に
//            let f = DateFormatter()
//            f.timeStyle = .none
//            f.dateStyle = .medium
//            f.locale = Locale(identifier: "ja_JP")
//            let lastCommentDateText = f.string(from: lastCommentDate!)
//            cell.timeLabel.text = lastCommentDateText
//        } else {
//            cell.timeLabel.text = ""
//        }
        
        
        return cell
    }
    
    func loadFromRealm(){
        sortedPosts = DB.sortByYear()
        //セクションの作成
        yearSection = getSecNum()
        sectionName = getSecNumStr()
    }
    
    //投稿を読み込む
    func loadPost(){
        //NCMBからデータを取ってくる
        let query = NCMBQuery(className: "Post")

        //自分の投稿を取得
        query?.whereKey("postUser", equalTo: NCMBUser.current())

        //初期化
        secPosts = [:]

        for i in yearSection {
            query?.whereKey("year", equalTo: i)
            // 取ってきたデータを降順（投稿が新しい順）
            query?.order(byDescending: "createDate")

            var thisYearsPost = [Post]()

            //とある年の投稿のみ取得
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    //エラー時にアラートを出す
                    PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "ロードに失敗しました。", subtitle: error?.localizedDescription)
                    PKHUD.sharedHUD.show()
                    PKHUD.sharedHUD.hide(afterDelay: 2.0)
                } else {
                    for postObject in result as! [NCMBObject]{
                        let postId = postObject.object(forKey: "objectId") as! String
                        let year = postObject.object(forKey: "year") as! Int
                        let movieUrl = postObject.object(forKey: "movieName") as! String
                        let postTitle = postObject.object(forKey: "postTitle") as! String

                        let post = Post(postId: postId, year: year, movieUrl: movieUrl, postTitle: postTitle)

                        thisYearsPost.append(post)
                    }

                    self.secPosts[i] = thisYearsPost
                    self.loadComment(secPostsKey: i)
                }

            })

        }

        // 投稿のデータが揃ったらTableViewをリロード
        self.timelineTableView.reloadData()
    }

    //最終コメントの日にちを読み込む
    func loadComment(secPostsKey: Int){
        let postsArray = secPosts[secPostsKey]!
        for post in postsArray {
            let postId = post.postId
            //最終コメント日時を拾ってくる
            var createDate: Date?
            
            let comQuery = NCMBQuery(className: "Comment")
            comQuery?.whereKey("postId", equalTo: postId)
            // 取ってきたデータを昇順（投稿が古い順）
            comQuery?.order(byAscending: "createDate")
            
            //できない
//            // 取ってきたデータを降順（投稿が新しい順）
//            comQuery?.order(byDescending: "createDate")
//            comQuery?.getFirstObjectInBackground({ (result, error) in
//                if error != nil {
//                    //エラー時にアラートを出す
//                    PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "ロード失敗", subtitle: error?.localizedDescription)
//                    PKHUD.sharedHUD.show()
//                    PKHUD.sharedHUD.hide(afterDelay: 2.0)
//                } else {
//                    let commentObject = result as! NCMBObject
//                    createDate = commentObject.createDate
//                }
//                post.lastCommentDate = createDate
//
//                if self.secPosts.count == self.sectionName.count{
//                    // 投稿のデータが揃ったらTableViewをリロード
//                    self.timelineTableView.reloadData()
//                }
//            })
            
            comQuery?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    //エラー時にアラートを出す
                    PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "コメントのロードに失敗しました。", subtitle: error?.localizedDescription)
                    PKHUD.sharedHUD.show()
                    PKHUD.sharedHUD.hide(afterDelay: 2.0)
                } else {
                    for commentObject in result as! [NCMBObject] {
                        createDate = commentObject.createDate
                    }
                }
                post.lastCommentDate = createDate
                
                if self.secPosts.count == self.sectionName.count{
                    // 投稿のデータが揃ったらTableViewをリロード
                    self.timelineTableView.reloadData()
                }
                
            })
        }
        
    }
    
    //引っ張ってタイムライン更新
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        timelineTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
//        self.loadPost()
        self.loadFromRealm()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
}

//アラートのカスタム
class CustomHUDView: PKHUDSquareBaseView {

    override init(image: UIImage?, title: String?, subtitle: String?) {
        super.init(image: image, title: title, subtitle: subtitle)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}


