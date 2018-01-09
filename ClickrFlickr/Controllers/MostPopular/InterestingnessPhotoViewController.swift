//
//  InterestingnessPhotoViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 11/15/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit
import CoreData

class InterestingnessPhotoViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView?
    
    private var blockOperations = [BlockOperation]()
    private let refreshControl = UIRefreshControl()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<PhotoEntitie> = {
        let context = CoreDatastack.default.mainManagedObjectContext
        let fetchRequest: NSFetchRequest<PhotoEntitie> = PhotoEntitie.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "indexOfPopular", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    private let spacingItem: CGFloat = 2
    private let photoFrameSize: CGFloat = 8
    private let reuseIdentifier = "CellInterestingnessPhoto"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        guard let collectionView = collectionView else {return}
    
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadData), for: .valueChanged)
        refreshControl.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        refreshControl.attributedTitle = NSAttributedString(string: "Loading...", attributes: [.foregroundColor: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
        
        collectionView.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        view.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        
        loadData()
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
    }
    
    @objc private func loadData() {
        
        let activityIndicator = addActivityIndecator()
        view.addSubview(activityIndicator)
        
        InterestingnessPhotoNetworkservice.parseJsonForInterestingnessPhoto() {[weak self] success in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                
                if self?.refreshControl.isRefreshing == true {
                    self?.refreshControl.endRefreshing()
                }
            }
        }
    
    }
    
    private func addActivityIndecator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.center = view.center
        activityIndicator.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let collectionView = collectionView else {return}
        let offset = collectionView.contentOffset
        let width = collectionView.bounds.size.width
        let newWidth = size.width
        let index = offset.x / width
        let newOffset = CGPoint(x: index * newWidth, y: offset.y)

        collectionView.setContentOffset(newOffset, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageLoader.cleanAllCash()
    }
    
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate

extension InterestingnessPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {return 0}
        print(sections[section].numberOfObjects)
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InterstingnessPhotoCollectionViewCell
        configureCell(cell: cell, atIndexPath: indexPath)
        return cell
        
    }
    
    private func configureCell(cell: InterstingnessPhotoCollectionViewCell, atIndexPath indexPath: IndexPath) {
        
        let photoEntitie = fetchedResultsController.object(at: indexPath)
        cell.photo.alpha = 0
        guard let imageURL = photoEntitie.imageURL, let collectionView = collectionView else {return}
        
        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            cell.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.configure(with: photoEntitie, image: nil)
        }
        ImageLoader.loadImageUsingUrlString(urlString: imageURL) { image in
            guard let image = image else {return}
            if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
                cell.configerOnlyPhoto(image: image)
            } else {
                cell.configure(with: photoEntitie, image: image)
            }
            UIView.animate(withDuration: 0.5, delay: 0, options: [.allowUserInteraction, .curveEaseInOut], animations: {
                cell.photo.alpha = 1
            }, completion: nil)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            
            guard let navigationController = navigationController, let tabBarController = tabBarController else {return}
            
            if navigationController.isNavigationBarHidden {
                navigationController.isNavigationBarHidden = false
                tabBarController.tabBar.isHidden = false
            } else {
                navigationController.isNavigationBarHidden = true
                tabBarController.tabBar.isHidden = true
            }
            
        } else {
            let layout = CenterCellCollectionViewFlowLayout()
            collectionView.setCollectionViewLayout(layout, animated: false) { [weak self] (success) in
                guard let strongSelf = self else {return}
                if success {
                    strongSelf.collectionView?.reloadItems(at: [indexPath])
                }
            }
            
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            collectionView.bounces = false
            let closeItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel"), style: .plain , target: self , action: #selector(closeButtonPressed))
            closeItem.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            navigationItem.rightBarButtonItem = closeItem
        }
    }
    
    @objc private func closeButtonPressed() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        guard let collectionView = collectionView else {return}
        collectionView.setCollectionViewLayout(layout, animated: true) { (success) in
            if success {
                let visibleCells = collectionView.indexPathsForVisibleItems
                collectionView.reloadItems(at: visibleCells)
            }
        }
        collectionView.decelerationRate = UIScrollViewDecelerationRateNormal
        collectionView.bounces = true
        navigationItem.rightBarButtonItem = nil
    }
    
}

extension InterestingnessPhotoViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let collectionView = collectionView else {return}
        
        if type == .insert {
            blockOperations.append(BlockOperation(block: {
                if let newIndexPath = newIndexPath {
                    collectionView.insertItems(at: [newIndexPath])
                }
            }))
        }
        
        if type == .update {
            blockOperations.append(BlockOperation(block: {
                if let indexPath = indexPath {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.reuseIdentifier, for: indexPath) as! InterstingnessPhotoCollectionViewCell
                    self.configureCell(cell: cell, atIndexPath: indexPath)
                }
            }))
        }
        
        if type == .delete {
            blockOperations.append(BlockOperation(block: {
                if let indexPath = indexPath {
                    collectionView.deleteItems(at: [indexPath])
                }
            }))
        }
        
        if type == .move {
            blockOperations.append(BlockOperation(block: {
                if let indexPath = indexPath {
                    collectionView.deleteItems(at: [indexPath])
                }
            }))
            
            blockOperations.append(BlockOperation(block: {
                if let newIndexPath = newIndexPath {
                    collectionView.insertItems(at: [newIndexPath])
                }
            }))

        }
      
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
         guard let collectionView = collectionView else {return}
  
        collectionView.performBatchUpdates({
            guard let sections = fetchedResultsController.sections else {return}
            print("controllerDidChangeContent: \(sections[0].numberOfObjects)")
            
            for operation in self.blockOperations {
                operation.start()
            }
        }, completion: nil)
        
    }

}

extension InterestingnessPhotoViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionViewLayout is CenterCellCollectionViewFlowLayout {
            if #available(iOS 11.0, *) {
                return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height - (collectionView.safeAreaInsets.bottom + collectionView.safeAreaInsets.top))
            } else {
                return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height - (collectionView.layoutMargins.bottom + collectionView.layoutMargins.top))
            }
        }
        
        let photoEntitie = fetchedResultsController.object(at: indexPath)

        let width = collectionView.bounds.size.width

        guard let aspectSize = photoEntitie.aspectRatio, let aspectSizeFloat = Float(aspectSize) else {
            return CGSize(width: 0, height: 0)
        }
        
        let photoHeight = (width - 2 * photoFrameSize) * CGFloat(aspectSizeFloat)
        
        let height = photoHeight

        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionViewLayout is CenterCellCollectionViewFlowLayout {
            return 0
        }
        return 20
    }

}

