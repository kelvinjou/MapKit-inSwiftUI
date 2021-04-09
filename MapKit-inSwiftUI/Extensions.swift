//
//  Extensions.swift
//  MapKit-NoUIKit
//
//  Created by mimi on 4/4/21.
//

import Foundation
import MapKit
import SwiftUI

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last
            else { return }
        DispatchQueue.main.async {
            self.location = location
            print(location.coordinate)
            self.pins.append(Pin(location: location))
            
        }
    }
}

extension CLLocationCoordinate2D {
    static let defaultRegion = CLLocationCoordinate2D(latitude: 40.71, longitude: -82)
}

extension MKPointAnnotation {
    static let customAnnotation = {
        let annotation = MKPointAnnotation()
        annotation.title = "Street name"
        annotation.subtitle = "Empty street"
        
    }
}

struct ButtonModifiers: ButtonStyle {
    var color: Color
    func makeBody(configuration: Self.Configuration) -> some View {
            configuration.label
                .padding()
                .background(color)
                .foregroundColor(.white)
                .font(.title)
                .clipShape(Circle())
                .padding(.trailing)
    }
}

