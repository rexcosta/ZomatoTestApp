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

public final class SqliteStatement {
    
    private let database: OpaquePointer
    private var sqlStatement: OpaquePointer?
    
    typealias SqliteDestructor = @convention(c) (UnsafeMutableRawPointer?) -> Void
    
    deinit {
        finalize()
    }
    
    init(sqlStatement: OpaquePointer?, database: OpaquePointer) {
        self.sqlStatement = sqlStatement
        self.database = database
    }
    
    public func close() {
        finalize()
    }
    
    public func finalize() {
        if let sqlStatement = sqlStatement {
            sqlite3_finalize(sqlStatement)
        }
        sqlStatement = nil
    }
    
    public func step() -> Int32 {
        if let sqlStatement = sqlStatement {
            return sqlite3_step(sqlStatement)
        }
        return SQLITE_MISUSE
    }
    
    public func reset() throws -> Int32 {
        guard let sqlStatement = sqlStatement else {
            throw SqliteDatabase.DatabaseError(
                errorMessage: "Unable to reset sql statement is nil",
                errorCode: .sqlStatementIsNil
            )
        }
        
        let sqlResult = sqlite3_reset(sqlStatement)
        try validateSqliteCode(sqlResult)
        return sqlResult
    }
    
}

// MARK: Bind
extension SqliteStatement {
    
    public func bind(position: Int, _ value: String) throws {
        guard let sqlStatement = sqlStatement else {
            throw SqliteDatabase.DatabaseError(
                errorMessage: "Unable to bind sql statement is nil",
                errorCode: .sqlStatementIsNil
            )
        }
        
        let sqlResult = sqlite3_bind_text(
            sqlStatement,
            getBindPosition(position),
            value,
            Int32(value.utf8.count),
            unsafeBitCast(OpaquePointer(bitPattern: -1), to: SqliteDestructor.self)
        )
        
        try validateSqliteCode(sqlResult)
    }
    
}

// MARK: Read
extension SqliteStatement {
    
    public func columnInt(position: Int) throws -> Int {
        guard let sqlStatement = sqlStatement else {
            throw SqliteDatabase.DatabaseError(
                errorMessage: "Unable to columnInt sql statement is nil",
                errorCode: .sqlStatementIsNil
            )
        }
        return Int(
            sqlite3_column_int64(
                sqlStatement,
                Int32(position)
            )
        )
    }
    
}

// MARK: Helpers
extension SqliteStatement {
    
    func validateSqliteCode(_ code: Int32) throws {
        if code != SQLITE_OK {
            throw SqliteDatabase.DatabaseError.sqlStatement(db: database, errorCode: code)
        }
    }
    
    // SQLite3 starts at one but we use index 0 for start
    private func getBindPosition(_ position: Int) -> Int32 {
        return Int32(position + 1)
    }
    
}
