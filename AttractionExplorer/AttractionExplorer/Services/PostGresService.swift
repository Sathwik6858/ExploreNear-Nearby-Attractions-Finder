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
    
    //Ben's config:
    var hostVal="::1"
    var databaseName="benashkenazi"
    var userName="admin"
    var password="adminpass"
    var portNum=5432
    
    //Sathwik's config:
    /*var hostVal="localhost"
    var databaseName="sathwik30"
    var userName="admin"
    var password="adminpass"
    var portNum=5431*/
    
    func getConnection() -> PostgresClientKit.Connection? {
            do {
                var configuration = PostgresClientKit.ConnectionConfiguration()
                configuration.host = hostVal
                configuration.database = databaseName
                configuration.user = "admin"
                //configuration.credential = .scramSHA256(password: password)
                configuration.ssl = false
                configuration.port = portNum

                let connection = try PostgresClientKit.Connection(configuration: configuration)
                print("Successfully connected to PostgreSQL database.")
                return connection
            } catch {
                print("Error connecting to PostgreSQL: \(error)")
                return nil
            }
        }

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
            guard let connection = getConnection() else {
                print("Failed to connect to the database.")
                return []
            }
            defer { connection.close() }

            let sql = """
            SELECT a.id, a.name, a.latitude, a.longitude, a.zipcode, a.address, a.description
            FROM attraction_list al
            INNER JOIN attractions a ON al.attraction_id = a.id
            WHERE al.user_name = $1;
            """
            let statement = try connection.prepareStatement(text: sql)
            defer { statement.close() }

            let cursor = try statement.execute(parameterValues: [userName])
            defer { cursor.close() }

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
    
    func addAttractionToFavorites(userString: String, attractionID: Int) -> Bool {
        do {
            // Configure the connection with the admin role
            var configuration = PostgresClientKit.ConnectionConfiguration()
            configuration.host = hostVal
            configuration.database = databaseName
            configuration.user = "admin" // Use the admin role for database operations
            //configuration.credential = .scramSHA256(password: password) // Add admin password if required
            configuration.ssl = false
            configuration.port = portNum

            // Establish connection
            let connection = try PostgresClientKit.Connection(configuration: configuration)
            defer { connection.close() }

            // SQL query to insert into attraction_list table
            let sql = """
            INSERT INTO attraction_list (user_name, attraction_id)
            VALUES ($1, $2)
            ON CONFLICT DO NOTHING;
            """
            let statement = try connection.prepareStatement(text: sql)
            defer { statement.close() }

            // Execute the statement with parameters
            try statement.execute(parameterValues: [userString, attractionID])
            print("Attraction \(attractionID) added to favorites for user \(userString).")
            return true // Operation succeeded
        } catch {
            // Log the error with more detail for debugging
            print("Error adding attraction to favorites: \(error)")
            return false // Operation failed
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
    
    func addUser(userName: String, password: String, lastName: String, firstName: String, zipCode: String, phoneNumber: String, email: String) {
            print("Adding user to database: \(userName)")
            
            guard let connection = getConnection() else {
                print("Failed to connect to the database.")
                return
            }
            
            defer { connection.close() }
            
            do {
                let sql = """
                INSERT INTO users (user_name, password, last_name, first_name, favorite_zipcode, phone_number, email)
                VALUES ($1, $2, $3, $4, $5, $6, $7);
                """
                let statement = try connection.prepareStatement(text: sql)
                defer { statement.close() }
                
                print("Executing SQL: \(sql)")
                try statement.execute(parameterValues: [userName, password, lastName, firstName, zipCode, phoneNumber, email])
                print("User \(userName) created successfully.")
            } catch {
                print("Error adding new user: \(error)")
            }
        }

        func authenticateUser(userName: String, password: String) -> Bool {
            print("Authenticating user: \(userName) with password: \(password)")
            
            guard let connection = getConnection() else {
                print("Failed to connect to the database.")
                return false
            }

            defer { connection.close() }

            do {
                let sql = """
                SELECT COUNT(*) FROM users WHERE user_name = $1 AND password = $2;
                """
                let statement = try connection.prepareStatement(text: sql)
                defer { statement.close() }

                print("Executing SQL: \(sql) with parameters: \(userName), \(password)")
                let cursor = try statement.execute(parameterValues: [userName, password])
                defer { cursor.close() }

                if let row = try cursor.next()?.get() {
                    let count = try row.columns[0].int()
                    print("Query result: \(count) user(s) found.")
                    return count > 0
                } else {
                    print("No rows returned.")
                }
            } catch {
                print("Error authenticating user: \(error)")
            }

            return false
        }
    
        func getUserFavoriteZipcode(userName: String) -> String? {
            print("Retrieving favorite zipcode for user: \(userName)")
            
            guard let connection = getConnection() else {
                print("Failed to connect to the database.")
                return nil
            }
            
            defer { connection.close() }
            
            do {
                let sql = """
                SELECT favorite_zipcode FROM users WHERE user_name = $1;
                """
                let statement = try connection.prepareStatement(text: sql)
                defer { statement.close() }
                
                print("Executing SQL: \(sql) with parameter: \(userName)")
                let cursor = try statement.execute(parameterValues: [userName])
                defer { cursor.close() }
                
                if let row = try cursor.next()?.get() {
                    let favoriteZipcode = try row.columns[0].string()
                    print("Favorite zipcode found: \(favoriteZipcode)")
                    return favoriteZipcode
                } else {
                    print("No favorite zipcode found for user.")
                    return nil
                }
            } catch {
                print("Error retrieving favorite zipcode: \(error)")
                return nil
            }
        }
    
        func updateUserFavoriteZipcode(userName: String, newZipcode: String) -> Bool {
            print("Updating favorite zipcode for user: \(userName) to \(newZipcode)")
            
            guard let connection = getConnection() else {
                print("Failed to connect to the database.")
                return false
            }
            
            defer { connection.close() }
            
            do {
                let sql = """
                UPDATE users SET favorite_zipcode = $1 WHERE user_name = $2;
                """
                let statement = try connection.prepareStatement(text: sql)
                defer { statement.close() }
                
                print("Executing SQL: \(sql) with parameters: \(newZipcode), \(userName)")
                
                let result = try statement.execute(parameterValues: [newZipcode, userName])
                return true
            } catch {
                print("Error updating favorite zipcode: \(error)")
                return false
            }
        }


    }
