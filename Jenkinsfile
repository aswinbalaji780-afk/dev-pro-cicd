pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '195231313161'
        AWS_REGION = 'ap-southeast-2'
        IMAGE_REPO_NAME = 'my-web'
        IMAGE_TAG = 'latest'
        ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
                echo 'Source code checked out successfully.'
            }
        }

        stage('Docker Build') {
            steps {
                echo 'Building Docker image...'

                sh "docker build -t ${IMAGE_REPO_NAME}:${IMAGE_TAG} ."

                sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${ECR_REGISTRY}/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
            }
        }

        stage('ECR Authentication & Push') {
            steps {
                echo 'Logging in to Amazon ECR...'

                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"

                echo 'Pushing image to ECR...'

                sh "docker push ${ECR_REGISTRY}/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
            }
        }
    }

    post {
        success {
            echo 'Pipeline completed successfully. Docker image pushed to ECR.'
        }

        failure {
            echo 'Pipeline failed. Check the Jenkins console output.'
        }
    }
}
