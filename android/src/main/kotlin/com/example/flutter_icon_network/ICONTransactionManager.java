package com.example.flutter_icon_network;

import java.io.IOException;
import java.math.BigInteger;
import java.util.concurrent.TimeUnit;
import foundation.icon.icx.IconService;
import foundation.icon.icx.KeyWallet;
import foundation.icon.icx.SignedTransaction;
import foundation.icon.icx.Transaction;
import foundation.icon.icx.TransactionBuilder;
import foundation.icon.icx.Wallet;
import foundation.icon.icx.data.Address;
import foundation.icon.icx.data.Bytes;
import foundation.icon.icx.data.IconAmount;
import foundation.icon.icx.data.TransactionResult;
import foundation.icon.icx.transport.http.HttpProvider;
import okhttp3.OkHttpClient;

public class ICONTransactionManager {

    private final IconService iconService;

    private final String nid;

    private static final ICONTransactionManager instance = null;

    private ICONTransactionManager(String domain, String networkId) {
        nid = networkId;
        OkHttpClient okHttpClient = new OkHttpClient.Builder()
                .readTimeout(2000, TimeUnit.MILLISECONDS)
                .writeTimeout(6000, TimeUnit.MILLISECONDS)
                .build();
        iconService = new IconService(new HttpProvider(okHttpClient, domain));
    }

    public static ICONTransactionManager getInstance(String host, String networkId) {
        if (instance == null) {
            return new ICONTransactionManager(host, networkId);
        }
        return instance;
    }

    /**
     * send ICX to another address
     *
     * @param privateKey use to load the KeyWallet
     * @param value      How much ICX you want to send
     * @param toAddress  The address you want to send
     * @return TransactionResult
     * @throws IOException
     */
    String sendICX(String privateKey, String value, String toAddress) throws IOException {
        Wallet wallet = KeyWallet.load(new Bytes(privateKey));
        Address addressToSend = new Address(toAddress);
        // 1 ICX -> 1000000000000000000 loop conversion
        BigInteger valueToSend = IconAmount.of(value, IconAmount.Unit.ICX).toLoop();
        // Network ID ("1" for Mainnet, "2" for Testnet, etc)
        BigInteger networkId = new BigInteger(nid);
        // Only `default` step cost is required to transfer ICX: it is `100000` as of now.
        BigInteger stepLimit = new BigInteger("100000");
        // Timestamp is used to prevent the identical transactions. Only current time is required (Standard unit: us)
        // If the timestamp is considerably different from the current time, the transaction will be rejected.
        long timestamp = System.currentTimeMillis() * 1000L;
        //Enter transaction information
        Transaction transaction = TransactionBuilder.newBuilder()
                .nid(networkId)
                .from(wallet.getAddress())
                .to(addressToSend)
                .value(valueToSend)
                .stepLimit(stepLimit)
                .timestamp(new BigInteger(Long.toString(timestamp)))
                .build();

        // Create signature of the transaction
        SignedTransaction signedTransaction = new SignedTransaction(transaction, wallet);
        // Read params to transfer to nodes
        // System.out.println(signedTransaction.getProperties());
        // Send the transaction
        Bytes txHash = iconService.sendTransaction(signedTransaction).execute();
        return txHash.toString();
//        return iconService.getTransactionResult(txHash).execute();
    }

    /**
     * you can check the ICX balance by looking up the transaction before and after the transaction
     *
     * @param privateKey use to load the KeyWallet
     * @return BigInteger balance
     * @throws IOException
     */
    BigInteger getICXBalance(String privateKey) throws IOException {
        Wallet wallet = KeyWallet.load(new Bytes(privateKey));
        return iconService.getBalance(wallet.getAddress()).execute();
    }

    //gradle myRun --args='c958108ccc79513ef9bf7647c29194199e3c5b86a88cbbc236dd5f74dfc37366  hx1f617adb52d49f65d60c48a3109fb0e7b3cd72ea 11'
//    public static void main(String[] args) {
//        if (args != null && args.length > 0) {
//            System.out.println("Your private key: " + args[0]);
//            System.out.println("Address to send: " + args[1]);
//            System.out.println("ICX: " + args[2]);
//            try {
//                TransactionResult result = ICONTransactionManager.getInstance("https://bicon.net.solidwallet.io/api/v3").sendICX(args[0], args[2].toString(), args[1], false);
//                System.out.println("TransactionResult " + result.getStatus());
//            } catch (IOException e) {
//                System.out.println(e.getLocalizedMessage());
//                e.printStackTrace();
//            }
//        } else {
//            System.out.println("Please provide the args for me with this statement: gradle myRun --args='[your private key] [address to send icx] [icx value]'");
//        }
//    }
}
