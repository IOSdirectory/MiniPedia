//
//  ProductListCellViewModel.swift
//  MiniPedia
//
//  Created by Agus RoomMe on 12/10/20.
//  Copyright © 2020 Agus Cahyono. All rights reserved.
//

import RxSwift

struct ProductListCellViewModel {
    let didClose = PublishSubject<Void>()
    
    let productName: String
    let productPrice: String
    let productImage: String
    
    init(product: DataProducts) {
        self.productName = product.name
        self.productPrice = product.price
        self.productImage = product.imageURI
    }
    
    
}
