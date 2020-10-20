//
//  HomeViewCoordinator.swift
//  MiniPedia
//
//  Created by Agus RoomMe on 19/10/20.
//  Copyright © 2020 Agus Cahyono. All rights reserved.
//

import RxSwift

class HomeViewCoordinator: ReactiveCoordinator<Void> {
    
    let rootController: UIViewController!
    
    init(rootViewController: UIViewController) {
        self.rootController = rootViewController
    }
    
    override func start() -> Observable<Void> {
        let viewController = rootController as! HomeView
        viewController.viewModel = HomeViewViewModel()
        return Observable.never()
    }
    
}
