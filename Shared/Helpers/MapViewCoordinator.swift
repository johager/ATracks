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
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    init(_ parent: MapView) {
        self.parent = parent
    }
    
    // MARK: - Methods
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            #if os(iOS)
                renderer.strokeColor = UIColor(.track)
            #elseif os(macOS)
                renderer.strokeColor = NSColor(.track)
            #endif
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
//        print("=== \(file).\(#function) - camera.centerCoordinateDistance: \(mapView.camera.centerCoordinateDistance) ===")
//    }
}
