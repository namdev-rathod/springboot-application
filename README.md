# Deploy Springboot Application
## Result
![image](image.png)

## 1. Run in the Local
### Requirement
Installing Java 17:

    sudo apt update
    sudo apt install openjdk-17-jdk

Installing Maven:
    
    sudo apt update
    sudo apt install maven



Clean and Install the Project:

    mvn clean install


Compile the Project:

    mvn compile

Build the Project:

    mvn package

Run the Application:
Or, navigate to the target directory and run the packaged JAR file:
    
    cd target
    java -jar springboot-0.0.1-SNAPSHOT.jar


Build Issues:
If the build fails, run Maven with detailed logging to diagnose the problem:

    mvn clean install -X

## 2. Run in Docker

Building and Running the Docker Image

        docker build -t namdevnmr/spring-boot-app:latest .

Pushing the Docker Image

        docker push namdevnmr/spring-boot-app:latest       

Run the Docker Container:

        docker run -d -p 8080:8080 namdevnmr/spring-boot-app:latest

# Jenkins file for Docker deployment Auto stop/terminate & deployment of container with latest changes.
Note: 
No need to stop and kill existing docker container. this pipeline will take care automatically.

```
pipeline {
    agent any
    tools {
        jdk 'jdk17'
        maven 'maven3'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        IMAGE_NAME = "my-springboot-app"
        CONTAINER_NAME = "springboot-app-container"
        REGISTRY = "namdevnmr/${IMAGE_NAME}"
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
                sh 'docker build -t namdevnmr/${IMAGE_NAME}:${BUILD_NUMBER} .'
            }
        }
        stage('Trivy image Scan') {
            steps {
                sh "trivy image namdevnmr/${IMAGE_NAME}:${BUILD_NUMBER} --format table -o image.html"
            }
        }
        stage('Docker Push Image') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'DockerHub') {
                        sh "docker push namdevnmr/${IMAGE_NAME}:${BUILD_NUMBER}"
                  }
                }
            }
        }
        stage('Stop and Remove Old Container') {
            steps {
                script {
                    // Stop and remove the existing container if it exists
                    sh """
                    if [ \$(docker ps -q -f name=${CONTAINER_NAME}) ]; then
                        docker stop ${CONTAINER_NAME}
                        docker rm ${CONTAINER_NAME}
                    fi
                    """
                }
            }
        }
        
        stage('Deploy on Container') {
            steps {
                sh 'docker run -d --name ${CONTAINER_NAME} -p 8070:8080 namdevnmr/${IMAGE_NAME}:${BUILD_NUMBER}'
            }
        }
    }
}
```

        
