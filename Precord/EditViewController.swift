//
//  EditViewController.swift
//  Precord
//
//  Created by Karen Shichijo on 2020/06/21.
//  Copyright © 2020 Karen Shichijo. All rights reserved.
//

import UIKit
import NCMB
import AVFoundation
import AVKit
import PKHUD

class EditViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet var selectedMovieImageView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var yearPickerView: UIPickerView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var playImageView: UIImageView!
    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var cameraButton: UIButton!
    
    //前の画面から持ってくる
    var receivedDB = DB()
    //    var postId: String!
    //    var movieName: String!
    //    var titleText: String!
    //    var year: Int!
    
    //変更後の値を入れる
    var newYear = 0
    var newText: String?
    var isNewMovie = false
    
    //yearPickerView
    let years = [Int](2000...2030)
    
    //動画撮影用の変数
    //    let sourceType = UIImagePickerController.SourceType.camera
    //    var movieInfo: URL?
    //    var movieTmpUrl: URL?
    //    var movieDocUrl: URL?
    
    var tmpUrl: URL?
    var docUrl: URL?
    var savedName: String?
    
    var infoURL: URL?
    
    //ライブラリからか
    var isLibrary = false
    //写真か動画か
    var isImage = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //初期値設定
        titleTextField.text = receivedDB.title
        
        //yearPickerViewのdelegate datasourceの設定
        yearPickerView.delegate = self
        yearPickerView.dataSource = self
        
        //yearPickerViewの初期値設定
        yearPickerView.selectRow(receivedDB.year, inComponent: 0, animated: false)
        
        //titleTextFieldのdelegate設定
        titleTextField.delegate = self
        
        newYear = receivedDB.year
        newText = receivedDB.title
        
        //saveボタン押せるか
        confirmContent()
        
        isImage = receivedDB.isImage
        
        memoTextView.layer.cornerRadius = 13.0
        memoTextView.layer.masksToBounds = true
        
        cameraButton.layer.cornerRadius = cameraButton.bounds.width / 2.0
        cameraButton.layer.masksToBounds = true
        
        //        // タイトルテキストの装飾設定
        //        self.navigationController?.navigationBar.titleTextAttributes = [
        //            // 文字の色
        //            .foregroundColor: UIColor(hex: 0x2A5F6A)
        //        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadThumbnail()
    }
    
    //動画撮影
    
    //撮影ボタンにつける
    @IBAction func record() {
        let alertController = UIAlertController(title: "写真/動画の撮影または選択", message: "写真/動画をカメラで撮影するかライブラリから選択するか選んでください。", preferredStyle: .actionSheet)
        let imageAction = UIAlertAction(title: "写真撮影", style: .default) { (action) in
            // 端末でカメラが利用可能か調べる
            let sourceType = UIImagePickerController.SourceType.camera
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = sourceType
                // ここで写真を選択
                //                pickerController.mediaTypes = ["public.image"]
                pickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType) ?? []
                // 動画を高画質で保存する
                //                pickerController.videoQuality = .typeHigh
                self.present(pickerController, animated: true, completion: nil)
                self.isLibrary = false
            }
        }
        
        let movieAction = UIAlertAction(title: "動画撮影", style: .default) { (action) in
            // 端末でカメラが利用可能か調べる
            let sourceType = UIImagePickerController.SourceType.camera
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = sourceType
                // ここで動画を選択
                pickerController.mediaTypes = ["public.movie"]
                // 動画を高画質で保存する
                pickerController.videoQuality = .typeHigh
                self.present(pickerController, animated: true, completion: nil)
                self.isLibrary = false
            }
        }
        
        let libraryAction = UIAlertAction(title: "ライブラリ", style: .default) { (action) in
            let sourceType = UIImagePickerController.SourceType.photoLibrary
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let pickerController = UIImagePickerController()
                pickerController.delegate = self
                pickerController.sourceType = sourceType
                // ここで動画を選択
                //                pickerController.mediaTypes = ["public.movie"]
                pickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: sourceType) ?? []
                self.present(pickerController, animated: true, completion: nil)
                self.isLibrary = true
            }
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            //アラートを消す
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(imageAction)
        alertController.addAction(movieAction)
        alertController.addAction(libraryAction)
        alertController.addAction(cancelAction)
        
        //アラートを表示する
        self.present(alertController, animated: true, completion: nil)
    }
    
    //保存関係　動画取り終わったときに呼ばれる
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if info[UIImagePickerController.InfoKey.mediaURL] as? URL != nil {
            //動画のURL
            infoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL
            isImage = false
        } else {
            //写真のURL
            infoURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
            isImage = true
        }
        
        
        
        //tmpに入っている要らないMOVを消去
        if tmpUrl != nil {
            do {
                try FileManager.default.removeItem(at: tmpUrl!)
            } catch {
                
            }
        }
        
        // 一時フォルダ(tmp)に保存されたファイルのURL
        guard let guardTmpUrl = infoURL else { return }
        tmpUrl = guardTmpUrl
        
        //        saveToIPhone()
        //        //端末のアルバムに動画を保存
        //        if let selectedMovie:URL = (movieInfo) {
        //            let selectorToCall = #selector(AddViewController.movieSaved(_:didFinishSavingWithError:context:))
        //            UISaveVideoAtPathToSavedPhotosAlbum(selectedMovie.relativePath, self, selectorToCall, nil)
        //        }
        
        if isImage == false {
            //動画だったら
            //サムネイル表示
            loadThumbnail()
            //再生ボタン表示
            playImageView.isHidden = false
            
        } else {
            //写真だったら
            selectedImagePicker()
            //再生ボタン非表示
            playImageView.isHidden = true
        }
        
        picker.dismiss(animated: true)
        
        isNewMovie = true
        //saveボタンを押せるようにする
        confirmContent()
    }
    
    func loadThumbnail(){
        var postMovieUrl: URL!
        if isNewMovie == false {
            // DocumentフォルダのURL
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            //MOVファイルのURL
            postMovieUrl = documentsDirectoryURL.appendingPathComponent(receivedDB.pictureUrl)
        } else {
            postMovieUrl = tmpUrl
        }
        
        let movieAVURLAsset = AVURLAsset(url:postMovieUrl)
        
        let generator = AVAssetImageGenerator(asset: movieAVURLAsset)
        generator.appliesPreferredTrackTransform = true
        // 今回は00:00の部分を切り出し
        let thumbnail = try! generator.copyCGImage(at: .zero, actualTime: nil)
        selectedMovieImageView.image = UIImage(cgImage: thumbnail)
    }
    
    func selectedImagePicker(){
        var postMovieUrl: URL!
        if isNewMovie == false {
            // DocumentフォルダのURL
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            //MOVファイルのURL
            postMovieUrl = documentsDirectoryURL.appendingPathComponent(receivedDB.pictureUrl)
        } else {
            postMovieUrl = tmpUrl
        }
        
        let uiImage = UIImage(contentsOfFile: postMovieUrl.path)!
        selectedMovieImageView.image = uiImage
    }
    
    //tmpに入っているMOVを削除して元の画面に戻る
    @IBAction func cancelButton(){
        
        if isNewMovie == true && isLibrary == false {
            let alertController = UIAlertController(title: "写真/動画が新規で撮影されています。", message: "保存せずに戻った場合この写真/動画は削除されます。", preferredStyle: .alert)
            
            let back = UIAlertAction(title: "保存せずに戻る", style: .destructive) { (action) in
                //tmp削除
                if self.tmpUrl != nil {
                    do {
                        //tmpに入っているMOVを消去
                        try FileManager.default.removeItem(at: self.tmpUrl!)
                    } catch {
                        
                    }
                }
                
                self.navigationController?.popViewController(animated: true)
            }
            
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                //アラートを消す
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(back)
            alertController.addAction(cancel)
            //アラートを表示する
            self.present(alertController, animated: true, completion: nil)
        } else if isNewMovie == true && isLibrary == true {
            let alertController = UIAlertController(title: "写真/動画が新規で選択されています。", message: "保存せずに戻った場合選択が解除されます。", preferredStyle: .alert)
            
            let back = UIAlertAction(title: "保存せずに戻る", style: .destructive) { (action) in
                //tmp削除
                if self.tmpUrl != nil {
                    do {
                        //tmpに入っているMOVを消去
                        try FileManager.default.removeItem(at: self.tmpUrl!)
                    } catch {
                        
                    }
                }
                
                self.navigationController?.popViewController(animated: true)
            }
            
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                //アラートを消す
                alertController.dismiss(animated: true, completion: nil)
            }
            
            alertController.addAction(back)
            alertController.addAction(cancel)
            //アラートを表示する
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func savebutton(){
        if isNewMovie == true {
            //Documents
            moveToDocuments()
        }
        //NCMB
        //        saveToNCMB()
        saveToRealm()
    }
    
    //MOVファイルをDocumentsに保存
    func moveToDocuments(){
        // DocumentフォルダのURL
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            //tmpに保存された動画をDocumentに移動
            try FileManager.default.moveItem(at: tmpUrl!, to: documentsDirectoryURL.appendingPathComponent(tmpUrl!.lastPathComponent))
            
            //ファイルネームを取得
            savedName = tmpUrl!.lastPathComponent
            
        }catch {
            print(error.localizedDescription)
        }
    }
    
    //realmへの保存
    func saveToRealm(){
        let db = DB.create()
        db.title = titleTextField.text!
        db.pictureUrl = savedName!
        db.year = newYear + 2000
        db.memo = memoTextView.text
        db.isImage = isImage
        DB.update(id: receivedDB.id, afterDB: db)
    }
    
    @IBAction func playMovie(_ sender: Any) {
        if isImage == false {
            var videoPlayer: AVPlayer!
            if isNewMovie == false {
                let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                //MOVファイルのURL
                let postMovieUrl = documentsDirectoryURL.appendingPathComponent(receivedDB.pictureUrl)
                videoPlayer = AVPlayer(url: postMovieUrl)
            } else {
                videoPlayer = AVPlayer(url: tmpUrl!)
            }
            
            let playerController = AVPlayerViewController()
            playerController.player = videoPlayer
            self.present(playerController, animated: true, completion: {
                videoPlayer.play()
            })
        }
    }
    
    //NCMBへ 上書き保存
//    func saveToNCMB(){
//        //上書き保存
//        let query = NCMBQuery(className: "Post")
//        query?.getObjectInBackground(withId: postId, block: { (post, error) in
//            if error != nil {
//                //エラー時にアラートを出す
//                PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "保存に失敗しました。", subtitle: error?.localizedDescription)
//                PKHUD.sharedHUD.show()
//                PKHUD.sharedHUD.hide(afterDelay: 2.0)
//            } else {
//                post?.setObject(self.movieName, forKey: "movieName")
//                post?.setObject(self.newText, forKey: "postTitle")
//                post?.setObject(self.newYear, forKey: "year")
//                post?.saveInBackground({ (error) in
//                    if error != nil {
//                        //エラー時にアラートを出す
//                        PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "保存に失敗しました。", subtitle: error?.localizedDescription)
//                        PKHUD.sharedHUD.show()
//                        PKHUD.sharedHUD.hide(afterDelay: 2.0)
//                    }
//                    //セクション
//                    self.sectionOperation()
//
//                })
//
//            }
//        })
//    }
    
    //セクション削除するか＆保存するか
    //    func sectionOperation(){
    //        //今まで投稿したものの中に同じ年の投稿があるか調べる
    //        let query = NCMBQuery(className: "Post")
    //        query?.whereKey("year", equalTo: year)
    //        query?.findObjectsInBackground({ (result, error) in
    //            var count = [Int]()
    //            if error != nil {
    //                //エラー時にアラートを出す
    //                PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "セクションの更新に失敗しました。", subtitle: error?.localizedDescription)
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
    //                yearSection.remove(value: self.year)
    //            }
    //
    //            //新しい年を追加するか
    //            //重複確認
    //            let ans = yearSection.filter{$0 == self.newYear}
    //            if ans == [] {
    //                yearSection.append(self.newYear)
    //            }
    //
    //            //大きい順にソートして保存
    //            yearSection.sort(by: > )
    //
    //            ud.set(yearSection, forKey: "yearSection")
    //
    //            //最初の画面に遷移
    //            self.navigationController?.popToRootViewController(animated: true)
    //        })
    //
    //    }
    
    
    
    
    //yearPickerView
    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        years.count
    }
    
    // UIPickerViewに表示される内容
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(years[row])+" 年"
    }
    
    // UIPickerViewのRowが選択された時の挙動 何列目（何年）が選択されたかをnewYearに入れる
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {
        newYear = row
        confirmContent()
    }
    
    //その他
    
    //テキストが書かれていて写真が選ばれていたらsaveボタンを押せるようにする
    func confirmContent() {
        if titleTextField.text!.count > 0 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    
    //saveボタンを押せるようにする
    func textFieldDidChangeSelection(_ textField: UITextField) {
        newText = titleTextField.text
        confirmContent()
    }
    
    //エンターでテキストフィールドを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension Array where Element: Equatable {
    mutating func remove(value: Element) {
        if let i = self.firstIndex(of: value) {
            self.remove(at: i)
        }
    }
}
