//
//  LineHolderView.swift
//  DrawExample
//
//  Created by Mukesh Yadav on 07/12/16.
//  Copyright © 2016 Mukesh Yadav. All rights reserved.
//

import UIKit

class LineHolderView: UIView {

	var startPoint: CGPoint?
	var endPoint: CGPoint?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initializeView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initializeView()
	}
	
	private func initializeView() {
		self.backgroundColor = UIColor.clear
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDragged(_:)))
		addGestureRecognizer(panGesture)
	}
	
	func viewDragged(_ sender: UIPanGestureRecognizer) {
		let point = sender.location(in: self)
		
		switch sender.state {
		case .began:
			startPoint = point
			break;
		case .changed:
			endPoint = point
			setNeedsDisplay()
			break;
		case .ended:
			break;
		default:
			break;
		}
	}
	
    override func draw(_ rect: CGRect) {
		if let start = startPoint, let end = endPoint {
			UIColor.red.setStroke()
			let path = UIBezierPath()
			path.lineWidth = 4
			path.move(to: start)
			path.addLine(to: end)
			path.stroke()
		}
    }

}
