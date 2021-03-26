package com.example.flutter_icon_network;

import java.io.IOException;
import java.math.BigInteger;
import java.util.concurrent.TimeUnit;

import foundation.icon.icx.Call;
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
import foundation.icon.icx.transport.jsonrpc.RpcItem;
import foundation.icon.icx.transport.jsonrpc.RpcObject;
import foundation.icon.icx.transport.jsonrpc.RpcValue;
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
        // Send the transaction
        Bytes txHash = iconService.sendTransaction(signedTransaction).execute();
        return txHash.toString();
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

    BigInteger getTokenBalance(String privateKey, String scoreAddress) throws IOException {
        Wallet wallet = KeyWallet.load(new Bytes(privateKey));
        Address tokenAddress = new Address(scoreAddress);
        String methodName = "balanceOf";
        RpcObject params = new RpcObject.Builder()
                .put("_owner", new RpcValue(wallet.getAddress()))
                .build();

        Call<RpcItem> call = new Call.Builder()
                .to(tokenAddress)
                .method(methodName)
                .params(params)
                .build();

        RpcItem result = iconService.call(call).execute();
        return result.asInteger();
    }

    String sendToken(String privateKey, String toAddress, String scoreAddress, String numOfToken) throws IOException {
        Wallet wallet = KeyWallet.load(new Bytes(privateKey));
        int tokenDecimals = 18;
        BigInteger value = IconAmount.of(numOfToken, tokenDecimals).toLoop();
        Address tokenAddress = new Address(scoreAddress);
        BigInteger networkId = new BigInteger(nid);
        long timestamp = System.currentTimeMillis() * 1000L;
        String methodName = "transfer";

        RpcObject params = new RpcObject.Builder()
                .put("_to", new RpcValue(toAddress))
                .put("_value", new RpcValue(value))
                .build();
        Transaction transaction = TransactionBuilder.newBuilder()
                .nid(networkId)
                .from(wallet.getAddress())
                .to(tokenAddress)
                .timestamp(new BigInteger(Long.toString(timestamp)))
                .call(methodName)
                .params(params)
                .build();
        BigInteger estimatedStep = iconService.estimateStep(transaction).execute();
        SignedTransaction signedTransaction = new SignedTransaction(transaction, wallet, estimatedStep);
        Bytes txHash = iconService.sendTransaction(signedTransaction).execute();
        return txHash.toString();
    }
}
