import UIKit

class SuccessAnimatedView: UIView {
    
    var circleLayer = CAShapeLayer()
    var outlineLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        circleLayer.strokeStart = 0.0
        circleLayer.strokeEnd = 0.0
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupLayers()
        circleLayer.strokeStart = 0.0
        circleLayer.strokeEnd = 0.0
    }
    
    override func layoutSubviews() {
        setupLayers()
    }
    
    
    var outlineCircle: CGPath {
        let path = UIBezierPath()
        let startAngle: CGFloat = CGFloat((0) / 180.0 * M_PI)  //0
        let endAngle: CGFloat = CGFloat((360) / 180.0 * M_PI)   //360
        path.addArc(withCenter: CGPoint(x:self.frame.size.width/2.0, y:self.frame.size.height/2.0), radius: self.frame.size.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path.cgPath
    }
    
    var path: CGPath {
        let path = UIBezierPath()
        let startAngle:CGFloat = CGFloat((60) / 180.0 * M_PI) //60
        let endAngle:CGFloat = CGFloat((200) / 180.0 * M_PI)  //190
        path.addArc(withCenter: CGPoint(x:self.frame.size.width/2.0, y:self.frame.size.height/2.0), radius: self.frame.size.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addLine(to: CGPoint(x: 36.0 - 10.0 ,y: 60.0 - 10.0))
        path.addLine(to: CGPoint(x: 85.0 - 20.0, y: 30.0 - 20.0))
        return path.cgPath
    }
    
    
    func setupLayers() {
        
        outlineLayer.position = CGPoint(x:0,y:0);
        outlineLayer.path = outlineCircle
        outlineLayer.fillColor = UIColor.clear.cgColor;
        outlineLayer.strokeColor = UIColor(red: 150.0/255.0, green: 216.0/255.0, blue: 115.0/255.0, alpha: 1.0).cgColor;
        outlineLayer.lineCap = kCALineCapRound
        outlineLayer.lineWidth = 4;
        outlineLayer.opacity = 0.1
        self.layer.addSublayer(outlineLayer)
        
        circleLayer.position = CGPoint(x:0,y:0)
        circleLayer.path = path
        circleLayer.fillColor = UIColor.clear.cgColor;
        circleLayer.strokeColor = UIColor(red: 150.0/255.0, green: 216.0/255.0, blue: 115.0/255.0, alpha: 1.0).cgColor;
        circleLayer.lineCap = kCALineCapRound
        circleLayer.lineWidth = 4;
        circleLayer.actions = [
            "strokeStart": NSNull(),
            "strokeEnd": NSNull(),
            "transform": NSNull()
        ]
        self.layer.addSublayer(circleLayer)
    }
    
     func animate() {
        let strokeStart = CABasicAnimation(keyPath: "strokeStart")
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        let factor = 0.045
        strokeEnd.fromValue = 0.00
        strokeEnd.toValue = 0.93
        strokeEnd.duration = 10.0*factor
        let timing = CAMediaTimingFunction(controlPoints: 0.3, 0.6, 0.8, 1.2)
        strokeEnd.timingFunction = timing
        
        strokeStart.fromValue = 0.0
        strokeStart.toValue = 0.68
        strokeStart.duration =  7.0*factor
        strokeStart.beginTime =  CACurrentMediaTime() + 3.0*factor
        strokeStart.fillMode = kCAFillModeBackwards
        strokeStart.timingFunction = timing
        circleLayer.strokeStart = 0.68
        circleLayer.strokeEnd = 0.93
        self.circleLayer.add(strokeEnd, forKey: "strokeEnd")
        self.circleLayer.add(strokeStart, forKey: "strokeStart")
    }
    
}

class CancelAnimatedView: UIView {
    
    var circleLayer = CAShapeLayer()
    var crossPathLayer = CAShapeLayer()
    
    override required init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        var t = CATransform3DIdentity;
        t.m34 = 1.0 / -500.0;
        t = CATransform3DRotate(t, CGFloat(90.0 * M_PI / 180.0), 1, 0, 0);
        circleLayer.transform = t
        crossPathLayer.opacity = 0.0
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupLayers()
        circleLayer.strokeStart = 0.0
        circleLayer.strokeEnd = 0.0
    }

    
    override func layoutSubviews() {
        setupLayers()
    }
    

    
    private var outlineCircle: CGPath  {
        let path = UIBezierPath()
        let startAngle: CGFloat = CGFloat((0) / 180.0 * M_PI)  //0
        let endAngle: CGFloat = CGFloat((360) / 180.0 * M_PI)   //360
        path.addArc(withCenter: CGPoint(x:self.frame.size.width/2.0, y:self.frame.size.width/2.0), radius: self.frame.size.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        return path.cgPath
    }
    
    private var crossPath: CGPath  {
        let path = UIBezierPath()
        let factor:CGFloat = self.frame.size.width / 5.0
        path.move(to: CGPoint(x: self.frame.size.height/2.0-factor,y: self.frame.size.height/2.0-factor))
        path.addLine(to: CGPoint(x: self.frame.size.height/2.0+factor,y: self.frame.size.height/2.0+factor))
        path.move(to: CGPoint(x: self.frame.size.height/2.0+factor,y: self.frame.size.height/2.0-factor))
        path.addLine(to: CGPoint(x: self.frame.size.height/2.0-factor,y: self.frame.size.height/2.0+factor))
        
        return path.cgPath
    }
    
    private func setupLayers() {
        circleLayer.path = outlineCircle
        circleLayer.fillColor = UIColor.clear.cgColor;
        circleLayer.strokeColor = UIColor.colorFromRGB(0xF27474).cgColor;
        circleLayer.lineCap = kCALineCapRound
        circleLayer.lineWidth = 4;
        circleLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        circleLayer.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        self.layer.addSublayer(circleLayer)
        
        crossPathLayer.path = crossPath
        crossPathLayer.fillColor = UIColor.clear.cgColor;
        crossPathLayer.strokeColor = UIColor.colorFromRGB(0xF27474).cgColor;
        crossPathLayer.lineCap = kCALineCapRound
        crossPathLayer.lineWidth = 4;
        crossPathLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        crossPathLayer.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        self.layer.addSublayer(crossPathLayer)
        
    }
    
    func animate() {
        var t = CATransform3DIdentity;
        t.m34 = 1.0 / -500.0;
        t = CATransform3DRotate(t, CGFloat(90.0 * M_PI / 180.0), 1, 0, 0);
        
        var t2 = CATransform3DIdentity;
        t2.m34 = 1.0 / -500.0;
        t2 = CATransform3DRotate(t2, CGFloat(-M_PI), 1, 0, 0);
        
        let animation = CABasicAnimation(keyPath: "transform")
        let time = 0.3
        animation.duration = time;
        animation.fromValue = NSValue(caTransform3D: t)
        animation.toValue = NSValue(caTransform3D:t2)
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        self.circleLayer.add(animation, forKey: "transform")
        
        
        var scale = CATransform3DIdentity;
        scale = CATransform3DScale(scale, 0.3, 0.3, 0)
        
        
        let crossAnimation = CABasicAnimation(keyPath: "transform")
        crossAnimation.duration = 0.3;
        crossAnimation.beginTime = CACurrentMediaTime() + time
        crossAnimation.fromValue = NSValue(caTransform3D: scale)
        crossAnimation.timingFunction = CAMediaTimingFunction(controlPoints: 0.25, 0.8, 0.7, 2.0)
        crossAnimation.toValue = NSValue(caTransform3D:CATransform3DIdentity)
        self.crossPathLayer.add(crossAnimation, forKey: "scale")
        
        let fadeInAnimation = CABasicAnimation(keyPath: "opacity")
        fadeInAnimation.duration = 0.3;
        fadeInAnimation.beginTime = CACurrentMediaTime() + time
        fadeInAnimation.fromValue = 0.3
        fadeInAnimation.toValue = 1.0
        fadeInAnimation.isRemovedOnCompletion = false
        fadeInAnimation.fillMode = kCAFillModeForwards
        self.crossPathLayer.add(fadeInAnimation, forKey: "opacity")
    }
    
}

class InfoAnimatedView: UIView {
    
    var circleLayer = CAShapeLayer()
    var crossPathLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    override func layoutSubviews() {
        setupLayers()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var outlineCircle: CGPath  {
        let path = UIBezierPath()
        let startAngle: CGFloat = CGFloat((0) / 180.0 * M_PI)  //0
        let endAngle: CGFloat = CGFloat((360) / 180.0 * M_PI)   //360
        path.addArc(withCenter: CGPoint(x:self.frame.size.width/2.0, y:self.frame.size.width/2.0), radius: self.frame.size.width/2.0, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        
        let factor:CGFloat = self.frame.size.width / 1.5
        path.move(to: CGPoint(x: self.frame.size.width/2.0 , y: 15.0))
        path.addLine(to: CGPoint(x: self.frame.size.width/2.0,y: factor))
        path.move(to: CGPoint(x: self.frame.size.width/2.0,y: factor + 10.0))
        path.addArc(withCenter: CGPoint(x: self.frame.size.width/2.0,y: factor + 10.0), radius: 1.0, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        return path.cgPath
    }
    
    func setupLayers() {
        circleLayer.path = outlineCircle
        circleLayer.fillColor = UIColor.clear.cgColor;
        circleLayer.strokeColor = UIColor.colorFromRGB(0xF8D486).cgColor;
        circleLayer.lineCap = kCALineCapRound
        circleLayer.lineWidth = 4;
        circleLayer.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        circleLayer.position = CGPoint(x: self.frame.size.width/2.0, y: self.frame.size.height/2.0)
        self.layer.addSublayer(circleLayer)
    }
    
     func animate() {
        
        let colorAnimation = CABasicAnimation(keyPath:"strokeColor")
        colorAnimation.duration = 1.0;
        colorAnimation.repeatCount = HUGE
        colorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        colorAnimation.autoreverses = true
        colorAnimation.fromValue = UIColor.colorFromRGB(0xF7D58B).cgColor
        colorAnimation.toValue = UIColor.colorFromRGB(0xF2A665).cgColor
        circleLayer.add(colorAnimation, forKey: "strokeColor")
    }
}

extension UIColor {
    class func colorFromRGB(_ rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


