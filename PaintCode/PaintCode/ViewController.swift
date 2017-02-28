//
//  ViewController.swift
//  PaintCode
//
//  Created by Alex on 2/24/17.
//  Copyright © 2017 aau. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var successView: SuccessAnimatedView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewWillAppear(_ animated: Bool) {
        successView.animate()
    }
 
    @IBAction func diAnimation(_ sender: Any) {
        successView.animate()
    }
}

