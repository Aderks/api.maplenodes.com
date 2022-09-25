# Build via docker:
# docker build --build-arg cores=8 -t webserver .

# docker run -d --name webserver -p 8192:8192 webserver:latest

FROM nginx

ARG cores=1
ENV ecores=$cores

RUN apt update \
  && apt install -y --no-install-recommends \
     software-properties-common \
     ca-certificates \
     python3 curl bash nano jq bc wget \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt update \
  && apt install -y --no-install-recommends \
     build-essential \
     libcairo2-dev pkg-config python3-dev python3-pip python3-setuptools \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Update pip
RUN pip3 install --upgrade pip

# Install jtc
RUN wget https://github.com/ldn-softdev/jtc/releases/download/LatestBuild/jtc-linux-64.latest
RUN mv jtc-linux-64.latest jtc
RUN chmod +x jtc
RUN cp jtc /usr/bin/

# Make directory and set working directory
RUN mkdir -p /services/
RUN mkdir -p /services/blackjack
RUN mkdir -p /services/telegram
RUN mkdir -p /services/trollbox
RUN mkdir -p /services/scripts
RUN mkdir -p /services/tmp

WORKDIR /services/

# Copy scripts
COPY 4chanthreads.sh /services/scripts
COPY 4chanthreadviewer.sh /services/scripts
COPY 4chanthreadviewerprice.sh /services/scripts
COPY bitly.sh /services/scripts
COPY cc_multi_price.sh /services/scripts
COPY cc_single_price.sh /services/scripts
COPY cc_top24hr_volume.sh /services/scripts
COPY cc_topexchanges_volume_bypair.sh /services/scripts
COPY cc_toplist_marketcap.sh /services/scripts
COPY cc_toplist_pairvolume.sh /services/scripts
COPY currencyconverter.sh /services/scripts
COPY currencylist.sh /services/scripts
COPY dxget24hrtradehistory.sh /services/scripts
COPY dxget24hrtradesummary.sh /services/scripts
COPY livesportsodds.sh /services/scripts
COPY livesportsoddslist.sh /services/scripts
COPY sendsms.sh /services/scripts
COPY smsstatus.sh /services/scripts
COPY twitter.sh /services/scripts
COPY xmr_get_block_header_by_hash.sh /services/scripts
COPY xmr_get_fee_estimate.sh /services/scripts
COPY xmr_on_get_block_hash.sh /services/scripts
COPY xmr_get_block.sh /services/scripts
COPY xmr_get_block_header_by_height.sh /services/scripts
COPY xmr_get_last_block_header.sh /services/scripts
COPY xmr_get_block_count.sh /services/scripts
COPY xmr_get_block_headers_range.sh /services/scripts
COPY xmr_hard_fork_info.sh /services/scripts
COPY xmr_get_transaction_pool.sh /services/scripts
COPY xmr_get_transaction_pool_stats.sh /services/scripts
COPY xmr_get_transactions.sh /services/scripts
COPY xmr_get_version.sh /services/scripts
COPY xmr_send_raw_transaction.sh /services/scripts
COPY eth_passthrough_status.sh /services/scripts
COPY blackjack.sh /services/blackjack
COPY blackjack_hit.sh /services/blackjack
COPY blackjack_stand.sh /services/blackjack
COPY telegramsendmessage.sh /services/telegram
COPY telegramuserregistration.sh /services/telegram
COPY userlist.json /services/telegram
COPY trollbox.sh /services/trollbox
COPY trollboxmsg.sh /services/trollbox
COPY trollboxchat.json /services/trollbox
COPY graph_rewards.sh /services/scripts
COPY graph_rewards_testnet.sh /services/scripts
COPY graph_indexers.sh /services/scripts
COPY graph_indexers_testnet.sh /services/scripts
COPY graph_network.sh /services/scripts
COPY graph_network_testnet.sh /services/scripts
COPY graph_ens.sh /services/scripts
COPY graph_subgraphs.sh /services/scripts
COPY graph_subgraphs_active.sh /services/scripts
COPY graph_subgraphs_active_testnet.sh /services/scripts
COPY graph_allocations.sh /services/scripts
COPY graph_allocations_with_id.sh /services/scripts
COPY graph_allocations_with_id_testnet.sh /services/scripts
COPY graph_kpi.sh /services/scripts
COPY graph_trace.sh /services/scripts
COPY graph_network_stake.sh /services/scripts
COPY graph_network_stake_testnet.sh /services/scripts
COPY graph_failed_subgraph.sh /services/scripts
COPY evmos_transactions.sh /services/scripts
COPY evmos_apr.sh /services/scripts
COPY evmos_evm_transactions.sh /services/scripts
COPY evmos_evm_token_transfers.sh /services/scripts

# Execute rights on scripts

RUN chmod -R 777 /services
RUN chmod -R 777 /services/tmp

# Write nginx.conf /etc/nginx/nginx.conf
RUN echo "                                                                         \n\
user www-data;                                                                     \n\
worker_processes $ecores;                                                          \n\
pid /run/nginx.pid;                                                                \n\
events {                                                                           \n\
    worker_connections 1024;                                                       \n\
    use epoll;                                                                     \n\
    multi_accept on;                                                               \n\
}                                                                                  \n\
http {                                                                             \n\
    access_log /dev/stdout;                                                        \n\
    error_log /dev/stdout;                                                         \n\
    sendfile            on;                                                        \n\
    tcp_nopush          on;                                                        \n\
    tcp_nodelay         on;                                                        \n\
    keepalive_timeout   65;                                                        \n\
    types_hash_max_size 2048;                                                      \n\
    include             /etc/nginx/mime.types;                                     \n\
    default_type        application/octet-stream;                                  \n\
    index   index.html index.htm;                                                  \n\
    server {                                                                       \n\
        listen       8192;                                            \n\
        listen       [::]:8192;                                       \n\
        server_name  localhost;                                                    \n\
        root         /var/www/html;                                                \n\
        location / {                                                               \n\
            include uwsgi_params;                                                  \n\
            uwsgi_pass unix:/tmp/uwsgi.socket;                                     \n\
        }                                                                          \n\
    }                                                                              \n\
}                                                                                  \n\
                                                                                   \n\
\n" > /etc/nginx/nginx.conf

# Write uwsgi.ini /services/uwsgi.ini
RUN echo "                                                                                                         \n\
[uwsgi]                                                                                                            \n\
module = services:app                                                                                              \n\
uid = www-data                                                                                                     \n\
gid = www-data                                                                                                     \n\
master = true                                                                                                      \n\
processes = $ecores                                                                                                \n\
threads = 2                                                                                                        \n\
                                                                                                                   \n\
socket = /tmp/uwsgi.socket                                                                                         \n\
chmod-sock = 664                                                                                                   \n\
vacuum = true                                                                                                      \n\
                                                                                                                   \n\
die-on-term = true                                                                                                 \n\
                                                                                                                   \n\
\n" > /services/uwsgi.ini

# Install app dependencies from requirements.txt
COPY requirements.txt /services/
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy startup script
COPY start.sh /services/

# Bundle Python app source
COPY services.py /services/

# Expose port 8192
EXPOSE 8192

# Execution rights and set default command
RUN chmod +x ./start.sh
CMD ["./start.sh"]
