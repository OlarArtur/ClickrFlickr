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

    @IBOutlet weak var collectionView: UICollectionView!
    
    var blockOperations = [BlockOperation]()
    
    lazy var fetchedResultsController: NSFetchedResultsController<PhotoEntitie> = {
        let context = CoreDatastack.default.mainManagedObjectContext
        let fetchRequest: NSFetchRequest<PhotoEntitie> = PhotoEntitie.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "indexOfPopular", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    private let spacingItem: CGFloat = 2
    private let reuseIdentifier = "CellInterestingnessPhoto"
    
    override var shouldAutorotate: Bool {
        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            return true
        } else {
            return false
        }
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        collectionView?.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        view.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        
        let activityIndicator = addActivityIndecator()
        view.addSubview(activityIndicator)
        
        InterestingnessPhotoNetworkservice.parseJsonForInterestingnessPhoto() { success in
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
            }
        }
        
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("\(fetchError), \(fetchError.userInfo)")
        }
        
    }
    
    private func addActivityIndecator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        ImageLoader.cleanAllCash()
    }
    
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate

extension InterestingnessPhotoViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {return 0}
        return fetchedObjects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InterstingnessPhotoCollectionViewCell
        configureCell(cell: cell, atIndexPath: indexPath)
        return cell
        
    }
    
    private func configureCell(cell: InterstingnessPhotoCollectionViewCell, atIndexPath indexPath: IndexPath) {
        
        let photoEntitie = fetchedResultsController.object(at: indexPath)
        cell.photo.alpha = 0
        guard let imageURL = photoEntitie.imageURL else {return}
        
        if collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
            cell.backgroundColor = #colorLiteral(red: 0.1915385664, green: 0.1915385664, blue: 0.1915385664, alpha: 1)
        } else {
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.configure(with: photoEntitie, image: nil)
        }
        ImageLoader.loadImageUsingUrlString(urlString: imageURL) { [weak self] image in
            guard let image = image else {return}
            if self?.collectionView.collectionViewLayout is CenterCellCollectionViewFlowLayout {
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
                    strongSelf.collectionView.reloadItems(at: [indexPath])
                }
            }
            
            collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            let closeItem = UIBarButtonItem(image: #imageLiteral(resourceName: "cancel"), style: .plain , target: self , action: #selector(closeButtonPressed))
            closeItem.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            navigationItem.rightBarButtonItem = closeItem
        }
    }
    
    @objc func closeButtonPressed() {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.setCollectionViewLayout(layout, animated: true) { [weak self] (success) in
            guard let strongSelf = self else {return}
            if success {
                let visibleCells = strongSelf.collectionView.indexPathsForVisibleItems
                strongSelf.collectionView.reloadItems(at: visibleCells)
            }
        }
        collectionView.decelerationRate = UIScrollViewDecelerationRateNormal
        navigationItem.rightBarButtonItem = nil
    }
    
}

extension InterestingnessPhotoViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if type == .insert {
            blockOperations.append(BlockOperation(block: {
                if let indexPath = newIndexPath {
                    self.collectionView.insertItems(at: [indexPath])
                }
            }))
        }
        
        if type == .update {
            if let indexPath = indexPath {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InterstingnessPhotoCollectionViewCell
                configureCell(cell: cell, atIndexPath: indexPath)
            }
        }

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            for operation in self.blockOperations {
                operation.start()
            }
        }, completion: nil)
        
    }

}

extension InterestingnessPhotoViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if collectionViewLayout is CenterCellCollectionViewFlowLayout {
            return collectionView.bounds.size
        }
        let photoEntitie = fetchedResultsController.object(at: indexPath)

        let width = collectionView.bounds.size.width

        guard let aspectSize = photoEntitie.aspectRatio, let aspectSizeFloat = Float(aspectSize) else {
            return CGSize(width: 0, height: 0)
        }
        
        let photoHeight = (width - 16) * CGFloat(aspectSizeFloat)
        
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

