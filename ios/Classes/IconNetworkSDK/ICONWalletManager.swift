//  Created by Leo Ngo on 25/03/2021.
import Foundation
import ICONKit
import BigInt

class ICONWalletManager {
    static let instance = ICONWalletManager()
    let iconService = ICONService(provider: "https://bicon.net.solidwallet.io/api/v3", nid: "0x3")
    private init(){}
    
    func createWallet() -> Wallet {
        let wallet = Wallet(privateKey: nil)
        return wallet
    }
    
    func getBalance(privateKey: String) -> String {
        let wallet = getWalletFromPrivateKey(privateKey: privateKey)
        let result:Result<BigUInt, ICError> = iconService.getBalance(address: wallet.address).execute()
        switch result {
        case .success(let balance):
            return "\(balance)"
        case .failure( _):
            return "0"
        }
    }
    
    func getWalletFromPrivateKey(privateKey: String) -> Wallet {
        let privateKey = PrivateKey(hex: Data(hex: privateKey))
        return Wallet(privateKey: privateKey)
    }
}
