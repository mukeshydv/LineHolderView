//
//  ViewController.swift
//  DrawExample
//
//  Created by Mukesh Yadav on 06/12/16.
//  Copyright © 2016 Mukesh Yadav. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet weak var drawingView: LineHolderView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	//MARK:- IBActions
	@IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .photoLibrary
		if UIImagePickerController.isSourceTypeAvailable(.camera) {
			imagePicker.sourceType = .camera
		}
		imagePicker.allowsEditing = true
		imagePicker.delegate = self
		present(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func clickedButtonExportImages(_ sender: AnyObject) {
		let backgroundImage = backgroundImageView.image
		saveImageToDocuments(image: drawingView.getFinalImage(background: backgroundImage), imageName: "drawingImage")
	}
	
	func saveImageToDocuments(image: UIImage?, imageName: String) {
		if image != nil {
			UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
		}
	}
	
	//MARK:- UIImagePickerControllerDelegate
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage?
		if let image = selectedImage {
			backgroundImageView.image = image
		}
		
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
}

