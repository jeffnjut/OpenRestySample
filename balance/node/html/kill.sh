# ps aux | grep openresty | cut -c 9-15 | xargs kill -9
# ps aux | grep nginx | cut -c 9-15 | xargs kill -9

/data/openresty/openresty_1.13.6.1/nginx/sbin/nginx -p `pwd` -c conf/nginx_node.conf -s stop
