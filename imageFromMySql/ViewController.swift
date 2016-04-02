//
//  ViewController.swift
//  imageFromMySql
//
//  Created by DaichiSaito on 2016/04/02.
//  Copyright © 2016年 DaichiSaito. All rights reserved.
//

import UIKit
extension NSMutableData {
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}
class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var imageInfo = [];

    @IBAction func loadView(sender: AnyObject) {
        loadView()
        viewDidLoad()
    }
    @IBOutlet weak var customerId: UITextField!
    @IBAction func loadMySql(sender: AnyObject) {
        
        //myUrlには自分で用意したphpファイルのアドレスを入れる
        let myUrl = NSURL(string:"http://test.localhost/loadFromMySql.php")
        let request = NSMutableURLRequest(URL:myUrl!)
        request.HTTPMethod = "POST"
        
        let customerId = self.customerId.text;
        print(customerId!)
        //下記のパラメータはあくまでもPOSTの例
        let param = [
            "customerId" : customerId!
        ]

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(param, options: [])
            
        } catch {
            
        }
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
//            var json:NSDictionary = [:]
            do {
                self.imageInfo = try NSJSONSerialization.JSONObjectWithData(data!,
                                                                  options: NSJSONReadingOptions.MutableContainers) as! NSArray
            } catch {
                
            }
            print("-------")
            print(self.imageInfo)
            print((self.imageInfo[0]["imagePath"]))
//            print(self.imageInfo)
//            imageInfo = json;
            dispatch_async(dispatch_get_main_queue(),{
                
            });
        }
        task.resume()
        
        
        
        
//        let myUrl = NSURL(string:"http://test.localhost/uploadToFileServer.php")
//        let request = NSMutableURLRequest(URL:myUrl!)
//        request.HTTPMethod = "POST"
////        let uri = NSURL(string: json)
////        let uridata = NSData(contentsOfURL: uri!)
////        let objects = uridata!.objectFromJSONData() as! NSDictionary
////        let array = objects.objectForKey("images") as! [String]
////        data += array
//        let param = [
//            "customerId" : customerId!
//        ]
    }
    @IBAction func uploadButton(sender: AnyObject) {
        let chooseFromCameraInstanse: chooseFromCamera = chooseFromCamera()
        self.addChildViewController(chooseFromCameraInstanse)

        chooseFromCameraInstanse.uploadImages()


    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("self.imageInfo.countは：")
        print(self.imageInfo.count)
        return self.imageInfo.count;
//        return self.memoArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        print("collectionViewの設定開始")
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! MyCollectionViewCell
//        //各値をセルに入れる
        let targetImageData: NSDictionary = self.imageInfo[indexPath.row] as! NSDictionary
        let url = NSURL(string: targetImageData["imagePath"] as! String)
        
//        let url = NSURL(targetImageData
        let placeholder = UIImage(named: "transparent.png")
        cell.image!.setImageWithURL(url, placeholderImage: placeholder)

        return cell
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //        let width: CGFloat = self.view.frame.width / 3 - 2
        //        let width: CGFloat = self.view.frame.width / 3 - 2
        let width: CGFloat = super.view.frame.width / 3 - 6
        print(width)
        let height: CGFloat = width
        return CGSize(width: width, height: height) // The size of one cell
        
    }
    
    
}

