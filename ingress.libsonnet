local conf = import 'config.libsonnet';

local k = import 'ksonnet/ksonnet.beta.3/k.libsonnet';
local secret = k.core.v1.secret;
local ingress = k.extensions.v1beta1.ingress;
local ingressTls = ingress.mixin.spec.tlsType;
local ingressRule = ingress.mixin.spec.rulesType;
local httpIngressPath = ingressRule.mixin.http.pathsType;
local service = k.core.v1.service;
local servicePort = k.core.v1.service.mixin.spec.portsType;

{
  _config+:: {
    clusterName: conf.Config.clusterName,
    domain: conf.Config.domain,
    namespace: conf.Config.namespace,
  },
  ingressPrometheus+:: {
    ingress:
      ingress.new() +
      ingress.mixin.metadata.withName('prometheus-' + std.strReplace($._config.domain, '.', '-')) +
      ingress.mixin.metadata.withNamespace($._config.namespace) +
      ingress.mixin.metadata.withAnnotations({
        'kubernetes.io/ingress.class': 'nginx',
        'certmanager.k8s.io/cluster-issuer': 'letsencrypt-prod',
        'nginx.ingress.kubernetes.io/auth-url': 'https://$host/oauth2/auth',
        'nginx.ingress.kubernetes.io/auth-signin': 'https://$host/oauth2/start',
      }) +
      ingress.mixin.spec.withTls(
        ingressTls.new() +
        ingressTls.withHosts('prometheus.' + $._config.domain) +
        ingressTls.withSecretName('prometheus-' + std.strReplace($._config.domain, '.', '-'))
      ) +
      ingress.mixin.spec.withRules(
        [
          ingressRule.new() +
          ingressRule.withHost('prometheus.' + $._config.domain) +
          ingressRule.mixin.http.withPaths([
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('prometheus-' + $._config.clusterName) +
            httpIngressPath.mixin.backend.withServicePort('web'),
          ]),
          ingressRule.new() +
          ingressRule.withHost('prometheus.' + $._config.domain) +
          ingressRule.mixin.http.withPaths([
            httpIngressPath.new() +
            httpIngressPath.withPath('/oauth2') +
            httpIngressPath.mixin.backend.withServiceName('oauth2-proxy') +
            httpIngressPath.mixin.backend.withServicePort('http'),
          ]),
        ]
      ),
  },
  ingressAlertManager+:: {
    ingress:
      ingress.new() +
      ingress.mixin.metadata.withName('alertmanager-' + std.strReplace($._config.domain, '.', '-')) +
      ingress.mixin.metadata.withNamespace($._config.namespace) +
      ingress.mixin.metadata.withAnnotations({
        'kubernetes.io/ingress.class': 'nginx',
        'certmanager.k8s.io/cluster-issuer': 'letsencrypt-prod',
        'nginx.ingress.kubernetes.io/auth-url': 'https://$host/oauth2/auth',
        'nginx.ingress.kubernetes.io/auth-signin': 'https://$host/oauth2/start',
      }) +
      ingress.mixin.spec.withTls(
        ingressTls.new() +
        ingressTls.withHosts('alertmanager.' + $._config.domain) +
        ingressTls.withSecretName('alertmanager-' + std.strReplace($._config.domain, '.', '-'))
      ) +
      ingress.mixin.spec.withRules(
        [
          ingressRule.new() +
          ingressRule.withHost('alertmanager.' + $._config.domain) +
          ingressRule.mixin.http.withPaths([
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('alertmanager-' + $._config.clusterName) +
            httpIngressPath.mixin.backend.withServicePort('web'),
          ]),
          ingressRule.new() +
          ingressRule.withHost('alertmanager.' + $._config.domain) +
          ingressRule.mixin.http.withPaths([
            httpIngressPath.new() +
            httpIngressPath.withPath('/oauth2') +
            httpIngressPath.mixin.backend.withServiceName('oauth2-proxy') +
            httpIngressPath.mixin.backend.withServicePort('http'),
          ]),
        ]
      ),
  },
  ingressGrafana+:: {
    ingress:
      ingress.new() +
      ingress.mixin.metadata.withName('grafana-' + std.strReplace($._config.domain, '.', '-')) +
      ingress.mixin.metadata.withNamespace($._config.namespace) +
      ingress.mixin.metadata.withAnnotations({
        'kubernetes.io/ingress.class': 'nginx',
        'certmanager.k8s.io/cluster-issuer': 'letsencrypt-prod',
      }) +
      ingress.mixin.spec.withTls(
        ingressTls.new() +
        ingressTls.withHosts('grafana.' + $._config.domain) +
        ingressTls.withSecretName('grafana-' + std.strReplace($._config.domain, '.', '-'))
      ) +
      ingress.mixin.spec.withRules([
        ingressRule.new() +
        ingressRule.withHost('grafana.' + $._config.domain) +
        ingressRule.mixin.http.withPaths([
          httpIngressPath.new() +
          httpIngressPath.withPath('/') +
          httpIngressPath.mixin.backend.withServiceName('grafana') +
          httpIngressPath.mixin.backend.withServicePort('http'),
        ]),
      ]),
  },
}
