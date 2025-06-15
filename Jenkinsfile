#!/usr/bin/env groovy
library 'identifier' : 'jenkins-shared-library@master','retriever': modernSCM(
    [
        $class: 'GitSCMSource',
        remote: 'https://gitlab.com/AbdelrahmanElshahat/jenkins-shared-library.git',
        credentials: 'gitlab-credentials'
    ]
)
pipeline{
    agent any 
    tools {
        nodejs 'my-nodejs'
    }
    environment {
       DISCORD_WEBHOOK_URL = credentials('discord')
    }
    stages{
        stage("Detect Changes"){
            steps{
                script {
                    def changes = sh(script: 'git diff --name-only HEAD~1', returnStdout: true).trim()
                    env.BUILD_FRONTEND = changes.contains('frontend/') ? 'true' : 'false'
                    env.BUILD_BACKEND = changes.contains('backend/') ? 'true' : 'false'
                }
            }
        }
        stage("build frontend"){
            when {
                anyOf {
                    environment name: 'BUILD_FRONTEND', value: 'true'
                }
            }
            steps{
                script {
                    dir('frontend'){
                        buildNodejs()
                        incrementNodejsVersion()
                    }
                }
            }
        }
        stage("build backend"){
            when {
                anyOf {
                    environment name: 'BUILD_BACKEND', value: 'true'
                }
            }
            steps{
                script {
                    dir('backend'){
                        buildNodejs()
                        incrementNodejsVersion()
                    }
                }
            }
        }
        stage("build backend image"){
            when {
                anyOf {
                    environment name: 'BUILD_BACKEND', value: 'true'
                }
            }
            steps{
                echo "========executing build backend image stage========"
                script {
                    dir('backend'){
                    def version = getVersionFromPackageJson()
                    buildImage "elshahat20/my-app:itiBack-${version}"
                    }
                }
            }
        }
        stage("build frontend image"){
            when {
                anyOf {
                    environment name: 'BUILD_FRONTEND', value: 'true'
                }
            }
            steps{
                echo "========executing build frontend image stage========"
                script {
                    dir('frontend') {
                        def version = getVersionFromPackageJson()
                        buildImage "elshahat20/my-app:itiFront-${version}"
                    }
                }
            }
        }
        stage("docker Login"){
            steps{
                echo "========executing docker login stage========"
                script {
                    dockerLogin()
                }
            }
        }
        stage("push Frontend Image"){
            when {
                anyOf {
                    environment name: 'BUILD_FRONTEND', value: 'true'
                }
            }
            steps{
                echo "========executing push frontend image stage========"
                script {
                    dir('frontend') {
                    def version = getVersionFromPackageJson()
                    dockerPush "elshahat20/my-app:itiFront-${version}"
                    }
                }
            }
        }
        stage("push Backend Image"){
            when {
                anyOf {
                    environment name: 'BUILD_BACKEND', value: 'true'
                }
            }
            steps{
                echo "========executing push backend image stage========"
                script {
                    dir('backend') {
                    def version = getVersionFromPackageJson()
                    dockerPush "elshahat20/my-app:itiBack-${version}"
                    }
                }
            }
        }
        stage("update backend k8s manifest"){
            when {
                anyOf {
                    environment name: 'BUILD_BACKEND', value: 'true'
                }
            }
            steps{
                echo "========executing update k8s manifest stage========"
                dir('backend'){
                    script {
                        def version = getVersionFromPackageJson()
                    }
                }
                script {
                    dir('k8s') {
                        sh """
                            sed -i 's|image: elshahat20/my-app:itiBack-.*|image: elshahat20/my-app:itiBack-${version}|' backend-deployment.yaml
                        """
                    }
                }
            }
        }
        stage("update frontend k8s manifest"){
            when {
                anyOf {
                    environment name: 'BUILD_FRONTEND', value: 'true'
                }
            }
            steps{
                echo "========executing update k8s manifest stage========"
                dir('frontend'){
                    script {
                        def version = getVersionFromPackageJson()
                    }
                }
                script {
                    dir('k8s') {
                        sh """
                            sed -i 's|image: elshahat20/my-app:itiFront-.*|image: elshahat20/my-app:itiFront-${version}|' frontend-deployment.yaml
                        """
                    }
                }
            }
        }
         stage("push version"){
            steps{
                echo "========executing push version stage========"
                script {
                    pushVersionToGit()
                }
            }
        }
    }
    post{
        always{
            echo "========always========"
        }
        success{
            echo "========pipeline executed successfully ========"
            script {
                def changes = []
                if (env.BUILD_FRONTEND == 'true') {
                    changes.add('Frontend')
                }
                if (env.BUILD_BACKEND == 'true') {
                    changes.add('Backend')
                }
                def changesText = changes.size() > 0 ? changes.join(' & ') : 'No changes detected'
                
                def payload = """
                {
                    "embeds": [
                        {
                            "title": "✅ Pipeline Build Successful",
                            "description": "Build completed successfully for: ${changesText}",
                            "color": 65280,
                            "timestamp": "${new Date().format("yyyy-MM-dd'T'HH:mm:ss'Z'")}",
                            "fields": [
                                {
                                    "name": "Job Name",
                                    "value": "${env.JOB_NAME}",
                                    "inline": true
                                },
                                {
                                    "name": "Build Number",
                                    "value": "#${env.BUILD_NUMBER}",
                                    "inline": true
                                },
                                {
                                    "name": "Status",
                                    "value": "SUCCESS",
                                    "inline": true
                                },
                                {
                                    "name": "Duration",
                                    "value": "${currentBuild.durationString}",
                                    "inline": true
                                },
                                {
                                    "name": "Build URL",
                                    "value": "[View Build](${env.BUILD_URL})",
                                    "inline": false
                                }
                            ],
                            "footer": {
                                "text": "Jenkins CI/CD Pipeline",
                                "icon_url": "https://wiki.jenkins.io/download/attachments/2916393/logo.png"
                            }
                        }
                    ]
                }
                """
                
                sh """
                    curl -H "Content-Type: application/json" \\
                         -X POST \\
                         -d '${payload}' \\
                         "${env.DISCORD_WEBHOOK_URL}"
                """
            }
        }
        failure{
            echo "========pipeline execution failed========"
            script {
                def changes = []
                if (env.BUILD_FRONTEND == 'true') {
                    changes.add('Frontend')
                }
                if (env.BUILD_BACKEND == 'true') {
                    changes.add('Backend')
                }
                def changesText = changes.size() > 0 ? changes.join(' & ') : 'No changes detected'
                
                def payload = """
                {
                    "embeds": [
                        {
                            "title": "❌ Pipeline Build Failed",
                            "description": "Build failed for: ${changesText}",
                            "color": 16711680,
                            "timestamp": "${new Date().format("yyyy-MM-dd'T'HH:mm:ss'Z'")}",
                            "fields": [
                                {
                                    "name": "Job Name",
                                    "value": "${env.JOB_NAME}",
                                    "inline": true
                                },
                                {
                                    "name": "Build Number",
                                    "value": "#${env.BUILD_NUMBER}",
                                    "inline": true
                                },
                                {
                                    "name": "Status",
                                    "value": "FAILURE",
                                    "inline": true
                                },
                                {
                                    "name": "Duration",
                                    "value": "${currentBuild.durationString}",
                                    "inline": true
                                },
                                {
                                    "name": "Build URL",
                                    "value": "[View Build](${env.BUILD_URL})",
                                    "inline": false
                                }
                            ],
                            "footer": {
                                "text": "Jenkins CI/CD Pipeline",
                                "icon_url": "https://wiki.jenkins.io/download/attachments/2916393/logo.png"
                            }
                        }
                    ]
                }
                """
                
                sh """
                    curl -H "Content-Type: application/json" \\
                         -X POST \\
                         -d '${payload}' \\
                         "${env.DISCORD_WEBHOOK_URL}"
                """
            }
        }
        unstable{
            echo "========pipeline execution unstable========"
            script {
                def changes = []
                if (env.BUILD_FRONTEND == 'true') {
                    changes.add('Frontend')
                }
                if (env.BUILD_BACKEND == 'true') {
                    changes.add('Backend')
                }
                def changesText = changes.size() > 0 ? changes.join(' & ') : 'No changes detected'
                
                def payload = """
                {
                    "embeds": [
                        {
                            "title": "⚠️ Pipeline Build Unstable",
                            "description": "Build completed with warnings for: ${changesText}",
                            "color": 16776960,
                            "timestamp": "${new Date().format("yyyy-MM-dd'T'HH:mm:ss'Z'")}",
                            "fields": [
                                {
                                    "name": "Job Name",
                                    "value": "${env.JOB_NAME}",
                                    "inline": true
                                },
                                {
                                    "name": "Build Number",
                                    "value": "#${env.BUILD_NUMBER}",
                                    "inline": true
                                },
                                {
                                    "name": "Status",
                                    "value": "UNSTABLE",
                                    "inline": true
                                },
                                {
                                    "name": "Duration",
                                    "value": "${currentBuild.durationString}",
                                    "inline": true
                                },
                                {
                                    "name": "Build URL",
                                    "value": "[View Build](${env.BUILD_URL})",
                                    "inline": false
                                }
                            ],
                            "footer": {
                                "text": "Jenkins CI/CD Pipeline",
                                "icon_url": "https://wiki.jenkins.io/download/attachments/2916393/logo.png"
                            }
                        }
                    ]
                }
                """
                
                sh """
                    curl -H "Content-Type: application/json" \\
                         -X POST \\
                         -d '${payload}' \\
                         "${env.DISCORD_WEBHOOK_URL}"
                """
            }
        }
    }
}

                    
