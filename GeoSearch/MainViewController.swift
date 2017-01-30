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




class MainViewController: UIViewController, NSFetchedResultsControllerDelegate
{
    @IBOutlet weak var hoverBar: UIView!

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var mapHeight: NSLayoutConstraint!
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<Restaurant>!

    var coordinates = [CLLocationCoordinate2D]()
    var polygon = MKPolygon()
    let screenHight = UIScreen.main.bounds.size.height

    let clusteringManager = FBClusteringManager()
    let configuration = FBAnnotationClusterViewConfiguration.default()


    override func viewDidLoad() {
        super.viewDidLoad()


        let loc = CLLocationCoordinate2DMake(37.750893, -122.451336)
        mapView.region = MKCoordinateRegionMakeWithDistance(loc, 9000, 9000)

        mapHeight.constant = screenHight / 3
        tableViewHeight.constant = screenHight * 2 / 3
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100


    }



    @IBAction func toggleMapEdit(_ sender: UIButton) {
        isEditing = !sender.isSelected
        sender.isSelected = isEditing

        mapView.isUserInteractionEnabled = !isEditing
        
        UIView.animate(withDuration: 1, animations: {
            self.mapView.frame.size.height = self.isEditing ? self.screenHight : self.screenHight / 3
        })
        mapHeight.constant = isEditing ? screenHight : screenHight / 3
        tableViewHeight.constant = isEditing ? 0 : screenHight * 2 / 3
        if isEditing {
            clusteringManager.removeAll()
        }

        
    
        tableView.isHidden = isEditing



    }

    override func viewDidLayoutSubviews() {

        if !isEditing && coordinates.count > 0 {
            let boundingMapRect = polygon.boundingMapRect


            mapView.visibleMapRect = mapView.mapRectThatFits(boundingMapRect)
            let center = MKCoordinateForMapPoint(boundingMapRect.getCenter())
            SearchNearBy(center)

        }
    }

    func SearchNearBy(_ coordinate: CLLocationCoordinate2D) {
        let request: NSFetchRequest<Restaurant> = Restaurant.fetchRequest()
        let hash = Geohash.encode(latitude: coordinate.latitude, longitude: coordinate.longitude, 5)
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
                self.feedFBAnnotations()
                self.tableView.reloadData()
            }


        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }

    }
    

    func feedFBAnnotations () {

        var pinArray: [FBAnnotation] = []
        for object in fetchedResultsController.fetchedObjects! {
            let item: Restaurant = object
            let coordinat = CLLocationCoordinate2D(latitude: item.latitude as! CLLocationDegrees, longitude: item.longitude  as! CLLocationDegrees)
            let  point = MKMapPointForCoordinate(coordinat)
            if  pointIsInside(point: point, polygon: polygon) {
                let pin = FBAnnotation()
                pin.coordinate = coordinat
                pinArray.append(pin)
            }
        }
        DispatchQueue.main.async {
            self.clusteringManager.add(annotations: pinArray)
            self.mapView.showAnnotations(pinArray, animated: true)
      //      self.clusteringManager.display(annotations: pinArray, onMapView: self.mapView)

        }
    }
    
    func pointIsInside(point: MKMapPoint, polygon: MKPolygon) -> Bool {
        let mapRect = MKMapRectMake(point.x, point.y, 0.00001, 0.00001)
        return polygon.intersects(mapRect)
    }

    @IBAction func zoomIn(_ sender: Any) {
        zoomMap(byFactor: 0.5)
    }

    @IBAction func zoomOut(_ sender: Any) {
        zoomMap(byFactor: 2)
    }
    
    func zoomMap(byFactor delta: Double) {
        var region: MKCoordinateRegion = self.mapView.region
        var span: MKCoordinateSpan = mapView.region.span
        span.latitudeDelta *= delta
        span.longitudeDelta *= delta
        region.span = span
        mapView.setRegion(region, animated: true)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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

        if isEditing {
            // Convert touches to map coordinates
            for touch in touches {
                let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
                coordinates.append(coordinate)

            }

            // Remove existing polygon
            mapView.remove(polygon)

            polygon = MKPolygon(coordinates: &coordinates, count: coordinates.count)
            mapView.add(polygon)
        }
    }




    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}


extension MainViewController: UITableViewDelegate, UITableViewDataSource {


    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolygonRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 5.0
        return renderer
    }




    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = fetchedResultsController.sections?[section]
        return "Zip code: \(section!.name)"
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        guard fetchedResultsController != nil else { return 0 }
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = fetchedResultsController.sections?[section].numberOfObjects
        return count ?? 0
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! StoreCell
        let section = fetchedResultsController.sections?[indexPath.section]
        let restaurant: Restaurant = section!.objects?[indexPath.row] as! Restaurant
        cell.name?.text = restaurant.name!

        return cell
    }
}


extension MainViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {

        DispatchQueue.global(qos: .userInitiated).async {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth = self.mapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth

            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale: scale)

            DispatchQueue.main.async {
                self.clusteringManager.display(annotations: annotationArray, onMapView: self.mapView)
            }
        }

    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        var reuseId = ""

        if annotation is FBAnnotationCluster {

            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if clusterView == nil {
                clusterView = FBAnnotationClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: self.configuration)
            } else {
                clusterView?.annotation = annotation
            }

            return clusterView

        } else {

            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView?.pinTintColor = UIColor.green
            } else {
                pinView?.annotation = annotation
            }

            return pinView
        }

    }

}

