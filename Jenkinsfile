pipeline {
    agent any

    stages {

        stage('Hello') {
            steps {
                echo 'Welcome to K8s'
            }
        }

        stage('Deploy Application') {
            steps {
                dir('config') {
                    sh '''
                    echo "Deploying application to Kubernetes..."
                    ansible-playbook -i inventory.ini k8s_deploy.yaml
                    '''
                }
            }
        }

    }
}