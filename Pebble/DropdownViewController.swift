//
//  DropdownViewController.swift
//  Pebble
//
//  Created by Eddy Mercado on 11/19/24.
//


import UIKit

class DropdownViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var activityTypes: [String] = []
    var onActivitySelected: ((String) -> Void)?
    
    let pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pickerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        pickerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pickerView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return activityTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return activityTypes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        onActivitySelected?(activityTypes[row])
        dismiss(animated: true, completion: nil)
    }
}
