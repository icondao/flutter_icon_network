package com.example.flutter_icon_network;

import java.io.File;
import java.io.IOException;
import java.security.InvalidAlgorithmParameterException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.util.HashMap;
import java.util.Map;

import foundation.icon.icx.KeyWallet;
import foundation.icon.icx.crypto.KeystoreException;
import foundation.icon.icx.data.Bytes;

class ICONWalletManager {
    private static ICONWalletManager instance = null;

    private ICONWalletManager() {
    }

    public static ICONWalletManager getInstance() {
        if (instance == null) {
            return new ICONWalletManager();
        }
        return instance;
    }

    Map<String, String> createWallet() throws InvalidAlgorithmParameterException, NoSuchAlgorithmException, NoSuchProviderException {
        KeyWallet wallet = KeyWallet.create();
        Map<String, String> output = new HashMap<>();
        output.put("private_key", wallet.getPrivateKey().toHexString(false));
        output.put("address", wallet.getAddress().toString());
        return output;
    }

    Map<String, String> getWalletByPrivateKey(String privateKey) {
        assert privateKey != null;
        Map<String, String> output = new HashMap<>();
        KeyWallet wallet = KeyWallet.load(new Bytes(privateKey));  // Load keyWallet with privateKey
        output.put("private_key", wallet.getPrivateKey().toHexString(false));
        output.put("address", wallet.getAddress().toString());
        return output;
    }

    KeyWallet getWallet(String privateKey) {
        assert privateKey != null;
        return KeyWallet.load(new Bytes(privateKey));  // Load keyWallet with privateKey
    }

    Map<String, String> getStoredWallet(String password, String filePath) throws IOException, KeystoreException {
        Map<String, String> output = new HashMap<>();
        KeyWallet wallet = KeyWallet.load(password, new File(filePath));  // Load keyWallet with privateKey
        output.put("private_key", wallet.getPrivateKey().toHexString(false));
        output.put("address", wallet.getAddress().toString());
        return output;
    }

    String storeTheWallet(String directoryPath, String password, KeyWallet wallet) throws IOException, KeystoreException {
        //TODO check permission before create file, or we just need to store the private key in the share preferences
        File destinationDirectory = new File(directoryPath);
        return KeyWallet.store(wallet, password, destinationDirectory);
    }
}
