//
//  ViewController.swift
//  DrawExample
//
//  Created by Mukesh Yadav on 06/12/16.
//  Copyright © 2016 Mukesh Yadav. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, LineHolderViewDelegate {

	@IBOutlet weak var backgroundImageView: UIImageView!
	@IBOutlet weak var drawingView: LineHolderView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		drawingView.delegate = self
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
		let image = drawingView.getFinalImage(background: backgroundImage)
		saveImageToDocuments(image: image, imageName: "drawingImage")
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
	
	// MARK:- LineHolderViewDelegate
	func lineHolderViewDrawingEnd(_ view: LineHolderView) {
		let randomR = arc4random_uniform(256)
		let randomG = arc4random_uniform(256)
		let randomB = arc4random_uniform(256)
		
		drawingView.lineColor = UIColor(red: CGFloat(randomR) / 255, green: CGFloat(randomG) / 255, blue: CGFloat(randomB) / 255, alpha: 1)
		drawingView.lineColor = UIColor(red: CGFloat(255 - randomR) / 255, green: CGFloat(255 - randomG) / 255, blue: CGFloat(255 - randomB) / 255, alpha: 1)
	}
}

