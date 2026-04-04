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

        stage('Install Dependencies') {
            steps {
                sh '''
                sudo dnf install -y ansible-core git wget vim nano tar unzip
                '''
            }
        }

        stage('Install Ansible Collections') {
            steps {
                sh '''
                ansible-galaxy collection install ansible.posix community.general --upgrade
                '''
            }
        }

        stage('Test') {
            steps {
                sh 'echo "I am exist"'
            }
        }

        stage('Run Kubernetes Setup') {
            steps {
                dir('config') {
                    sh '''
                    ansible-playbook -i inventory.ini k8s_setup.yaml
                    '''
                }
            }
        }

        stage('Deploy Dashboard') {
            steps {
                dir('config') {
                    sh '''
                    ansible-playbook -i inventory.ini k8s_dashboard.yaml
                    '''
                }
            }
        }

        stage('Complete') {
            steps {
                echo 'Kubernetes + Dashboard setup completed successfully 🚀'
            }
        }
    }
}