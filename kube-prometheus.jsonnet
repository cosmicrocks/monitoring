local conf = import 'config.libsonnet';

local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  {
    _config+:: {
      clusterName: conf.Config.clusterName,
      namespace: conf.Config.namespace,

      kubeApiserverSelector: 'job="kube-apiserver"',
      alertmanagerSelector: 'job="alertmanager-%s"' % self.clusterName,

      versions+:: {
        prometheusOperator: 'v0.32.0',
        prometheus: 'v2.12.0',
        nodeExporter: "v0.18.1",
      },

      prometheus+:: {
        name: $._config.clusterName,
        namespaces+: ['cortex'],
      },

      alertmanager+:: {
        name: $._config.clusterName,
      } + (import 'alertmanager.libsonnet').alertmanager,

    },
    prometheus+:: (import 'prometheus.libsonnet').prometheus,
    ingressPrometheus+:: (import 'ingress.libsonnet').ingressPrometheus,
    ingressAlertManager+:: (import 'ingress.libsonnet').ingressAlertManager,
    grafana+:: (import 'grafana.libsonnet').grafana,
    ingressGrafana+:: (import 'ingress.libsonnet').ingressGrafana,
  };

local manifests =
  { ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
  { ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
  { ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
  { ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
  { ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
  { ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
  { ['prometheus-' + name]: kp.ingressPrometheus[name] for name in std.objectFields(kp.ingressPrometheus) } +
  { ['prometheus-adapter' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
  { ['alertmanager-' + name]: kp.ingressAlertManager[name] for name in std.objectFields(kp.ingressAlertManager) } +
  { ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
  { ['grafana-' + name]: kp.ingressGrafana[name] for name in std.objectFields(kp.ingressGrafana) };

local kustomizationResourceFile(name) = './manifests/' + name + '.yaml';
local kustomization = {
  apiVersion: 'kustomize.config.k8s.io/v1beta1',
  kind: 'Kustomization',
  resources: std.map(kustomizationResourceFile, std.objectFields(manifests)),
};

manifests {
  '../kustomization': kustomization,
}
