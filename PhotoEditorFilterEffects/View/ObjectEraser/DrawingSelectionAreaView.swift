//
//  DrawingSelectionAreaView.swift
//  PhotoEditorFilterEffects
//
//  Created by Sonjoy Borkakoty on 29/12/22.
//

import UIKit

class DrawingSelectionAreaView: UIView {
    
    var lastPoint: CGPoint = CGPoint.zero
    var points = [CGPoint]()
    var curves = [[CGPoint]]()
    var drawingPath: UIBezierPath!
    var isSelectionFinished = false
    
    var callback: ((_ points: [CGPoint]) -> Void)?
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }

    /*convenience init () {
        self.init(frame:CGRect.zero)
    }*/

    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func draw(_ rect: CGRect) {
        
        drawingPath = drawPath(curve: points)

        drawingPath.lineWidth = AppConstants.sharedHeightMultiplier.drawPathLineWidth
        drawingPath.lineCapStyle = .round
        drawingPath.stroke(with: .normal, alpha: 0.5)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        points = [CGPoint]()
        
        if let touch = touches.first {
            lastPoint = touch.location(in: self)
            points.append(lastPoint)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let newPoint = touch.location(in: self)
            points.append(newPoint)
            
            lastPoint = newPoint
            setNeedsDisplay()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isSelectionFinished = true
        
        callback?(points)
    }
    
    func drawPath(curve: [CGPoint]) -> UIBezierPath {
        
        let path = UIBezierPath()
        
        UIColor(hexaRGB: "#7D038C")!.setStroke()
        //UIColor.red.setFill()
        
        if curve.count > 0 {
            path.move(to: curve.first!)
            for point in curve {
                path.addLine(to: point)
            }
        }
        
        return path
    }
    
    func erase() {
        
        points.removeAll()
        drawingPath = nil
        drawingPath = UIBezierPath()
        self.setNeedsDisplay()
    }
}
