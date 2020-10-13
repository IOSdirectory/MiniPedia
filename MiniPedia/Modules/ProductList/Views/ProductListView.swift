//
//  ProductListView.swift
//  MiniPedia
//
//  Created by Agus RoomMe on 12/10/20.
//  Copyright © 2020 Agus Cahyono. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

enum ListStyle {
    case list
    case column
}

class ProductListView: UIViewController {
    
    init() {
        super.init(nibName: "ProductListView", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.setupCollectionView()
        }
    }
    
    @IBOutlet weak var btnFilter: UIButton!
    @IBOutlet weak var btnFilterMarginBottom: NSLayoutConstraint!
    
    let disposeBag = DisposeBag()
    var viewModel: ProductListViewModel!
    var layout = GridCollectionViewLayout()
    var listStyle = ListStyle.column
    lazy var refreshHandler = RefreshHandler(view: collectionView)
    
    lazy var dataSource: RxCollectionViewSectionedReloadDataSource<ProductSection> = {
        let dataSource = RxCollectionViewSectionedReloadDataSource<ProductSection>(configureCell: { (_, collectionView, indexPath, viewModel) -> UICollectionViewCell in
            let cell: ProductListCell = collectionView.dequeueReusableCell(indexPath: indexPath)
            cell.viewModel = viewModel
            cell.customUI(indexPath.row, collectionView: self.collectionView)
            return cell
        })
        return dataSource
    }()
    
    lazy var btnListStyle = UIBarButtonItem(image: UIImage(systemName: "rectangle.grid.1x2.fill"), style: .done, target: self, action: #selector(self.didChangeListStyle(_:)))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        self.navigationItem.rightBarButtonItem = btnListStyle
    }
    
    private func setupCollectionView() {
        self.navigationItem.title = "My Product"
        self.collectionView.registerReusableCell(ProductListCell.self)
        self.layout.itemsPerRow = 2
        self.layout.itemSpacing = 0
        self.layout.itemHeightRatio = 1.5/1
        self.collectionView.collectionViewLayout = self.layout
        self.collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        self.collectionView.reloadData()
    }
    
    @objc
    func didChangeListStyle(_ sender: UIBarButtonItem) {
        if listStyle == .list {
            btnListStyle.image = UIImage(systemName: "rectangle.grid.1x2.fill")
            listStyle = .column
        } else {
            btnListStyle.image = UIImage(systemName: "rectangle.grid.2x2.fill")
            listStyle = .list
        }
        self.changeListStyle(listStyle)
    }
    
    private func bindViewModel() {
        
        viewModel.getProductList()
        
        viewModel.state
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { state in
                switch state {
                case .loading:
                    self.showLoading()
                case .finish:
                    self.hideLoading()
                default:
                    self.hideLoading()
                }
            }).disposed(by: disposeBag)
        
        viewModel.products
            .asObserver()
            .catchErrorJustReturn([])
            .observeOn(MainScheduler.instance)
            .bind(to: collectionView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        viewModel.products
            .asObserver()
            .subscribe(onNext: {[unowned self] _ in
                self.refreshHandler.end()
            }, onError: { error in
                self.refreshHandler.end()
                let alert = ACAlertsView(position: .bottom, direction: .toRight, marginBottom: 120)
                alert.delay = 5
                alert.show(error.localizedDescription, style: .error)
            }).disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { indexPath in
                self.collectionView.deselectItem(at: indexPath, animated: true)
            }).disposed(by: disposeBag)
        
        collectionView.rx.modelSelected(ProductListCellViewModel.self)
            .observeOn(MainScheduler.instance)
            .bind(to: viewModel.selectedProduct)
            .disposed(by: disposeBag)
        
        refreshHandler.refresh
            .startWith(())
            .asObservable()
            .subscribe(onNext: { [unowned self] in
                self.viewModel.getProductList()
            }).disposed(by: disposeBag)
        
    }
    
    private func changeListStyle(_ style: ListStyle) {
        if style == .list {
            layout.itemsPerRow = 1
            layout.itemSpacing = 0
            layout.itemHeightRatio = 1/1.4
        } else {
            layout.itemsPerRow = 2
            layout.itemSpacing = 0
            layout.itemHeightRatio = 1.5/1
        }
        
        self.collectionView.performBatchUpdates ({
            self.collectionView.reloadData()
        }, completion: nil)
        
    }
    
}

extension ProductListView: UICollectionViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        setPosition(scrollView)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        setPosition(scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        setPosition(scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setPosition(scrollView)
    }
    
    func setPosition(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            self.btnFilterMarginBottom.constant = -100
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.btnFilterMarginBottom.constant = 38
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
}
