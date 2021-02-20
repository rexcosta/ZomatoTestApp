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

import RxSwift
import RxCocoa
import CoreLocation
import ZomatoFoundation
import ZomatoUIKit

final class LocationManager: LocationManagerProtocol {
    
    func currentLocation() -> Observable<CLLocation?> {
        return Observable.create { observer -> Disposable in
            
            observer.onNext(nil)
            
            var locationManager: CLLocationManager? = CLLocationManager()
            var delegate: LocationManagerDelegate? = LocationManagerDelegate()
            
            delegate?.didFailWithError = { error in
                observer.onError(Location.LocationError.unknown(error))
            }
            
            delegate?.didChangeAuthorization = { status in
                switch status {
                case .notDetermined:
                    // Ignore, user will make a decision
                    break
                    
                case .restricted:
                    observer.onError(Location.LocationError.restricted)
                    
                case .denied:
                    observer.onError(Location.LocationError.denied)
                    
                case .authorizedAlways, .authorizedWhenInUse:
                    locationManager?.requestLocation()
                    
                @unknown default:
                    observer.onError(Location.LocationError.unknown(nil))
                }
            }
            
            delegate?.didUpdateLocations = { locations in
                observer.onNext(locations.first)
                observer.onCompleted()
            }
            
            locationManager?.delegate = delegate
            
            locationManager?.requestWhenInUseAuthorization()
            
            return Disposables.create {
                locationManager = nil
                delegate = nil
            }
        }
    }
    
}

// MARK: CLLocationManagerDelegate
private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    
    var didFailWithError: ((_ error: Error) -> Void)?
    var didChangeAuthorization: ((_ status: CLAuthorizationStatus) -> Void)?
    var didUpdateLocations: ((_ locations: [CLLocation]) -> Void)?
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        didFailWithError?(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        didChangeAuthorization?(status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        didUpdateLocations?(locations)
    }
    
}
