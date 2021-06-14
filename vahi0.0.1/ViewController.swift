//
//  ViewController.swift
//  vahi0.0.1
//
//  Created by Andrew Baughman on 12/9/20.
//

import UIKit

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
        self.view.backgroundColor = UIColor.systemGray4
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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

    private var base: Double = 16
    private var digits: Double = 4
    
    @objc private func update() {
        time_display.text = getCptTime(base: base, digits: digits)
        
        let factor = 1 / getCptFactor(base: base, digits: digits)
        conversion_ratio.text = String(Double(round(1000*factor)/1000)) + " seconds"
    }
}
