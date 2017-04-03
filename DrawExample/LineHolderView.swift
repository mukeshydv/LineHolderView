//
//  LineHolderView.swift
//  DrawExample
//
//  Created by Mukesh Yadav on 07/12/16.
//  Copyright © 2016 Mukesh Yadav. All rights reserved.
//

import UIKit

@objc protocol LineHolderViewDelegate {
	@objc optional func lineHolderViewDrawingStarted(_ view: LineHolderView)
	@objc optional func lineHolderViewDrawingEnd(_ view: LineHolderView)
}

class LineHolderView: UIView {
	
	@IBInspectable var drawArrow: Bool = false
	@IBInspectable var addOutline: Bool = false
	
	@IBInspectable var lineColor: UIColor = .red
	@IBInspectable var outlineColor: UIColor = .black
	
    weak var delegate: LineHolderViewDelegate?
    
    var isDrawEnable = true
	
	private let sin150: CGFloat = 0.5
	private let cos150: CGFloat = -0.86602540378
	private var bufferImage: UIImage?
	
	private var bezierPathLine: UIBezierPath!
	private var bezierPathOutline: UIBezierPath!
	private var bezierPathTriangle: UIBezierPath!
	
	private var bezierCurvePoints: [CGPoint] = []
	
	private var startPoint: CGPoint?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		initializeView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initializeView()
	}
	
	private func addCircle(at point: CGPoint) {
		if addOutline {
			let circlePathOutline = UIBezierPath()
			outlineColor.setFill()
			circlePathOutline.addArc(withCenter: point, radius: 3, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
			circlePathOutline.fill()
		}
		
		let circlePath = UIBezierPath()
		lineColor.setFill()
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
		bufferImage?.draw(in: rect)
		drawLine()
	}
	
	private func drawLine() {
		if let point = startPoint {
			addCircle(at: point)
		}
		
		if let points = getArrowHeadPoints() {
			addCircle(at: points.point3)
			if drawArrow {
				addCircle(at: points.point2)
				addCircle(at: points.point1)
				if addOutline {
					let trianglePath = UIBezierPath()
					outlineColor.setStroke()
					trianglePath.lineWidth = 6
					trianglePath.move(to: points.point3)
					trianglePath.addLine(to: points.point1)
					trianglePath.move(to: points.point3)
					trianglePath.addLine(to: points.point2)
					trianglePath.stroke()
				}
			}
		}
		
		if addOutline {
			outlineColor.setStroke()
			bezierPathOutline.stroke()
		}
		
		lineColor.setStroke()
		bezierPathLine.stroke()
		
		if drawArrow {
			if let points = getArrowHeadPoints() {
				let trianglePath = UIBezierPath()
				lineColor.setStroke()
				trianglePath.lineWidth = 4
				trianglePath.move(to: points.point3)
				trianglePath.addLine(to: points.point1)
				trianglePath.move(to: points.point3)
				trianglePath.addLine(to: points.point2)
				trianglePath.stroke()
			}
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
        
        if !isDrawEnable {
            return
        }
        
		let point = sender.location(in: self)
		
        if point.x < 0 || point.x > frame.width || point.y < 0 || point.y > frame.height {
            endDrawing()
            return
        }
        
		switch sender.state {
		case .began:
			delegate?.lineHolderViewDrawingStarted?(self)
			bezierCurvePoints.append(point)
			startPoint = point
			break;
		case .changed:
            
            if bezierCurvePoints.count > 0 {
                let x1 = bezierCurvePoints.last?.x
                let y1 = bezierCurvePoints.last?.y
                let x2 = point.x
                let y2 = point.y
                
                let ex = (x1!-x2)*(x1!-x2)
                let ey = (y1!-y2)*(y1!-y2)
                
                let dist = sqrt(ex + ey)
                
                if dist < 3.5 {
                    return
                }
            }
            
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
			break
		case .ended:
			endDrawing()
			break
		default:
			break
		}
	}

    private func endDrawing() {
        drawLastPath()
        saveBufferImage()
        
        bezierPathLine.removeAllPoints()
        bezierPathOutline.removeAllPoints()
        bezierPathTriangle.removeAllPoints()
        
        bezierCurvePoints.removeAll()
        startPoint = nil
        
        delegate?.lineHolderViewDrawingEnd?(self)
    }
    
	private func getArrowHeadPoints(aspectWidth: CGFloat = 1, aspectHeight: CGFloat = 1) -> (point1: CGPoint, point2: CGPoint, point3: CGPoint)? {
		
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
	
	private func saveBufferImage() {
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1)
		if bufferImage == nil {
			let fillPath = UIBezierPath(rect: self.bounds)
			UIColor.clear.setFill()
			fillPath.fill()
		}
		bufferImage?.draw(at: .zero)
		drawLine()
		bufferImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
	}
	
	/// Use this method to get the final image. You can also use a background image for your line.
	///
	/// - Parameter background: Your background image.
	/// - Returns: Image drawn with your background image.
	public func getFinalImage(background: UIImage? = nil) -> UIImage? {
		if background == nil {
			return bufferImage
		}
		
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 1)
		background?.draw(in: self.bounds)
		bufferImage?.draw(at: .zero)
		bufferImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return bufferImage
    }
    
    func clearDrawing() {
        bufferImage = nil
        setNeedsDisplay()
    }
}
