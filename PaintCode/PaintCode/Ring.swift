//
//  StyleKitName.swift
//  (null)
//
//  Created by (null) on 2/24/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//
//  Generated by PaintCode
//  http://www.paintcodeapp.com
//



import UIKit

public class Ring : NSObject {

    //// Drawing Methods

    public dynamic class func drawRing(frame targetFrame: CGRect = CGRect(x: 0, y: 0, width: 160, height: 160), resizing: ResizingBehavior = .aspectFit) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()!
        
        //// Resize to Target Frame
        context.saveGState()
        let resizedFrame: CGRect = resizing.apply(rect: CGRect(x: 0, y: 0, width: 160, height: 160), target: targetFrame)
        context.translateBy(x: resizedFrame.minX, y: resizedFrame.minY)
        context.scaleBy(x: resizedFrame.width / 160, y: resizedFrame.height / 160)


        //// Color Declarations
        let strokeColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)

        //// Bezier Drawing
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 19, y: 12))
        bezierPath.addLine(to: CGPoint(x: 10, y: 5))
        bezierPath.addLine(to: CGPoint(x: 14, y: 0))
        bezierPath.addLine(to: CGPoint(x: 24, y: 0))
        bezierPath.addLine(to: CGPoint(x: 28, y: 5))
        bezierPath.addLine(to: CGPoint(x: 19, y: 12))
        bezierPath.close()
        strokeColor.setStroke()
        bezierPath.lineWidth = 2
        bezierPath.lineCapStyle = .round
        bezierPath.lineJoinStyle = .round
        bezierPath.stroke()


        //// Bezier 2 Drawing
        let bezier2Path = UIBezierPath()
        bezier2Path.move(to: CGPoint(x: 28, y: 5))
        bezier2Path.addLine(to: CGPoint(x: 22, y: 5))
        bezier2Path.addLine(to: CGPoint(x: 16, y: 5))
        bezier2Path.addLine(to: CGPoint(x: 10, y: 5))
        strokeColor.setStroke()
        bezier2Path.lineWidth = 2
        bezier2Path.lineCapStyle = .round
        bezier2Path.lineJoinStyle = .round
        bezier2Path.stroke()


        //// Bezier 3 Drawing
        let bezier3Path = UIBezierPath()
        bezier3Path.move(to: CGPoint(x: 24, y: 0))
        bezier3Path.addLine(to: CGPoint(x: 22, y: 5))
        strokeColor.setStroke()
        bezier3Path.lineWidth = 2
        bezier3Path.lineCapStyle = .round
        bezier3Path.lineJoinStyle = .round
        bezier3Path.stroke()


        //// Bezier 4 Drawing
        let bezier4Path = UIBezierPath()
        bezier4Path.move(to: CGPoint(x: 14, y: 0))
        bezier4Path.addLine(to: CGPoint(x: 16, y: 5))
        strokeColor.setStroke()
        bezier4Path.lineWidth = 2
        bezier4Path.lineCapStyle = .round
        bezier4Path.lineJoinStyle = .round
        bezier4Path.stroke()


        //// Bezier 5 Drawing
        let bezier5Path = UIBezierPath()
        bezier5Path.move(to: CGPoint(x: 16.05, y: 10.29))
        bezier5Path.addCurve(to: CGPoint(x: 4, y: 25), controlPoint1: CGPoint(x: 9.18, y: 11.66), controlPoint2: CGPoint(x: 4, y: 17.73))
        bezier5Path.addCurve(to: CGPoint(x: 19, y: 40), controlPoint1: CGPoint(x: 4, y: 33.28), controlPoint2: CGPoint(x: 10.72, y: 40))
        bezier5Path.addCurve(to: CGPoint(x: 34, y: 25), controlPoint1: CGPoint(x: 27.28, y: 40), controlPoint2: CGPoint(x: 34, y: 33.28))
        bezier5Path.addCurve(to: CGPoint(x: 21.95, y: 10.29), controlPoint1: CGPoint(x: 34, y: 17.73), controlPoint2: CGPoint(x: 28.82, y: 11.66))
        strokeColor.setStroke()
        bezier5Path.lineWidth = 2
        bezier5Path.lineCapStyle = .round
        bezier5Path.lineJoinStyle = .round
        bezier5Path.stroke()


        //// Bezier 6 Drawing
        let bezier6Path = UIBezierPath()
        bezier6Path.move(to: CGPoint(x: 12.48, y: 7.17))
        bezier6Path.addCurve(to: CGPoint(x: 0, y: 25), controlPoint1: CGPoint(x: 5.2, y: 9.83), controlPoint2: CGPoint(x: 0, y: 16.8))
        bezier6Path.addCurve(to: CGPoint(x: 19, y: 44), controlPoint1: CGPoint(x: 0, y: 35.49), controlPoint2: CGPoint(x: 8.51, y: 44))
        bezier6Path.addCurve(to: CGPoint(x: 38, y: 25), controlPoint1: CGPoint(x: 29.49, y: 44), controlPoint2: CGPoint(x: 38, y: 35.49))
        bezier6Path.addCurve(to: CGPoint(x: 25.52, y: 7.17), controlPoint1: CGPoint(x: 38, y: 16.8), controlPoint2: CGPoint(x: 32.8, y: 9.83))
        strokeColor.setStroke()
        bezier6Path.lineWidth = 2
        bezier6Path.lineCapStyle = .round
        bezier6Path.lineJoinStyle = .round
        bezier6Path.stroke()
        
        context.restoreGState()

    }




    @objc public enum ResizingBehavior: Int {
        case aspectFit /// The content is proportionally resized to fit into the target rectangle.
        case aspectFill /// The content is proportionally resized to completely fill the target rectangle.
        case stretch /// The content is stretched to match the entire target rectangle.
        case center /// The content is centered in the target rectangle, but it is NOT resized.

        public func apply(rect: CGRect, target: CGRect) -> CGRect {
            if rect == target || target == CGRect.zero {
                return rect
            }

            var scales = CGSize.zero
            scales.width = abs(target.width / rect.width)
            scales.height = abs(target.height / rect.height)

            switch self {
                case .aspectFit:
                    scales.width = min(scales.width, scales.height)
                    scales.height = scales.width
                case .aspectFill:
                    scales.width = max(scales.width, scales.height)
                    scales.height = scales.width
                case .stretch:
                    break
                case .center:
                    scales.width = 1
                    scales.height = 1
            }

            var result = rect.standardized
            result.size.width *= scales.width
            result.size.height *= scales.height
            result.origin.x = target.minX + (target.width - result.width) / 2
            result.origin.y = target.minY + (target.height - result.height) / 2
            return result
        }
    }
}
