//
//  DetailViewController.swift
//  Precord
//
//  Created by Karen Shichijo on 2020/06/21.
//  Copyright © 2020 Karen Shichijo. All rights reserved.
//

import UIKit
import NCMB
import AVKit
import PKHUD

class DetailViewController: UIViewController,UITableViewDataSource, UITextViewDelegate, UITableViewDelegate {

    @IBOutlet var commentTableView: UITableView!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var postedMovieImageView: UIImageView!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var postButton: UIButton!
    
//    var postId: String!
//    var movieName: String!
//    var titleText: String!
//    var yearSec: Int!
//
    var Url: URL!
    
    var comments = [Comment]()
    
    var receivedDB = DB()

    //yearLabelに年表示
    //commentTableViewのdataSourceの設定
    //commentTextViewのdelegateの設定
    //コメント投稿ボタンを押せなくする
    //カスタムセルの登録
    //tableViewのフッターの不要な線を消す
    //サムネイル表示
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //yearLabelに年表示
//        let year = String(yearSec + 2000)
//        yearLabel.text = year
        
        yearLabel.text = String(receivedDB.year)
        
        //commentTableViewのdataSource,delegateの設定
        commentTableView.dataSource = self
        commentTableView.delegate = self
        
        //commentTextViewのdelegateの設定
        commentTextView.delegate = self
        
        //コメント投稿ボタンを押せなくする
        postButton.isEnabled = false
        
        //カスタムセルの登録
        let nib = UINib(nibName: "CommentTableViewCell", bundle: Bundle.main)
        commentTableView.register(nib, forCellReuseIdentifier: "CommentCell")
        
        //タイトル表示
        navigationItem.title = receivedDB.title
        
        //サムネイル表示
        loadImage()
        
        // 枠を角丸にする
        commentTextView.layer.cornerRadius = 15.0
        commentTextView.layer.masksToBounds = true
        
        //セルの高さを可変に
        commentTableView.estimatedRowHeight = 200
        commentTableView.rowHeight = UITableView.automaticDimension
        
//        // タイトルテキストの装飾設定
//           self.navigationController?.navigationBar.titleTextAttributes = [
//               // 文字の色
//               .foregroundColor: UIColor(hex: 0x2A5F6A)
//           ]
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadComments()
    }
    

    
    func toEdit() {
        let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "editView") as! EditViewController
        //postIdを詳細画面に送る
        editViewController.receivedDB = receivedDB
//        editViewController.postId = postId
//        editViewController.movieName = movieName
//        editViewController.titleText = titleText
//        editViewController.year = yearSec
        self.navigationController?.pushViewController(editViewController, animated: true)
//        editViewController.modalPresentationStyle = .fullScreen
//        self.present(editViewController, animated: true, completion: nil)
    }
    
    //テキストを編集したら呼ばれる関数？
    func textViewDidChange(_ textView: UITextView) {
        confirmContent()
    }
    
    //生成するセルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    //セルに入れる内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cellにカスタムセルを入れる
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
        
        //timeLabel
        cell.timeLabel.text = receivedDB.comments[indexPath.row].createDateText
//        let commentDate = comments[indexPath.row].createDate
//        //表示の仕方　2020/7/2 の形式に
//        let f = DateFormatter()
//        f.timeStyle = .none
//        f.dateStyle = .medium
//        f.locale = Locale(identifier: "ja_JP")
//        let commentDateText = f.string(from: commentDate)
//        cell.timeLabel.text = commentDateText
          
        //commentTextView
//        cell.commentTextView.text = comments[indexPath.row].commentText
        
        //commentLabel
        cell.commentLabel.text = receivedDB.comments[indexPath.row].text
        
        return cell
    }
    
    //セルがタップされたとき
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "コメントを削除しますか？", message: "この操作によりこのコメントは削除されます。", preferredStyle: .alert)
        let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
            
            Com.delete(deleateCom: self.receivedDB.comments[indexPath.row])
            
//            let query = NCMBQuery(className: "Comment")
//            query?.getObjectInBackground(withId: self.comments[indexPath.row].commentId, block: { (result, error) in
//                if error != nil {
//                    //エラー時にアラートを出す
//                    PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "コメントの削除に失敗しました。", subtitle: error?.localizedDescription)
//                    PKHUD.sharedHUD.show()
//                    PKHUD.sharedHUD.hide(afterDelay: 2.0)
//                } else {
//                    result?.deleteInBackground({ (error) in
//                        if error != nil {
//                            //エラー時にアラートを出す
//                            PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "コメントの削除に失敗しました。", subtitle: error?.localizedDescription)
//                            PKHUD.sharedHUD.show()
//                            PKHUD.sharedHUD.hide(afterDelay: 2.0)
//                        } else {
//                            self.loadComments()
//                        }
//                    })
//                }
//            })
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            //アラートを消す
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(delete)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
        commentTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func loadImage(){
        // DocumentフォルダのURL
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        //MOVファイルのURL
        Url = documentsDirectoryURL.appendingPathComponent(receivedDB.pictureUrl)
        
        if receivedDB.isImage == false {
            let movieAVURLAsset = AVURLAsset(url:Url)

            let generator = AVAssetImageGenerator(asset: movieAVURLAsset)
            generator.appliesPreferredTrackTransform = true
            // 今回は00:00の部分を切り出し
            let thumbnail = try! generator.copyCGImage(at: .zero, actualTime: nil)
            postedMovieImageView.image = UIImage(cgImage: thumbnail)
        } else {
            //写真の場合
            let uiImage = UIImage(contentsOfFile: Url.path)!.scale(byFactor: 0.3)
            postedMovieImageView.image = uiImage
        }
        
    }
    
    //動画再生
    @IBAction func playMovie(_ sender: Any) {
        let videoPlayer = AVPlayer(url: Url)
        let playerController = AVPlayerViewController()
        playerController.player = videoPlayer
        self.present(playerController, animated: true, completion: {
            videoPlayer.play()
        })
    }

    
    @IBAction func saveComment(){
        
        DB.addComment(thisDB: receivedDB, commentText: commentTextView.text)
        
//        let commentObject = NCMBObject(className: "Comment")
//        commentObject?.setObject(postId, forKey: "postId")
//        commentObject?.setObject(commentTextView.text, forKey: "commentText")
//        commentObject?.saveInBackground({ (error) in
//            if error != nil {
//                //エラー時にアラートを出す
//                PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "コメントが投稿できませんでした。", subtitle: error?.localizedDescription)
//                PKHUD.sharedHUD.show()
//                PKHUD.sharedHUD.hide(afterDelay: 2.0)
//            } else {
//                self.commentTextView.text = nil
//            }
//            self.loadComments()
//        })
    }
    
    func loadComments(){
        
        //投稿のデータが揃ったらTableViewをリロード
        self.commentTableView.reloadData()
        //commentTableViewを一番下にスクロールする
        self.scrollComment()
        
        
//        let query = NCMBQuery(className: "Comment")
//
//        query?.whereKey("postId", equalTo: postId)
//        // 取ってきたデータを昇順（投稿が古い順）
//        query?.order(byAscending: "createDate")
//
//        //初期化
//        comments = []
//
//        query?.findObjectsInBackground({ (result, error) in
//            if error != nil {
//                //エラー時にアラートを出す
//                PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "コメントのロードに失敗しました。", subtitle: error?.localizedDescription)
//                PKHUD.sharedHUD.show()
//                PKHUD.sharedHUD.hide(afterDelay: 2.0)
//            } else {
//                for commentObject in result as! [NCMBObject]{
//                    let commentText = commentObject.object(forKey: "commentText") as! String
//
//                    let comment = Comment(commentId: commentObject.objectId, commentText: commentText, createDate: commentObject.createDate)
//
//                    self.comments.append(comment)
//                }
//            }
//            // 投稿のデータが揃ったらTableViewをリロード
//            self.commentTableView.reloadData()
//            //commentTableViewを一番下にスクロールする
//            self.scrollComment()
//        })
    }

    //自作関数　テキストが書かれていて写真が選ばれていたら投稿するボタンを押せるようにする
    func confirmContent() {
        if commentTextView.text.count > 0 {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
    }

    @IBAction func editPost(){
        let alertController = UIAlertController(title: "メニュー", message: "メニューを選択してください。", preferredStyle: .actionSheet)
        
        //編集画面に遷移
        let editAction = UIAlertAction(title: "編集", style: .default) { (action) in
            self.toEdit()
        }
        
        //諸々削除
        let deleteAction = UIAlertAction(title: "削除", style: .destructive) { (action) in
            //削除確認のアラート
            let alert = UIAlertController(title: "投稿を削除しますか？", message: "この操作により動画およびコメントの全てが削除されます。", preferredStyle: .alert)
            //Postの投稿、Documentsの動画、Comment全部を消す
            let delete = UIAlertAction(title: "削除", style: .destructive) { (action) in
                DB.delete(thisDB: self.receivedDB)
                //最初の画面に遷移
                self.navigationController?.popToRootViewController(animated: true)
                //投稿の削除
//                let query = NCMBQuery(className: "Post")
//                query?.getObjectInBackground(withId: self.postId, block: { (post, error) in
//                    if error != nil {
//                        //エラー時にアラートを出す
//                        PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "削除に失敗しました。", subtitle: error?.localizedDescription)
//                        PKHUD.sharedHUD.show()
//                        PKHUD.sharedHUD.hide(afterDelay: 2.0)
//                    } else {
//                        // 取得した投稿オブジェクトを削除
//                        post?.deleteInBackground({ (error) in
//                            if error != nil {
//                                //エラー時にアラートを出す
//                                PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "削除に失敗しました。", subtitle: error?.localizedDescription)
//                                PKHUD.sharedHUD.show()
//                                PKHUD.sharedHUD.hide(afterDelay: 2.0)
//                            } else {
//                                do {
//                                    try FileManager.default.removeItem(at: self.postMovieUrl)
//                                } catch {
//                                }
//                                //コメントの削除
//                                let commentQuery = NCMBQuery(className: "Comment")
//                                for comment in self.comments {
//                                    commentQuery?.getObjectInBackground(withId: comment.commentId, block: { (com, error) in
//                                        if error != nil {
//                                            //エラー時にアラートを出す
//                                            PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "コメントの削除に失敗しました。", subtitle: error?.localizedDescription)
//                                            PKHUD.sharedHUD.show()
//                                            PKHUD.sharedHUD.hide(afterDelay: 2.0)
//                                        } else {
//                                            //取得したコメントオブジェクトを削除
//                                            com?.deleteInBackground({ (error) in
//                                                if error != nil {
//                                                    //エラー時にアラートを出す
//                                                    PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "コメントの削除に失敗しました。", subtitle: error?.localizedDescription)
//                                                    PKHUD.sharedHUD.show()
//                                                    PKHUD.sharedHUD.hide(afterDelay: 2.0)
//                                                }
//                                            })
//                                        }
//                                    })
//                                }
//
//                                //セクションの管理
//                                self.sectionOperation()
//                            }
//                        })
//                    }
//                })
            }
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                //アラートを消す
                alert.dismiss(animated: true, completion: nil)
            }
            
            alert.addAction(delete)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            //アラートを消す
            alertController.dismiss(animated: true, completion: nil)
        }
        
        //作った編集ボタンと削除ボタンとキャンセルボタンをアラートに追加する
        alertController.addAction(editAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        //アラートを表示する
        self.present(alertController, animated: true, completion: nil)
    }
    
    //セクション削除するか＆保存するか
//    func sectionOperation(){
//        //今まで投稿したものの中に同じ年の投稿があるか調べる
//        let query = NCMBQuery(className: "Post")
//        query?.whereKey("year", equalTo: yearSec)
//        query?.findObjectsInBackground({ (result, error) in
//            var count = [Int]()
//            if error != nil {
//                //エラー時にアラートを出す
//                PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "セクションの削除に失敗しました。", subtitle: error?.localizedDescription)
//                PKHUD.sharedHUD.show()
//                PKHUD.sharedHUD.hide(afterDelay: 2.0)
//            } else {
//                for postObject in result as! [NCMBObject]{
//                    let yearForCount = postObject.object(forKey: "year") as! Int
//                    count.append(yearForCount)
//                }
//            }
//
//            //セクションの配列をユーザーデフォルトから読み込む
//            //セクション分けするためにyearをyearSectionに保存する
//            var yearSection = [Int]()
//            //userDefaultsの確保
//            let ud = UserDefaults.standard
//            yearSection = ud.array(forKey: "yearSection") as! [Int]
//
//            print(count)
//            print(yearSection)
//            //同じ年の投稿が他になかったら
//            if count == []{
//                //セクションの配列からこの年を削除
//                yearSection.remove(value: self.yearSec)
//            }
//
//
//            ud.set(yearSection, forKey: "yearSection")
//
//            //最初の画面に遷移
//            self.navigationController?.popToRootViewController(animated: true)
//        })
//
//    }
    
    //commentTableViewを一番下にスクロールする
    func scrollComment() {
        if receivedDB.comments.count > 0 {
            commentTableView.scrollToRow(at: IndexPath(row: receivedDB.comments.count - 1, section: 0), at: .bottom, animated: false)
        }
    }
    
}

extension UIColor {
    /// 16進カラーコードでカラーを生成
    ///
    /// - Parameters:
    ///   - hex: 16進カラーコード
    ///   - alpha: アルファ値
    convenience init(hex: UInt, alpha: CGFloat = 1.0) {
        let red: CGFloat = CGFloat((hex & 0xFF0000) >> 16) / 255.0
        let green: CGFloat = CGFloat((hex & 0x00FF00) >> 8) / 255.0
        let blue: CGFloat = CGFloat(hex & 0x0000FF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
