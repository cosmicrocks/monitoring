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
        prometheusOperator: 'v0.33.0',
        prometheus: 'v2.13.1',
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
    ingressPrometheusExternal+:: (import 'ingress.libsonnet').ingressPrometheusExternal,
    ingressPrometheusOauth2Proxy+:: (import 'ingress.libsonnet').ingressPrometheusOauth2Proxy,
    ingressAlertManagerExternal+:: (import 'ingress.libsonnet').ingressAlertManagerExternal,
    ingressAlertManagerOauth2Proxy+:: (import 'ingress.libsonnet').ingressAlertManagerOauth2Proxy,
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
  { ['prometheus-external-' + name]: kp.ingressPrometheusExternal[name] for name in std.objectFields(kp.ingressPrometheusExternal) } +
  { ['prometheus-oauth2-proxy-' + name]: kp.ingressPrometheusOauth2Proxy[name] for name in std.objectFields(kp.ingressPrometheusOauth2Proxy) } +
  { ['prometheus-adapter' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
  { ['alertmanager-exeternal-' + name]: kp.ingressAlertManagerExternal[name] for name in std.objectFields(kp.ingressAlertManagerExternal) } +
  { ['alertmanager-oauth2-proxy-' + name]: kp.ingressAlertManagerOauth2Proxy[name] for name in std.objectFields(kp.ingressAlertManagerOauth2Proxy) } +
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
