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
                archiveArtifacts artifacts: 'target/*.jar' // Correct way to archive artifacts
            }
        }
    }
}

