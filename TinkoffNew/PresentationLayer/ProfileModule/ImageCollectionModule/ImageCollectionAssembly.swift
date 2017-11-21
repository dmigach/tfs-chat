//
//  ImageCollectionAssembly.swift
//  TinkoffNew
//
//  Created by Dmitry Gachkovsky on 21/11/2017.
//  Copyright © 2017 Dmitry Gachkovsky. All rights reserved.
//

import UIKit
import Foundation

class ImageCollectionAssembly {
    
    func assembleImageCollectionModule() -> UINavigationController {
        let imageCollectionStoryboard = UIStoryboard(name: "ImageCollection", bundle: nil)
        let imageCollectionNavigationController = imageCollectionStoryboard.instantiateInitialViewController() as! UINavigationController
        return imageCollectionNavigationController
    }
}
