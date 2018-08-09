//
//  ViewController.swift
//  Seafood
//
//  Created by Charles Martin Reed on 8/9/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    //create image picker object
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting current View Controller as delegate for the imagePicker object
        imagePicker.delegate = self
        
        //allows user to take an image using the device camera
        imagePicker.sourceType = .photoLibrary
        //imagePicker.sourceType = .photoLibrary
        
        //editing currently not allowed, could be allowed to control how much of an image the model uses to determine the nature of the taken image
        imagePicker.allowsEditing = false
    }
    
    //tells the delegate the user has finished picking an image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //check that the image has chosen an image
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            //the original type from the info dictionary is Any?, so we need to downcast it
            imageView.image = userPickedImage
            
            //convert UI image to Core Image image in order to get interpretation fro it
            //if unable to convert, trigger fatal error
            //guard seems to be the new do-try-catch
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert UIimage to CIImage")
            }
            
            //call our detect function to make the request to our Inception v3 model for classification of the passed image
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
        
    }
        
        func detect(image: CIImage) {
            //use the Inception v3 model
            //if can't load the model, present fatal error
            guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
                fatalError("Loading CoreML Model failed")
            }
            
            let request = VNCoreMLRequest(model: model) { (request, error) in
                //process the results of the result
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("Model failed to process image")
                }
                
                //check the first result classification, check the identifier and see whether or not the predication is of a "hotdog".
                if let firstResult = results.first {
                    if firstResult.identifier.contains("hotdog") {
                        self.navigationItem.title = "Hotdog!"
                    } else {
                        self.navigationItem.title = "Not hotdog! :("
                    }
                }
                
            }
            
            //perform the request by creating handler to specify the image we want to classifiy
            let handler = VNImageRequestHandler(ciImage: image)
            
            do {
                try handler.perform([request])
            } catch {
                print(error)
            }

        }
        

    @IBAction func barButtonClicked(_ sender: UIBarButtonItem) {
        
        //present the
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

