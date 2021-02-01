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

extension SqliteDatabase {
    
    public enum ErrorCode {
        case createDatabaseDirectory
        case databaseNotOpen
        case databaseIsNil
        case sqlStatementIsNil
        case sqlite(code: Int32)
        case sqlStatement(code: Int32)
    }
    
    public struct DatabaseError: Error {
        let errorMessage: String
        let errorCode: ErrorCode
        
        static func sqlite(db: OpaquePointer, errorCode: Int32) -> DatabaseError {
            if let errorPointer = sqlite3_errmsg(db) {
                return DatabaseError.sqlite(
                    message: String(cString: errorPointer),
                    errorCode: errorCode
                )
            } else {
                return DatabaseError.sqlite(
                    message: "Unable to read SQLite3 database error",
                    errorCode: errorCode
                )
            }
        }
        
        static func sqlStatement(db: OpaquePointer?, errorCode: Int32) -> DatabaseError {
            if let db = db, let errorPointer = sqlite3_errmsg(db) {
                return DatabaseError(
                    errorMessage: String(cString: errorPointer),
                    errorCode: .sqlStatement(code: errorCode)
                )
            } else {
                return DatabaseError(
                    errorMessage: "Unable to read SQLite3 sqlStatement error",
                    errorCode: .sqlStatement(code: errorCode)
                )
            }
        }
        
        static func sqlite(message: String, errorCode: Int32) -> DatabaseError {
            return DatabaseError(errorMessage: message, errorCode: ErrorCode.sqlite(code: errorCode))
        }
        
    }
    
    static func validateSqliteCode(_ code: Int32, database: OpaquePointer) throws {
        if code != SQLITE_OK {
            throw DatabaseError.sqlite(db: database, errorCode: code)
        }
    }
    
    static func errorMessage(fromDb database: OpaquePointer) -> String {
        if let errorPointer = sqlite3_errmsg(database) {
            return String(cString: errorPointer)
        } else {
            return ""
        }
    }

}
