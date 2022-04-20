//
//  MapViewCoordinator.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation
import MapKit

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    
    var parent: MapView
    
    init(_ parent: MapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(.track)
            renderer.lineWidth = 5
            return renderer
        }
        return MKOverlayRenderer()
    }
}
