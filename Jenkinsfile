pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        script {
          def server = Artifactory.server('BMS Artifactory')
          server.credentialsId = 'fae7e791-df21-4789-b8e5-e7075e48a2eb'
          def rtMaven = Artifactory.newMavenBuild()
          rtMaven.deployer releaseRepo:'bms-training-release', snapshotRepo:'bms-training-snapshot', server: server
          rtMaven.resolver releaseRepo:'bms-training-group', snapshotRepo:'bms-training-group', server: server
          rtMaven.tool = 'M3'
          def buildInfo = rtMaven.run pom: 'pom.xml', goals: 'clean install'
          server.publishBuildInfo buildInfo
        }
        
      }
    }
    stage('SonarQube analysis') {
      steps {
        script {
          def scannerHome = tool 'BMS SonarQube';
          env.WORKSPACE = pwd() //apparently env.WORKSPACE doesn't exist, you have to set it.
          
          // The withSonarQubeEnv doesn't work unless you have the latest SQ plugin, 2.5
          withSonarQubeEnv('BMS SJC SonarQube') {
            sh "${scannerHome}/bin/sonar-scanner " +
            "-Dsonar.projectKey=bms-training-project " +
            "-Dsonar.projectName=BMS-Training" +
            "-Dsonar.projectVersion=${env.BUILD_TAG} " +
            "-Dsonar.language=java " +
            "-Dsonar.sources=${env.WORKSPACE} " +
            "-Dsonar.dynamicAnalysis=reuseReports " +
            "-Dsonar.junit.reportsPath=target/surefire-reports " +
            "-Dsonar.jacoco.reportPath=target/jacoco.exec " +
            "-Dsonar.binaries=target/classes " +
            "-Dsonar.tests=. " +
            "-Dsonar.test.inclusions=**/*Test*/** " +
            "-Dsonar.exclusions=src/main/webapp/assets/vendor/**/*,target/**/*"
          }
        }
        
      }
    }
    stage('Docker Build') {
      steps {
        script {
          withDockerRegistry([credentialsId: 'docker-credential', registry: 'https://dockerhub.cisco.com/']) {
            def app = docker.build("dockerhub.cisco.com/training:${env.BUILD_TAG}", ".")
            app.push();
          }
        }
        
        node(label: 'docker')
      }
    }
    stage('Clean') {
      steps {
        cleanWs(cleanWhenSuccess: true, cleanWhenNotBuilt: true, cleanWhenFailure: true, cleanWhenAborted: true, cleanWhenUnstable: true, cleanupMatrixParent: true, deleteDirs: true)
      }
    }
  }
}