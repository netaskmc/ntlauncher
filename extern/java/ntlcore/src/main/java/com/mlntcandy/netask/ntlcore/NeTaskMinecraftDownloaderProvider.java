package com.mlntcandy.netask.ntlcore;

import org.to2mbn.jmccc.mcdownloader.MinecraftDownloader;
import org.to2mbn.jmccc.mcdownloader.MinecraftDownloaderBuilder;
import org.to2mbn.jmccc.mcdownloader.provider.DownloadProviderChain;
import org.to2mbn.jmccc.mcdownloader.provider.fabric.FabricDownloadProvider;
import org.to2mbn.jmccc.mcdownloader.provider.forge.ForgeDownloadProvider;
import org.to2mbn.jmccc.mcdownloader.provider.quilt.QuiltDownloadProvider;

public class NeTaskMinecraftDownloaderProvider {
    static ForgeDownloadProvider forgeProvider = new ForgeDownloadProvider();
    static FabricDownloadProvider fabricProvider = new FabricDownloadProvider();
    static QuiltDownloadProvider quiltProvider = new QuiltDownloadProvider();

    public static MinecraftDownloader downloader = MinecraftDownloaderBuilder.create().providerChain(
            DownloadProviderChain.create()
                    .addProvider(forgeProvider)
                    .addProvider(fabricProvider)
                    .addProvider(quiltProvider)
    ).build();
}
