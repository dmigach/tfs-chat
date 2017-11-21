//
//  ImageCollectionCell.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 18/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit

class ImageCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageInCell: UIImageView!

    var imageUrl: String?

    override func prepareForReuse() {
        self.imageUrl = nil
        self.imageInCell?.image = #imageLiteral(resourceName: "PhotoPlaceholder")
        super.prepareForReuse()
    }
}
