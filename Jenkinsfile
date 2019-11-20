pipeline {
    agent any
    environment{
        DOCKER_TAG = getDockerTag()
        PATH = "/usr/bin:$PATH"
    }
    stages{
        
        stage('Pull Code From GITHUB'){
            steps{
                git 'https://github.com/batpool/nodeapp'
            }
        }
        
        stage('Build Docker Image id-${DOCKER_TAG}'){
            steps{
                sh "docker build . -t deadloop/nodeapp:${DOCKER_TAG} "
            }
        }

        stage('DockerHub Push'){
            steps{
                withCredentials([string(credentialsId: 'deadloop', variable: 'password')]) {
                    sh "docker login -u deadloop -p ${password}"
                    sh "docker push deadloop/nodeapp:${DOCKER_TAG}"
                }
            }
        }

        stage('Deploy to k8s'){
            steps{
                sh "chmod +x changeTag.sh"
                sh "./changeTag.sh ${DOCKER_TAG}"
                sshagent(['ssh-key']) {
                    sh "scp -o StrictHostKeyChecking=no services.yml node-app-pod.yml root@192.168.56.107:/root/"
                    script{
                        try{
                            sh "ssh root@192.168.56.107 kubectl apply -f ."
                        }catch(error){
                            sh "ssh root@192.168.56.107 kubectl create -f ."
                        }
                    }
                }
            }
        }
    }
}

def getDockerTag(){
    def tag  = sh label: 'return unique git last commit', returnStdout: true, script: 'git rev-parse HEAD'
    return tag
}