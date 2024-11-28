//
//  PostGresService.swift
//  AttractionExplorer
//
//  Created by Ben Ashkenazi on 11/28/24.
//

import Foundation
import PostgresClientKit


class PostgresConnection {
    //You can find most of this info with the ./conninfo command, also you need to create an admin role with all permissions
    var hostVal="::1"
    var databaseName="benashkenazi"
    var userName="admin"
    var password="adminpass"
    var portNum=5432
    
    
    
    func getAttractionsByZip(zipCode: String) -> [Attraction] {
        var attractions: [Attraction] = []

        do {
            var configuration = PostgresClientKit.ConnectionConfiguration()
            configuration.host = hostVal
            configuration.database = databaseName
            configuration.user = userName
            //configuration.credential = .scramSHA256(password: password)
            configuration.ssl = false
            configuration.port = portNum

            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }

            let sql = """
            SELECT id, name, latitude, longitude, zipcode, address, description
            FROM attractions
            WHERE zipcode = $1
            ORDER BY id
            LIMIT 50;
            """
            let statement = try connection.prepareStatement(text: sql)
            defer { statement.close() }
            
            let cursor = try statement.execute(parameterValues: [zipCode])
            defer { cursor.close() }
    
            do{
                for row in cursor {
                    let columns = try row.get().columns
                    let attraction = Attraction(
                        attractionID: try columns[0].int(),
                        name: try columns[1].string(),
                        lat: try columns[2].double(),
                        long: try columns[3].double(),
                        zipcode: try columns[4].string(),
                        address: try columns[5].string(),
                        description: try columns[6].string()
                    )
                    attractions.append(attraction)
                }
            }catch{
                print("Error converting vals for attraction id \(error)")
            }
            
        } catch {
            print("Error retrieving attractions by zip: \(error)")
        }

        return attractions
    }

    func getFavoriteAttractions(userName: String) -> [Attraction] {
        var attractions: [Attraction] = []

        do {
            var configuration = PostgresClientKit.ConnectionConfiguration()
            configuration.host = hostVal
            configuration.database = databaseName
            configuration.user = userName
            //configuration.credential = .scramSHA256(password: password)
            configuration.ssl = false
            configuration.port = portNum

            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }

            let sql = """
            SELECT a.id, a.name, a.latitude, a.longitude, a.zipcode, a.address, a.description
            FROM attraction_list al
            INNER JOIN attractions a ON al.attraction_id = a.id
            WHERE al.user_name = '\(userName)';
            """
            let statement = try connection.prepareStatement(text: sql)
            defer { statement.close() }

            let cursor = try statement.execute()
            defer { cursor.close() }

            do{
                for row in cursor {
                    let columns = try row.get().columns
                    let attraction = Attraction(
                        attractionID: try columns[0].int(),
                        name: try columns[1].string(),
                        lat: try columns[2].double(),
                        long: try columns[3].double(),
                        zipcode: try columns[4].string(),
                        address: try columns[5].string(),
                        description: try columns[6].string()
                    )
                    attractions.append(attraction)
                }
            }catch{
                print("Error converting vals for attraction id \(error)")
            }
            
        } catch {
            print("Error retrieving favorite attractions: \(error)")
        }

        return attractions
    }

    

    func getAttractionsByCoordinates(lat: Double, long: Double, radius: Double = 50.0) -> [Attraction] {
        var attractions: [Attraction] = []

        do {
            var configuration = PostgresClientKit.ConnectionConfiguration()
            configuration.host = hostVal
            configuration.database = databaseName
            configuration.user = userName
            configuration.ssl = false
            configuration.port = portNum

            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }

            let sql = """
            SELECT id, name, latitude, longitude, zipcode, address, description
            FROM attractions
            ORDER BY id
            LIMIT 50;
            """
            let statement = try connection.prepareStatement(text: sql)
            defer { statement.close() }

            let cursor = try statement.execute()
            defer { cursor.close() }

            for row in cursor {
                let columns = try row.get().columns

                let attractionLat = try columns[2].double()
                let attractionLong = try columns[3].double()

                // Calculate distance from the target coordinates
                let distance = haversineDistance(lat1: lat, lon1: long, lat2: attractionLat, lon2: attractionLong)

                // If the attraction is within the radius, add it to the result list
                if distance <= radius {
                    let attraction = Attraction(
                        attractionID: try columns[0].int(),
                        name: try columns[1].string(),
                        lat: attractionLat,
                        long: attractionLong,
                        zipcode: try columns[4].string(),
                        address: try columns[5].string(),
                        description: try columns[6].string()
                    )
                    attractions.append(attraction)
                }
            }
        } catch {
            print("Error retrieving attractions by coordinates: \(error)")
        }

        return attractions
    }
    
    func addAttractionToFavorites(userString: String, attractionID: Int) {
        do {
            var configuration = PostgresClientKit.ConnectionConfiguration()
            configuration.host = hostVal
            configuration.database = databaseName
            configuration.user = userName
            //configuration.credential = .scramSHA256(password: password)
            configuration.ssl = false
            configuration.port = portNum

            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }

            let sql = """
            INSERT INTO attraction_list (user_name, attraction_id)
            VALUES ($1, $2)
            ON CONFLICT DO NOTHING;
            """
            let statement = try connection.prepareStatement(text: sql)
            defer { statement.close() }

            try statement.execute(parameterValues: [userString, attractionID])
            print("Attraction \(attractionID) added to favorites for user \(userName).")
        } catch {
            print("Error adding attraction to favorites: \(error)")
        }
    }
    
    func removeAttractionFromFavorites(userString: String, attractionID: Int) {
        do {
            var configuration = PostgresClientKit.ConnectionConfiguration()
            configuration.host = hostVal
            configuration.database = databaseName
            configuration.user = userName
            //configuration.credential = .scramSHA256(password: password)
            configuration.ssl = false
            configuration.port = portNum

            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }

            let sql = """
            DELETE FROM attraction_list
            WHERE user_name = $1 AND attraction_id = $2;
            """
            
            let statement = try connection.prepareStatement(text: sql)
            defer { statement.close() }

            try statement.execute(parameterValues: [userString, attractionID])
            print("Attraction \(attractionID) removed from favorites for user \(userName).")
        } catch {
            print("Error removing attraction from favorites: \(error)")
        }
    }

}


