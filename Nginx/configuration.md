# Configuration of Nginx

## Configure default_server

 for the listen and server, a default server must be set, as when configure redirect, it will not affect all virtual hosts.

This is a default server, which set to `default_server` .

```conf
    server {
        listen       80 default_server;
        server_name  _;

        location /  {
            root   /usr/share/nginx/html;
            index index.html index.htm;
        }

        location /metrics {
            vhost_traffic_status_display;
            vhost_traffic_status_display_format prometheus;
        }
        location /status {
                check_status;
                access_log   off;
           }
        }
```

## Configure  nginx-module-vts

As module `nginx-module-vts` is added into nginx when complilation, so it shoud be configured.

besides in  [Configure default_server](#1-Configure-default_server) configured the `location /metrics`,this will expose prometheus format metrics under `/metrics`, then we can monitor it via prometheus. we will also add `vhost_traffic_status_zone;` under `http`.

```conf

user  nginx;
worker_processes  4;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {

    vhost_traffic_status_zone;
    include       mime.types;
    default_type  application/octet-stream;


    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" "$request_uri" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"'
                      'http_x_header="$http_x_header" uri_query="$query_string" uri_path="$uri" '
                      'request_time=$request_time upstream_connect_time="$upstream_connect_time" upstream_header_time="$upstream_header_time" upstream_response_time="$upstream_response_time"';

    access_log  /var/log/nginx/access.log   main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  150;

    gzip  on;



    include /etc/nginx/conf.d/*.conf;
}
```

the whole configureation we can reference [nginx-module-vts home page](https://github.com/vozlt/nginx-module-vts).

## Configure  nginx_upstream_check_module

`nginx_upstream_check_module` is used in `upstream` to check the upstream server health status

As default, we can add following entity to upstream for normal nginx or grafana backends:

```conf
        check interval=3000 rise=2 fall=5 timeout=1000 type=http;
        check_keepalive_requests 100;
        check_http_send "HEAD / HTTP/1.0\r\n\r\n";
        check_http_expect_alive http_2xx http_3xx;
```

but for some backend applications this setting is not woring, we can use following settings:

```conf
        check interval=3000 rise=2 fall=5 timeout=1000 type=http;
        check_keepalive_requests 100;
        check_http_send "HEAD / HTTP/1.1\r\nConnection: keep-alive\r\n\r\n";
        check_http_expect_alive http_2xx http_3xx http_4xx;
```

if http check is not applicable, we only have to use `tcp` check

```conf
        check interval=3000 rise=2 fall=5 timeout=1000 type=tcp;
        check_keepalive_requests 100;
```

and as configured in  [Configure default_server](#1-Configure-default_server), `location /status` also display upstream health status under `/status`

### Configure redirect root to subpath

sometimes, when we access a root url, we want it to be redirect to its subpath, then we can use folloing redirect (301 redirect):

```conf

    location = / {
      return 301 http://{{dev_server_name}}/hac;
    }

    location /hac  {
      proxy_http_version   1.1;
      proxy_hide_header    Vary;
      proxy_hide_header    X-Powered-By;
      proxy_set_header     Host             $host;
      proxy_set_header     X-Real_IP        $remote_addr;
      proxy_set_header     X-Forwarded-For  $proxy_add_x_forwarded_for;
      proxy_next_upstream  http_502 http_504 http_404 error timeout invalid_header;
      proxy_pass           https://dev_upstream/hac;
    }
```

As example above, when access https://dev_server_name/, it will redirect to https://dev_server_name/hac

### Force redirect http to https

sometime, when the backend it http, nginx serve as https. when access root path of the domain with https is ok, but when access to subpath, it will redirect to http as the backend is http. so the it is to configure the force http to https redirect

```conf
server {
    listen 80;
    server_name  {{artifactory_server_name}};
    return 301 https://{{artifactory_server_name}}$request_uri;
}
server {
    listen       443;
    server_name  {{artifactory_server_name}};
    ssl on;
    ssl_certificate /etc/nginx/server.pem;
    ssl_certificate_key /etc/nginx/server-key.pem;
    location /  {
      proxy_http_version   1.1;
      proxy_hide_header    Vary;
      proxy_hide_header    X-Powered-By;
      proxy_set_header     Host             $host;
      proxy_set_header     X-Real_IP        $remote_addr;
      proxy_set_header     X-Forwarded-For  $proxy_add_x_forwarded_for;
      proxy_next_upstream  http_502 http_504 http_404 error timeout invalid_header;
      proxy_pass           http://artifactory_upstream;
    }
}
```

### Redirect specified subpath to other url

sometimes, insdie a domain we can redirect do other url

```conf
    location ~ ^/(metrics|status) {
        return 301 http://$Host$request_uri;
    }
```

As above, for `/metrics` and `/status`, it will rediect to default_server.

## Configure to use ldap auth

 add following snip to `/etc/nginx/nginx.conf` before line `include /etc/nginx/conf.d/*.conf;`, so each other vhost can utilize this ldap setting

 ```conf
    ldap_server ad_1 {
      # user search base.
      url "ldaps://server1.389.local/DC=389,DC=local?uid?sub?(objectClass=*)";
      # bind as
      binddn "uid=devops,ou=people,dc=389,dc=local";
      # bind pw
      binddn_passwd Cqmyg@711;
      # group attribute name which contains member object
      group_attribute member;
      #group_attribute memberuid;
      # search for full DN in member object
      group_attribute_is_dn on;
      # matching algorithm (any / all)
      #satisfy any;
      # list of allowed groups
      #require group "CN=Admins,OU=My Security Groups,DC=company,DC=com";
      #require group "CN=New York Users,OU=My Security Groups,DC=company,DC=com";
      # list of allowed users
      # require 'valid_user' cannot be used together with 'user' as valid user is a superset
      require valid_user;
      #require user "uid=devops,OU=people,DC=389,DC=local";
      #require user "CN=Robocop,OU=Users,OU=New York Office,OU=Offices,DC=company,DC=com";
      ssl_check_cert on;
      ssl_ca_file /etc/openldap/cacerts/cacert.asc;
    }
```

then add following lines to vhost conf if retuired, above the location directives

```conf
    auth_ldap "Forbidden";
    auth_ldap_servers ad_1;
```
