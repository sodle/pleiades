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
    
    @State var alertActive = false
    @State var alertTitle = ""
    @State var alertText = ""
    
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )
    
    var body: some View {
        ScrollView {
            if let data = vehicleData {
                VStack {
                    if (vehicleData?.apiGeneration == .g2) {
                        TelematicsViewG2(vin: vehicle.vin)
                    }
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
                                coordinate: data.vehicleGeoPosition.coordinate,
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
                if let vehicle = try? await client.selectVehicle(withVin: vehicle.vin), vehicle.success, let data = vehicle.data {
                    vehicleData = data
                } else {
                    alertActive = true
                    alertTitle = "Failed to load vehicle information"
                    alertText = "Please try again later."
                }
            }
            
            if let data = vehicleData {
                mapRegion.center = data.vehicleGeoPosition.coordinate
            }
        }.alert(alertTitle, isPresented: $alertActive) {
            Button("Dismiss") {}
        } message: {
            Text(alertText)
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
