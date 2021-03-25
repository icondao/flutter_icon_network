//
//  ICONWalletManager.swift
//  BigInt
//
//  Created by Leo Ngo on 25/03/2021.
//

import Foundation
import ICONKit
import BigInt

class ICONWalletManager {
    static let instance = ICONWalletManager()
    let iconService = ICONService(provider: "https://ctz.solidwallet.io/api/v3", nid: "0x3")
    private init(){}
    
    func createWallet() -> Wallet {
        let wallet = Wallet(privateKey: nil)
        return wallet
    }
    
    func getBalance(address: String) -> String {
        let result:Result<BigUInt, ICError> = iconService.getBalance(address: address).execute()
        switch result {
        case .success(let balance):
            return "\(balance)"
        case .failure( _):
            return "0"
        }
    }
}
