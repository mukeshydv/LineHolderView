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
	
	var bezierPathLine: UIBezierPath!
	var bezierPathOutline: UIBezierPath!
	var bezierPathTriangle: UIBezierPath!
	
	var bezierCurvePoints: [CGPoint] = []
	
	var startPoint: CGPoint?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initializeView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initializeView()
	}
	
	private func addCircle(at point: CGPoint) {
		let circlePathOutline = UIBezierPath()
		UIColor.black.setFill()
		circlePathOutline.addArc(withCenter: point, radius: 3, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
		circlePathOutline.fill()
		
		let circlePath = UIBezierPath()
		UIColor.red.setFill()
		circlePath.addArc(withCenter: point, radius: 2, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
		circlePath.fill()
	}
	
	private func drawLastPath() {
		if bezierCurvePoints.count > 1 {
			if bezierCurvePoints.count >= 4 {
				bezierPathLine.move(to: bezierCurvePoints[0])
				bezierPathLine.addCurve(to: bezierCurvePoints[3], controlPoint1: bezierCurvePoints[1], controlPoint2: bezierCurvePoints[2])
				
				bezierPathOutline.move(to: bezierCurvePoints[0])
				bezierPathOutline.addCurve(to: bezierCurvePoints[3], controlPoint1: bezierCurvePoints[1], controlPoint2: bezierCurvePoints[2])
			} else {
				bezierPathLine.move(to: bezierCurvePoints[0])
				bezierPathOutline.move(to: bezierCurvePoints[0])
				
				for i in 1..<bezierCurvePoints.count {
					let point = bezierCurvePoints[i]
					
					bezierPathLine.addLine(to: point)
					bezierPathOutline.addLine(to: point)
				}
				
			}
			setNeedsDisplay()
		}
	}
	
	override func draw(_ rect: CGRect) {
		
		if let point = startPoint {
			addCircle(at: point)
		}
		
		if let points = getArrowHeadPoints() {
			addCircle(at: points.point2)
			addCircle(at: points.point1)
			addCircle(at: points.point3)
			let trianglePath = UIBezierPath()
			UIColor.black.setStroke()
			trianglePath.lineWidth = 6
			trianglePath.move(to: points.point3)
			trianglePath.addLine(to: points.point1)
			trianglePath.move(to: points.point3)
			trianglePath.addLine(to: points.point2)
			trianglePath.stroke()
		}
		
		UIColor.black.setStroke()
		bezierPathOutline.stroke()
		
		UIColor.red.setStroke()
		bezierPathLine.stroke()
		
		if let points = getArrowHeadPoints() {
			let trianglePath = UIBezierPath()
			UIColor.red.setStroke()
			trianglePath.lineWidth = 4
			trianglePath.move(to: points.point3)
			trianglePath.addLine(to: points.point1)
			trianglePath.move(to: points.point3)
			trianglePath.addLine(to: points.point2)
			trianglePath.stroke()
		}
	}
	
	private func initializeView() {
		isMultipleTouchEnabled = false
		bezierPathLine = UIBezierPath()
		bezierPathLine.lineWidth = 4
		
		bezierPathOutline = UIBezierPath()
		bezierPathOutline.lineWidth = 6
		
		bezierPathTriangle = UIBezierPath()
		
		self.backgroundColor = UIColor.clear
		let panGesture = UIPanGestureRecognizer(target: self, action: #selector(viewDragged(_:)))
		addGestureRecognizer(panGesture)
	}
	
	func viewDragged(_ sender: UIPanGestureRecognizer) {
		let point = sender.location(in: self)
		
		switch sender.state {
		case .began:
			
			bezierPathLine.removeAllPoints()
			bezierPathOutline.removeAllPoints()
			bezierPathTriangle.removeAllPoints()
			
			bezierCurvePoints.removeAll()
			bezierCurvePoints.append(point)
			startPoint = point
			break;
		case .changed:
			bezierCurvePoints.append(point)
			if bezierCurvePoints.count == 5 {
				let x1 = bezierCurvePoints[2].x
				let y1 = bezierCurvePoints[2].y
				
				let x2 = bezierCurvePoints[4].x
				let y2 = bezierCurvePoints[4].y
				
				bezierCurvePoints[3] = CGPoint(x: (x1 + x2) / 2, y: (y1 + y2) / 2)
				
				bezierPathLine.move(to: bezierCurvePoints[0])
				bezierPathLine.addCurve(to: bezierCurvePoints[3], controlPoint1: bezierCurvePoints[1], controlPoint2: bezierCurvePoints[2])
				
				bezierPathOutline.move(to: bezierCurvePoints[0])
				bezierPathOutline.addCurve(to: bezierCurvePoints[3], controlPoint1: bezierCurvePoints[1], controlPoint2: bezierCurvePoints[2])
				
				setNeedsDisplay()
				
				let point1 = bezierCurvePoints[3]
				let point2 = bezierCurvePoints[4]
				
				bezierCurvePoints.removeAll()
				
				bezierCurvePoints.append(point1)
				bezierCurvePoints.append(point2)
			}
			break;
		case .ended:
			drawLastPath()
			break;
		default:
			break;
		}
	}

	func getArrowHeadPoints(aspectWidth: CGFloat = 1, aspectHeight: CGFloat = 1) -> (point1: CGPoint, point2: CGPoint, point3: CGPoint)? {
		
		var points: (CGPoint, CGPoint, CGPoint)? = nil
		
		if bezierCurvePoints.count >= 2 {
			
			var start = bezierCurvePoints[bezierCurvePoints.count - 2]
			var end = bezierCurvePoints[bezierCurvePoints.count - 1]
			
			start.x = start.x * aspectWidth
			start.y = start.y * aspectHeight
			
			end.x = end.x * aspectWidth
			end.y = end.y * aspectHeight
			
			let dx = end.x - start.x
			let dy = end.y - start.y
			
			let normal = sqrt(dx*dx + dy*dy)
			
			var udx = dx / normal
			var udy = dy / normal
			
			if normal == 0 {
				udx = 0
				udy = 0
			}
			
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
			let point3 = CGPoint(x: end.x, y: end.y)
			
			points = (point1, point2, point3)
		}
		
		return points
	}
}
