pipeline {
    agent any

    environment {
        ANSIBLE_HOST_KEY_CHECKING = 'False'
    }

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

        stage('Run Kubernetes Setup') {
            steps {
                sh '''
                cd config
                ansible-playbook -i inventory.ini k8s_setup.yaml
                '''
            }
        }

        stage('Deploy Dashboard') {
            steps {
                sh '''
                cd config
                ansible-playbook -i inventory.ini k8s_dashboard.yaml
                '''
            }
        }

        stage('Complete') {
            steps {
                echo 'Kubernetes + Dashboard setup completed successfully 🚀'
            }
        }
    }
}