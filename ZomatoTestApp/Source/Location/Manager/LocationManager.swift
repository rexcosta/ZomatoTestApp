//
// The MIT License (MIT)
//
// Copyright (c) 2021 David Costa Gonçalves
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import CoreLocation
import ZomatoFoundation

final class LocationManager: NSObject {
    
    typealias LocationRequestHandler = (_ result: Result<CLLocation, LocationError>) -> Void
    
    enum LocationError: Error {
        case restricted
        case denied
        case noLocationsFound
        case unknown
    }
    
    private lazy var locationManager = CLLocationManager()
    
    private let appCoordinator: AppCoordinator
    
    private let userLocation = Property<CLLocation?>(nil, skipRepeated: true)
    var readOnlyUserLocation: ReadOnlyProperty<CLLocation?> {
        return userLocation.readOnly
    }
    
    init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
        super.init()
    }
    
    func monitorLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        Log.info("LocationManager", "Will monitor location")
    }
    
}

// MARK: CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Log.error("LocationManager", "CLLocationManagerDelegate didFailWithError \(error)")
        DispatchQueue.main.async {
            self.appCoordinator.showLocationError(.unknown)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Log.info("LocationManager", "CLLocationManagerDelegate didChangeAuthorization \(status.rawValue)")
        
        DispatchQueue.main.async {
            switch status {
            case .notDetermined:
                // Ignore, user will make a decision
                break
                
            case .restricted:
                self.appCoordinator.showLocationError(.restricted)
                
            case .denied:
                self.appCoordinator.showLocationError(.denied)
                
            case .authorizedAlways, .authorizedWhenInUse:
                manager.requestLocation()
                
            @unknown default:
                self.appCoordinator.showLocationError(.unknown)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            Log.warning("LocationManager", "CLLocationManagerDelegate didUpdateLocations did not found location")
            return
        }
        
        Log.info("LocationManager", "CLLocationManagerDelegate didUpdateLocations found location")
        DispatchQueue.main.async {
            self.userLocation.value = location
        }
    }
    
}
