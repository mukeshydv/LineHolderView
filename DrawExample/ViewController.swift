//
//  ViewController.swift
//  DrawExample
//
//  Created by Mukesh Yadav on 06/12/16.
//  Copyright © 2016 Mukesh Yadav. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, LineHolderViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var drawingView: LineHolderView!
    
    @IBOutlet weak var viewLineColor: UIView!
    @IBOutlet weak var viewOutlineColor: UIView!
    
    private var wrapperView: UIView!
    private var selectedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawingView.delegate = self
    }
    
    private func saveImageToDocuments(image: UIImage?, imageName: String) {
        if image != nil {
            UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        }
    }
    
    // MARK:- UIPickerView
    private func showColorPicker(color: UIColor?) {
        wrapperView = getWrapperView()
        
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = UIColor.white
        
        pickerView.frame.size = CGSize(width: wrapperView.frame.width-40 , height: pickerView.frame.height)
        let pickerFrame = CGRect(x: (wrapperView.frame.width - pickerView.frame.width)/2, y: (wrapperView.frame.height - pickerView.frame.height)/2, width: pickerView.frame.width, height: pickerView.frame.height)
        pickerView.frame = pickerFrame
        
        wrapperView.addSubview(pickerView)
        
        UIApplication.shared.keyWindow?.addSubview(wrapperView)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPickerView))
        wrapperView.addGestureRecognizer(tapGesture)
        
        var fRed: CGFloat = 0
        var fGreen: CGFloat = 0
        var fBlue: CGFloat = 0
        
        if color?.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: nil) == true {
            var red = Int(fRed * 255.0)
            var green = Int(fGreen * 255.0)
            var blue = Int(fBlue * 255.0)
            
            if red > 255 {
                red = 255
            } else if red < 0 {
                red = 0
            }
            
            if green > 255 {
                green = 255
            } else if green < 0 {
                green = 0
            }
            
            if blue > 255 {
                blue = 255
            } else if blue < 0 {
                blue = 0
            }
            
            pickerView.selectRow(red, inComponent: 0, animated: false)
            pickerView.selectRow(green, inComponent: 1, animated: false)
            pickerView.selectRow(blue, inComponent: 2, animated: false)
        }
    }
    
    private func getWrapperView() -> UIView {
        
        let window = UIApplication.shared.windows.first
        let wrapperView = UIView()
        wrapperView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        wrapperView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        wrapperView.frame = (window?.frame)!
        return wrapperView
    }
    
    @objc private func dismissPickerView() {
        drawingView.lineColor = viewLineColor.backgroundColor ?? .red
        drawingView.outlineColor = viewOutlineColor.backgroundColor ?? .black
        removePickerViewWithAnimation()
    }
    
    private func removePickerViewWithAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.wrapperView.alpha = 0
        }) { (completed) in
            self.wrapperView.removeFromSuperview()
        }
    }
    
    // MARK:- UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 256
    }
    
    // MARK:- UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row.description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let red = CGFloat(pickerView.selectedRow(inComponent: 0))
        let green = CGFloat(pickerView.selectedRow(inComponent: 1))
        let blue = CGFloat(pickerView.selectedRow(inComponent: 2))
        
        let color = UIColor(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
        
        selectedView.backgroundColor = color
    }
    
    //MARK:- UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage?
        if let image = selectedImage {
            backgroundImageView.image = image
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
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
    
    @IBAction func clickedBtnClearDrawing(_ sender: Any) {
        drawingView.clearDrawing()
    }
    
    @IBAction func clickedButtonExportImages(_ sender: AnyObject) {
        let backgroundImage = backgroundImageView.image
        let image = drawingView.getFinalImage(background: backgroundImage)
        saveImageToDocuments(image: image, imageName: "drawingImage")
    }
    
    @IBAction func outlineSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            drawingView.addOutline = true
        } else {
            drawingView.addOutline = false
        }
    }
    
    @IBAction func arrowSegmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            drawingView.drawArrow = true
        } else {
            drawingView.drawArrow = false
        }
    }
    
    @IBAction func clickedBtnLineColor(_ sender: Any) {
        selectedView = viewLineColor
        showColorPicker(color: selectedView.backgroundColor)
    }
    
    @IBAction func clickedBtnOutlineColor(_ sender: Any) {
        selectedView = viewOutlineColor
        showColorPicker(color: selectedView.backgroundColor)
    }
}
