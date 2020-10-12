//
//  UIViewController+Extension.swift
//  MiniPedia
//
//  Created by Agus RoomMe on 12/10/20.
//  Copyright © 2020 Agus Cahyono. All rights reserved.
//

import UIKit
import SVProgressHUD

extension UITableView {
    
    func showSkeleton() {
    }
    
    func removeSkeleton() {
    }
    
}

extension UICollectionView {
    
    func showSkeleton() {
    }
    
    func removeSkeleton() {
    }
    
}


extension UIViewController {
    
    func showLoading() {
        SVProgressHUD.show()
    }
    
    func hideLoading() {
        SVProgressHUD.dismiss()
    }
    
}
