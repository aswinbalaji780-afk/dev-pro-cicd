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
    
       stage('Deploy to Website EC2') {
             steps {
                  echo 'Deploying latest image to Website EC2...'

                  sh """
                  aws ssm send-command \
                  --instance-ids i-04a752c91e066a31e \
                  --document-name "AWS-RunShellScript" \
                  --parameters 'commands=[
                  "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}",
                  "docker pull ${ECR_REGISTRY}/${IMAGE_REPO_NAME}:${IMAGE_TAG}",
                  "docker stop my-web || true",
                  "docker rm my-web || true",
                  "docker run -d --restart unless-stopped -p 80:80 --name my-web ${ECR_REGISTRY}/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
                  ]' \
                  --region ${AWS_REGION}
                  """
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
