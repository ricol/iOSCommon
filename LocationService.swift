//
//  LocationService.swift
//  iOSCommon
//
//  Created by Ricol Wang on 23/10/19.
//

import CoreLocation
import UIKit

protocol LocationServiceDelegate
{
    func locationServicePositionUpdated(lat: Double, lng: Double, accuracy: Double)
    func locationServicePositionUpdateFailed(error: Error)
    func locationServiceAuthorizationChanged()
    func locationServiceNotEnabled()
}

class LocationService: NSObject, CLLocationManagerDelegate
{
    static let sharedInstance = LocationService()

    var lat: Double = 0
    var lng: Double = 0
    var accuracy: Double = 0
    private var bStartOnce = false

    var locationManager = CLLocationManager()
    var timer: Timer?
    var delegate: LocationServiceDelegate?

    override init()
    {
        super.init()
        locationManager.delegate = self
    }

    func isLocationServiceDetermined() -> Bool
    {
        return CLLocationManager.authorizationStatus() != .notDetermined
    }

    func isLocationServiceEnabled() -> Bool
    {
        let status = CLLocationManager.authorizationStatus()
        switch status
        {
        case .notDetermined, .restricted, .denied:
            return false
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        }
    }

    func requirePermission()
    {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }

    func start()
    {
        bStartOnce = false
        stop()
        if isLocationServiceEnabled()
        {
            locationManager.startUpdatingLocation()
        }
        else
        {
            delegate?.locationServiceNotEnabled()
        }
    }

    func startOnce()
    {
        bStartOnce = true
        stop()
        if isLocationServiceEnabled()
        {
            locationManager.startUpdatingLocation()
        }
        else
        {
            delegate?.locationServiceNotEnabled()
        }
    }

    func stop()
    {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let latestLocation = locations.last
        {
            lat = latestLocation.coordinate.latitude
            lng = latestLocation.coordinate.longitude
            accuracy = latestLocation.horizontalAccuracy
            delegate?.locationServicePositionUpdated(lat: lat, lng: lng, accuracy: accuracy)

            if bStartOnce
            {
                stop()
            }
        }
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error)
    {
        lat = 0
        lng = 0
        accuracy = 0
        delegate?.locationServicePositionUpdateFailed(error: error)
    }

    func locationManager(_: CLLocationManager, didChangeAuthorization _: CLAuthorizationStatus)
    {
        delegate?.locationServiceAuthorizationChanged()
    }
}

