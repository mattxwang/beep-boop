//
//  BLEConnection.swift
//  beep-boop
//
//  Created by Matt Wang on 2020-03-30.
//  Copyright © 2020 Matthew Wang. All rights reserved.
//
//
//import Foundation
//import UIKit
//import CoreBluetooth
//
//open class BLEConnection: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, ObservableObject {
//
//    // Properties
//    private var centralManager: CBCentralManager! = nil
//    private var peripheral: CBPeripheral!
//
//    public static let bleServiceUUID = CBUUID.init(string: "XXXX")
//    public static let bleCharacteristicUUID = CBUUID.init(string: "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXXX")
//
//    // Array to contain names of BLE devices to connect to.
//    // Accessable by ContentView for Rendering the SwiftUI Body on change in this array.
//    @Published var scannedBLEDevices: [String] = []
//
//    func startCentralManager() {
//        self.centralManager = CBCentralManager(delegate: self, queue: nil)
//        print("Central Manager State: \(self.centralManager.state)")
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            self.centralManagerDidUpdateState(self.centralManager)
//        }
//    }
//
//    // Handles BT Turning On/Off
//    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
//        switch (central.state) {
//            case .unsupported:
//                print("BLE is Unsupported")
//                break
//            case .unauthorized:
//                print("BLE is Unauthorized")
//                break
//            case .unknown:
//                print("BLE is Unknown")
//                break
//            case .resetting:
//                print("BLE is Resetting")
//                break
//            case .poweredOff:
//                print("BLE is Powered Off")
//                break
//            case .poweredOn:
//                print("Central scanning for", BLEConnection.bleServiceUUID);
//                self.centralManager.scanForPeripherals(withServices: [BLEConnection.bleServiceUUID],options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
//                break
//            @unknown default:
//                print("Unknown state")
//                break
//        }
//
//       if(central.state != CBManagerState.poweredOn)
//       {
//           // In a real app, you'd deal with all the states correctly
//           return;
//       }
//    }
//
//
//    // Handles the result of the scan
//    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//        print("Peripheral Name: \(String(describing: peripheral.name))  RSSI: \(String(RSSI.doubleValue))")
//        // We've found it so stop scan
//        self.centralManager.stopScan()
//        // Copy the peripheral instance
//        self.peripheral = peripheral
//        self.scannedBLEDevices.append(peripheral.name!)
//        self.peripheral.delegate = self
//        // Connect!
//        self.centralManager.connect(self.peripheral, options: nil)
//    }
//
//
//    // The handler if we do connect successfully
//    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
//        if peripheral == self.peripheral {
//            print("Connected to your BLE Board")
//            peripheral.discoverServices([BLEConnection.bleServiceUUID])
//        }
//    }
//
//
//    // Handles discovery event
//    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
//        if let services = peripheral.services {
//            for service in services {
//                if service.uuid == BLEConnection.bleServiceUUID {
//                    print("BLE Service found")
//                    //Now kick off discovery of characteristics
//                    peripheral.discoverCharacteristics([BLEConnection.bleCharacteristicUUID], for: service)
//                    return
//                }
//            }
//        }
//    }
//
//    // Handling discovery of characteristics
//    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//        if let characteristics = service.characteristics {
//            for characteristic in characteristics {
//                if characteristic.uuid == BLEConnection.bleServiceUUID {
//                    print("BLE service characteristic found")
//                } else {
//                    print("Characteristic not found.")
//                }
//            }
//        }
//    }
//}

import SwiftUI
import Foundation
import UIKit
import CoreBluetooth

open class BLEConnection: NSObject, CBPeripheralDelegate, CBCentralManagerDelegate, ObservableObject {
  
  // Properties
  private var centralManager: CBCentralManager! = nil
  private var peripheral: CBPeripheral!
  
  public static let bleServiceUUID = CBUUID.init(string: "C100")
  public static let bleCharacteristicUUID = CBUUID.init(string: "C111")
  var charDictionary = [String: CBCharacteristic]()
  
  // Array to contain names of BLE devices to connect to.
  // Accessable by ContentView for Rendering the SwiftUI Body on change in this array.
  struct BLEDevice: Identifiable {
    let id: String
    let name: String
    let rssi: Double
  }
  @Published var scannedBLEDevices: [BLEDevice] = []
  @Published var scannedBLENames: [BLEDevice] = []
  
  func startCentralManager() {
    self.centralManager = CBCentralManager(delegate: self, queue: nil)
    print("Central Manager State: \(self.centralManager.state)")
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.centralManagerDidUpdateState(self.centralManager)
    }
  }
  
  // Handles BT Turning On/Off
  public func centralManagerDidUpdateState(_ central: CBCentralManager) {
    switch (central.state) {
    case .unsupported:
      print("BLE is Unsupported")
      break
    case .unauthorized:
      print("BLE is Unauthorized")
      break
    case .unknown:
      print("BLE is Unknown")
      break
    case .resetting:
      print("BLE is Resetting")
      break
    case .poweredOff:
      print("BLE is Powered Off")
      break
    case .poweredOn:
      print("")
      self.centralManager.scanForPeripherals(withServices:nil)
      //self.centralManager.scanForPeripherals(withServices: [BLEConnection.bleServiceUUID],options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
      break
    @unknown default:
      print("BLE is Unknown")
    }
    
//    if(central.state != CBManagerState.poweredOn)
//    {
//      // In a real app, you'd deal with all the states correctly
//      return;
//    }
  }
  
  var deviceID0: Int = 0
  
  // Handles the result of the scan
  public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    print("Peripheral Name: \(String(describing: peripheral.name))  RSSI: \(String(RSSI.doubleValue))")
    
    // We've found it so stop scan
    //self.centralManager.stopScan()
    
    if let safeName = peripheral.name {
        self.scannedBLEDevices.append(BLEDevice(id:String(deviceID0), name:safeName, rssi: RSSI.doubleValue))
      deviceID0 = deviceID0 + 1
    }
    else{
        print("no name")
        //self.scannedBLEDevices.append(BLEDevice(id:String(deviceID0), name:"Unknown Device", rssi: RSSI.doubleValue))
        //deviceID0 = deviceID0 + 1
    }
  }
  
  
  // The handler if we do connect successfully
  public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    if peripheral == self.peripheral {
      print("Connected to your BLE Board")
      peripheral.discoverServices([BLEConnection.bleServiceUUID])
      //peripheral.discoverServices(nil)
    }
  }
  
  
  // Handles discovery event
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    if let services = peripheral.services {
      for service in services {
        print("Found services UUID: \(service.uuid), uuidstring:\(service.uuid.uuidString)")
      
        
        if service.uuid == BLEConnection.bleServiceUUID {
          print("BLE Service found")
          //Now kick off discovery of characteristics
          peripheral.discoverCharacteristics([BLEConnection.bleCharacteristicUUID], for: service)
          return
        }
      }
    }
  }
  
  // Handling discovery of characteristics
  public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    if let characteristics = service.characteristics {
      for characteristic in characteristics {
        let uuidString = characteristic.uuid.uuidString
        charDictionary[uuidString] = characteristic
        print("characteristic: \(uuidString)")
        print(characteristic)
        peripheral.setNotifyValue(true, for: characteristic)
        //peripheral.readValue(for: characteristic)
        //        if characteristic.uuid == BLEConnection.bleCharacteristicUUID {
        //          print("BLE service characteristic \(BLEConnection.bleCharacteristicUUID) found")
        //        } else {
        //          print("Characteristic not found.")
        //        }
      }
    }
  }
  
  public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    if error == nil {
      print("Notification Set OK, isNotifying: \(characteristic.isNotifying)")
      if !characteristic.isNotifying {
        print("isNotifying is false, set to true again!")
        peripheral.setNotifyValue(true, for: characteristic)
      }
    }
  }
  
  public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    
    if characteristic.uuid.uuidString == "C111" {
      let data = characteristic.value!
      //let string = "> " + String(data: data as Data, encoding: .utf8)!
      for i in 0 ... 19 {
        print("\(i):\(data[i])", terminator:" ")
      }
      print("")
      
    }
  }
  
}
