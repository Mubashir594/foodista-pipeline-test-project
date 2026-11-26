pipeline {
    agent any

    environment {
        DOCKER_CREDENTIALS_ID = 'docker-cred'
        DOCKER_IMAGE          = 'mubashir594/foodista-pipeline-test-project'

        SONAR_SERVER_NAME     = 'sonarqube_env'
        SONAR_SCANNER_TOOL    = 'sonar-scanner'

        GIT_CREDENTIALS_ID    = 'github-cred'
        MANIFEST_REPO         = 'https://github.com/Mubashir594/foodista-pipeline-test-project.git'
        MANIFEST_BRANCH       = 'main'
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                echo "Source code checked out by Jenkins SCM"
                sh 'pwd && ls -la'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool "${SONAR_SCANNER_TOOL}"

                    withSonarQubeEnv("${SONAR_SERVER_NAME}") {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=foodista-pipeline-test-project-key \
                            -Dsonar.projectName=foodista-pipeline-test-project \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=**/.git/**,**/images/**,**/venv/**,**/.scannerwork/**
                        """
                    }
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: "${DOCKER_CREDENTIALS_ID}",
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )
                    ]) {
                        sh """
                            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin

                            docker build \
                                -t ${DOCKER_IMAGE}:${env.BUILD_NUMBER} \
                                -t ${DOCKER_IMAGE}:latest \
                                -f Dockerfile .

                            docker push ${DOCKER_IMAGE}:${env.BUILD_NUMBER}
                            docker push ${DOCKER_IMAGE}:latest
                        """
                    }
                }
            }
        }

        stage('Update Manifest Repo') {
            steps {
                dir('manifest-workspace') {
                    git branch: "${MANIFEST_BRANCH}",
                        credentialsId: "${GIT_CREDENTIALS_ID}",
                        url: "${MANIFEST_REPO}"

                    withCredentials([
                        usernamePassword(
                            credentialsId: "${GIT_CREDENTIALS_ID}",
                            usernameVariable: 'GH_USER',
                            passwordVariable: 'GH_TOKEN'
                        )
                    ]) {
                        sh """
                            sed -i '/name: foodista$/{n;s|image:.*|image: ${DOCKER_IMAGE}:${env.BUILD_NUMBER}|}' k8s/Deployment.yaml

                            git config user.name "Mubashir594"
                            git config user.email "mubumubashir594@gmail.com"

                            git add k8s/Deployment.yaml

                            if ! git diff --cached --quiet; then
                                git commit -m "chore(manifest): update foodista image tag to ${env.BUILD_NUMBER} [skip ci]"

                                git remote set-url origin https://\${GH_USER}:\${GH_TOKEN}@github.com/Mubashir594/foodista-pipeline-test-project.git

                                git push origin ${MANIFEST_BRANCH}
                            else
                                echo "Manifest image is already up to date."
                            fi
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline executed successfully! Foodista image pushed and manifest updated.'
        }

        failure {
            echo 'Pipeline failed. Please review the stage logs above.'
        }
    }
}
