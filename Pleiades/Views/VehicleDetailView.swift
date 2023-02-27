//
//  VehicleDetailView.swift
//  Pleiades
//
//  Created by Scott Odle on 2/26/23.
//

import SwiftUI
import MapKit

struct VehicleDetailView: View {
    let vehicle: VehicleStub
    var preview = false
    
    @State var vehicleData: Vehicle?
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
    
    var body: some View {
        ScrollView {
            if let data = vehicleData {
                VStack {
                    VStack {
                        Text("Vehicle information")
                            .font(.title)
                        Text("\(data.modelYear) Subaru \(data.modelName) \(data.transCode)")
                        Text(data.extDescrip)
                        Text("VIN: \(data.vin)")
                        Text("Plate: \(data.licensePlate) (\(data.licensePlateState))")
                        Text("API Generation: \(data.apiGeneration.rawValue)")
                    }.padding()
                    VStack {
                        Text("Last known location")
                            .font(.title)
                        Map(coordinateRegion: $mapRegion, annotationItems: [data]) { marker in
                            MapMarker(
                                coordinate: CLLocationCoordinate2D(
                                    latitude: data.vehicleGeoPosition.latitude,
                                    longitude: data.vehicleGeoPosition.longitude
                                ),
                                tint: .red
                            )
                        }.frame(maxWidth: .infinity, idealHeight: 200)
                        Text("As of \(data.vehicleGeoPosition.timestamp) UTC")
                    }.padding()
                }
            } else {
                Text("Loading...")
            }
        }
        .padding()
        .task {
            if preview {
                vehicleData = Vehicle(
                    vehicleName: "John's WRX",
                    vin: "VXXX",
                    licensePlate: "SBRU",
                    licensePlateState: "NJ",
                    features: [
                        "g2"
                    ],
                    modelYear: "2023",
                    modelName: "WRX",
                    transCode: "CVT",
                    extDescrip: "Purple",
                    timeZone: "America/New_York",
                    vehicleGeoPosition: VehicleGeoPosition(
                        latitude: 39.942924861659826,
                        longitude: -75.10853083087152,
                        timestamp: "2023-02-26T02:21:20"
                    )
                )
            } else {
                let vehicleResponse = try! await selectVehicle(vin: vehicle.vin)
                vehicleData = vehicleResponse.data
            }
            
            if let data = vehicleData {
                mapRegion.center.latitude = data.vehicleGeoPosition.latitude
                mapRegion.center.longitude = data.vehicleGeoPosition.longitude
            }
        }
    }
}

struct VehicleDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VehicleDetailView(
            vehicle: VehicleStub(vehicleName: "John's WRX", vin: "VXXX"),
            preview: true
        )
    }
}
