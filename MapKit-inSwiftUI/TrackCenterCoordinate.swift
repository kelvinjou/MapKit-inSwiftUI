//
//  TrackCenterCoordinate.swift
//  MapKit-NoUIKit
//
//  Created by mimi on 4/4/21.
//

import SwiftUI
import MapKit
import CoreLocation

struct TrackCenterCoordinate: View {
    
    @ObservedObject var locationManager = LocationManager()
    @State public var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.71, longitude: -82), span: MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9))
    @State private var location = MKPointAnnotation()
    var userLocation: MKPointAnnotation {
        let mkPointAnnotation = MKPointAnnotation()
        mkPointAnnotation.coordinate = LocationManager().location!.coordinate
        print(mkPointAnnotation)
        return mkPointAnnotation
    }
    @State private var pin: [Pin] = []
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var turnOffOpacity: Bool = false
    @State private var advisoryNotices = [String]()
    

    @State private var showAdvisory: Bool = false
    var mapTypes: [String] = ["standard", "hybrid", "satellite"]
    @State private var addLine: Bool = false
    @State private var currentSelectedMapType = 0
//    @ObservableObject var coordinator = Coordinator(mapView)
    func setCurentLocation() {
        locationManager.$location.sink { location in
            region = MKCoordinateRegion(center: location?.coordinate ?? CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9))
        }
    }
    var body: some View {
        let mapView: MapView = {
            MapView(centerCoordinate: $centerCoordinate, currentSelectedMapType: $currentSelectedMapType, adivsoryNotices: $advisoryNotices, annotation: $location, addLine: addLine)
        }()
        
        return ZStack {
            mapView
                .edgesIgnoringSafeArea(.all)
            Circle()
                .stroke(lineWidth: 4)
                .fill(Color.blue)
                .opacity(0.5)
                .frame(width: 32, height: 32)
            VStack {

                Map(coordinateRegion: $region, interactionModes: .pan, showsUserLocation: true, userTrackingMode: .constant(.follow))
                    .frame(width: 300, height: 300)
                    .mask(Circle())
                    .shadow(radius: 25)
                    .overlay(Circle().stroke(lineWidth: 7).foregroundColor(Color(#colorLiteral(red: 0, green: 0.6509803922, blue: 1, alpha: 1))))


                Spacer()
                HStack {
                    Picker(selection: $currentSelectedMapType, label: Text("Map Selector")) {
                        ForEach(0..<mapTypes.count, id: \.self) { i in
                            Text("\(mapTypes[i])")
                        }
                    }.labelsHidden()
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(maxWidth: 350)
                    .padding(.leading, 75)
                    Spacer()
                    Button(action: {
                        showAdvisory.toggle()
                    }) {
                        Text("Advisory Notices")
                    }
                    Spacer()
//                    Button(action: {
//
////                        addLine = false
//                        print(addLine)
//                    }) {
//                        Image(systemName: "trash")
//                    }.disabled(false)
//                    .buttonStyle(ButtonModifiers(color: Color.red.opacity(0.95)))
//                    Text("\()")
                    Button(action: {
//                        pin.append(Pin(location: CLLocation(coordinate: centerCoordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())))
//                        print(pin)
                        let newLocation = MKPointAnnotation()
                        newLocation.coordinate = centerCoordinate
                        self.location = newLocation
                        addLine = true
                        print(self.addLine)
//                        print(newLocation.coordinate)
                        print(newLocation.coordinate)
                    }) {
                        Image(systemName: "plus")
                    }.buttonStyle(ButtonModifiers(color: Color.black.opacity(0.70)))

                }
            }.sheet(isPresented: $showAdvisory) {
                List(advisoryNotices, id: \.self) { i in
                    Text(i)
                    
                }
                if advisoryNotices.isEmpty {
                    Text("\(mapView.ETA)")
                    Text("No Advisory notices for this route")
                }
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    static var defaultRegion = CLLocationCoordinate2D(latitude: 40.71, longitude: -82)
    @ObservedObject var locationManager = LocationManager()
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var currentSelectedMapType: Int
    @Binding var adivsoryNotices: [String]

    @Binding var annotation: MKPointAnnotation
    
    @State var ETA = TimeInterval()
    
     var addLine: Bool
    @State var route: MKRoute?
    let mapView = MKMapView()
    func makeUIView(context: Context) -> MKMapView {
        
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
//        print(mapView.userLocation.coordinate)
        mapView.userTrackingMode = .follow
        locationManager
        
//        mapView.mapType = .satellite

        return mapView
    }
    
//    func render(_ location: CLLocation) {
//        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
//
//        let region = MKCoordinateRegion(center: coordinate, span: span)
//
//        mapView.setRegion(region, animated: true)
//    }
    
    
    func updateUIView(_ view: UIViewType, context: Context) {
            //annotations over here are the new annotations(passed from the SwiftUI view
        
//        if annotation != view.annotations.count {
                                //view.annotations are the old annotations
            
            if locationManager.location != nil {
                let request = MKDirections.Request()

                request.source = MKMapItem(placemark: MKPlacemark(coordinate: view.userLocation.coordinate))
//                request.source = MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
                request.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotation.coordinate))
                request.requestsAlternateRoutes = true
                request.transportType = .automobile
                

                let directions = MKDirections(request: request)
                directions.calculate { (response, err) in
                    //          checking to make sure something is there and would assign it to "route" if response is not nil.
                    guard let route = response?.routes.first else { return }
                    
                    if let oldRoute = self.route {
                        print("here")
                        view.removeAnnotation(annotation)
                        view.removeOverlay(oldRoute.polyline)
                        
//                        view.dequeueReusableAnnotationView(withIdentifier: "point")
                    }
                    self.route = route
                    
                    //          a route that would be drawn between these 2 places
                    view.addOverlay(self.route!.polyline, level: .aboveRoads)
                    view.addAnnotation(annotation)
//                    self.addLine = true
                    view.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40), animated: true)
                    
//                    self.travelTime = route.expectedTravelTime
                    
                    self.adivsoryNotices = route.advisoryNotices
                    
                    ETA = route.expectedTravelTime
                    print("\(ETA / 60) minutes or", String(format: "%.02f", ETA / 60 / 60), "hour(s)")
                    
                    let dist = route.distance
                    print(String(format: "%.02f", convertKMtoMiles(from: dist)), "miles")
                    
                    
//                directions.calculateETA { (etaResponse, err) in
//                    if let error = err {
//                        print(error.localizedDescription)
//                    } else {
//                        print("\(Int(etaResponse?.expectedTravelTime ?? 0)/60) min")
//                    }
                }
            }
//        }
    }
    private func convertKMtoMiles(from meter: Double) -> Double {
        let conversionRate = (meter / 1000) * 0.621371
        return conversionRate
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
}
class Coordinator: NSObject, MKMapViewDelegate, ObservableObject {
    @Published var addressLabel: String?
    var locationManager = LocationManager()
    var previousLoc: CLLocation?
    
    var parent: MapView?
    
    
    init(_ parent: MapView) {
        
        self.parent = parent
    }
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        //            passed from @Binding in MapView(which is passed from main view)
        parent!.centerCoordinate = mapView.centerCoordinate
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(#colorLiteral(red: 0, green: 0.6509803922, blue: 1, alpha: 1))
        renderer.lineWidth = 5
        return renderer
    }
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    
    //        Geocoding
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        locationManager.$initialLocation.sink { (loc) in
            self.previousLoc = loc!
            print("previous location: \(self.previousLoc)")
        }
        
        guard center.distance(from: previousLoc!) > 50 else { return }
        
        previousLoc = center
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let err = error {
                print("false")
            }
            guard let placemark = placemarks?.first else {
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
            DispatchQueue.main.async {
                self.addressLabel = String("\(streetNumber) @ \(streetName)")
                print(self.addressLabel as Any)
            }
        }
    }
    
}

