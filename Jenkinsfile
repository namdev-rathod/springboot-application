pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
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
                    withDockerRegistry(credentialsId: 'DockerHub') {
                        sh "docker push namdevnmr/spring-boot-app:latest"
                  }
                }
            }
        }
        // stage('Deploy on Container') {
        //     steps {
        //         sh "docker run -d -p 8090:8080 namdevnmr/spring-boot-app:latest"
        //     }
        // }

        	stage('Deploy to kubernets'){
                steps{
                    script{
                        withKubeConfig(caCertificate: '', clusterName: 'EKS_CLOUD_DEMO', contextName: '', credentialsId: 'k8skey', namespace: 'default', restrictKubeConfigAccess: false, serverUrl: 'https://DADC05496E69DA7E44F778B5575347D4.gr7.ap-south-1.eks.amazonaws.com') {
                            sh "kubectl apply -f deployment.yaml"
                            sh "kubectl apply -f service.yaml"
                    }
                }
            }
        }
    }
}
