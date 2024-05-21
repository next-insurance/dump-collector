@Library('jenkins.pipeline') _

env.LOG_LEVEL = "INFO"

def imageUniqueTag
def yamlContent

def final ECR_URL = "${constants.OPS_SHARED_SERVICES_ACCOUNT}.dkr.ecr.${constants.AWS_DEFAULT_REGION}.amazonaws.com/dump-collector"

node("master") {
    github.getFile("devops", "master", "jenkins/docker_files/slave.yaml", "slave.yaml")
    yamlContent = readFile(file: "slave.yaml").replaceAll("#ECR#", constants.OPS_SHARED_SERVICES_ACCOUNT)
}

pipeline {

    agent {
        kubernetes {
            inheritFrom "jenkins-dumper-build-agent"
            yaml yamlContent
        }
    }

    options {
        timeout(time: 10, unit: 'MINUTES')
        timestamps()
    }

    triggers {
        cron("0 0 1 * *")

        GenericTrigger([
            genericVariables         : [
                [key: 'ref', value: '$.ref', expressionType: 'JSONPath', defaultValue: null],
            ],
            genericHeaderVariables   : [[key: 'X-GitHub-Event', regexpFilter: 'push']],
            regexpFilterText         : '$ref',
            regexpFilterExpression   : '^refs/heads/master$',
            causeString              : 'Triggered by webhook',
            token                    : env.JOB_BASE_NAME,
            printPostContent         : 'true',
            printContributedVariables: 'true'
        ])
    }

    stages {
        stage("Init") {
            steps {
                script {
                    def shortCommit = shell.withOutput("git log -n 1 --pretty=format:'%h'")
                    imageUniqueTag = "$shortCommit-${env.BUILD_NUMBER}"
                }
            }
        }

        stage("Build and push") {
            steps {
                script {
                    dockerFunctions.buildAndPushMultiArchDockerImage([], ["$ECR_URL:latest", "$ECR_URL:$imageUniqueTag"])
                }
            }
        }
    }

    post {
        unsuccessful {
            script {
                slackNotifier.notifySlackFreeMessage("${env.JOB_NAME} failed\n${env.BUILD_URL}", "danger", "#devex_alerts")
            }
        }
    }
}
