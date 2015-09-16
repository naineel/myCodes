package com.couchflix;

import javax.ws.rs.ApplicationPath;

import org.glassfish.jersey.server.ResourceConfig;

@ApplicationPath("/")
public class MyApplication extends ResourceConfig {
 
    public MyApplication() {
        // Register resources and providers using package-scanning.
        packages("com.couchflix.api");
    }
}