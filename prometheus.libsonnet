local conf = import 'config.libsonnet';

local defaultPrometheusConfiguration = {
  prometheus+: {
    metadata+: {
      name: conf.Config.clusterName,
    },
    spec+: {
      tolerations: [
        {
          effect: 'NoSchedule',
          key: 'dedicated',
          operator: 'Equal',
          value: 'prometheus'
        }
      ],
          
      affinity: {
        nodeAffinity: {
          requiredDuringSchedulingIgnoredDuringExecution: {
            nodeSelectorTerms: [
              {
                matchExpressions: [
                  {
                    key: 'dedicated',
                    operator: 'In',
                    values: [
                      'prometheus'
                    ]
                  }
                ]
              }
            ]
          }
        }
      },

      #prometheusExternalLabelName: '',
      #replicaExternalLabelName: '',
      remoteWrite: [{
        url: 'http://nginx.default.svc/api/prom/push',
        capacity: '1000',
        maxShards: '2000',
        minShards: '1',
        maxSamplesPerSend: '1000',
        batchSendDeadline: '5s',
        minBackoff: '30ms',
        maxBackoff: '100ms',
      }],
      replicas: 1,
      resources: {
        requests: {
          memory: '96Gi',
          cpu: '8',
        },
      },
      retention: '1d',
    },
  },
};

{
  prometheus+:: (
    defaultPrometheusConfiguration
  ),
}
