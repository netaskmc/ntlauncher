package com.mlntcandy.netask.ntlcore;

import mjson.Json;
import org.to2mbn.jmccc.launch.LaunchException;
import org.to2mbn.jmccc.launch.Launcher;
import org.to2mbn.jmccc.launch.LauncherBuilder;
import org.to2mbn.jmccc.launch.ProcessListener;
import org.to2mbn.jmccc.option.LaunchOption;
import org.to2mbn.jmccc.option.MinecraftDirectory;

import java.io.*;
import java.util.List;
import java.util.Scanner;

public class Launch {
    Launcher launcher = LauncherBuilder.buildDefault();
    NeTaskAuthenticator authenticator;
    String version;
    MinecraftDirectory dir;
    int minMemory;
    int maxMemory;
    List<String> jvmArgs;
    List<String> gameArgs;

    public Launch(Json json, MinecraftDirectory dir) {
        Json session = json.at("session");
        this.authenticator = new NeTaskAuthenticator(
                session.at("username").asString(),
                session.at("token").asString(),
                session.at("uuid").asString()
        );
        this.version = json.at("version").asString();
        this.minMemory = json.at("minMemory").asInteger();
        this.maxMemory = json.at("maxMemory").asInteger();
        this.jvmArgs = json.at("jvmArgs").asJsonList().stream().map(Json::asString).toList();
        this.gameArgs = json.at("gameArgs").asJsonList().stream().map(Json::asString).toList();
        this.dir = dir;

        try {
            launch();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static class MinecraftListener implements ProcessListener {
        @Override
        public void onLog(String log) {
            System.out.println("GAME LOG: " + log);
        }

        @Override
        public void onErrorLog(String log) {
            System.out.println("GAME ERROR: " + log);
        }

        @Override
        public void onExit(int code) {
            System.out.println("GAME EXIT: " + code);
        }
    }

    void launch() throws IOException {
        System.out.println("LOG: Launching version " + version);
        LaunchOption option = new LaunchOption(version, authenticator, dir);
        option.setMinMemory(minMemory);
        option.setMaxMemory(maxMemory);
        option.extraJvmArguments().addAll(jvmArgs);
        option.extraMinecraftArguments().addAll(gameArgs);


        try {
            Process game = launcher.launch(option, new MinecraftListener());
            // on ^D, send SIGINT to game
            Thread exiter = new Thread(() -> {
                Scanner scanner = new Scanner(System.in);

                while (scanner.hasNextLine()) {
                    String l = scanner.nextLine();
                    if (l.equals("\u0004")) {
                        game.destroy();
                        break;
                    }
                }
            });
            exiter.start();
            // wait for game to exit
            game.waitFor();
            exiter.interrupt();
            // exit
            System.out.println("LOG: Game exited.");
            System.exit(0);
        } catch (LaunchException e) {
            System.out.print("ERROR: Failed to launch. ");
            e.printStackTrace();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
