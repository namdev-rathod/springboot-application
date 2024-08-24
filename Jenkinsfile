pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME = 'sonar-scanner'
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Git Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/namdev-rathod/springboot-application.git'
            }
        }
        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }
        stage('Test') {
            steps {
                sh "mvn test"
            }
        }
        stage('Trivy FS Scan') {
            steps {
                sh "trivy fs --format table -o fs.html . "
            }
        }
        stage("SonarQube Analysis"){
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token') {
                        sh '''$SCANNER_HOME/bin/sonar-scanner \
                                -Dsonar.projectName=springboot \
                                -Dsonar.projectKey=springboot \
                                -Dsonar.java.binaries=target'''
                    }
                }
            }
        }
        stage('Build') {
            steps {
                sh "mvn package"
            }
        }
        stage('Docker build and tag') {
            steps {
                sh "docker build -t namdevnmr/spring-boot-app:latest ."
            }
        }
        stage('Trivy image Scan') {
            steps {
                sh "trivy image namdevnmr/spring-boot-app:latest --format table -o image.html"
            }
        }
        stage('Docker Push Image') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'dockerhub') {
                        sh "docker push namdevnmr/spring-boot-app:latest"
                  }
                }
            }
        }
        stage('Deploy on Container') {
            steps {
                sh "docker run -d -p 8080:8080 namdevnmr/spring-boot-app:latest"
            }
        }
    }
}
