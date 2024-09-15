pipeline {
    agent any

    tools {
        maven 'maven' // Ensure "maven" matches the name in Global Tool Configuration
    }

    environment {
        MAVEN_OPTS = '--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED'
        DOCKER_IMAGE_NAME = 'hala' // Set Docker image name to "hala"
        DOCKER_IMAGE_TAG = "${env.GIT_COMMIT}" // Use Git commit as Docker image tag
    }

    stages {
        stage('Build Artifact') {
            steps {
                sh "mvn clean package -DskipTests=true"
                archiveArtifacts artifacts: 'target/*.jar' // Archive JAR artifacts
            }
        }

        stage('Unit Test') {
            steps {
                sh "mvn test"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml' // Archive JUnit test results
                }
            }
        }

        stage('Code Coverage') {
            steps {
                // Generate JaCoCo report
                jacoco execPattern: '**/target/jacoco.exec',
                       classPattern: '**/target/classes',
                       sourcePattern: '**/src/main/java'
            }
        }

        stage('Docker Build and Push') {
            steps {
                script {
                    // Print environment variables for debugging
                    sh 'printenv'

                    // Build Docker image
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."

                    // Push Docker image
                    sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Clean workspace after build
        }
    }
}

