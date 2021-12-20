//
//  TextFIeldViewController.swift
//  Final_Finalproject
//
//  Created by dong eun shin on 2020/11/01.
//  Copyright © 2020 dong eun shin. All rights reserved.
//



import UIKit
import CoreData
import UserNotifications

class TextFIeldViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
//    var interval = 0
    
    static let newItemDidInsert = Notification.Name(rawValue: "newItemDidInsert")
    
    var target: NSManagedObject?
    
    @IBOutlet weak var imageView: UIImageView!
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var category_segment: UISegmentedControl!
    
    @IBOutlet weak var name_inputfield: UITextField!
    
    @IBOutlet weak var quantity_label: UILabel!
    @IBOutlet weak var quantity_stepper: UIStepper!
    @IBAction func quantity_valueChanged(_ sender: UIStepper) {
        quantity_label.text = "\(Int(sender.value))"
    }
    
    @IBOutlet weak var expirationdate_picker: UIDatePicker!

    @IBOutlet weak var alertTime_picker: UIDatePicker!
    
    @IBOutlet weak var alertbefore_picker: UIPickerView!
    
    @IBAction func cancel_btn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func saveinfo(){
        guard let name = name_inputfield.text else{return}
        var quantity: Int?
        if let quantityStr = quantity_label.text, let quantityVal = Int(quantityStr){
           quantity = quantityVal
        }
        let category = category_segment.selectedSegmentIndex
        let photo = imageView.image!.pngData()
        let expiryData = expirationdate_picker.date
        let alerttime = alertTime_picker.date
        let alertbefore = alertbefore_picker.selectedRow(inComponent: 0)
        if let target = target as? ItemEntity{
            DataManager.shared.updateItem(entity: target, name: name, quantity: quantity, eDay: expiryData, category: category,photo: photo!, alertbefore: alertbefore, alerttime: alerttime){
                NotificationCenter.default.post(name: TextFIeldViewController.newItemDidInsert, object: nil)
                self.dismiss(animated: true, completion: nil)
            }
           }else{
            DataManager.shared.createItem(name: name, quantity: quantity, eDay: expiryData, category: category,photo: photo!, alertbefore: alertbefore, alerttime: alerttime){
               NotificationCenter.default.post(name: TextFIeldViewController.newItemDidInsert, object: nil)
               self.dismiss(animated: true, completion: nil)
               }
           }
//        UIApplication.shared.applicationIconBadgeNumber += 1
        let content = UNMutableNotificationContent()
        content.title = "Tracker Alert"
        content.body = " Your '\(name_inputfield.text ?? " ")' is about to expire"
        content.sound = UNNotificationSound.default
        //content.badge =
        let alertDate : Date = Calendar.current.date(byAdding: .day, value: -1 * alertbefore, to: expiryData)!
        let d = Calendar.current.dateComponents([.year, .month, .day], from: alertDate)
        let year = d.year
        let month = d.month
        let day = d.day
//        print(alertDate)
//        print(alertbefore)
        alertTime_picker.datePickerMode = .time
        let alertTimedate = alertTime_picker.date
        let components = Calendar.current.dateComponents([.hour, .minute], from: alertTimedate)
        let hour = components.hour!
        let minute = components.minute!
        
        var dateComponents = DateComponents(year: year, month: month, day: day)
        dateComponents.hour = hour
        dateComponents.minute = minute

        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: "Alert \(String(describing: name_inputfield.text))", content: content, trigger: trigger)
          
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    @IBAction func save_btn(_ sender: Any) {
        let alerttime2 = alertTime_picker.date
        let dateRangeStart = Date()
        let expiryData2 = expirationdate_picker.date
        let alertbefore2 = alertbefore_picker.selectedRow(inComponent: 0)
        let alertDate2 : Date = Calendar.current.date(byAdding: .day, value: -1 * alertbefore2, to: expiryData2)!
        let components2 = Calendar.current.dateComponents([.day], from: dateRangeStart, to: alertDate2)
        let components3 = Calendar.current.dateComponents([.hour, .minute], from: dateRangeStart, to: alerttime2)
        let availableAlert = components2.day
        let availableHour = components3.hour!
        let availableMin = components3.minute!

        print(dateRangeStart)
        print(alerttime2)
        print(availableHour)
        print(availableMin)
        
        if name_inputfield.text?.isEmpty == true{
            let alert = UIAlertController(title: "Alert", message: "what is the name of this item?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { action -> Void in
                                   //Just dismiss the action sheet
                   })
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }else if(availableAlert! < 0 || (availableAlert! == 0 && availableHour < 0) || (availableAlert! <= 0 && availableHour == 0 && availableMin < 0)){
            let alert2 = UIAlertController(title: "ERROR", message: "This alert is not avilable. Is that okay?", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { action -> Void in
                //Just dismiss the action sheet
                   })
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { action -> Void in
                self.saveinfo()
            })
            alert2.addAction(cancelAction)
            alert2.addAction(okAction)
            self.present(alert2, animated: true, completion: nil)
        }else{
            saveinfo()
            
        }
        
        
    
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view == imageView {
            let alertController: UIAlertController
            alertController = UIAlertController(title: "Edit Item Image", message: "", preferredStyle: .actionSheet)

            alertController.addAction(UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                    if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                        self.imagePicker.delegate = self
                        self.imagePicker.sourceType = .photoLibrary
                        self.imagePicker.allowsEditing = false
                        self.present(self.imagePicker, animated: true, completion: nil)
                }
            }))
            alertController.addAction(UIAlertAction(title: "Take photo", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)){
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = UIImagePickerController.SourceType.camera
                    picker.cameraDevice = UIImagePickerController.CameraDevice.rear
                    self.present(picker, animated: true, completion: nil)
                    
                }else{
                    print("Camera is not avilable")
                }
                
            }))
            alertController.addAction(UIAlertAction(title: "Remove Photo", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                self.imageView.image = UIImage(systemName: "photo.fill.on.rectangle.fill")
                
            }))
            


            let cancelAction: UIAlertAction
            cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
            alertController.addAction(cancelAction)

            self.present(alertController, animated: true, completion: { print("Alert controller shown") })
        }}
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var newImage: UIImage

        if let possibleImage = info[.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[.originalImage] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        imageView.image = newImage
        dismiss(animated: true) //close imagePicker
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
       super.viewDidLoad()
        //UIApplication.shared.applicationIconBadgeNumber = 0
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current
        if let target = target as? ItemEntity{
            navigationItem.title = "Edit"
            name_inputfield.text = target.name
            quantity_label.text = "\(target.quantity)"
            category_segment.selectedSegmentIndex = Int(target.category)
            expirationdate_picker.date = target.eDay!
            if let data = target.value(forKey: "photo") as? Data {
                imageView.image = UIImage(data: data)}
            alertTime_picker.date = target.alerttime!
            alertbefore_picker.selectRow(Int(target.alertbefore), inComponent: 0, animated: false)
        }else{
            navigationItem.title = "Add"
        }
       let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
       doneToolbar.barStyle = .default

       let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
       let undo = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.undo, target: self, action: #selector(tapUndo(sender:)))
       let done = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(tapDone(sender:)))

       let items = [flexSpace,undo, done]
       doneToolbar.items = items
       doneToolbar.sizeToFit()

       name_inputfield.inputAccessoryView = doneToolbar
    }
    @objc func tapDone(sender: Any) {
            self.view.endEditing(true)
        }
    @objc func tapUndo(sender: Any) {
            name_inputfield.text?.removeAll()
        }
}

extension TextFIeldViewController: UIPickerViewDataSource {
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
   }

   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return 60
   }
}

extension TextFIeldViewController: UIPickerViewDelegate {
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return "\(row) day(s)"
   }

}
