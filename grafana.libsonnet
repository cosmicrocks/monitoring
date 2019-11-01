local conf = import 'config.libsonnet';

(import 'kube-prometheus/kube-prometheus.libsonnet') +
(import 'kubernetes-mixin/mixin.libsonnet') +
{
  _config+:: {
    clusterName: conf.Config.clusterName,
    clientId: conf.Config.oidc_google_clientId,
    clientSecret: conf.Config.oidc_google_clientSecret,
    namespace: conf.Config.namespace,
    versions+:: {
      grafana: '6.4.3',
    },
    grafana+:: {
      config: {
        sections: {
          metrics: { enabled: true },
          server: {
            domain: 'grafana.%s' % conf.Config.domain,
            root_url: 'https://grafana.%s' % conf.Config.domain,
          },
          auth: { disable_login_form: true },
          'auth.basic': { enabled: false },
          users: {
            auto_assign_org_role: 'Editor',
          },
          security: {
            admin_user: conf.Config.admin_user,
          },
          'auth.generic_oauth': {
            enabled: true,
            client_id: $._config.clientId,
            client_secret: $._config.clientSecret,
            scopes: 'openid profile email offline_access',
            auth_url: 'https://dex.%s/auth' % conf.Config.domain ,
            token_url: 'https://dex.%s/token' % conf.Config.domain,
            allowed_domains: conf.Config.allowed_domains,
            allow_sign_up: true,
          },
        },
      },
      datasources:
        [
          {
            name: 'Prometheus',
            type: 'prometheus',
            access: 'proxy',
            orgId: 1,
            url: 'http://prometheus-' + $._config.clusterName + '.' + conf.Config.namespace + '.svc:9090',
            version: 1,
            editable: true,
          },
        ],
    },
  },
  grafanaDashboards+::
    {
    'postgres.json': (import 'dashboards/postgres.json'),
    'nginx.json': (import 'dashboards/nginx.json'),
    'cortex.json': (import 'dashboards/cortex.json')
  },
}
