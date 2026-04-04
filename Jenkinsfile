pipeline {
    agent any

    stages {
        stage('Initialize') {
            steps {
                echo 'Starting pipeline...'
            }
        }

        stage('Test') {
            steps {
                sh 'echo "I am exist"'
            }
        }

        stage('Complete') {
            steps {
                echo 'Pipeline completed successfully'
            }
        }
    }
}