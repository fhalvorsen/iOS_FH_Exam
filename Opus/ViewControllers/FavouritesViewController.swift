//
//  FavouritesViewController.swift
//  Opus
//
//  Created  on 03/12/2018.
//  Copyright © 2018  All rights reserved.
//

import UIKit
import CoreData


class FavouritesViewController: UITableViewController,UICollectionViewDataSource, UICollectionViewDelegate, NSFetchedResultsControllerDelegate {
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //kontroller for database
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    
    var allFavorites: [FavouriteTrack] = []
    var reccomendedArtists = [Reccomended]() {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let favoriteNib = UINib(nibName: "FavoritesViewCell", bundle: nil)
        tableView.register(favoriteNib, forCellReuseIdentifier: "FavoritesViewCell")
        
        //Udemy course iOS12 bootcamp
        //her henter vi entitiet fra database og sorterer etter artist (a-å)
        let fetchRequest =  NSFetchRequest<NSFetchRequestResult>(entityName: "FavouriteTrack")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "artist", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: AppDelegate.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        allFavorites = fetchedResultsController.fetchedObjects as! [FavouriteTrack]
        
        getSimilarArtists(to: allFavorites)
        
        
        tableView.reloadData()
        
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFavorites.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesViewCell", for: indexPath) as? FavoritesViewCell else {
            fatalError("unable to dequeue FavoritesViewCell")
        }
        let favourite = allFavorites[indexPath.row]
        
        cell.artistName.text = favourite.artist
        cell.trackTitle.text = favourite.trackTitle
        cell.trackDuration.text = favourite.trackDuration
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //Sletter valgt favoritt track fra database
            let favoriteToDelete = fetchedResultsController.object(at: indexPath) as! FavouriteTrack
            AppDelegate.context.delete(favoriteToDelete)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            
            tableView.reloadData()
            
            let alertDeleted = UIAlertController(title: "Tired of the song?!", message: "Song deleted", preferredStyle: .alert)
            present(alertDeleted, animated: true) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    alertDeleted.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reccomendedArtists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReccomendedCell", for: indexPath) as! ReccomendedCell
        
        let reccomendedArtist = reccomendedArtists[indexPath.row]
        
        cell.sizeToFit()
        cell.layer.cornerRadius = 5
        
        cell.reccomendedArtistLbl.text = reccomendedArtist.name
        
        
        return cell
    }
    
    //funksjon som lytter til forandringer i core data database samt oppdaterer tableview deretter.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("Change in db")
        allFavorites = fetchedResultsController.fetchedObjects as! [FavouriteTrack]
        getSimilarArtists(to: allFavorites)
        tableView.reloadData()
        
        if allFavorites.isEmpty {
            self.reccomendedArtists = []
        }
        
    }
    
    func getSimilarArtists(to artists: [FavouriteTrack]) {
        // API key limited to 300 request an hour
        var url = "https://tastedive.com/api/similar?type=music&limit=10&k=350796-OPUSexam-HCD3DNWH&q="
        
        let likedArtist = artists.map({$0.artist!})
        
        let uniqueArtists = Array(Set(likedArtist)).joined(separator: ",")
        let parameters = uniqueArtists.replacingOccurrences(of: ",", with: "%2C").replacingOccurrences(of: " ", with: "+")
        
        url.append(parameters)
        print(url)
        if !self.allFavorites.isEmpty{
            let reccomended = NetworkHandler(from: url)
            reccomended.getReccomended{ result in
                guard let result = result else {
                    print("could not find reccomended")
                    return
                }
                self.reccomendedArtists = result.results
                
            }
        }
        
        //resets the url with no artist query
        //https://stackoverflow.com/a/39185097
        if let index = url.range(of: "q=")?.upperBound {
            let substring = url[..<index]
            url = String(substring)
        }
    }
}



