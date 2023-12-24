package com.mlntcandy.netask.ntlcore;

import org.to2mbn.jmccc.auth.AuthInfo;
import org.to2mbn.jmccc.auth.Authenticator;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class NeTaskAuthenticator implements Authenticator {
    Map<String, String> properties = new HashMap<>();

    String username;
    String token;
    UUID uuid;

    public NeTaskAuthenticator(String username, String token, String uuid) {
        this.username = username;
        this.token = token;
        this.uuid = UUID.fromString(uuid);
    }
    @Override
    public AuthInfo auth() {
        return new AuthInfo(
                username,
                token,
                uuid,
                properties,
                "mojang"
        );
    }




}
