package com.example.cicdapp;

import java.util.Map;
import org.springframework.boot.info.BuildProperties;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class VersionController {

  private final BuildProperties buildProperties;

  public VersionController(BuildProperties buildProperties) {
    this.buildProperties = buildProperties;
  }

  @GetMapping("/version")
  public Map<String, String> version() {
    return Map.of(
        "name", buildProperties.getName(),
        "version", buildProperties.getVersion(),
        "time", String.valueOf(buildProperties.getTime())
    );
  }
}