package com.mlntcandy.netask.ntlcore;

import mjson.Json;
import org.to2mbn.jmccc.option.MinecraftDirectory;

public class Main {
    public static void main(String[] args) {
        String inputJson = String.join(" ", args);
//        System.out.println("LOG: Input JSON: " + inputJson);
        Json json = Json.read(inputJson);
        String action = json.at("action").asString();
        String dir = json.at("dir").asString();

        MinecraftDirectory minecraftDirectory = new MinecraftDirectory(dir);
        switch (action) {
            case "install" -> new Install(json.at("installDetails"), minecraftDirectory);
            case "launch" -> new Launch(json.at("launchDetails"), minecraftDirectory);
            default -> System.out.println("ERROR: Invalid action");
        }
    }
}
