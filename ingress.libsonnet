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
  ingressPrometheusExternal+:: {
    ingress:
      ingress.new() +
      ingress.mixin.metadata.withName('prometheus-external-' + std.strReplace($._config.domain, '.', '-')) +
      ingress.mixin.metadata.withNamespace($._config.namespace) +
      ingress.mixin.metadata.withAnnotations({
        'kubernetes.io/ingress.class': 'nginx',
        'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
        'nginx.ingress.kubernetes.io/auth-url': 'https://$host/oauth2/auth',
        'nginx.ingress.kubernetes.io/auth-signin': 'https://$host/oauth2/start?rd=https://$host$request_uri$is_args$args'
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
        ]
      ),
  },
  ingressPrometheusOauth2Proxy+:: {
    ingress:
      ingress.new() +
      ingress.mixin.metadata.withName('prometheus-oauth2-proxy-' + std.strReplace($._config.domain, '.', '-')) +
      ingress.mixin.metadata.withNamespace('auth-system') +
      ingress.mixin.metadata.withAnnotations({
        'kubernetes.io/ingress.class': 'nginx',
        'cert-manager.io/cluster-issuer': 'letsencrypt-prod'
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
            httpIngressPath.withPath('/oauth2') +
            httpIngressPath.mixin.backend.withServiceName('oauth2-proxy') +
            httpIngressPath.mixin.backend.withServicePort(4180),
          ]),
        ]
      ),
  },
  ingressAlertManagerExternal+:: {
    ingress:
      ingress.new() +
      ingress.mixin.metadata.withName('alertmanager-external-' + std.strReplace($._config.domain, '.', '-')) +
      ingress.mixin.metadata.withNamespace($._config.namespace) +
      ingress.mixin.metadata.withAnnotations({
        'kubernetes.io/ingress.class': 'nginx',
        'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
        'nginx.ingress.kubernetes.io/auth-url': 'https://$host/oauth2/auth',
        'nginx.ingress.kubernetes.io/auth-signin': 'https://$host/oauth2/start?rd=https://$host$request_uri$is_args$args'
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
        ]
      ),
  },
  ingressAlertManagerOauth2Proxy+:: {
    ingress:
      ingress.new() +
      ingress.mixin.metadata.withName('alertmanager-oauth2-proxy-' + std.strReplace($._config.domain, '.', '-')) +
      ingress.mixin.metadata.withNamespace('auth-system') +
      ingress.mixin.metadata.withAnnotations({
        'kubernetes.io/ingress.class': 'nginx',
        'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
        'nginx.ingress.kubernetes.io/auth-url': 'https://$host/oauth2/auth',
        'nginx.ingress.kubernetes.io/auth-signin': 'https://$host/oauth2/start?rd=https://$host$request_uri$is_args$args'
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
            httpIngressPath.withPath('/oauth2') +
            httpIngressPath.mixin.backend.withServiceName('oauth2-proxy') +
            httpIngressPath.mixin.backend.withServicePort(4180),
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
        'cert-manager.io/cluster-issuer': 'letsencrypt-prod',
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
