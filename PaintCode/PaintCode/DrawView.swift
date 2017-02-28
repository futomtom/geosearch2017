//
//  DrawView.swift
//  PaintCode
//
//  Created by Alex on 2/24/17.
//  Copyright © 2017 aau. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    
    

    override func draw(_ rect: CGRect) {
        layer.borderColor = UIColor.red.cgColor
        layer.borderWidth = 1

        Ring.drawRing(frame: bounds, resizing: .aspectFill)

    }

}
