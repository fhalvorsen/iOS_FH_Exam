//
//  Top50AlbumsListViewController.swift
//  Opus
//
//  Created on 22/10/2018.
//  Copyright © 2018. All rights reserved.
//

import UIKit

class Top50AlbumsListViewController: UITableViewController{
    
    
    var totalAlbums: [Album] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let topAlbumNib = UINib(nibName: "TopAlbumListViewCell", bundle: nil)
        tableView.register(topAlbumNib, forCellReuseIdentifier: "TopAlbumListViewCell")
        
        let topAlbums = NetworkHandler(from: "https://theaudiodb.com/api/v1/json/1/mostloved.php?format=album")
        
        topAlbums.getTopAlbums { [weak self] result in
            guard let result = result else {
                print("Could not fetch Albums")
                return
            }
            self?.totalAlbums = result
            
        }
        
        
        tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalAlbums.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TopAlbumListViewCell", for: indexPath) as? TopAlbumListViewCell else {
            fatalError("Unable to dequeue TopAlbumCell")
        }
        
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 3
        cell.layer.cornerRadius = 8
        cell.clipsToBounds = true
        
        let album = totalAlbums[indexPath.row]
        
        Utils.convertStrToUIImage(album.strAlbumThumb) { uiImage in
            
            cell.albumImage.image = uiImage
        }
        
        
        cell.albumTitle.text = album.strAlbum
        cell.artistName.text = album.strArtist
        
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let albumDetailVC = storyboard.instantiateViewController(withIdentifier: "AlbumDetailViewController") as? AlbumDetailViewController
        
        let albumDetailData = totalAlbums[indexPath.row]
        
        
        Utils.setUpAndShowModal(album: albumDetailData, albumDetailVC, senderVC: self)
        
    }
    
    
}

