//
//  TaskTwoMainViewController.swift
//  Task2
//
//  Created by Armaghan  on 4/23/21.
//

import UIKit
import Network
class TaskTwoMainViewController: UIViewController
{

    @IBOutlet weak var imgView: UIImageView!
    var imgToSend : UIImage?
    var imagePicker = UIImagePickerController()
    let tcpServerConection = TCPConnection()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tcpServerConection.delegate = self
        tcpServerConection.start(host: "localhost", port: 63641)
        imagePicker.delegate = self
        // Do any additional setup after loading the view.
    }

    //MARK:- Button Actions
    @IBAction func btnSend_pressed(_ sender: Any)
    {
        let alert = UIAlertController(title: "Choose Image", message: "Please Select an Option", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Gallery", style: .default , handler:{
            (UIAlertAction)in

            self.openGallery()

        }))
        alert.addAction(UIAlertAction(title: "Open Camera", style: .default , handler:{
            (UIAlertAction)in

            self.openCamera()

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
       
    
    }
    //MARK:- Sending Image To Server
    func sendImageToServer()
    {
        let imgData = imgToSend?.jpegData(compressionQuality: 1.0)
        
        //////// Sending Image as Data
        tcpServerConection.sendStreamOriented(connection: tcpServerConection.connection!, data: imgData!)
        
        /////// We can also send image as string
//        let strImage = imgData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//        tcpServerConection.sendMessage(message: ["image", strImage])
        
    }
}
//MARK:- Camera and Gallery Methods And Delegates
extension TaskTwoMainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "oK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        self.imgToSend = selectedImage
        
        picker.dismiss(animated: true) {
            self.sendImageToServer()
        }
    }
    
    private func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        
        picker.dismiss(animated: true, completion: nil)
    }
}
//MARK:- TCPConnection Delegate
extension TaskTwoMainViewController : TCPConnectionDelegate
{
    func didRecievedImageData(imgData: Data?)
    {
        let imageFromData = UIImage.init(data: imgData!)
        self.imgView.image = imageFromData
    }
}
