//
//  LineHolderView.swift
//  DrawExample
//
//  Created by Mukesh Yadav on 07/12/16.
//  Copyright © 2016 Mukesh Yadav. All rights reserved.
//

import UIKit

class LineHolderView: UIView {

	private let sin150: CGFloat = 0.5
	private let cos150: CGFloat = -0.86602540378
	
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
	
	override func draw(_ rect: CGRect) {
		if let start = startPoint, let end = endPoint {
			UIColor.red.setStroke()
			let path = UIBezierPath()
			path.lineWidth = 4
			path.move(to: start)
			path.addLine(to: end)
			path.stroke()
			if let points = getArrowHeadPoints() {
				UIColor.red.setFill()
				let trianglePath = UIBezierPath()
				trianglePath.move(to: points.point3)
				trianglePath.addLine(to: points.point1)
				trianglePath.addLine(to: points.point2)
				trianglePath.close()
				trianglePath.fill()
			}
		}
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

	func getArrowHeadPoints(aspectWidth: CGFloat = 1, aspectHeight: CGFloat = 1) -> (point1: CGPoint, point2: CGPoint, point3: CGPoint)? {
		
		var points: (CGPoint, CGPoint, CGPoint)? = nil
		
		if var start = startPoint, var end = endPoint {
			
			start.x = start.x * aspectWidth
			start.y = start.y * aspectHeight
			
			end.x = end.x * aspectWidth
			end.y = end.y * aspectHeight
			
			let dx = end.x - start.x
			let dy = end.y - start.y
			
			let normal = sqrt(dx*dx + dy*dy)
			
			let udx = dx / normal
			let udy = dy / normal
			
			let ax = (udx * cos150) - (udy * sin150)
			let ay = (udx * sin150) + (udy * cos150)
			
			let bx = (udx * cos150) + (udy * sin150)
			let by = (-1 * udx * sin150) + (udy * cos150)
			
			let ax0 = end.x + 20 * ax
			let ay0 = end.y + 20 * ay
			
			let ax1 = end.x + 20 * bx
			let ay1 = end.y + 20 * by
			
			let point1 = CGPoint(x: ax0, y: ay0)
			let point2 = CGPoint(x: ax1, y: ay1)
			let point3 = CGPoint(x: end.x + 3 * udx, y: end.y + 3 * udy)
			
			points = (point1, point2, point3)
		}
		
		return points
	}
}
