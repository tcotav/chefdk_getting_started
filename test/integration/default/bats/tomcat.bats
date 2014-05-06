#!/usr/bin/env bats

@test "java is found in PATH" {
  run which java
  [ "$status" -eq 0 ]
}

@test "tomcat process is visible " {
  result=$(ps aux | grep java | grep tomcat|wc -l)
  [ "$result" -eq 1 ]
}


@test "war is placed in proper location " {
  run [ -f /var/lib/tomcat6/webapps/punter.war ]
  [ "$status" -eq 0 ]
}


@test "war is unrolled" {
  run [ -d /var/lib/tomcat6/webapps/punter ]
  [ "$status" -eq 0 ]
}