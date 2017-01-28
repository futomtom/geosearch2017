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
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapHeight: NSLayoutConstraint!
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<Restaurant>!

    override func viewDidLoad() {
        super.viewDidLoad()
        let hight = UIScreen.main.bounds.size.height
        
        let loc = CLLocationCoordinate2DMake(37.750893, -122.451336)
        mapView.region = MKCoordinateRegionMakeWithDistance(loc, 1200, 1200)
        mapHeight.constant = hight
        
        let request: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        let hash = Geohash.encode(latitude: 37.7702087, longitude: -122.4458823, 5)
        request.predicate = NSPredicate(format: "geohash BEGINSWITH %@", hash)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: coreDataStack.mainContext,
                                                              sectionNameKeyPath: "postalCode",
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        tableView.isHidden = true

     
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Create polygon renderer
        let renderer = MKPolygonRenderer(overlay: overlay)
        
        // Set the line color
        renderer.strokeColor = UIColor.orange
        
        // Set the line width
        renderer.lineWidth = 5.0
        
        // Return the customized renderer
        return renderer
    }
    
    // MARK: - Get notified when the view begins/ends editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            // Disable the map from moving
            mapView.isUserInteractionEnabled = false
        }
        else {
            // Enable the map to move
            mapView.isUserInteractionEnabled = true
        }
    }

    
    // MARK: - Handle Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If editing
        if isEditing {
            // Empty array
            coordinates.removeAll()
            
            // Convert touches to map coordinates
            for touch in touches {
                let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
                coordinates.append(coordinate)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If editing
        if isEditing {
            // Convert touches to map coordinates
            for touch in touches {
                // Use this method to convert a CGPoint to CLLocationCoordinate2D
                let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
                // Add the coordinate to the array
                coordinates.append(coordinate)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // If editing
        if isEditing {
            print("end \(touches.count)" )
            // Convert touches to map coordinates
            for touch in touches {
                let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
                coordinates.append(coordinate)
            }
            
            // Remove existing polygon
            mapView.remove(polygon)
            
            // Create new polygon
            polygon = MKPolygon(coordinates: &coordinates, count: coordinates.count)
            
            // Add polygon to map
            mapView.add(polygon)
        }
    }

    
    func search() {
        
        do {
            //       try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
    }


    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}


extension MainViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = fetchedResultsController.sections?[section]
        return "Zip code: \(section?.name)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects
        return count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let section = fetchedResultsController.sections?[indexPath.section]
        let restaurant:Restaurant = section!.objects?[indexPath.row] as! Restaurant
        cell?.textLabel?.text = restaurant.name!
        
        return cell!
    }

}
