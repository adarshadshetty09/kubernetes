pipeline {
agent any

```
environment {
    ANSIBLE_HOST_KEY_CHECKING = 'False'
}

stages {

    stage('Initialize') {
        steps {
            echo '🚀 Starting Kubernetes CI/CD Pipeline...'
        }
    }

    stage('Install Ansible Collections') {
        steps {
            sh '''
            ansible-galaxy collection install ansible.posix community.general --upgrade
            '''
        }
    }

    stage('Verify Inventory') {
        steps {
            dir('config') {
                sh '''
                echo "📌 Checking inventory..."
                cat inventory.ini
                '''
            }
        }
    }

    stage('Kubernetes Cluster Setup') {
        steps {
            dir('config') {
                sh '''
                echo "⚙️ Setting up Kubernetes cluster..."
                ansible-playbook -i inventory.ini k8s_setup.yaml
                '''
            }
        }
    }

    stage('Deploy Kubernetes Dashboard') {
        steps {
            dir('config') {
                sh '''
                echo "📊 Deploying Kubernetes Dashboard..."
                ansible-playbook -i inventory.ini k8s_dashboard.yaml
                '''
            }
        }
    }

    stage('Setup Ingress Controller') {
        steps {
            dir('config') {
                sh '''
                echo "🌐 Installing NGINX Ingress Controller..."
                ansible-playbook -i inventory.ini ingress-setup.yaml
                '''
            }
        }
    }

    stage('Verify Deployment') {
        steps {
            dir('config') {
                sh '''
                echo "🔍 Verifying cluster resources..."

                kubectl get nodes
                kubectl get pods -A
                kubectl get svc -A
                kubectl get ingress -A
                '''
            }
        }
    }

    stage('Complete') {
        steps {
            echo '✅ Kubernetes + Dashboard + Ingress setup completed successfully 🚀'
        }
    }
}

post {
    success {
        echo '🎉 Pipeline executed successfully!'
    }
    failure {
        echo '❌ Pipeline failed. Check logs above.'
    }
}
```

}
