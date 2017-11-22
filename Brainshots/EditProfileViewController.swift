//
//  EditProfileViewController.swift
//  Brainshots
//
//  Created by Anuradha Sharma on 18/11/16.
//  Copyright © 2016 Anuradha Sharma. All rights reserved.
//

import UIKit
import CoreData

class EditProfileViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    
    //MARK: - Outlets
    @IBOutlet var vwProfile: UIView!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var txtNickName: UITextField!
    @IBOutlet var txtFirstName: UITextField!
    @IBOutlet var txtLastName: UITextField!
    @IBOutlet var txtCountry: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet var btnCancel: UIButton!
    @IBOutlet var btnSave: UIButton!
    @IBOutlet weak var pickerData: UIPickerView!
    @IBOutlet weak var pickerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerGenderBottomCOnstraint: NSLayoutConstraint!
    @IBOutlet weak var pickerGender: UIPickerView!

    // MARK: Variables
    var first_name = String()
    var last_name = String()
    var email = String()
    var gender = String()
    var country = String()
    var image = UIImage()
    var contentArray = NSArray()
    var countriesArray = NSArray()
    var genderArray = NSArray()
    var strCountry = NSString()
    var strGender = NSString()
    var isCountry = Bool()
    var isGender = Bool()
    
    let picker = UIImagePickerController()
    
    //MARK:- View Did Load
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        CommonFunctions.sharedInstance.setupView(view:txtNickName)
        CommonFunctions.sharedInstance.setupView(view:txtFirstName)
        CommonFunctions.sharedInstance.setupView(view:txtLastName)
        CommonFunctions.sharedInstance.setupView(view:txtCountry)
        CommonFunctions.sharedInstance.setupView(view: txtGender)
        CommonFunctions.sharedInstance.setupButtonBorder(vw: vwProfile)
        
        picker.delegate = self
        pickerData.delegate = self
        pickerGender.delegate = self
        
        pickerBottomConstraint.constant = -250
        pickerGenderBottomCOnstraint.constant = -250
       
        countriesArray = getCountriesList()
        genderArray = ["Male","Female"]
        strCountry = countriesArray.object(at: 0) as! NSString
        strGender = genderArray.object(at: 0) as! NSString
        
        fillDetails()

    }
    
    func getCountriesList()->NSArray {
    
        var arrayCountry = [String]()
        
        let bundle = Bundle.main
        let path = bundle.path(forResource: "countries", ofType: "txt")
        
        do{
            arrayCountry = try String.init(contentsOfFile: path!).components(separatedBy: "\n")
        }
        catch{
            print(error)
        }
    
        return arrayCountry as NSArray
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK:- Fill Details Method
    func fillDetails() {
    
        txtFirstName.text = first_name.capitalized
        txtLastName.text = last_name.capitalized
        txtCountry.text = country.capitalized
        txtGender.text = gender.capitalized
        
        let profileImage : UIImage = CommonFunctions.sharedInstance.getProfileImage()
        imgProfile.image = CommonFunctions.sharedInstance.cropToBounds(image: profileImage, width: Double(imgProfile.frame.size.width), height: Double(imgProfile.frame.size.height))
    }
        
    func addNickName(){
    
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Profile", in: context)
        let request: NSFetchRequest<Profile> = Profile.fetchRequest()
        request.entity = entity
        
        do {
            
            let fetchResults = try getContext().fetch(request)
            for trans in fetchResults as [NSManagedObject] {
                
                if trans.value(forKey: "nickname") != nil {
                    txtNickName.text = trans.value(forKey: "nickname") as? String
                }
            }
            
        } catch let error as NSError {
            
            print(error.localizedDescription)
        }
    }
    
    // Mark: - Button Save Actions
    @IBAction func btnSave(_ sender: AnyObject) {
        
        self.view.endEditing(true)
        
        if(txtFirstName.text?.isEmpty == false && txtLastName.text?.isEmpty == false && txtCountry.text?.isEmpty == false ) {
            
                  //  gender = checkGender()
                    ChangeProfileDetailsDB()
                    showAlertWithAction()
        }
        else {
            showALert(kFieldsEmpty, target: self)
        }
    }
    
    // MARK:- Show Alert Methods
    func showALert(_ message:String,target:AnyObject) {
        
        let alert = UIAlertController(title: nil , message: message, preferredStyle: UIAlertControllerStyle.alert )
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {Void in})
        alert.addAction(action)
        target.present(alert, animated: true, completion: nil)
    }
    
    func showAlertWithAction()  {
        
        let alert = UIAlertController(title: nil , message: kSaveProfileAlert, preferredStyle: UIAlertControllerStyle.alert )
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { Void in
            _ = self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- Change Profile Details in DB
    func ChangeProfileDetailsDB() {

        let data : NSData = UIImagePNGRepresentation(imgProfile.image!)! as NSData
        
        let fetchRequest : NSFetchRequest<Profile> = Profile.fetchRequest()
        do {
            let searchResults = try getContext().fetch(fetchRequest)
            for trans in searchResults as [NSManagedObject] {
                trans.setValue(data, forKey: "image")
                trans.setValue(txtFirstName.text!, forKey: "firstName")
                trans.setValue(txtLastName.text!, forKey: "lastName")
                trans.setValue(txtGender.text!, forKey: "gender")
                trans.setValue(txtCountry.text!, forKey: "country")
                if(txtNickName.text != nil){
                    trans.setValue(txtNickName.text!, forKey: "nickname")
                }
            }
            
            appDelegate.saveContext()
            
        }catch {
            print("Error with request:\(error)")
        }
    }
    
    //MARK:- ImagePicker Delegates
    func imagePickerController(_ picker: UIImagePickerController,didFinishPickingMediaWithInfo info: [String : Any]){
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        imgProfile.contentMode = .scaleToFill
        let myThumb1 = CommonFunctions.sharedInstance.cropToBounds(image: chosenImage, width: Double(imgProfile.frame.size.width), height: Double(imgProfile.frame.size.height))
        imgProfile.image = myThumb1
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- Image Picker Action Sheet
    func showActionSheet()  {
        
        let pickImageOptions = UIAlertController(title: nil, message:nil, preferredStyle: .actionSheet)
        
        let saveAction = UIAlertAction(title: "Camera", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
                self.picker.allowsEditing = false
                self.picker.sourceType = UIImagePickerControllerSourceType.camera
                self.picker.cameraCaptureMode = .photo
                self.present(self.picker, animated: true, completion: nil)
            } else {
                self.noCamera()
            }
        })
        
        let deleteAction = UIAlertAction(title: "Photo Library", style: .default, handler: {
            
            (alert: UIAlertAction!) -> Void in
            self.picker.allowsEditing = true //2
            self.picker.sourceType = .photoLibrary //3
            self.present(self.picker, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            
        })
        
        pickImageOptions.addAction(deleteAction)
        pickImageOptions.addAction(saveAction)
        pickImageOptions.addAction(cancelAction)
        self.present(pickImageOptions, animated: true, completion: nil)
    }
    
    func noCamera(){
        
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(
            alertVC,
            animated: true,
            completion: nil)
    }
    
    //MARK:- TouchDown Action
    @IBAction func touchDownAction(_ sender: Any) {
        SoundManager.sharedInstance.playButtonPressedSound()
    }
    
    //MARK:- Actions
    //Country and Gender action
    @IBAction func btnCountry(_ sender: Any) {
        
        self.view.endEditing(true)
        pickerGenderDown()
        pickerCountryUp()
    }
    
    @IBAction func btnGender(_ sender: Any) {
        
        self.view.endEditing(true)
        pickerCountryDown()
        pickerGenderUp()
    }
    
    @IBAction func btnCountryPickerDone(_ sender: Any) {
        
            txtCountry.text = strCountry as String
            pickerCountryDown()
    }
    
    @IBAction func btnGenderPickerDone(_ sender: Any) {
        
            txtGender.text = strGender as String
            pickerGenderDown()
    }
    
    @IBAction func btnCancel(_ sender: AnyObject) {
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnUploadPhoto(_ sender: AnyObject) {
        
        showActionSheet()
    }

    //MARK:- PickerView Delegate
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
    
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
    
        if(pickerView == pickerData){
        
          return countriesArray.count
        }
        else{
            return genderArray.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    
        let lbltext = UILabel(frame: CGRect(x: 10, y: 0, width: 300, height: 60))
        
        if(pickerView == pickerData){
        
            lbltext.text = String(describing: countriesArray.object(at: row))
        }
        else{
        
            lbltext.text = String(describing: genderArray.object(at: row))
        }
        
        lbltext.font = UIFont.init(name: kFatFrankRegular, size: 25)
        lbltext.textAlignment = NSTextAlignment.center
        lbltext.textColor = UIColor.white
        
        return lbltext
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
        if(pickerView == pickerData){
            
            strCountry = String(describing: countriesArray.object(at: row)) as NSString
            txtCountry.text = strCountry as String
        }
        else{
            
            strGender = String(describing: genderArray.object(at: row)) as NSString
            txtGender.text = strGender as String
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return 60
    }
    
    //MARK:- Textfield Delegates
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if(textField == txtFirstName || textField == txtLastName) {
            
            guard let text = textField.text else { return true }
            let newLength = text.characters.count + string.characters.count - range.length
            
            let aSet = NSCharacterSet(charactersIn:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered && newLength <= 30
        }
        else {
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        pickerGenderDown()
        pickerCountryDown()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if(textField == txtNickName){
        
            txtFirstName.becomeFirstResponder()
            
        }
        else if (textField == txtFirstName){
            
            txtLastName.becomeFirstResponder()
        }
        
        return true
    }
    
    
    //MARK:- Picker Animations
    func pickerCountryUp(){
        
        self.pickerBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func pickerCountryDown(){
        
        self.pickerBottomConstraint.constant = -250
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func pickerGenderUp(){
        
        self.pickerGenderBottomCOnstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func pickerGenderDown(){
        
        self.pickerGenderBottomCOnstraint.constant = -250
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
}

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSForegroundColorAttributeName: newValue!])
        }
    }
}
