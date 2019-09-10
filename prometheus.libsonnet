local conf = import 'config.libsonnet';

local defaultPrometheusConfiguration = {
  prometheus+: {
    metadata+: {
      name: conf.Config.clusterName,
    },
    spec+: {
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
          memory: '500Mi',
          cpu: '500m',
        },
      },
      retention: '30d',
    },
  },
};

{
  prometheus+:: (
    defaultPrometheusConfiguration
  ),
}
