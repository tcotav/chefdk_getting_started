#!/usr/bin/env bats

@test "java is found in PATH" {
  run which java
  [ "$status" -eq 0 ]
}

@test "tomcat process is visible " {
  result=$(ps aux | grep java | grep tomcat|wc -l)
  [ "$result" -eq 1 ]
}
