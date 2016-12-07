//
//  qrCodeGenerator.swift
//  QRCODE
//
//  Copyright © 2016 Riley Anderson. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale);
        
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return image!;
    }
}
extension String {
    var length: Int {
        return characters.count
    }
}

class qrCodeGenerator:ViewController
{
    @IBOutlet var qrImage: UIImageView!
    @IBOutlet var generateButtonPressed: UIView!
    @IBOutlet var textView: UITextField!
    @IBOutlet var generateButton: UIButton!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    var qrCodeImage: CIImage!
    

    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        saveButton.isEnabled = false

    }
    
    
    @IBAction func generateButtonAction(_ sender: Any)
    {
        
        if qrCodeImage == nil{
            if textView.text == ""
            {
                let alertController = UIAlertController(title: "Ooops!", message: "You forgot to enter something!", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            if((textView.text?.length)! > 16)
            {
                let alertController = UIAlertController(title: "Ooops!", message: "Looks like you entered too many characters", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            let data = textView.text!.data(using: String.Encoding.utf8, allowLossyConversion: false)
            
            let filter = CIFilter(name: "CIQRCodeGenerator")
            
            filter!.setValue(data, forKey: "inputMessage")
            filter!.setValue("L", forKey: "inputCorrectionLevel")
            
            qrCodeImage = filter!.outputImage
            
            textView.resignFirstResponder()
            
            saveButton.isEnabled = true
            displayQRCodeImage()
            
            generateButton.setTitle("Clear", for: .normal)
        }
        else {
            generateButton.setTitle("Generate", for: .normal)
            qrImage.image = nil
            qrCodeImage = nil
            
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any)
    {
        var image:UIImage = qrImage.image!
        UIImageWriteToSavedPhotosAlbum(self.qrImage!.takeSnapshot(), nil, nil, nil)
    }
    
    
    func displayQRCodeImage() {
        let scaleX = qrImage.frame.size.width / qrCodeImage.extent.size.width
        let scaleY = qrImage.frame.size.height / qrCodeImage.extent.size.height
        
        let transformedImage = qrCodeImage.applying(CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        qrImage.image = UIImage(ciImage: transformedImage)
    }
}

