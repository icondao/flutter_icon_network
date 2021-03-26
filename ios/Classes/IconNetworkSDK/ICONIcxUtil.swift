//  Created by Leo Ngo on 25/03/2021.
import Foundation
import ICONKit
import BigInt

class ICONIcxUtil {
    static func getInstance(host: String, networkId: String) -> ICONIcxUtil {
        if(instance == nil) {
            instance = ICONIcxUtil(host: host, networkId: networkId)
        }
        return instance!
    }
    static var instance: ICONIcxUtil?
    let iconService: ICONService

    private init(host: String, networkId: String){
        iconService = ICONService(provider: host, nid: networkId)
    }
    
    func getTotalSupply() -> String {
        let result:Result<BigUInt, ICError> = iconService.getTotalSupply().execute()
        switch result {
        case .success(let total):
            return "\(total)"
        case .failure( _):
            return "0"
        }
    }
    
    static func stringToHexString(value: String) -> String {
        let bigIntValue = BigUInt(Int(value)!*1000000000000000000)
        print("stringToHexString \(bigIntValue) to \(bigIntValue.toHexString())")
        return bigIntValue.toHexString()
    }
}
