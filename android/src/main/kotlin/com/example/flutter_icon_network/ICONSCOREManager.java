
package com.example.flutter_icon_network;

import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
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
import foundation.icon.icx.transport.jsonrpc.RpcError;
import foundation.icon.icx.transport.jsonrpc.RpcItem;
import foundation.icon.icx.transport.jsonrpc.RpcObject;
import foundation.icon.icx.transport.jsonrpc.RpcValue;
import okhttp3.OkHttpClient;


public class ICONSCOREManager {

    private final IconService iconService;

    private final String nid;

    private static final ICONSCOREManager instance = null;

    private ICONSCOREManager(String domain, String networkId) {
        nid = networkId;
        OkHttpClient okHttpClient = new OkHttpClient.Builder()
                .readTimeout(2000, TimeUnit.MILLISECONDS)
                .writeTimeout(6000, TimeUnit.MILLISECONDS)
                .build();
        iconService = new IconService(new HttpProvider(okHttpClient, domain));
    }

    public static ICONSCOREManager getInstance(String host, String networkId) {
        if (instance == null) {
            return new ICONSCOREManager(host, networkId);
        }
        return instance;
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
        BigInteger stepLimit = new BigInteger("2000000000");
        RpcObject params = new RpcObject.Builder()
                .put("_to", new RpcValue(toAddress))
                .put("_value", new RpcValue(value))
                .build();
        Transaction transaction = TransactionBuilder.newBuilder()
                .nid(networkId)
                .from(wallet.getAddress())
                .to(tokenAddress).stepLimit(stepLimit)
                .timestamp(new BigInteger(Long.toString(timestamp)))
                .call(methodName)
                .params(params)
                .build();
//        BigInteger estimatedStep = iconService.estimateStep(transaction).execute();
        SignedTransaction signedTransaction = new SignedTransaction(transaction, wallet);
        Bytes txHash = iconService.sendTransaction(signedTransaction).execute();
        return txHash.toString();
    }

    TransactionResult deployScore(String privateKey, String initIcxSupply, byte[] content) throws IOException {
        Wallet wallet = KeyWallet.load(new Bytes(privateKey));
        String contentType = "application/zip";
        BigInteger networkId = new BigInteger(nid);
        Address fromAddress = wallet.getAddress();
        Address toAddress = new Address("cx0000000000000000000000000000000000000000");
        long timestamp = System.currentTimeMillis() * 1000L;
        BigInteger nonce = new BigInteger("1");

        BigInteger initialSupply = new BigInteger(initIcxSupply);
        BigInteger decimals = new BigInteger("18");

        RpcObject params = new RpcObject.Builder()
                .put("_initialSupply", new RpcValue(initialSupply))
                .put("_decimals", new RpcValue(decimals))
                .build();
        BigInteger stepLimit = new BigInteger("2000000000");

        // make a raw transaction without the stepLimit
        Transaction transaction = TransactionBuilder.newBuilder()
                .nid(networkId)
                .from(fromAddress)
                .to(toAddress).stepLimit(stepLimit)
                .timestamp(new BigInteger(Long.toString(timestamp)))
                .nonce(nonce)
                .deploy(contentType, content)
                .params(params)
                .build();

        // set some margin value for the operation of `on_install`
        BigInteger margin = BigInteger.valueOf(10000);

        // make a signed transaction with the same raw transaction and the estimated step
        SignedTransaction signedTransaction = new SignedTransaction(transaction, wallet);
        Bytes hash = iconService.sendTransaction(signedTransaction).execute();
        System.out.println("txHash: " + hash);
        return getTransactionResult(hash);
    }

    TransactionResult getTransactionResult(Bytes txHash) throws IOException {
        TransactionResult result = null;
        while (result == null) {
            try {
                result = iconService.getTransactionResult(txHash).execute();
            } catch (RpcError e) {
                System.out.println("RpcError: code: " + e.getCode() + ", message: " + e.getMessage());
                try {
                    // wait until block confirmation
                    System.out.println("Sleep 1.2 second.");
                    Thread.sleep(1200);
                } catch (InterruptedException ie) {
                    ie.printStackTrace();
                }
            }
        }
        return result;
    }
}
