//
//  Top50AlbumsViewController.swift
//  Opus
//
//  Created on 12/10/2018.
//  Copyright © 2018 All rights reserved.
//

import UIKit




class Top50AlbumsViewController: UICollectionViewController {
    
    //var masterVc = Top50AlbumsMasterViewController()
    
    var topAlbumList = [Album]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    
    var collectionViewFlowLayout:  UICollectionViewFlowLayout!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        masterVc.delegate = self
        //        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        //            self.masterVc.sendAlbumsToVc()
        //        }
        //
        
        
        //register topalbum cell
        let topAlbumNib = UINib(nibName: "TopAlbumCell", bundle: nil)
        collectionView.register(topAlbumNib, forCellWithReuseIdentifier: "TopAlbumCell")
        
        DispatchQueue.global(qos: .background).async {
            let topAlbums = NetworkHandler(from: "https://theaudiodb.com/api/v1/json/1/mostloved.php?format=album")
            topAlbums.getTopAlbums { [weak self] result in
                guard let result = result else {
                    print("Could not fetch Albums")
                    return
                }
                self?.topAlbumList = result
            }
        }
    }
    override func viewWillLayoutSubviews() {
        if collectionViewFlowLayout == nil {
            let numberOfItemsRow:  CGFloat = 2
            let lineSpacing: CGFloat = 15
            let interItemSpacing: CGFloat = 15
            let width = (collectionView.frame.width - (numberOfItemsRow - 1) * interItemSpacing) / numberOfItemsRow
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            collectionViewFlowLayout.itemSize = CGSize(width: CGFloat(width), height: CGFloat(230))
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            collectionViewFlowLayout.sectionInset.top = CGFloat(15)
            
            
            collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
    
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topAlbumList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TopAlbumCell", for: indexPath) as? TopAlbumCell else {
            fatalError("Unable to dequeue TopAlbumCell")
        }
        
        let album = topAlbumList[indexPath.row]
        
        cell.contentView.layer.masksToBounds = true
        cell.layer.cornerRadius = 10
        
        Utils.convertStrToUIImage(album.strAlbumThumb) { uiImage in
            cell.albumImage.image = uiImage
        }
        cell.albumArtist.text = album.strArtist
        cell.albumTitle.text = album.strAlbum
        
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let albumDetailVC = storyboard.instantiateViewController(withIdentifier: "AlbumDetailViewController") as? AlbumDetailViewController
        
        let albumDetailData = topAlbumList[indexPath.row]
        
        Utils.setUpAndShowModal(album: albumDetailData, albumDetailVC, senderVC: self)
        
    }
    
}

//extension Top50AlbumsViewController: AlbumDelegate {
//    func didSendAlbums(_ albums: [TopAlbum]) {
//        if albums.count > 0 {
//        self.topAlbumList = albums.map({$0})
//        print("Receiving from delegate: \(albums.count)")
//        //self.navigationItem.title = "Top \(self.allAlbums.count) Albums"
//        } else {
//            print("Did not receive anything from delegate")
//        }
//
//    }
//}

class Utils {
    
    
    static func convertStrToUIImage(_ albumUrl: String, completion: @escaping(UIImage) -> Void) {
        let imageUrl: URL
        
        /*Some of the albums returns nil while others returns empty string from API
         i need to check if the string is empty since it only checks for NIL in decodable struct
         */
        if(albumUrl == "") {
            imageUrl = URL(string: "https://biturl.top/y6fMje")!
        } else {
            imageUrl = URL(string: albumUrl)!
        }
        DispatchQueue.global(qos: .background).async {
            if let data = try? Data(contentsOf: imageUrl) {
                let image: UIImage = UIImage(data: data)!
                DispatchQueue.main.async {
                    completion(image)
                }
            } else {
                fatalError()
            }
        }
    }
    
    static func setUpAndShowModal( album: Album, _ albumDetailVC: AlbumDetailViewController?, senderVC: UIViewController) {
        
        albumDetailVC?.albumImageStr = album.strAlbumThumb
        albumDetailVC?.albumTitleData = album.strAlbum
        albumDetailVC?.albumArtistData = album.strArtist
        albumDetailVC?.albumIdString = album.idAlbum
        albumDetailVC?.albumRelData = album.intYearReleased
        
        
        let navController = UINavigationController(rootViewController: albumDetailVC!)
        navController.setNavigationBarHidden( true, animated: true)
        senderVC.present(navController, animated: true)
        
        
    }
}

