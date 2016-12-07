//
//  ViewController.swift
//  QRCODE
//
//  Created by Riley Anderson on 12/3/16.
//  Copyright © 2016 Riley Anderson. All rights reserved.
//

import UIKit
import GPUImage


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate

{
    @IBOutlet var cameraView: UIView!
    @IBOutlet var uploadView: UIView!
    @IBOutlet var decodeButton: UIButton!
    @IBOutlet var decodedTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var createButton: UIBarButtonItem!
    @IBOutlet var selector: UISegmentedControl!

    @IBOutlet var uploadButton: UIBarButtonItem!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //cameraView.isHidden = true
    }
    
    @IBAction func uploadButtonPushed(_ sender: Any)
    {
        if(imageView.image == nil)
        {
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){

                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
                imagePicker.allowsEditing = false
            
                self.present(imagePicker, animated: true, completion: nil)
            }
            
            uploadButton.title = "Clear"
            decodeButton.isEnabled = true
        }
        
        else
        {
            imageView.image = nil
            decodeButton.isEnabled = false
            uploadButton.title = "Upload"
            decodedTextField.text = ""
            
        }

    }
    
    @IBAction func selectorChanged(_ sender: Any)
    {
        if(selector.selectedSegmentIndex == 1)
        {
            var CameraVC:CameraViewController = CameraViewController()
            self.navigationController?.pushViewController(CameraVC, animated: false)
        }
//        else
//        {
//            cameraView.isHidden = false
//            uploadView.isHidden = true
//        }
        
        
    }
    
    @IBAction func decodeButonPressed(_ sender: Any)
    {
        if(imageView.image != nil)
        {
            let model:QRCodeReader = QRCodeReader()
            decodedTextField.text = model.getMessage(image: imageView.image!)
            if(decodedTextField.text == "")
            {
                let alertController = UIAlertController(title: "Ooops!", message: "Looks like we dont support that version yet. Try using the camera setting on that one", preferredStyle: UIAlertControllerStyle.alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
        }
        
    }
    @IBAction func createButtonPressed(_ sender: Any)
    {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
        } else{
            print("Something went wrong")
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
