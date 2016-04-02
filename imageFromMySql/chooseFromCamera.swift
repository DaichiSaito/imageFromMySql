//
//  chooseFromCamera.swift
//  NailApp
//
//  Created by DaichiSaito on 2016/03/09.
//  Copyright © 2016年 DaichiSaito. All rights reserved.
//

import UIKit
class chooseFromCamera: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var imageForUpload = UIImageView()
    func uploadImages() {
        
        let photoLibrary = UIImagePickerControllerSourceType.PhotoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.sourceType = photoLibrary
            picker.delegate = self
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if info[UIImagePickerControllerOriginalImage] != nil {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            //iamgeForUploadというUIImageを用意しておいてそこに一旦預ける
            self.imageForUpload.image = image
//            self.AFNetworkingUploadRequest()
            self.myImageUploadRequest()
        }
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }
    //画像のアップロード処理
    func myImageUploadRequest(){
        //myUrlには自分で用意したphpファイルのアドレスを入れる
        let myUrl = NSURL(string:"http://test.localhost/uploadToFileServer.php")
//        let myUrl = NSURL(string:"http://dsh4k2h4k2.esy.es/uploadTest4.php")
        let request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "POST"
        
        let parentVC :ViewController = (self.parentViewController as? ViewController)!
//        vc.test = "hogehoge"
        
        let customerId = parentVC.customerId.text;
        print(customerId)
        //下記のパラメータはあくまでもPOSTの例
        let param = [
            "customerId" : customerId!
        ]
        let boundary = generateBoundaryString()
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = UIImageJPEGRepresentation(self.imageForUpload.image!, 1)
        if(imageData==nil) { return; }
        request.HTTPBody = createBodyWithParameters(param, filePathKey: "file", imageDataKey: imageData!, boundary: boundary)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            if error != nil {
                print("error=\(error)")
                return
            }
            // レスポンスを出力
            print("******* response = \(response)")
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("****** response data = \(responseString!)")
            dispatch_async(dispatch_get_main_queue(),{
                //アップロード完了
            });
        }
        task.resume()
        
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().UUIDString)"
    }
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> NSData {
        var body = NSMutableData()
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        let filename = "image(1).jpg"
        let mimetype = "image/jpg"
        body.appendString("--\(boundary)\r\n")
        // filePathKeyという識別しに対応するのがfilenameという変数
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.appendData(imageDataKey)
        body.appendString("\r\n")
        body.appendString("--\(boundary)--\r\n")
        return body
    }
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        
//        
//        
//        
//        
//        if info[UIImagePickerControllerOriginalImage] != nil {
//            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//            var imageForUpload = UIImageView()
//            //iamgeForUploadというUIImageを用意しておいてそこに一旦預ける
//            imageForUpload.image = image
//            // 画像をリサイズしてUIImageViewにセット
//            var resizeImage = resize(image, width: 480, height: 320)
//            imageForUpload.image = resizeImage
//            //            imageView.image = resizeImage
//            //            self.message?.hidden = true
//            //保存対象の画像ファイルを作成する
//            let imageData: NSData = UIImagePNGRepresentation(resizeImage)!
//            let targetFile = NCMBFile.fileWithData(imageData) as! NCMBFile
//            //新規データを1件登録する
//            var saveError: NSError? = nil
//            let obj: NCMBObject = NCMBObject(className: "MemoClass")
//            obj.setObject("title!", forKey: "title")
//            obj.setObject(targetFile.name, forKey: "filename")
//            obj.setObject(800, forKey: "money")
//            obj.setObject("comment!", forKey: "comment")
//            obj.setObject(false, forKey: "favFlg")
//            obj.save(&saveError)
//            
//            //ファイルはバックグラウンド実行をする
//            targetFile.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
//                
//                if error == nil {
//                    print("画像データ保存完了: \(targetFile.name)")
//                } else {
//                    print("アップロード中にエラーが発生しました: \(error)")
//                }
//                
//                }, progressBlock: { (percentDone: Int32) -> Void in
//                    
//                    // 進捗状況を取得します。保存完了まで何度も呼ばれます
//                    print("進捗状況: \(percentDone)% アップロード済み")
//            })
//            
//            if saveError == nil {
//                print("success save data.")
//            } else {
//                print("failure save data. \(saveError)")
//            }
//        }
//        
//        //            self.myImageUploadRequest()
//        
//        picker.dismissViewControllerAnimated(true, completion: nil)
//        
//    }
    
    // 画像をリサイズ
    func resize(image: UIImage, width: Int, height: Int) -> UIImage {
        let imageRef: CGImageRef = image.CGImage!
        var sourceWidth: Int = CGImageGetWidth(imageRef)
        var sourceHeight: Int = CGImageGetHeight(imageRef)
        
        var size: CGSize = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
        var resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
    }
    
    
}
