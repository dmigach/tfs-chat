//
//  ProfileViewController.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 04/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var coreDataSaveButton: UIButton!
    @IBOutlet private weak var profilePhoto: UIImageView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var infoTextField: UITextField!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    @IBOutlet private weak var selectProfilePhotoButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    //MARK: - Actions
    @IBAction func saveWithCoreData(_ sender: UIButton) {
        saveProfile(savingKind: .CoreData)
    }
    
    @IBAction private func selectPhoto(_ sender: UIButton) {
        showPhotoSetup()
    }
    
    @IBAction private func dismissKeyboard(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction private func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Properties
    var model: IProfileModel!
    var currentProfile = ProfileViewModel.createDefaultProfile() {
        didSet {
            model.update(with: currentProfile)
            coreDataSaveButton.isEnabled = model.profileChanged
        }
    }
    var imageCollectonAssembler: ImageCollectionAssembly?


    //MARK: - Static
    static let cornerRadiusForProfilePicture: CGFloat = 50

    
    //MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadUserProfile()
        setupPhotoImageView()
        setupAddPhotoButton()
        
        configureButtonStates()

        nameTextField.delegate = self
        infoTextField.delegate = self
        
        registerForKeyboardNotifications()
        coreDataSaveButton.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profilePhoto.layer.cornerRadius = selectProfilePhotoButton.layer.cornerRadius
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Dependency injection
    func injectDependencies(model: IProfileModel) {
        self.model = model
    }
    
    // MARK: - UI
    func configureButtonStates() {
        coreDataSaveButton.setTitleColor(UIColor.lightGray, for: .disabled)

    }
    
    func setupPhotoImageView() {
        profilePhoto.layer.cornerRadius = ProfileViewController.cornerRadiusForProfilePicture
        profilePhoto.layer.masksToBounds = true
    }
    
    func setupAddPhotoButton() {
        selectProfilePhotoButton.layer.cornerRadius = ProfileViewController.cornerRadiusForProfilePicture
        selectProfilePhotoButton.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20)
    }
    
    private func updateUI(with profile: ProfileViewModel) {
        nameTextField.text = profile.name
        infoTextField.text = profile.info
        profilePhoto.image = profile.profilePhoto
    }

    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moveScreen(_:)),
                                               name: .UIKeyboardWillChangeFrame,
                                               object: nil)
    }
    
    //MARK: - Loading/Saving
    private func loadUserProfile() {
        activityIndicator.startAnimating()
        model.loadProfile(saveKind: .CoreData,
                          completionHandler:  { [unowned self] (profile) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                    self.currentProfile = profile
                    self.updateUI(with: profile)
            }
        })
    }
    
    func saveProfile(savingKind: ProfileSaveKind) {
        if let changed = model?.profileChanged, changed {
            activityIndicator.startAnimating()
            model?.saveProfile(saveKind: savingKind,
                               completionHandler: { [weak self] (success) in
                if let strongSelf = self {
                    strongSelf.activityIndicator.stopAnimating()
                    strongSelf.coreDataSaveButton.isEnabled = false
                    if success {
                        strongSelf.showAlertForSuccessfulSave()
                    } else {
                        strongSelf.showAlertForFailedSave(with: savingKind)
                    }
                }
            })
        }
    }
    
    //MARK: - Saving alerts
    private func showAlertForSuccessfulSave() {
        let alertController = UIAlertController(title: "Данные сохранены",
                                                message: nil,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .default,
                                                handler: nil))
        present(alertController,
                animated: true,
                completion: nil)
    }
    
    private func showAlertForFailedSave(with saveKind: ProfileSaveKind) {
        let alertController = UIAlertController(title: "Ошибка",
                                                message: "Ошибка при сохранении данных",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .default,
                                                handler: nil))
        alertController.addAction(UIAlertAction(title: "Повторить",
                                                style: .default) { _ in
            self.saveProfile(savingKind: saveKind)
        })
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - ScreenMovement
    @objc private func moveScreen(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if endFrame.origin.y >= UIScreen.main.bounds.size.height {
                self.topConstraint?.constant = -16.0
            } else {
                self.topConstraint?.constant = endFrame.size.height/2.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}

//MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate {
    private func showPhotoSetup() {
        let alertController = UIAlertController(title: "Выбрать изображение профиля",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Сделать фото",
                                             style: .default) { _ in
                self.showImagePicker(for: .camera)
            }
            alertController.addAction(cameraAction)
        }
        let photoLibraryAction = UIAlertAction(title: "Выбрать из галереи",
                                               style: .default) { _ in
            self.showImagePicker(for: .photoLibrary)
        }
        
        let imageCollectionAction = UIAlertAction(title: "Загрузить из интернета",
                                               style: .default) { _ in
                                                self.showImageCollection()
        }
        
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
        
        alertController.addAction(cancelAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(imageCollectionAction)

        present(alertController, animated: true, completion: nil)
    }
    
    private func showImageCollection() {
        let imageCollectionNavigationController = ImageCollectionAssembly().assembleImageCollectionModule()
        let imageCollectionController = imageCollectionNavigationController.topViewController as? ImageCollectionViewController
            
        imageCollectionController?.delegate = self
        
        present(imageCollectionNavigationController, animated: true, completion: nil)
    }
    
    private func showImagePicker(for sourceType: UIImagePickerControllerSourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = sourceType
        imagePickerController.modalPresentationStyle = (sourceType == .camera) ? .fullScreen : .popover
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        var image = info[UIImagePickerControllerOriginalImage] as? UIImage
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            image = editedImage
        }
        profilePhoto.image = image
        currentProfile.profilePhoto = image
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UINavigationControllerDelegate
extension ProfileViewController: UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextFieldDelegate
extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        if (textField == nameTextField) {
            currentProfile.name = textField.text!
        } else if (textField == infoTextField) {
            currentProfile.info = textField.text!
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (textField == nameTextField) {
            currentProfile.name = textField.text!
        } else if (textField == infoTextField) {
            currentProfile.info = textField.text!
        }
    }
}

//MARK: - ImageCollectionViewControllerDelegate
extension ProfileViewController: ImageCollectionViewControllerDelegate {
    func imageCollectionViewControllerDidFinishPickingImage(image: UIImage) {
        profilePhoto.image = image
        currentProfile.profilePhoto = image
    }
}
