FROM weibocom/weibo-mesh:0.0.4 AS weibo-mesh

FROM bash:4.4
MAINTAINER idevz, zhoujing2@staff.weibo.com

COPY --from=weibo-mesh /weibo-mesh /weibo-mesh

ADD weibo-mesh-server /
