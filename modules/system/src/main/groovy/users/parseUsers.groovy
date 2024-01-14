#!/usr/bin/env groovy

import groovy.json.JsonOutput
import groovy.json.JsonSlurper

if (args.length != 1) {
    System.err.println("Usage: groovy parseUsers.groovy [path_to_json_file]")
    System.exit(1)
}

String jsonFilePath = args[0]

def jsonSlurper = new JsonSlurper()
def users

try {
    users = jsonSlurper.parse(new File(jsonFilePath))
} catch (FileNotFoundException e) {
    System.err.println("File not found: $jsonFilePath")
    System.exit(1)
} catch (Exception e) {
    System.err.println("Error parsing JSON file: ${e.message}")
    System.exit(1)
}

users.each { user ->
    println(JsonOutput.toJson(user))
}
