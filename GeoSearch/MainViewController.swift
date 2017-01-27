//
//  ViewController.swift
//  GeoSerach
//
//  Created by alexfu on 4/22/16.
//  Copyright © 2016 alexfu. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MainViewController: UIViewController, NSFetchedResultsControllerDelegate
{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<Restaurant>!

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(coreDataStack != nil)

        let request: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        let hash = Geohash.encode(latitude: 37.7702087, longitude: -122.4458823, 5)
        request.predicate = NSPredicate(format: "geohash BEGINSWITH %@", hash)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: coreDataStack.mainContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }

    }


     func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print (fetchedResultsController.sections?[section].objects?.count)
        return fetchedResultsController.sections?[section].objects?.count ?? 0
    }


     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        
        guard let sections = fetchedResultsController.sections else {
            assertionFailure("Sections missing")
            return cell
        }


        let section = sections[indexPath.section]
        let restaurant:Restaurant = section.objects?[indexPath.row] as! Restaurant
        cell.textLabel?.text = restaurant.name!

        return cell
    }




    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }



}

