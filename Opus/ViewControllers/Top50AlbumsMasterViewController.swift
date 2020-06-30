//
//  Top50AlbumsMasterViewController.swift
//  Opus
//
//  Created on 22/10/2018.
//  Copyright © 2018. All rights reserved.
//

import UIKit

//protocol AlbumDelegate {
//    func didSendAlbums(_ albums: [Album])
//}

class Top50AlbumsMasterViewController: UIViewController {
    
    /*
     For å implementere segmented controll, tenkte jeg at jeg kunne ha en Master viewcontroller som sendte topalbums til "topalbumGridVC" og "topalbumListVC" ved å lazyloade grid og liste viewcontrollerene for å minimere nettverkskall til bare denne viewcontrolleren.
     
     Jeg støtte på et problem/bug som gjorde at programflyten gjorde at lazyloadingen ble instansiert før masterGridViewcontroller (denne klassen), og endte opp med å ikke kunne vise noen album, siden TotalAlbums ble populert etter at grid viewcontroller var lastet inn.
     
     Det ble også et problem hvis man trykket på segmented controller mens nettverkskallet kjørte.
     
     Jeg endte derfor opp med å implementere nettverkskall i hver viewcontroller for å unngå denne buggen da jeg ikke fant ut hvordan jeg kunne løse dette problemet.
     
     Jeg forsøkte å lage et  delegat, og en "hack" for å utsette sending av objektene til viewcontroller som jeg har latt være i koden (kommentert bort) for å vise tankegangen, da jeg brukte en del tid på det.
     */
    
    
    //     var delegate: AlbumDelegate?
    
    var totalAlbums = [Album]() {
        didSet {
            DispatchQueue.main.async {
                self.navigationItem.title = "Top \(self.totalAlbums.count) Albums"
                
            }
        }
    }
    
    @IBOutlet var segmentedController: UISegmentedControl!
    
    
    private lazy var topAlbumsGridVc: Top50AlbumsViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "Top50AlbumsViewController") as! Top50AlbumsViewController
        
        
        /*
         Denne "hacken" løste problemet med visning av album med delegat, men
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
         vc.topAlbumList = self.totalAlbums.map({$0})
         print("Lazy loaded: " , vc.topAlbumList.count)
         }
         */
        
        self.addViewControllerAsChild(childVc: vc)
        return vc
    }()
    
    private lazy var topAlbumsListVc: Top50AlbumsListViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(withIdentifier: "Top50AlbumsListViewController") as! Top50AlbumsListViewController
        
        vc.totalAlbums = self.totalAlbums.map({$0})
        self.addViewControllerAsChild(childVc: vc)
        
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let topAlbums = NetworkHandler(from: "https://theaudiodb.com/api/v1/json/1/mostloved.php?format=album")
        
        topAlbums.getTopAlbums { [weak self] result in
            guard let result = result else {
                print("Could not fetch Albums")
                return
            }
            self?.totalAlbums = result
        }
        
        navigationItem.title = "Loading"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Scroll to top", style: .done, target: self, action: #selector(scrollToTop(_:)))
        
        segmentedController.selectedSegmentIndex = 0
        topAlbumsGridVc.view.isHidden = false
        segmentedController.addTarget(self, action: #selector(selectionDidChange(sender:)), for: .valueChanged)
    }
    
    //    func sendAlbumsToVc() {
    //        let albumsToSend = self.totalAlbums.map({$0})
    //        print(albumsToSend.count)
    //        if let delegate = self.delegate {
    //            delegate.didSendAlbums(self.totalAlbums)
    //            print("sending from mastervc: \(self.secondAlbums.count)")
    //        } else {
    //            print("Delegate not implemented correctly")
    //        }
    //    }
    
    
    //https://www.youtube.com/watch?v=kq-lHR5ZOW0
    @objc func selectionDidChange(sender: UISegmentedControl) {
        topAlbumsGridVc.view.isHidden = !(segmentedController.selectedSegmentIndex == 0)
        topAlbumsListVc.view.isHidden = (segmentedController.selectedSegmentIndex == 0)
    }
    
    private func addViewControllerAsChild(childVc: UIViewController) {
        addChild(childVc)
        
        view.addSubview(childVc.view)
        
        childVc.view.frame = view.bounds
        childVc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        childVc.didMove(toParent: self)
    }
    
    @objc func scrollToTop(_ sender: Any) {
        if !topAlbumsGridVc.view.isHidden { topAlbumsGridVc.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        } else {
            topAlbumsListVc.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
}




