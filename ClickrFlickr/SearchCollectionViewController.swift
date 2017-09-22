//
//  SearchCollectionViewController.swift
//  ClickrFlickr
//
//  Created by Artur Olar on 9/20/17.
//  Copyright © 2017 Artur Olar. All rights reserved.
//

import UIKit


class SearchCollectionViewController: UICollectionViewController {


    var arrayPhotosData = [[String: String]]()

    override func viewDidLoad() {
        super.viewDidLoad()
        AuthorizedViewController.delegate = self
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return arrayPhotosData.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SearchCollectionViewCell

        guard let title = arrayPhotosData[indexPath.row]["title"] else { return cell }

        cell.titlePhoto.text = title

        guard let farm = arrayPhotosData[indexPath.row]["farm"] else { return cell }

        guard let server = arrayPhotosData[indexPath.row]["server"] else { return cell }

        guard let id = arrayPhotosData[indexPath.row]["id"] else { return cell }

        guard let secret = arrayPhotosData[indexPath.row]["secret"] else { return cell }

        let url = URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg")

        let data = try? Data(contentsOf: url!)

        if let imageData = data {
            cell.photo.image = UIImage(data: imageData)
        }

        return cell
    }

    func getPhotosdata (data: Data, completion: @escaping ([[String: Any]]) -> ()) {
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as AnyObject
            if let photos = jsonData["photos"] as? [String: Any] {

                if let photo = photos["photo"] as? [[String: Any]] {

                    for arrayValue in photo {

                        var helpDict: [String: String] = [:]

                        for (key, value) in arrayValue {
                            switch key {
                            case "title", "owner", "server", "id", "secret", "farm":
                                let valueStr = String(describing: value)
                                helpDict[key] = valueStr
                            default:
                                break
                            }
                        }
                        arrayPhotosData.append(helpDict)
                    }
                }
            }
        } catch {
            print("Some ERROR JSONSerialization")
        }

        completion(arrayPhotosData)
    }

}

extension SearchCollectionViewController: AuthorizedViewControllerDelegate {
    
    func fillPhotoData(photoData: Data) {
        
        DispatchQueue.global().async {
            self.getPhotosdata(data: photoData, completion: { (arrayPhotosData) in
                self.arrayPhotosData = arrayPhotosData as! [[String: String]]
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            })
        }
    }
}
