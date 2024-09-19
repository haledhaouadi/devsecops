 pipeline {
    agent { label 'docker' } // This assumes you have a Docker agent configured

    environment {
        MAVEN_OPTS = '--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED'
        DOCKER_IMAGE_NAME = 'hala'
        DOCKER_IMAGE_TAG = "${env.GIT_COMMIT}"
    }

    stages {
        stage('Build Artifact') {
            steps {
                sh "mvn clean package -DskipTests=true"
                archiveArtifacts artifacts: 'target/*.jar'
            }
        }

        stage('Unit Test') {
            steps {
                sh "mvn test"
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Code Coverage') {
            steps {
                jacoco execPattern: '**/target/jacoco.exec',
                       classPattern: '**/target/classes',
                       sourcePattern: '**/src/main/java'
            }
        }

        stage('Docker Build and Push') {
            steps {
                script {
                    

                    // Build Docker image
                    sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."

                    // Push Docker image
                    sh "docker push ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}"

                    // Verify image was pushed successfully
                    def pushedImage = sh(script: "docker images", returnStdout: true).trim()
                    assert pushedImage.contains("${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}")
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
