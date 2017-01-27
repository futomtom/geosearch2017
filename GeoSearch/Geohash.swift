//
//  GeohashBox.swift
//  GeohashKit
//
//  Created by Maxim Veksler on 5/10/15.
//  Copyright (c) 2015 Maxim Veksler. All rights reserved.
//
struct GeohashBox {
    let hash: String
    
    let north: Double // top latitude
    let west: Double // left longitude
    let south: Double // bottom latitude
    let east: Double // right longitude
    var point: (latitude: Double, longitude: Double) {
        let latitude = (self.north + self.south) / 2
        let longitude = (self.east + self.west) / 2
        
        return (latitude: latitude, longitude: longitude)
    }
    
    var size: (latitude: Double, longitude: Double) {
        // * possible case examples:
        //
        // 1. bbox.north = 60, bbox.south = 40; point.latitude = 50, size.latitude = 20
        // 2. bbox.north = -40, bbox.south = -60; point.latitude = -50, size.latitude = 20
        // 3. bbox.north = 10, bbox.south = -10; point.latitude = 0, size.latitude = 20
        let latitude = north - south
        
        // * possible case examples:
        //
        // 1. bbox.east = 60, bbox.west = 40; point.longitude = 50, size.longitude = 20
        // 2. bbox.east = -40, bbox.west = -60; point.longitude = -50, size.longitude = 20
        // 3. bbox.east = 10, bbox.west = -10; point.longitude = 0, size.longitude = 20
        let longitude = east - west
        
        
        return (latitude: latitude, longitude: longitude)
    }
}




public class Geohash {
    // - MARK: Public
    public static func encode(latitude: Double, longitude: Double, _ precision: Int? = nil) -> String {
        return geohashbox(latitude: latitude, longitude: longitude, precision: precision)!.hash
    }
    
    public static func decode(hash: String) -> (latitude: Double, longitude: Double)? {
        return geohashbox(hash: hash)?.point
    }
    
    public static func neighbors(centerHash: String) -> [String]? {
        // neighbor precision *must* be them same as center'ed bounding box.
        let precision = centerHash.characters.count
        
        if let box = geohashbox(hash: centerHash) {
            let n = neighbor(box: box, direction: .North, precision: precision) // n
            let s = neighbor(box: box, direction: .South, precision: precision) // s
            let e = neighbor(box: box, direction: .East, precision: precision)  // e
            let w = neighbor(box: box, direction: .West, precision: precision)  // w
            let ne = neighbor(box: n, direction: .East, precision: precision)   // ne
            let nw = neighbor(box: n, direction: .West, precision: precision)   // nw
            let se = neighbor(box: s, direction: .East, precision: precision)   // se
            let sw = neighbor(box: s, direction: .West, precision: precision)   // sw
            
            // in clockwise order
            return [n!.hash, ne!.hash, e!.hash, se!.hash, s!.hash, sw!.hash, w!.hash, nw!.hash]
        } else {
            return nil
        }
    }
    
    // - MARK: Private
    static func geohashbox(latitude: Double, longitude: Double, precision: Int? = nil) -> GeohashBox? {
        var precisionVar = precision
        var lat = (-90.0, 90.0)
        var lon = (-180.0, 180.0)
        
        // to be generated result.
        var geohash = String()
        
        // Loop helpers
        var parity_mode = Parity.Even;
        var base32char = 0
        var bit = BASE32_BITFLOW_INIT
        
        // Set precision to 5 if not specified.
        if precisionVar == nil {
            precisionVar = 5
        }
        
        repeat {
            switch (parity_mode) {
            case .Even:
                let mid = (lon.0 + lon.1) / 2
                if(longitude >= mid) {
                    base32char |= Int(bit)
                    lon.0 = mid;
                } else {
                    lon.1 = mid;
                }
            case .Odd:
                let mid = (lat.0 + lat.1) / 2
                if(latitude >= mid) {
                    base32char |= Int(bit)
                    lat.0 = mid;
                } else {
                    lat.1 = mid;
                }
            }
            
            // Flip between Even and Odd
            parity_mode = !parity_mode
            // And shift to next bit
            bit >>= 1
            
            if(bit == 0b00000) {
                geohash += String(BASE32[base32char])
                bit = BASE32_BITFLOW_INIT // set next character round.
                base32char = 0
            }
            
        } while geohash.characters.count < precisionVar ?? 0
        
        return GeohashBox(hash: geohash, north: lat.1, west: lon.0, south: lat.0, east: lon.1)
    }
    
    static func geohashbox(hash: String) -> GeohashBox? {
        var parity_mode = Parity.Even;
        var lat = (-90.0, 90.0)
        var lon = (-180.0, 180.0)
        
        for c in hash.characters {
            let bitmap = BASE32.index(of:c)
            
            if let bitmap = bitmap {
                
                var mask = Int(BASE32_BITFLOW_INIT)
                while (mask != 0) {
                    
                    switch (parity_mode) {
                    case .Even:
                        if(bitmap & mask != 0) {
                            lon.0 = (lon.0 + lon.1) / 2
                        } else {
                            lon.1 = (lon.0 + lon.1) / 2
                        }
                    case .Odd:
                        if(bitmap & mask != 0) {
                            lat.0 = (lat.0 + lat.1) / 2
                        } else {
                            lat.1 = (lat.0 + lat.1) / 2
                        }
                    }
                    
                    parity_mode = !parity_mode
                    
                    mask >>= 1
                }
                
                // Original implementation of for loop
                //                for var mask = Int(BASE32_BITFLOW_INIT); mask != 0; mask >>= 1 {
                //                    switch (parity_mode) {
                //                    case .Even:
                //                        if(bitmap & mask != 0) {
                //                            lon.0 = (lon.0 + lon.1) / 2
                //                        } else {
                //                            lon.1 = (lon.0 + lon.1) / 2
                //                        }
                //                    case .Odd:
                //                        if(bitmap & mask != 0) {
                //                            lat.0 = (lat.0 + lat.1) / 2
                //                        } else {
                //                            lat.1 = (lat.0 + lat.1) / 2
                //                        }
                //                    }
                //
                //                    parity_mode = !parity_mode
                //                }
            } else {
                // Break on non geohash code char.
                return nil
            }
        }
        
        return GeohashBox(hash: hash, north: lat.1, west: lon.0, south: lat.0, east: lon.1)
    }
    
    static func neighbor(box: GeohashBox?, direction: CompassPoint, precision: Int) -> GeohashBox? {
        if let box = box {
            switch (direction) {
            case .North:
                let new_latitude = box.point.latitude + box.size.latitude // North is upper in the latitude scale
                return geohashbox(latitude: new_latitude, longitude: box.point.longitude, precision: precision)
            case .South:
                let new_latitude = box.point.latitude - box.size.latitude // South is lower in the latitude scale
                return geohashbox(latitude: new_latitude, longitude: box.point.longitude, precision: precision)
            case .East:
                let new_longitude = box.point.longitude + box.size.longitude // East is bigger in the longitude scale
                return geohashbox(latitude: box.point.latitude, longitude: new_longitude, precision: precision)
            case .West:
                let new_longitude = box.point.longitude - box.size.longitude // West is lower in the longitude scale
                return geohashbox(latitude: box.point.latitude, longitude: new_longitude, precision: precision)
            }
        } else {
            return nil
        }
    }
    
}

enum CompassPoint {
    case North // Top
    case South // Bottom
    case East // Right
    case West  // Left
}

enum Parity { case Even, Odd }
prefix func !(a: Parity) -> Parity {
    return a == .Even ? .Odd : .Even
}

let BASE32 = Array("0123456789bcdefghjkmnpqrstuvwxyz".characters) // decimal to 32base mapping (0 => "0", 31 => "z")
let BASE32_BITFLOW_INIT :UInt8 = 0b10000
