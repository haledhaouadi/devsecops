pipeline {
    agent any

    tools {
        maven 'maven' // Ensure "maven" matches the name in Global Tool Configuration
    }

    environment {
        MAVEN_OPTS = '--add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED'
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
    }

    post {
        always {
            cleanWs() // Clean workspace after build
        }
    }
}
