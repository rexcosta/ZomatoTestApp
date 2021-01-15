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

final class RestaurantRepository {
    
    private let database: ConcurrentSqliteDatabase
    
    init(database: ConcurrentSqliteDatabase) {
        self.database = database
        initDatabase()
    }
    
    private func initDatabase() {
        database.perform { database in
            do {
                try database.execute(
                    statement: RestaurantSql.createTableRestaurantFavourite
                )
                Log.verbose("RestaurantRepository", "Init database")
            } catch {
                Log.error("RestaurantRepository", "Unable to init database \(error)")
            }
        }
    }
    
}

// MARK: RestaurantRepositoryProtocol
extension RestaurantRepository: RestaurantRepositoryProtocol {
    
    func isRestaurantFavourite(id: String) -> Bool {
        return database.performAndWait { database -> Bool in
            do {
                var countResult = 0
                try database.execute(
                    statement: RestaurantSql.countRestaurantFavourite,
                    doBindings: { statement in
                        try statement.bind(position: 0, id)
                    },
                    handleRow: { statement in
                        countResult = try statement.columnInt(position: 0)
                    }
                )
                
                return countResult != 0
            } catch {
                Log.error("RestaurantRepository", "Error counting restaurant \(id) \(error)")
                return false
            }
        }
    }
    
    func saveRestaurantFavourite(
        id: String,
        isFavourite: Bool,
        completion: @escaping (_ error: ZomatoError?) -> Void
    ) {
        database.perform { database in
            do {
                let sql: String
                if isFavourite {
                    sql = RestaurantSql.insertRestaurantFavourite
                    Log.verbose("RestaurantRepository", "Using insert restaurant sql")
                } else {
                    sql = RestaurantSql.deleteRestaurantFavourite
                    Log.verbose("RestaurantRepository", "Using delete restaurant sql")
                }
                
                try database.execute(
                    statement: sql,
                    doBindings: { statement in
                        try statement.bind(position: 0, id)
                    }
                )
                Log.verbose("RestaurantRepository", "Update restaurant with success")
                completion(nil)
                
            } catch {
                Log.error("RestaurantRepository", "Error saving restaurant \(id) \(error)")
                completion(ZomatoError.database(context: .savingRestaurant, cause: error))
            }
        }
    }
    
}
