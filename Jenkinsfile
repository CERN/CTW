pipeline {
    agent { label 'ctw' }
    stages {
        stage('prepare') {
            steps{
              checkout([$class: 'GitSCM', branches: [[name: '*/develop']],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [[$class: 'SubmoduleOption',
                           disableSubmodules: false,
                           parentCredentials: false,
                           recursiveSubmodules: true,
                           reference: '',
                           trackingSubmodules: false]],
                        submoduleCfg: [],
                        userRemoteConfigs: [[url: 'https://github.com/CERN/CTW']]])
              sh 'killall -q minetest || true'
              sh 'rm -rf /tmp/CERN_v1*'
            }
        }
        stage('convert world') {
            steps{
              sh '''
              wpscript build/worldpainter/export-world.js mods/world/resources/CERN_v1.world /tmp;
              cd build/mcimport && python36 ./mcimport.py /tmp/CERN_v1 /tmp/CERN_v1.mt > /tmp/conversion.log;
              cd - ;
              cp -r /tmp/CERN_v1.mt ~/.minetest/worlds/cern/resources_v1
              cp build/minetest/auth-allprivs.txt ~/.minetest/worlds/cern/resources_v1/auth.txt
              '''
            }
        }
    }
    post {
        success {
            sh '''
              JENKINS_NODE_COOKIE=dontKillMe nohup minetest --server --port 30001 --worldname CERN_v1 > /tmp/CERN_v1.stdout 2>&1 &
              JENKINS_NODE_COOKIE=dontKillMe nohup minetest --server --port 30002 --worldname CERN_v1.creative > /tmp/CERN_v1.creative.stdout 2>&1 &
            '''
        }
    }

}
