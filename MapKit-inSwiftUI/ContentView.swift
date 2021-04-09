//
//  ContentView.swift
//  MapKit-inSwiftUI
//
//  Created by mimi on 4/5/21.
//

struct ContentView: View {
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.71, longitude: -82), span: MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9))
    @State var tracking: MapUserTrackingMode = .follow
    @State var manager = CLLocationManager()
    @ObservedObject var locationManager = LocationManager()
    
    private func setCurentLocation() {
        locationManager.$location.sink { location in
            region = MKCoordinateRegion(center: location?.coordinate ?? CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9))
        }
    }
    var body: some View {
        ZStack {
//            Map(coordinateRegion: $region, interactionModes: [.zoom, .pan], showsUserLocation: true, userTrackingMode: $tracking)
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: locationManager.pins) { pin in
                MapPin(coordinate: pin.location.coordinate, tint: .green)
                
            }
            
            
        }.onAppear {
            setCurentLocation()
        }
    }
}

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var pins: [Pin] = []
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}

struct Pin: Identifiable {
    var id = UUID().uuidString
    var location: CLLocation
    
}
