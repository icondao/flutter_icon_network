//  Created by Leo Ngo on 25/03/2021.
import Foundation
import ICONKit
import BigInt

class ICONTransactionManager {
    static let instance = ICONTransactionManager()
    let iconService = ICONService(provider: "https://ctz.solidwallet.io/api/v3", nid: "0x3")
    private init(){}
    
    func sendICX(from: String, to: String, value: String) -> String {
        let privateKey = PrivateKey(hex: Data(hex: from))
        let wallet = Wallet(privateKey: privateKey)
        
        let coinTransfer = Transaction()
            .from(wallet.address)
            .to(to)
            .value(BigUInt(Int(value)!))
            .stepLimit(BigUInt(1000000))
            .nid(self.iconService.nid)
            .nonce("0x1")
        
        do {
            let signed = try SignedTransaction(transaction: coinTransfer, privateKey: privateKey)
            let request = iconService.sendTransaction(signedTransaction: signed)
            let response = request.execute()
            
            switch response {
            case .success(let txHash):
                return txHash
            case .failure( _):
                return ""
            }
        } catch {
            return ""
        }
    }
    
}
