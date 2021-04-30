//
//  AddViewController.swift
//  Precord
//
//  Created by Karen Shichijo on 2020/06/21.
//  Copyright © 2020 Karen Shichijo. All rights reserved.
//

import UIKit
import NCMB
import AVFoundation
import AVKit
import Photos
import NYXImagesKit
import PKHUD
//import Realm
//import RealmSwift

class AddViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate{
    
    
    @IBOutlet var selectedMovieImageView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var yearPickerView: UIPickerView!
    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var playImageView: UIImageView!
    @IBOutlet var memoTextView: UITextView!
    @IBOutlet var cameraButton: UIButton!
    //userDefaultsの確保
    let ud = UserDefaults.standard
    
    //動画の撮影に使う変数
//    var movieTmpUrl: URL?
//    var movieDocUrl: URL?
//    var movieName: String?
//    var sourceType = UIImagePickerController.SourceType.camera
    var tmpUrl: URL?
    var docUrl: URL?
    var savedName: String?

    var infoURL: URL?
    
    //写真/動画があるか
    var isPicture = false
    
    //ライブラリからか
    var isLibrary = false
    
    //写真か動画か
    var isImage = false
    
    //placefolder
    let placeholderImage = UIImage(named: "placeholder.png")
    
    //yearPickerView
    let years = [Int](2000...2030)
    var selectedYear = 0
    
    
    
    //postImageViewにplaceholderImageを表示
    //yearPickerViewのdelegate datasourceの設定
    //yearPickerViewの初期値設定
    //titleTextFieldのdelegate設定
    //saveボタンを押せるようにする
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //postImageViewにplaceholderImageを表示
        selectedMovieImageView.image = placeholderImage
        
        //yearPickerViewのdelegate datasourceの設定
        yearPickerView.delegate = self
        yearPickerView.dataSource = self
        
        //yearPickerViewの初期値設定
        selectedYear = ud.integer(forKey: "selectedYear")
        
        yearPickerView.selectRow(selectedYear, inComponent: 0, animated: false)
        
        //titleTextFieldのdelegate設定
        titleTextField.delegate = self
        
        //動画があるか
        isPicture = false
        
        //saveボタンを押せるようにする
        confirmContent()
        
        //        // タイトルテキストの装飾設定
        //        self.navigationController?.navigationBar.titleTextAttributes = [
        //            // 文字の色
        //            .foregroundColor: UIColor(hex: 0x2A5F6A)
        //        ]
        
        //navigationControllerのdelegateの設定
        navigationController?.delegate = self
        
        memoTextView.layer.cornerRadius = 13.0
        memoTextView.layer.masksToBounds = true
        
        cameraButton.layer.cornerRadius = cameraButton.bounds.width / 2.0
        cameraButton.layer.masksToBounds = true
    }
    
    //動画の撮影・保存
    
    //撮影ボタンにつける
    @IBAction func record() {
        // 端末でカメラが利用可能か調べる
        //        if UIImagePickerController.isSourceTypeAvailable(self.sourceType) {
        //            let pickerController = UIImagePickerController()
        //            pickerController.delegate = self
        //            pickerController.sourceType = self.sourceType
        //            // ここで動画を選択
        //            pickerController.mediaTypes = ["public.movie"]
        ////            pickerController.mediaTypes = ["public.image"]
        //            // 動画を高画質で保存する
        //            pickerController.videoQuality = .typeHigh
        //            self.present(pickerController, animated: true, completion: nil)
        //        }
        
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
            selectedMovieImagePicker()
            //再生ボタン表示
            playImageView.isHidden = false
            
        } else {
            //写真だったら
//            selectedMovieImageView.image = info[.originalImage] as? UIImage
            selectedImagePicker()
            //再生ボタン非表示
            playImageView.isHidden = true
        }
        
        picker.dismiss(animated: true)
        
        isPicture = true
        //saveボタンを押せるようにする
        confirmContent()
    }
    
    //Saveボタンを押すとNCMBに保存される → 前の画面に戻る
    @IBAction func savebutton(){
        //        saveToIPhone()
        moveToDocuments()
//        saveToNCMB()
        saveToRealm()
        
//        //セクション分けするためにyearをyearSectionに保存する
//        var yearSection = [Int]()
//        if ud.array(forKey: "yearSection") != nil {
//            yearSection = ud.array(forKey: "yearSection") as! [Int]
//        }
//        
//        //重複確認
//        let ans = yearSection.filter{$0 == selectedYear}
//        if ans == [] {
//            yearSection.append(selectedYear)
//        }
//        
//        //大きい順にソート
//        yearSection.sort(by: > )
//        ud.set(yearSection, forKey: "yearSection")
        
        //selectedYearの保存
        saveSelectedYear()
        
        self.navigationController?.popViewController(animated: true)
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
    
    //NCMBへの保存
    func saveToNCMB(){
        let postObject = NCMBObject(className: "Post")
        postObject?.setObject(NCMBUser.current(), forKey: "postUser")
        postObject?.setObject(savedName, forKey: "movieName")
        postObject?.setObject(titleTextField.text, forKey: "postTitle")
        postObject?.setObject(selectedYear, forKey: "year")
        postObject?.saveInBackground({ (error) in
            if error != nil {
                //エラー時にアラートを出す
                PKHUD.sharedHUD.contentView = CustomHUDView(image: PKHUDAssets.crossImage, title: "保存に失敗しました。", subtitle: error?.localizedDescription)
                PKHUD.sharedHUD.show()
                PKHUD.sharedHUD.hide(afterDelay: 2.0)
            }
        })
    }
    
    //realmへの保存
    func saveToRealm(){
        let db = DB.create()
        db.title = titleTextField.text!
        db.pictureUrl = savedName!
        db.year = selectedYear + 2000
        db.memo = memoTextView.text
        db.isImage = isImage
        db.save()
    }
    
    //できない
    func saveToIPhone(){
        if let selectedMovie:URL = (infoURL) {
            let selectorToCall = #selector(AddViewController.movieSaved(_:didFinishSavingWithError:context:))
            UISaveVideoAtPathToSavedPhotosAlbum(selectedMovie.relativePath, self, selectorToCall, nil)
        }
    }
    
    //↑で使ってる　保存
    @objc func movieSaved(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        if let theError = error {
            print("error saving the movie = \(theError)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
            })
        }
    }
    
    //サムネイル表示
    func selectedMovieImagePicker(){
        if tmpUrl != nil {
            
            let url = AVURLAsset(url: tmpUrl!)
            
            // 動画から静止画を切り出すジェネレータ
            let generator = AVAssetImageGenerator(asset: url)
            //動画のとった向きに合わせたサムネイルにする
            generator.appliesPreferredTrackTransform = true
            
            // 今回は00:00の部分を切り出し
            let thumbnail = try! generator.copyCGImage(at: .zero, actualTime: nil)
            //サムネイルを表示
            let UIImageThumbnail = UIImage(cgImage: thumbnail)
            
            //サムネイルを表示
            selectedMovieImageView.image = UIImageThumbnail
            
        }
    }
    
    func selectedImagePicker(){
        if tmpUrl != nil {
             //.pathプロパティを引数に画像読み込み
            let uiImage = UIImage(contentsOfFile: tmpUrl!.path)
            selectedMovieImageView.image = uiImage
        }
    }
    
    @IBAction func back(){
        if isPicture == true && isLibrary == false {
            let alertController = UIAlertController(title: "写真/動画が撮影されています。", message: "保存せずに戻った場合この写真/動画は削除されます。", preferredStyle: .alert)
            
            let back = UIAlertAction(title: "保存せずに戻る", style: .destructive) { (action) in
                //tmp削除
                if self.tmpUrl != nil {
                    do {
                        //tmpに入っているMOVを消去
                        try FileManager.default.removeItem(at: self.tmpUrl!)
                    } catch {
                        
                    }
                }
                
                //selectedYearの保存
                self.saveSelectedYear()
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
        } else if isPicture == true && isLibrary == true {
            let alertController = UIAlertController(title: "写真/動画が選択されています。", message: "保存せずに戻った場合選択が解除されます。", preferredStyle: .alert)
            
            let back = UIAlertAction(title: "保存せずに戻る", style: .destructive) { (action) in
                //tmp削除
                if self.tmpUrl != nil {
                    do {
                        //tmpに入っているMOVを消去
                        try FileManager.default.removeItem(at: self.tmpUrl!)
                    } catch {
                        
                    }
                }
                
                //selectedYearの保存
                self.saveSelectedYear()
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
    
    //戻る時呼ばれる
//    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
//        if viewController is ViewController {
//
//            //tmp削除
//            if self.tmpUrl != nil {
//                do {
//                    //tmpに入っているMOVを消去
//                    try FileManager.default.removeItem(at: self.tmpUrl!)
//                } catch {
//
//                }
//            }
//
//            //selectedYearの保存
//            self.saveSelectedYear()
//
////            if isPicture == true {
////                let alertController = UIAlertController(title: "動画が撮影されています。", message: "保存せずに戻った場合この動画は削除されます。", preferredStyle: .alert)
////
////                let back = UIAlertAction(title: "保存せずに戻る", style: .destructive) { (action) in
////                    //tmp削除
////                    if self.tmpUrl != nil {
////                        do {
////                            //tmpに入っているMOVを消去
////                            try FileManager.default.removeItem(at: self.tmpUrl!)
////                        } catch {
////
////                        }
////                    }
////
////                    //selectedYearの保存
////                    self.saveSelectedYear()
////                    self.navigationController?.popViewController(animated: true)
////                }
////
////                let cancel = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
////                    //アラートを消す
////                    alertController.dismiss(animated: true, completion: nil)
////                    //画面遷移のキャンセル
////                }
////
////                alertController.addAction(back)
////
////            }
//
//
//        }
//    }
    
    //動画の再生
    @IBAction func tapImage(_ sender: Any) {
        if tmpUrl != nil && isImage == false {
            let videoPlayer = AVPlayer(url: tmpUrl!)
            let playerController = AVPlayerViewController()
            playerController.player = videoPlayer
            self.present(playerController, animated: true, completion: {
                videoPlayer.play()
            })
        }
    }
    
    
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
    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int) -> String? {
        
        return String(years[row])+" 年"
    }
    
    // UIPickerViewのRowが選択された時の挙動 何列目（何年）が選択されたかをselectedYearに入れる
    func pickerView(_ pickerView: UIPickerView,didSelectRow row: Int,inComponent component: Int) {
        selectedYear = row
    }
    
    //その他
    
    //saveボタンを押せるようにする
    func textFieldDidChangeSelection(_ textField: UITextField) {
        confirmContent()
    }
    
    //エンターでテキストフィールドを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //テキストが書かれていて写真が選ばれていたらsaveボタンを押せるようにする
    func confirmContent() {
        if titleTextField.text!.count > 0 && isPicture == true {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    func saveSelectedYear() {
        ud.set(selectedYear, forKey: "selectedYear")
    }
    
}


