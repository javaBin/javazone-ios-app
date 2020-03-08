import Foundation
import CommonCrypto
import CryptoSwift
import os

class HashService {
    public static func hash(salt: String, value: String) -> String {
        let valueBytes: [UInt8] = Array(value.utf8)
        let saltBytes: [UInt8] = Array(salt.utf8)
        
        let hash = PBKDF2SHA512(value: valueBytes, salt: saltBytes)
        
        os_log("Hash %{public}@", log: .crypto, type: .debug, hash)

        return hash
        
    }
    
    static func PBKDF2SHA512(value: Array<UInt8>, salt: Array<UInt8>) -> String {
        let value = try! PKCS5.PBKDF2(password: value, salt: salt, iterations: 10000, keyLength: 64, variant: .sha512).calculate()
        
        return value.toHexString()
    }
}
