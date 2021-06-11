//
//  ViewController.swift
//  vahi0.0.1
//
//  Created by Andrew Baughman on 12/9/20.
//

import UIKit

/* https://www.hackingwithswift.com/example-code/uicolor/how-to-convert-a-hex-color-to-a-uicolor
*   UIColor from Hex string of 9 digits. Very nice.
*/
 extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var stepper_base: UIStepper!
    @IBOutlet weak var stepper_digits: UIStepper!
    @IBOutlet weak var time_display: UILabel!
    @IBOutlet weak var explanation: UITextView!
    @IBOutlet weak var conversion_ratio: UILabel!
    @IBOutlet weak var colon: UILabel!
    @IBOutlet weak var new_second: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        stepper_base.value = 16
        stepper_digits.value = 4
        conversion_ratio.text = ""
        explanation.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpDisplayLink()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        displayLink.remove(from: .main, forMode: RunLoop.Mode.common)
    }
    
    @IBOutlet weak var digits_lbl: UILabel!
    @IBOutlet weak var base_lbl: UILabel!
    @IBOutlet weak var base_input: UILabel!
    @IBOutlet weak var digits_input: UILabel!
    
    
    @IBAction func baseStepper(_ sender: UIStepper) {
        base_input.text = String(Int(sender.value))
        base = stepper_base.value
    }
    @IBAction func digitsStepper(_ sender: UIStepper) {
        digits_input.text = String(Int(sender.value))
        digits = stepper_digits.value
    }
    @IBAction func tapDetected(_ sender: UITapGestureRecognizer) {
        //print("Tap Detected")
    }
    @IBAction func explain(_ sender: Any) {
        if (explanation.isHidden) {
            digits_input.isHidden = true
            digits_lbl.isHidden = true
            base_input.isHidden = true
            base_lbl.isHidden = true
            stepper_base.isHidden = true
            stepper_digits.isHidden = true
            conversion_ratio.isHidden = true
            colon.isHidden = true
            new_second.isHidden = true
            explanation.isHidden = false
            explanation.isUserInteractionEnabled = true
            explanation.text = load(file: "explanation")
        } else {
            digits_input.isHidden = false
            digits_lbl.isHidden = false
            base_input.isHidden = false
            base_lbl.isHidden = false
            stepper_base.isHidden = false
            stepper_digits.isHidden = false
            conversion_ratio.isHidden = false
            colon.isHidden = false
            new_second.isHidden = false
            explanation.isHidden = true
            explanation.text = ""
        }
    }
    
    func load(file name:String) -> String {
        if let path = Bundle.main.path(forResource: name, ofType: "txt") {
            if let contents = try? String(contentsOfFile: path) {
                return contents
            }
        }
        return ""
    }
    
    func getCptFactor(base: Double, digits: Double) -> Double {
        let new_seconds = pow(base, digits)
        let cpt_factor = new_seconds / 86400.0
        return cpt_factor
    }

    func getDoubleLeftSide() -> Double {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        let total_seconds:Double = Double(seconds + minutes * 60 + hour * 3600)
        return total_seconds
    }

    func getDoubleRightSide() -> Double {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 6
        formatter.maximumIntegerDigits = 0
        let time_string_double = formatter.string(for: Date().timeIntervalSince1970)
        let right_side = (time_string_double! as NSString).doubleValue
        return right_side
    }

    func getDoubleMPT(left_side:Double, right_side:Double) -> Double {
        let time_mpt:Double = left_side + right_side
        return time_mpt
    }

    func getCptTime(base:Double, digits:Double) -> String {
        let cpt_factor = getCptFactor(base: base, digits: digits)
        let cpt_time_decimal = getDoubleMPT(left_side: getDoubleLeftSide(), right_side: getDoubleRightSide()) * cpt_factor
        return String(Int(floor(cpt_time_decimal)), radix: Int(base))
    }
    
//    func getCptHighPrecision(base:Double, digits:Double) -> String {
//        let cpt_factor = getCptFactor(base: base, digits: digits)
//        let cpt_time_decimal = String(getDoubleMPT(left_side: getDoubleLeftSide(), right_side: getDoubleRightSide()) * cpt_factor.truncatingRemainder(dividingBy: 1.0))
//        let left = String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 2)])
//        let right = String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 2)]) + String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 3)]) + String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 4)]) + String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 5)]) + String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 6)]) + String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 7)])
//
//
//        return right
//    }

    private var base: Double = 16
    private var digits: Double = 4
    
    
    
    
    private var latestTimeUpdated:CFTimeInterval = CACurrentMediaTime()
    private var startedTime:CFTimeInterval = CACurrentMediaTime()
    
    private var displayLink:CADisplayLink!
    
    private var count:CGFloat = 0.501
    private var direction:CGFloat = 0.003
    private var RED:CGFloat = 0.005
    private var GREEN:CGFloat = 0.995
    private var BLUE:CGFloat = 0.667
    
    private func setUpDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.preferredFramesPerSecond = 60
        startedTime = CACurrentMediaTime()
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
    }
    
    @objc private func update() {
        let currentTime:CFTimeInterval = CACurrentMediaTime()
        if (count > 0.995 || count < 0.005) {
            direction = -direction
        }
        count += direction * 0.1
        //print(count)
        let color_modifier:CGFloat = direction * 2.5
        if (count < 0.17) {
            RED -= color_modifier / 2
            GREEN -= color_modifier / 2
            BLUE += color_modifier / 2
            //print("Part 1 \(RED) \(GREEN) \(BLUE)")
        } else if (count > 0.17 && count < 0.33) {
            RED -= color_modifier
            GREEN += color_modifier
            BLUE += color_modifier
            //print("Part 2 \(RED) \(GREEN) \(BLUE)")
        } else if (count > 0.33 && count < 0.5) {
            RED -= color_modifier
            GREEN += color_modifier
            BLUE += color_modifier
            //print("Part 3 \(RED) \(GREEN) \(BLUE)")
        } else if (count > 0.5 && count < 0.67) {
            RED += color_modifier
            GREEN -= color_modifier
            BLUE += color_modifier
            //print("Part 4 \(RED) \(GREEN) \(BLUE)")
        } else if (count > 0.67 && count < 0.83) {
            RED += color_modifier
            GREEN -= color_modifier
            BLUE -= color_modifier
            //print("Part 5 \(RED) \(GREEN) \(BLUE)")
        } else if (count > 0.83 && count < 0.995) {
            RED += color_modifier / 2
            GREEN += color_modifier / 2
            BLUE -= color_modifier / 2
            //print("Part 6 \(RED) \(GREEN) \(BLUE)")
        }
        
        self.view.backgroundColor = UIColor.init(red: RED, green: GREEN, blue: BLUE, alpha: 1)
        
        time_display.text = getCptTime(base: base, digits: digits)
        
        let factor = 1 / getCptFactor(base: base, digits: digits)
        conversion_ratio.text = String(Double(round(1000*factor)/1000)) + " seconds"
        latestTimeUpdated = currentTime
    }
    

}

