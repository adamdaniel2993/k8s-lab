### karpenter

- Karpenter se podria decir que se divide en 2 recursos:
   * NodePools:
       Los nodepools es donde le dices a karpenter cuales son las instancias que puede crear, y cuales pods pueden correr en ellos osea aqui tambien es donde se configura los taint y tolerations
   * Ec2NodeClass:
        El Ec2NodeClass por su parte es quien le dice a karpenter como se va a configurar el servidor digase, que AMI va a usar, que subnet, vpc, y todo eso


### HELM

Cuando instalas un helm chart, ya sabemos que se instalan los CRD (custom resoruce definitions), pero hay una particularidad con estos, Helm no actualiza los CRD ni en Updates ni reinstalaciones por lo que se quedan los CRD de la primera instalacion




