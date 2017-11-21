//
//  ImageCollectionViewController.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 18/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

protocol ImageCollectionViewControllerDelegate {
    func imageCollectionViewControllerDidFinishPickingImage(image: UIImage)
}

class ImageCollectionViewController: UICollectionViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var model: IImageCollectionModel?
    private var dataSource: [CellDisplayModel] = []
    
    public var delegate: ImageCollectionViewControllerDelegate?
    
    private let itemsPerRow: CGFloat = 3
    private let reuseIdentifier = "ImageCollectionCell"
    private let sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func injectDependencies(model: ImageCollectionModel) {
        self.model = model
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.model?.delegate = self
        model?.fetchImages()
    }

    //MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        if let imageCell = cell as? ImageCollectionCell {
            let imageUrl = self.dataSource[indexPath.row].imageURL
            imageCell.imageUrl = imageUrl
            self.setImageView(with: imageUrl, for: imageCell)
        }
        return cell
    }
    
    private func setImageView(with url: String, for cell: ImageCollectionCell) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let url = URL(string: url) else { return }
            
            if String(describing: url) == cell.imageUrl {
                let contentsOfURL = try? Data(contentsOf: url)
                if  let imageData = contentsOfURL  {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        if String(describing: url) == cell.imageUrl  {
                            cell.imageInCell?.image = image
                        }
                    }
                }
            }
        }
    }
    
    //MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ImageCollectionCell,
            let image = cell.imageInCell.image {
                delegate?.imageCollectionViewControllerDidFinishPickingImage(image: image)
        }
        self.dismiss(animated: true, completion: nil)
    }
}

extension ImageCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

extension ImageCollectionViewController: IImageCollectionModelDelegate {
    func setup(dataSource: [CellDisplayModel]) {
        self.dataSource = dataSource
        
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.collectionView?.reloadData()
        }
    }
    
    func show(error: String) {
        let alertController = UIAlertController(title: "Ошибка загрузки изображений",
                                                message: error,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK",
                                                style: .default,
                                                handler: nil))
        present(alertController,
                animated: true,
                completion: nil)
    }
}
