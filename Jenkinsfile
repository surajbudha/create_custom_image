pipeline {
    agent any

    stages {
        stage('Prerequisites'){
            steps {
                sh 'python3 -m venv .venv'
                sh 'ls -la'
                sh '. .venv/bin/activate; pip install -r requirements.txt'
            }
        }
        stage('Build') {
            steps {
                echo 'Starting ISO Creation'
                sh 'echo "Building ISO..."'
                sh '. .venv/bin/activate; ansible-playbook create_custom_iso_unattended.yml'
            }
        }
        stage('Upload') {
            steps {
                echo 'Uploading....'
            }
        }
    }
}