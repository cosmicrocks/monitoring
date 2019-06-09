local conf = import 'config.libsonnet';

local defaultPrometheusConfiguration = {
  local stage = conf.Config.stage,
  prometheus+: {
    metadata+: {
      name: conf.Config.clusterName,
    },
    spec+: {
      prometheusExternalLabelName: '',
      replicaExternalLabelName: '',
      remoteRead: [{
        readRecent: true,
        url: 'http://adapter.default:9201/read'
      }], 
      remoteWrite: [{
        url: 'http://adapter.default:9201/write'
      }],
      replicas: 3,
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
