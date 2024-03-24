//
//  CanvasView.swift
//  CG_Lab2
//
//  Created by Lubomyr Chorniak on 05.03.2024.
//

import UIKit

class CanvasView: UIView {
    
    var n = 0
    let stepCount = 600
    var isMatrix = false

    var controlPoints: [CGPoint] = []
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    
        guard !controlPoints.isEmpty else { return }
        n = controlPoints.count
        guard let context = UIGraphicsGetCurrentContext() else { return }
        drawCoordinateSystem(context)
        drawMarking(context)
        
        context.setStrokeColor(UIColor.gray.cgColor)
        context.setFillColor(UIColor.blue.cgColor)
        context.setLineWidth(3)

        for i in 0..<controlPoints.count - 1 {
            if i == controlPoints.startIndex || i == controlPoints.endIndex - 2 {
                context.setStrokeColor(UIColor.red.cgColor)
            } else {
                context.setStrokeColor(UIColor.gray.cgColor)
            }
            context.move(to: controlPoints[i])
            context.addLine(to: controlPoints[i + 1])
            context.strokePath()

        }
        for i in 0..<stepCount {
            let t = CGFloat(i) / CGFloat(stepCount)
            let point = bezierCurve(points: controlPoints, t: t)
            context.addRect(CGRect.point(origin: point))
        }

        context.drawPath(using: .fill)
    }

    private func С(arg1: Int, arg2: Int) -> Double {
        return Double ( factorial(arg1) / ( factorial(arg2) * factorial(arg1 - arg2) ) )
    }
    
    private func bezierCurve(points: [CGPoint], t: CGFloat) -> CGPoint {
        var b = [Double](repeating: 0.0, count: n)
        for i in 0..<n {
            b[i] = binomialCoefficient(i: i, n: n - 1, t: Double(t))
        }
        
        var x = 0.0
        var y = 0.0
        for i in 0..<n {
            x += b[i] * Double(points[i].x)
            y += b[i] * Double(points[i].y)
        }
        
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
    
    private func binomialCoefficient(i: Int, n: Int, t: Double) -> Double {
        var result = (Double(factorial(n)) * pow(t, Double(i)) * pow(1 - t, Double(n - i)))
        result = result / Double(factorial(i) * factorial(n - i))
        return result
    }


    private func drawCoordinateSystem(_ context: CGContext) {
        
        let coordinateSystemPath = UIBezierPath()
        
        coordinateSystemPath.move(to: CGPoint(
            x: 0,
            y: canvasHeight / 2))
        
        coordinateSystemPath.addLine(to: CGPoint(
            x: canvasWidth,
            y: canvasHeight / 2))
        
        coordinateSystemPath.move(to: CGPoint(
            x: canvasWidth / 2,
            y: 0))
        
        coordinateSystemPath.addLine(to: CGPoint(
            x: canvasWidth / 2,
            y: canvasHeight))
        
        let xPointerPath = UIBezierPath()
        xPointerPath.move(to: CGPoint(
            x: canvasWidth,
            y: canvasHeight / 2))
        
        xPointerPath.addLine(to: CGPoint(
            x: canvasWidth - 20,
            y: (canvasHeight / 2) + 10))
        
        xPointerPath.addLine(to: CGPoint(
            x: canvasWidth - 20,
            y: (canvasHeight / 2) - 10))
        
        xPointerPath.close()
        
        let yPointerPath = UIBezierPath()
        yPointerPath.move(to: CGPoint(
            x: canvasWidth / 2,
            y: 0))
        
        yPointerPath.addLine(to: CGPoint(
            x: (canvasWidth / 2) - 10,
            y: 20))
        
        yPointerPath.addLine(to: CGPoint(
            x: (canvasWidth / 2) + 10,
            y: 20))

        context.setFillColor(UIColor.blue.cgColor)
        context.setStrokeColor(UIColor.blue.cgColor)
        
        context.addPath(coordinateSystemPath.cgPath)
        context.setLineWidth(Constants.CoordinateLineWidth)
        context.strokePath()

        context.addPath(xPointerPath.cgPath)
        context.fillPath()
        
        context.addPath(yPointerPath.cgPath)
        context.fillPath()
    }
    
    private func drawMarking(isAxisPositive: Bool, isXAxis: Bool ,marksCount: Int, initialX: CGFloat, initialY: CGFloat, _ context: CGContext) {
        var x = initialX
        var y = initialY
        let inset: CGFloat = 5
        for index in 0..<marksCount {
            defer {
                switch (isAxisPositive, isXAxis) {
                case (true, true):
                    x += Constants.distanceBetweenMarkings
                case (false, false):
                    y += Constants.distanceBetweenMarkings
                case (true, false):
                    y -= Constants.distanceBetweenMarkings
                case (false, true):
                    x -= Constants.distanceBetweenMarkings
                }
            }
            
            var text: NSAttributedString
            if isAxisPositive {
                text = NSAttributedString(string: "\((index + 1) * Int(Constants.distanceBetweenMarkings))", attributes: attributes)
            } else {
                text = NSAttributedString(string: "-\((index + 1) * Int(Constants.distanceBetweenMarkings))", attributes: attributes)
            }
            let textSize = textSize(text: text.string)
            
            var textRect: CGRect
            if isXAxis {
                context.addRect(CGRect(
                    x: x - (markWidth / 2),
                    y: y - (markHeight / 2),
                    width: markWidth,
                    height: markHeight))
                
                textRect = CGRect(
                    x: x - (textSize.width / 2),
                    y: y - (markHeight / 2) - (textSize.height) - inset,
                    width: textSize.width,
                    height: textSize.height)

            } else {
                context.addRect(CGRect(
                    x: x - (markHeight / 2),
                    y: y - (markWidth / 2),
                    width: markHeight,
                    height: markWidth))
                
                textRect = CGRect(
                    x: x + (markHeight / 2) + inset,
                    y: y - (textSize.height / 2),
                    width: textSize.width,
                    height: textSize.height)

            }
            
            if index == 0 { continue }
            text.draw(in: textRect)
            
        }
    }
    
    private func drawMarking(_ context: CGContext) {
        var inset: CGFloat
        
        // positive x-axis
        var x: CGFloat = canvasWidth / 2 + Constants.distanceBetweenMarkings
        var y: CGFloat = canvasHeight / 2
        inset = 30
        var marksCount = Int( (canvasWidth / 2 - inset) / Constants.distanceBetweenMarkings)
        drawMarking(isAxisPositive: true, isXAxis: true, marksCount: marksCount, initialX: x, initialY: y, context)
        
        // positive y-axis
        x = canvasWidth / 2
        y = canvasHeight / 2 - Constants.distanceBetweenMarkings
        marksCount = Int( (canvasHeight / 2 - inset) / Constants.distanceBetweenMarkings)
        drawMarking(isAxisPositive: true, isXAxis: false, marksCount: marksCount, initialX: x, initialY: y, context)
        
        // negative x-axis
        x = canvasWidth / 2 - Constants.distanceBetweenMarkings
        y = canvasHeight / 2
        inset = 10
        marksCount = Int( (canvasWidth / 2 - inset) / Constants.distanceBetweenMarkings)
        drawMarking(isAxisPositive: false, isXAxis: true, marksCount: marksCount, initialX: x, initialY: y, context)
        
        // negative y-axis
        x = canvasWidth / 2
        y = canvasHeight / 2 + Constants.distanceBetweenMarkings
        marksCount = Int( (canvasHeight / 2 - inset) / Constants.distanceBetweenMarkings)
        drawMarking(isAxisPositive: false, isXAxis: false, marksCount: marksCount, initialX: x, initialY: y, context)
        
        context.fillPath()
        
    }
    
    enum Constants {
        static let squareLineWidth: CGFloat = 4
        static let CoordinateLineWidth: CGFloat = 3
        static let distanceBetweenMarkings: CGFloat = 30
    }
    
    private var canvasWidth: CGFloat {
        bounds.width
    }
    
    private var canvasHeight: CGFloat {
        bounds.height
    }
    
    private let markWidth: CGFloat = 2
    private let markHeight: CGFloat = 20
    
    private let attributes: [NSAttributedString.Key: Any] = [
         .font: UIFont.systemFont(ofSize: 14),
         .foregroundColor: UIColor.black
     ]
    
    func textSize(text: String) -> CGSize {
        text.size(withAttributes: attributes)
    }
    
}



extension CGRect {
    static func point(origin: CGPoint) -> Self {
        CGRect(origin: origin, size: CGSize(width: 3, height: 3))
    }
}

func factorial(_ number: Int) -> Int {
    if number == 0 {
        return 1 
    }
    
    var result = 1
    for i in 1...number {
        result *= i
    }
    return result
}
