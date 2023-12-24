package com.mlntcandy.netask.ntlcore;

import mjson.Json;
import org.to2mbn.jmccc.mcdownloader.MinecraftDownloader;
import org.to2mbn.jmccc.mcdownloader.MinecraftDownloaderBuilder;
import org.to2mbn.jmccc.mcdownloader.download.concurrent.CallbackAdapter;
import org.to2mbn.jmccc.mcdownloader.download.concurrent.DownloadCallback;
import org.to2mbn.jmccc.mcdownloader.download.tasks.DownloadTask;
import org.to2mbn.jmccc.mcdownloader.provider.DownloadProviderChain;
import org.to2mbn.jmccc.mcdownloader.provider.fabric.FabricDownloadProvider;
import org.to2mbn.jmccc.mcdownloader.provider.forge.ForgeDownloadProvider;
import org.to2mbn.jmccc.mcdownloader.provider.quilt.QuiltDownloadProvider;
import org.to2mbn.jmccc.option.MinecraftDirectory;
import org.to2mbn.jmccc.version.Version;

import java.net.URI;
import java.util.HashMap;
import java.util.Objects;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;

public class Install {
    String version;
    String mcVersion;
    MinecraftDirectory dir;

    AssetCounter assetCounter;

    long total;
    long downloaded = 0L;
    HashMap<URI, Long> currentProgress = new HashMap<>();

    InstallationType type = InstallationType.VANILLA;
    InstallationType currentType = InstallationType.VANILLA;

    MinecraftDownloader downloader = NeTaskMinecraftDownloaderProvider.downloader;

    public Install(Json json, MinecraftDirectory dir) {
        version = json.at("version").asString();
        mcVersion = version;
        if (version.contains("-")) {
            String[] split = version.split("-");
            mcVersion = split[0];

            if (Objects.equals(split[1], "forge")) {
                version = "Forge" + split[2];
                type = InstallationType.FORGE;
            }
        }
        assetCounter = new AssetCounter(mcVersion);
        this.dir = dir;

        try {
            install();
        } catch (ExecutionException | InterruptedException e) {
            e.printStackTrace();
            System.exit(1);
        }
    }

    public void install() throws ExecutionException, InterruptedException {
        if (version == null) {
            System.out.println("ERROR: No version specified");
            return;
        }
        System.out.println("LOG: Installing version " + version);

        assetCounter.countBytes().thenAccept((bytes) -> {
            total = bytes;
        }).get();

        downloadVersion(mcVersion).get();
        if (type != currentType) {
            currentType = type;
            total = 0L;
            downloadVersion(version).get();
        }
        downloader.shutdown();
        System.exit(0);
    }

    private Future<Version> downloadVersion(String ver) {
        // start a timer to report progress every 1/4 second
        Thread timer = new Thread(() -> {
            while (true) {
                try {
                    Thread.sleep(100);
                    reportProgress();
                } catch (InterruptedException e) {
                    break;
                }
            }
        });
        timer.start();

        return downloader.downloadIncrementally(dir, ver, new CallbackAdapter<Version>() {

            @Override
            public void failed(Throwable e) {
                System.out.println("ERROR: Install failed - " + e.getMessage());
                timer.interrupt();
                System.exit(1);
            }

            @Override
            public void done(Version result) {
                System.out.println("LOG: Install complete");
                timer.interrupt();
            }

            @Override
            public void cancelled() {
                System.out.println("ERROR: Install cancelled");
                timer.interrupt();
                System.exit(1);
            }

            @Override
            public <R> DownloadCallback<R> taskStart(DownloadTask<R> task) {
                URI fileUri = task.getURI();
                return new CallbackAdapter<R>() {
                    final URI uri = fileUri;

                    @Override
                    public void done(R result) {
                        downloaded += currentProgress.get(uri);
                        currentProgress.remove(uri);
                    }

                    @Override
                    public void failed(Throwable e) {
                        currentProgress.remove(uri);
                    }

                    @Override
                    public void cancelled() {
                        currentProgress.remove(uri);
                    }

                    @Override
                    public void updateProgress(long done, long total) {
                        currentProgress.put(uri, done);
                    }

                    @Override
                    public void retry(Throwable e, int current, int max) {
                        // when the sub download task fails, and the downloader decides to retry the task
                        // in this case, failed() won't be called
                    }
                };
            }
        });
    }

    public long getImmediateDownloaded() {
        long sum = downloaded;
        for (long value : currentProgress.values()) {
            sum += value;
        }
        return sum;
    }

    public void reportProgress() {
        System.out.println("PROGRESS " + currentType.identifier + ": " + getImmediateDownloaded() + "/" + total);
    }
}
