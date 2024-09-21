pipeline {
  agent any
  tools {
        maven 'maven' // Specify the version of Maven you want to use
  }
  environment {
        DOCKER_HUB_CREDENTIALS = credentials('docker_hub_repo')
        IMAGE_NAME = "haladhaouadi/my-repo"
        IMAGE_TAG = "devsecops-${env.BUILD_NUMBER}"  // Utilisation du numéro de build Jenkins comme version
  }
  stages {
      // Build Artifact Stage
      stage('Build Artifact') {
            steps {
              // Build the artifact without running tests
              sh "mvn clean package -DskipTests=true"
              // Archive the built JAR file
              archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
            }
        }

      // Unit Testing with JaCoCo Stage
      stage('Unit Test') {
            steps {
              // Run tests and generate code coverage
              sh "mvn test"
              // Publish JUnit test results
              junit '**/target/surefire-reports/*.xml'
            }
        }

      // Code Coverage with JaCoCo Stage
      stage('Code Coverage') {
            steps {
                // Generate code coverage report with JaCoCo
                jacoco execPattern: '**/target/jacoco.exec', 
                       classPattern: '**/target/classes', 
                       sourcePattern: '**/src/main/java', 
                       exclusionPattern: '**/target/test-classes'
            }
        }
        
      // Build Docker Image Stage
      stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

      // Push Docker Image to Docker Hub Stage
      stage('Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker_hub_repo', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                        sh "echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin"
                        sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }

      // Deploy to Kubernetes Stage
      stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Use the secret file stored in Jenkins for the kubeconfig
                    withCredentials([file(credentialsId: 'kubeconfig-cred', variable: 'KUBECONFIG')]) {
                        sh '''
                            export KUBECONFIG=${KUBECONFIG}
                            kubectl config current-context
                            sed -i "s|image: ${IMAGE_NAME}:.*|image: ${IMAGE_NAME}:${IMAGE_TAG}|g" k8s_deployment_service.yaml
                            kubectl apply -f k8s_deployment_service.yaml --validate=false
                        '''
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Cleanup workspace after the build
            cleanWs()
        }
    }
}
