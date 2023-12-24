package com.mlntcandy.netask.ntlcore;

import java.util.Locale;

public enum InstallationType {
    VANILLA("VANILLA", true),
    FORGE("FORGE", false),
    FABRIC("FABRIC", false),
    LITELOADER("LITELOADER", false),
    ;

    public final String identifier;
    public final boolean isVanilla;

    InstallationType(String identifier, boolean isVanilla) {
        this.identifier = identifier;
        this.isVanilla = isVanilla;
    }

    public static InstallationType fromVersionName(String version) {
        for (InstallationType type : values()) {
            if (version.toUpperCase(Locale.ROOT).contains(type.identifier)) {
                return type;
            }
        }
        return null;
    }
}
