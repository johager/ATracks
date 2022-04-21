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
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationID")
        
        if let aaPointAnnotation = annotation as? AAPointAnnotation {
            let isDark = Appearance.isDark
            annotationView.image = aaPointAnnotation.image(mapType: mapView.mapType, isDark: isDark)
            annotationView.centerOffset = CGPoint(x: 0, y: aaPointAnnotation.imageOffsetY)
        }
        
        #if os(iOS)
        annotationView.clipsToBounds = false
        #endif
        
        return annotationView
    }
    
//    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//        print("\(#function) - camera.centerCoordinateDistance: \(mapView.camera.centerCoordinateDistance)")
//    }
}
