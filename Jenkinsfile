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
        stage('Build Artifact') {
            steps {
                // Build the artifact without running tests
                sh "mvn clean package -DskipTests=true"
                // Archive the built JAR file
                archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: true
            }
        }
         stage('Unit Tests - JUnit and Jacoco') {
            steps { 
                sh "mvn test"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml' 
                    jacoco execPattern: 'target/jacoco.exec'
                }
            }
        }
        stage('Mutation Tests - PIT') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
        }

        stage('Vulnerability Scan - Docker') {
            steps {
                parallel(
                    "Dependency Scan": {
                        sh "mvn dependency-check:check"
                    },
                    "Trivy Scan": {
                        sh "bash trivy-docker-image-scan.sh"
                    }
                )
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker_hub_repo', passwordVariable: 'DOCKER_HUB_PASSWORD', usernameVariable: 'DOCKER_HUB_USERNAME')]) {
                        sh "echo $DOCKER_HUB_PASSWORD | docker login -u $DOCKER_HUB_USERNAME --password-stdin"
                        sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                    }
                }
            }
        }
        stage('Vulnerability Scan - k8s') {
            steps {
                parallel(
                    "Kubesec Scan": {
                        sh "bash kubesec-scan.sh"
                    },
                    "Trivy Scan": {
                        sh "bash trivy-k8s-scan.sh"
                    }
                )
            }
        }

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
        stage('K8S Deployment - DEV') {
          steps {
            parallel(
              "Deployment": {
                withCredentials([file(credentialsId: 'kubeconfig-cred', variable: 'KUBECONFIG')]) {
                    sh '''
                        export KUBECONFIG=${KUBECONFIG}
                        bash k8s-deployment.sh
                    '''
                }
              },
              "Rollout Status": {
                withCredentials([file(credentialsId: 'kubeconfig-cred', variable: 'KUBECONFIG')]) {
                    sh '''
                        export KUBECONFIG=${KUBECONFIG}
                        bash k8s-deployment-rollout-status.sh
                    '''
                }
              }
            )
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
