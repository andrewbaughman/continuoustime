//
//  ViewController.swift
//  vahi0.0.1
//
//  Created by Andrew Baughman on 12/9/20.
//

import UIKit //I don't recall what this is important for, but it is.


//I guess I'm not currently using this hexcolor thing, but it's for inputting a hex and getting a usable color.
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

//This class controls the app. I don't know anything beyond that.
class ViewController: UIViewController {

    //These @IBOutlet things are how you connect visual elements to the code.
    @IBOutlet weak var stepper_base: UIStepper! //the increment/decrement thing
    @IBOutlet weak var stepper_digits: UIStepper!
    @IBOutlet weak var time_display: UILabel! //this is the main clock
    override func viewDidLoad() { //This makes things happen as soon as you load the app
        super.viewDidLoad()
        stepper_base.value = 16
        stepper_digits.value = 4
        
    }
    
    override func viewWillAppear(_ animated: Bool) { //I don't know why it's separate from viewDidLoad(), but this is how I get update by Frames to work, so I didn't argue. Does the same thing as far as I know.
        super.viewWillAppear(animated)
        self.setUpDisplayLink()
    }
    
    override func viewWillDisappear(_ animated: Bool) { //I don't know, but it's part of making Frames work.
        super.viewWillDisappear(animated)
        displayLink.remove(from: .main, forMode: RunLoop.Mode.common)
    }
    
    
    //These are all the things with text. The words Base, Digits, and the number on the display that associate with those words and +/- buttons.
    @IBOutlet weak var digits_lbl: UILabel!
    @IBOutlet weak var base_lbl: UILabel!
    @IBOutlet weak var base_input: UILabel!
    @IBOutlet weak var digits_input: UILabel!
    @IBOutlet weak var explanation: UITextView! //This is the scrollable text field. Unfortunately it's  editable. I'll fix this at some point before App Store.
    
    //@IBAction is how I make the +/- buttons do stuff.
    @IBAction func baseStepper(_ sender: UIStepper) {
        base_input.text = String(Int(sender.value))
        base = stepper_base.value
    }
    @IBAction func digitsStepper(_ sender: UIStepper) {
        digits_input.text = String(Int(sender.value))
        digits = stepper_digits.value
    }
    
    //Not used right now, but I was hoping to make a tap on the screen do something. It works actually, but I wasn't able to get other things to work.
    @IBAction func tapDetected(_ sender: UITapGestureRecognizer) {
        print("Tap Detected")
    }
    
    //Makes the scrollable text field appear/disappear
    @IBAction func explain(_ sender: Any) {
        if (explanation.isHidden) {
            explanation.isHidden = false
        } else {
            explanation.isHidden = true
        }
    }
    
    //This is all the time functions
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
    //End of the time functions
    
    
    //I was hoping to use this function to acquire only the right side of the decimal point for setting background color. It worked, but was a bad idea.
//    func getCptHighPrecision(base:Double, digits:Double) -> String {
//        let cpt_factor = getCptFactor(base: base, digits: digits)
//        let cpt_time_decimal = String(getDoubleMPT(left_side: getDoubleLeftSide(), right_side: getDoubleRightSide()) * cpt_factor.truncatingRemainder(dividingBy: 1.0))
//        let left = String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 2)])
//        let right = String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 2)]) + String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 3)]) + String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 4)]) + String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 5)]) + String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 6)]) + String(cpt_time_decimal[cpt_time_decimal.index(cpt_time_decimal.startIndex, offsetBy: 7)])
//
//
//        return right
//    }

    //I don't know why they're private, but it might be important. Need to be doubles because types are important
    private var base: Double = 16
    private var digits: Double = 4
    
    
    
    //This is all update by Frames code.
    private var latestTimeUpdated:CFTimeInterval = CACurrentMediaTime()
    private var startedTime:CFTimeInterval = CACurrentMediaTime()
    
    private var displayLink:CADisplayLink!
    
    private var count:CGFloat = 0.01
    private var direction:CGFloat = 0.003
    
    private func setUpDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink.preferredFramesPerSecond = 60
        startedTime = CACurrentMediaTime()
        displayLink.add(to: .main, forMode: RunLoop.Mode.common)
    }
    
    
    
    //Another function to make the background a result of hextime. It worked in tandem with getCptHighPrecision(), but again not a good result.
//    func getHexColor(hex: String) -> String {
//        let char2 = hex[hex.index(hex.startIndex, offsetBy: 0)]
//        let char3 = hex[hex.index(hex.startIndex, offsetBy: 1)]
//        let char4 = hex[hex.index(hex.startIndex, offsetBy: 2)]
//        let char5 = hex[hex.index(hex.startIndex, offsetBy: 3)]
//        let char6 = hex[hex.index(hex.startIndex, offsetBy: 4)]
//        let char7 = hex[hex.index(hex.startIndex, offsetBy: 5)]
//
//        let red = String(char2) + String(char7)
//        let green = String(char3) + String(char6)
//        let blue = String(char4) + String(char5)
//
//        return red + green + blue + "ff"
//    }
    
    //This function runs every Frame
    @objc private func update() {
        let currentTime:CFTimeInterval = CACurrentMediaTime() //important for frames
        //Keeps background in bounds.
        if (count > 0.95 || count < 0.005) {
            direction = -direction
        }
        count += direction
        
        self.view.backgroundColor = UIColor.init(red: count, green: count / 2.0, blue: 0.1 / count, alpha: 1)
        
        time_display.text = getCptTime(base: base, digits: digits) //Sets the screen label to say time
        
        latestTimeUpdated = currentTime //part of frames code
    }
    

}



//Where I got the frames code: https://medium.com/@AybekCan/basic-understanding-of-cadisplaylink-ae78a5efe976
//It required a basic knowledge of how to use Xcode's UI designer and the ability to figure out what the guy implied, so I was very surprised that it worked when I tested it. 
