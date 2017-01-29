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


extension MKMapRect {

    func getCenter() -> MKMapPoint {
        return MKMapPointMake(MKMapRectGetMidX(self), MKMapRectGetMidY(self))
 }
}

 


class MainViewController: UIViewController, NSFetchedResultsControllerDelegate, MKMapViewDelegate
{
    @IBOutlet weak var hoverBar: UIView!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapHeight: NSLayoutConstraint!
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<Restaurant>!
    
    // Array for holding coordinates
    var coordinates = [CLLocationCoordinate2D]()
    // Polygon to draw on map
    var polygon = MKPolygon()
  //  var mapEditing = false
    let screenHight = UIScreen.main.bounds.size.height


    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let loc = CLLocationCoordinate2DMake(37.750893, -122.451336)
        mapView.region = MKCoordinateRegionMakeWithDistance(loc, 1200, 1200)
    
         mapHeight.constant =  screenHight / 3
        tableViewHeight.constant = screenHight * 2 / 3
    
    }
    
    
    
    @IBAction func toggleMapEdit(_ sender: UIButton) {
        isEditing = !sender.isSelected
        sender.isSelected = isEditing
        
        mapView.isUserInteractionEnabled = !isEditing
        mapHeight.constant = isEditing ? screenHight: screenHight / 3
        tableViewHeight.constant = isEditing ? 0: screenHight * 2 / 3
        tableView.isHidden = isEditing
        
       
    
    }
    
    override func viewDidLayoutSubviews() {
        print("hi")
        if !isEditing && coordinates.count > 0 {
            print(coordinates.count)
            let boundingMapRect = polygon.boundingMapRect
            
            
            mapView.visibleMapRect = mapView.mapRectThatFits(boundingMapRect)
            let center = MKCoordinateForMapPoint(boundingMapRect.getCenter())
            SearchNearBy(center)
            
        }
    }
    
    func SearchNearBy(_ coordinate:CLLocationCoordinate2D ) {
        let request: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        let hash = Geohash.encode(latitude: coordinate.latitude   , longitude: coordinate.longitude, 5)
        request.predicate = NSPredicate(format: "geohash BEGINSWITH %@", hash)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: coreDataStack.mainContext,
                                                              sectionNameKeyPath: "postalCode",
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            DispatchQueue.main.async {
                
                self.tableView.reloadData()
            }
           
            
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
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

    
  

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}


extension MainViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = fetchedResultsController.sections?[section]
        return "Zip code: \(section?.name)"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard  fetchedResultsController != nil else { return 0}
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
