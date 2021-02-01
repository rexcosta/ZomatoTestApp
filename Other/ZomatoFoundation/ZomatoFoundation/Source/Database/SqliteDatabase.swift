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
import SQLite3

public final class SqliteDatabase {
    
    public struct Configs {
        public let databaseName: String
        public let databasePath: URL
        public let databaseFullPath: URL
        
        public init(
            databaseName: String,
            databasePath: URL,
            databaseFullPath: URL
        ) {
            self.databaseName = databaseName
            self.databasePath = databasePath
            self.databaseFullPath = databaseFullPath
        }
        
    }
    
    enum State {
        case closed
        case open
        case error(_ error: DatabaseError)
    }
    
    let configs: Configs
    
    private var database: OpaquePointer?
    private var state: State = .closed
    
    deinit {
        if let database = database {
            sqlite3_close(database)
        }
        database = nil
    }
    
    public init(configs: Configs) {
        self.configs = configs
    }
    
}

// MARK: Public
extension SqliteDatabase {
    
    public func openDatabase() -> Bool {
        switch state {
        case .error:
            break
        case .closed:
            break
        case .open:
            assertionFailure("[SqliteDatabase] Unable open databse because it's already opened")
            return false
        }
        
        do {
            try FileManager.default.createDirectory(
                at: configs.databasePath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            Log.error("SqliteDatabase", "Unable to create database directory \(error)")
            state = .error(
                DatabaseError(
                    errorMessage: "Unable to create database directory.",
                    errorCode: .createDatabaseDirectory
                )
            )
            return false
        }
        
        let path = configs.databaseFullPath.absoluteString
        let flags = SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE
        let sqlResult = sqlite3_open_v2(path, &database, flags, nil)
        if sqlResult == SQLITE_OK {
            Log.verbose("SqliteDatabase", "Success connection to database at \(path)")
            state = .open
            return true
        } else {
            let sqliteError = DatabaseError.sqlite(message: "Unable to open database.", errorCode: sqlResult)
            Log.error("SqliteDatabase", "Unable to open database at \(path) \(sqliteError)")
            state = .error(sqliteError)
            return false
        }
    }
    
    public func close() {
        switch state {
        case .error, .closed:
            assertionFailure("[SqliteDatabase] Database already closed")
            
        case .open:
            state = .closed
            if let database = database {
                sqlite3_close(database)
            }
            database = nil
        }
    }
    
    public func execute(
        statement: String
    ) throws {
        let database = try validateDatabaseState()
        
        let sqlStatement = try prepare(statement: statement, database: database)
        defer { sqlStatement.finalize() }
        
        let resultCode = sqlStatement.step()
        guard resultCode == SQLITE_ROW || resultCode == SQLITE_DONE else {
            try SqliteDatabase.validateSqliteCode(resultCode, database: database)
            return
        }
    }
    
    public func execute(
        statement: String,
        doBindings: ((SqliteStatement) throws -> Void)? = nil,
        handleRow: ((SqliteStatement) throws -> Void)? = nil
    ) throws {
        let database = try validateDatabaseState()
        
        let sqlStatement = try prepare(statement: statement, database: database)
        defer { sqlStatement.finalize() }
        
        try doBindings?(sqlStatement)
        try processRow(sqlStatement: sqlStatement, database: database, handleRow: handleRow)
        _ = try sqlStatement.reset()
    }
    
}

// MARK: Private
extension SqliteDatabase {
    
    private func prepare(statement stat: String, database: OpaquePointer) throws -> SqliteStatement {
        var sqlStatement = OpaquePointer(bitPattern: 0)
        let tail = UnsafeMutablePointer<UnsafePointer<Int8>?>(nil as OpaquePointer?)
        let resultCode = sqlite3_prepare_v2(database, stat, Int32(stat.utf8.count), &sqlStatement, tail)
        try SqliteDatabase.validateSqliteCode(resultCode, database: database)
        return SqliteStatement(sqlStatement: sqlStatement, database: database)
    }
    
    private func processRow(
        sqlStatement: SqliteStatement,
        database: OpaquePointer,
        handleRow: ((SqliteStatement) throws -> Void)? = nil
    ) throws {
        let resultCode = sqlStatement.step()
        guard resultCode == SQLITE_ROW || resultCode == SQLITE_DONE else {
            try SqliteDatabase.validateSqliteCode(resultCode, database: database)
            return
        }
        try handleRow?(sqlStatement)
    }
    
    private func validateDatabaseState() throws -> OpaquePointer {
        switch state {
        case .error, .closed:
            assertionFailure("[SqliteDatabase] Database not open")
            
            throw DatabaseError(
                errorMessage: "Unable to execute because database is not open.",
                errorCode: .databaseNotOpen
            )
            
        case .open:
            guard let database = database else {
                assertionFailure("[SqliteDatabase] Unable to find databse, is nil.")
                
                throw DatabaseError(
                    errorMessage: "Unable to find databse, is nil.",
                    errorCode: .databaseIsNil
                )
            }
            return database
        }
    }
    
}
