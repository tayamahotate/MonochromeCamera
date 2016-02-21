//
//  ViewController.swift
//  MonochromeCamera
//
//  Created by 田山　由理 on 2016/02/12.
//  Copyright © 2016年 Yuri Tayama. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var myImageView: UIImageView!
    var originalImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //タップされたらImagePickerを表示させる
    @IBAction func handleTap(sender: UITapGestureRecognizer) {
        //＊1:UIImagePickerが使用可能か判定
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        {
            let imgPickCtl:UIImagePickerController = UIImagePickerController();
            //＊2:デリゲートの委譲先とソースタイプを指定
            imgPickCtl.delegate = self
            imgPickCtl.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            //＊３：UIImagePickerControllerのPhotoLibraryを表示
            self.presentViewController(imgPickCtl, animated:true, completion:nil)
        }
    }

    // ImagePicker で画像が選択された時に呼ばれる処理
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if info[UIImagePickerControllerOriginalImage] != nil {
            
            // 選択した画像をImageViewに設定
            myImageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            // 加工用に変数を作成
            originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        
        // ImagePickerを閉じる
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func monochromeButton(sender: UIButton) {

        //＊1:画像が選択されていることを確認
        guard let image = myImageView.image else {
            return
        }
        
        //画像を渡してモノクロ化
        let monochromeimage = monochromeImage(image)
        
        //imageViewにモノクロ化した画像を設定
        myImageView.image = monochromeimage
        //輝度調節へ渡すように変数を作成
        originalImage = monochromeimage
    }
    
    //UIImage型の画像を引数として受け取り、最終的にUIImage型で返す
    func monochromeImage(srcImage: UIImage) -> UIImage {
        
        //UIImageからCIImageを作成
        let ciImage:CIImage = CIImage(image:srcImage)!;
        
        //コンテキストを作成
        let ciContext:CIContext = CIContext(options:nil)
        
        //フィルターを作成
        let ciFilter:CIFilter = CIFilter(name: "CIMinimumComponent")!
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        
        //フィルターを通した画像を生成
        let cgImage:CGImageRef = ciContext.createCGImage(ciFilter.outputImage!, fromRect:ciFilter.outputImage!.extent)
        
        //CGImageRefからUIImageを生成して返す
        return UIImage(CGImage: cgImage, scale: 1.0, orientation:UIImageOrientation.Up)
        
    }
    
    @IBAction func valueChangeSlider(sender: UISlider) {

        //スライダーを操作した時に呼ばれる
        guard let image = originalImage else {
            return
        }
        
        myImageView.image = brightnessImage(image, brightness: CGFloat(sender.value))
    }
    
    //引数のUIImage画像を輝度調節処理を行った後UIImageで返す
    func brightnessImage (srcImage: UIImage, brightness: CGFloat) -> UIImage {
        
        //UIImageからCIImageを作成
        let ciImage :CIImage = CIImage(image:srcImage)!;
        
        //コンテキストを作成
        let ciContext:CIContext = CIContext(options:nil)
        
        //フィルターを作成
        let ciFilter:CIFilter = CIFilter(name: "CIColorControls")!
        ciFilter.setValue(ciImage, forKey:kCIInputImageKey)
        ciFilter.setValue(brightness, forKey: kCIInputBrightnessKey)
        
        //フィルターを通した画像を生成
        let cgImage:CGImageRef = ciContext.createCGImage(ciFilter.outputImage!, fromRect:ciFilter.outputImage!.extent)
        
        //CGImageRefからUIImageを生成
        return UIImage(CGImage: cgImage, scale: 1.0, orientation:UIImageOrientation.Up)
        
    }
    
    @IBAction func saveButton(sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(myImageView.image!, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

