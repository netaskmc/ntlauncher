package com.mlntcandy.netask.ntlcore;


import mjson.Json;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.nio.client.CloseableHttpAsyncClient;
import org.apache.http.impl.nio.client.HttpAsyncClients;
import org.apache.http.util.EntityUtils;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.Future;

public class AssetCounter {
    static final String VERSION_MANIFEST = "https://piston-meta.mojang.com/mc/game/version_manifest_v2.json";

    String version;
    long total;

    CloseableHttpAsyncClient httpclient = HttpAsyncClients.createDefault();

    public AssetCounter(String version) {
        this.version = version;
    }

    private CompletableFuture<Json> makeJsonRequest(String url) {
        httpclient.start();
        HttpGet request = new HttpGet(url);
        Future<HttpResponse> responseFuture = httpclient.execute(request, null);
        return FutureUtil.makeCompletableFuture(responseFuture)
                .thenApplyAsync(response -> {
                    try {
                        String json = EntityUtils.toString(response.getEntity());
                        return Json.read(json);
                    } catch (Exception e) {
                        throw new RuntimeException(e);
                    }
                });
    }

    public CompletableFuture<Long> countBytes() {
        return makeJsonRequest(VERSION_MANIFEST)
                .thenApplyAsync(json -> json.at("versions").asJsonList().stream()
                        .filter(v -> v.at("id").asString().equals(version))
                        .findFirst()
                        .orElseThrow()
                        .at("url")
                        .asString())
                .thenComposeAsync(this::makeJsonRequest)
                .thenApplyAsync(json -> {
                    // count client jar
                    total += json.at("downloads").at("client").at("size").asLong();

                    // count assets
                    total += json.at("assetIndex").at("totalSize").asLong();

                    // count libraries
                    json.at("libraries").asJsonList().forEach(lib -> {
                        if (lib.has("downloads")) {
                            total += lib.at("downloads").at("artifact").at("size").asLong();
                        }
                    });

                    return this.total;
                });
    }

}
