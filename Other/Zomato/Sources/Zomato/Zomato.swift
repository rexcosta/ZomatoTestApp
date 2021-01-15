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
import ZomatoFoundation

/// Zomato dependencies
public struct Zomato {
    
    public let restaurantManager: RestaurantManagerProtocol
    
    public init(
        apiKey: String,
        userAgent: String,
        network: NetworkProtocol
    ) {
        let authenticationManager = AuthenticationManager(apiKey: apiKey)
        
        let apiRequestBuilder = ApiRequestBuilder(
            userAgent: userAgent,
            authenticationManager: authenticationManager
        )
        
        let restaurantNetworkService = RestaurantNetworkService(
            network: network,
            apiRequestBuilder: apiRequestBuilder
        )
        
        let databaseName = "zomato"
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let databasePath = documentsDirectory
            .appendingPathComponent("ZomatoDatabase", isDirectory: true)
        
        let databaseFullPath = databasePath
            .appendingPathComponent(databaseName, isDirectory: false)
            .appendingPathExtension("sqlite")
        
        let database = SqliteDatabase(
            configs: SqliteDatabase.Configs(
                databaseName: "zomato",
                databasePath: databasePath,
                databaseFullPath: databaseFullPath
            )
        )
        
        let concurrentSqliteDatabase = ConcurrentSqliteDatabase(
            database: database
        )
        
        concurrentSqliteDatabase.perform { database in
            if database.openDatabase() {
                Log.info("Zomato", "Success opening database")
            } else {
                Log.error("Zomato", "Error opening database")
            }
        }
        
        let restaurantRepository = RestaurantRepository(
            database: concurrentSqliteDatabase
        )
        
        restaurantManager = RestaurantManager(
            restaurantNetworkService: restaurantNetworkService,
            restaurantRepository: restaurantRepository
        )
    }
    
}
