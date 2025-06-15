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
       CI = 'false'
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
            environment {
                CI = 'false'
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
                    buildImage "public.ecr.aws/w2s7s2g7/iti-project-backend:${version}"
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
            environment {
                CI = 'false'
            }
            steps{
                echo "========executing build frontend image stage========"
                script {
                    dir('frontend') {
                        def version = getVersionFromPackageJson()
                        buildImage "public.ecr.aws/w2s7s2g7/iti-project-frontend:${version}"
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
        stage("Trivy Scan Frontend"){
            when {
                anyOf {
                    environment name: 'BUILD_FRONTEND', value: 'true'
                }
            }
            steps{
                echo "========executing Trivy scan frontend image stage========"
                script {
                    dir('frontend') {
                        def version = getVersionFromPackageJson()
                        sh """
                            # Install Trivy if not already installed (Amazon Linux)
                            if ! command -v trivy &> /dev/null; then
                                echo "Installing Trivy on Amazon Linux..."
                                sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.48.3/trivy_0.48.3_Linux-64bit.rpm
                            fi
                            
                            # Scan the frontend image
                            trivy image --exit-code 0 --severity LOW,MEDIUM --format table public.ecr.aws/w2s7s2g7/iti-project-frontend:${version}
                            trivy image --exit-code 1 --severity HIGH,CRITICAL --format table public.ecr.aws/w2s7s2g7/iti-project-frontend:${version}
                        """
                    }
                }
            }
        }
        stage("Trivy Scan Backend"){
            when {
                anyOf {
                    environment name: 'BUILD_BACKEND', value: 'true'
                }
            }
            steps{
                echo "========executing Trivy scan backend image stage========"
                script {
                    dir('backend') {
                        def version = getVersionFromPackageJson()
                        sh """
                            # Install Trivy if not already installed (Amazon Linux)
                            if ! command -v trivy &> /dev/null; then
                                echo "Installing Trivy on Amazon Linux..."
                                sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.48.3/trivy_0.48.3_Linux-64bit.rpm
                            fi
                            
                            # Scan the backend image
                            trivy image --exit-code 0 --severity LOW,MEDIUM --format table public.ecr.aws/w2s7s2g7/iti-project-backend:${version}
                            trivy image --exit-code 1 --severity HIGH,CRITICAL --format table public.ecr.aws/w2s7s2g7/iti-project-backend:${version}
                        """
                    }
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
                    dockerPush "public.ecr.aws/w2s7s2g7/iti-project-frontend:${version}"
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
                    dockerPush "public.ecr.aws/w2s7s2g7/iti-project-backend:${version}"
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
                script {
                    def version
                    dir('backend'){
                        version = getVersionFromPackageJson()
                    }
                    dir('k8s') {
                        sh """
                            sed -i 's|image: public.ecr.aws/w2s7s2g7/iti-project-backend:.*|image: public.ecr.aws/w2s7s2g7/iti-project-backend:${version}|' backend.yaml
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
                script {
                    def version
                    dir('frontend'){
                        version = getVersionFromPackageJson()
                    }
                    dir('k8s') {
                        sh """
                            sed -i 's|image: public.ecr.aws/w2s7s2g7/iti-project-frontend:.*|image: public.ecr.aws/w2s7s2g7/iti-project-frontend:${version}|' frontend.yaml
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

                    
