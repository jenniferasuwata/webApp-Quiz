pipeline {
    agent any

    environment {
        AWS_REGION     = "eu-west-2"
        ECR_REGISTRY   = "892139891520.dkr.ecr.eu-west-2.amazonaws.com"
        ECR_REPOSITORY = "quiz-app-repo"
        IMAGE_TAG      = "latest"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/jenniferasuwata/webApp-Quiz'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                        docker build -t \${ECR_REPOSITORY}:\${IMAGE_TAG} .
                    """
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withAWS(credentials: 'jenny_admin', region: "${AWS_REGION}") {
                    sh 'aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY'
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                script {
                    sh """
                        # Tag with the full ECR path
                        docker tag \${ECR_REPOSITORY}:\${IMAGE_TAG} \${ECR_REGISTRY}/\${ECR_REPOSITORY}:\${IMAGE_TAG}
                        docker push \${ECR_REGISTRY}/\${ECR_REPOSITORY}:\${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to EKS') {
    steps {
        script {
            withAWS(credentials: 'jenny_admin', region: "${AWS_REGION}") {
                sh """
                    aws eks update-kubeconfig --region $AWS_REGION --name quiz-eks-cluster

                    # First time apply (or if the Deployment doesn’t exist yet):
                    kubectl apply -f k8s/k8s-deployment.yaml
                    kubectl apply -f k8s/k8s-service.yaml

                    # Then update the image if needed:
                    kubectl set image deployment/quiz-app-deployment quiz-app-container=${ECR_REGISTRY}/quiz-app-repo:${IMAGE_TAG} -n default
                """
                    }
                }
            }
        }
    }
}
