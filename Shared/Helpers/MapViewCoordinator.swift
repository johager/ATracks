//
//  MapViewCoordinator.swift
//  ATracks
//
//  Created by James Hager on 4/18/22.
//

import Foundation
import MapKit

#if os(iOS)
import UIKit
#else
import AppKit
#endif

class MapViewCoordinator: NSObject {
    
    var parent: MapView
    
    lazy var file = Func.sourceFileNameFromFullPath(#file)
    
    init(_ parent: MapView) {
        self.parent = parent
        super.init()
        #if os(iOS)
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        #else
        let gestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(handleTap))
        #endif
        parent.mapViewHelper.mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: - Methods
    
    @objc func handleTap(_ gesture: Any) {
        print("=== \(file).\(#function) ===")
        parent.mapViewHelper.centerMap()
    }
}

extension MapViewCoordinator: MKMapViewDelegate {
    
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
            annotationView.image = aaPointAnnotation.image(mapType: mapView.mapType, isDark: parent.isDark)
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
