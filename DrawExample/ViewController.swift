//
//  ViewController.swift
//  DrawExample
//
//  Created by Mukesh Yadav on 06/12/16.
//  Copyright © 2016 Mukesh Yadav. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

	
	@IBOutlet weak var viewTopLeft: UIView!
	@IBOutlet weak var viewTopRight: UIView!
	@IBOutlet weak var viewBottomLeft: UIView!
	@IBOutlet weak var viewBottomRight: UIView!
	
	var tappedView: UIView?
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	//MARK:- IBActions
	@IBAction func viewTapped(_ sender: UITapGestureRecognizer) {
		let point = sender.location(in: view)
		
		if viewTopLeft.frame.contains(point) {
			tappedView = viewTopLeft
		} else if viewTopRight.frame.contains(point) {
			tappedView = viewTopRight
		} else if viewBottomLeft.frame.contains(point) {
			tappedView = viewBottomLeft
		} else if viewBottomRight.frame.contains(point) {
			tappedView = viewBottomRight
		}
		
		let imagePicker = UIImagePickerController()
		imagePicker.sourceType = .photoLibrary
		imagePicker.allowsEditing = true
		imagePicker.delegate = self
		present(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func clickedButtonExportImages(_ sender: AnyObject) {
		let imageTopLeft = getImage(view: viewTopLeft)
		let imageTopRight = getImage(view: viewTopRight)
		let imageBottomLeft = getImage(view: viewBottomLeft)
		let imageBottomRight = getImage(view: viewBottomRight)
		
		saveImageToDocuments(image: imageTopLeft, imageName: "topLeft")
		saveImageToDocuments(image: imageTopRight, imageName: "topRight")
		saveImageToDocuments(image: imageBottomLeft, imageName: "bottomLeft")
		saveImageToDocuments(image: imageBottomRight, imageName: "bottomRight")
	}
	
	
	//MARK:- Image Operations
	func getImage(view: UIView) -> UIImage? {
		var result: UIImage?
		if let imageView = view.viewWithTag(101) as? UIImageView {
			if let image = imageView.image {
				if let holderView = view.viewWithTag(102) as? LineHolderView {
					if let startPoint = holderView.startPoint, let endPoint = holderView.endPoint {
						UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
						let imageFrame = CGRect(origin: .zero, size: view.frame.size)
						image.draw(in: imageFrame)
						UIColor.red.setStroke()
						let path = UIBezierPath()
						path.lineWidth = 4
						path.move(to: startPoint)
						path.addLine(to: endPoint)
						path.stroke()
						if let points = holderView.getArrowHeadPoints() {
							UIColor.red.setFill()
							let trianglePath = UIBezierPath()
							trianglePath.move(to: endPoint)
							trianglePath.addLine(to: points.point1)
							trianglePath.addLine(to: points.point2)
							trianglePath.close()
							trianglePath.fill()
						}
						result = UIGraphicsGetImageFromCurrentImageContext()
						UIGraphicsEndImageContext()
					}
				}
			}
		}
		return result
	}
	
	func saveImageToDocuments(image: UIImage?, imageName: String) {
		if image != nil {
			let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
			let filePath = docDir?.appendingPathComponent(imageName + ".png")
			let imageData = UIImagePNGRepresentation(image!)
			try? imageData?.write(to: filePath!)
		}
	}
	
	
	//MARK:- UIImagePickerControllerDelegate
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		
		if let view = tappedView {
			let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage?
			if let image = selectedImage {
				let imageView = view.viewWithTag(101) as? UIImageView
				imageView?.image = image
			}
			tappedView = nil
		}
		
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		tappedView = nil
		picker.dismiss(animated: true, completion: nil)
	}
}

