FROM alpine
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && echo "Asia/Tokyo" > /etc/timezone
ENV TZ=Asia/Tokyo
ENTRYPOINT ["/entrypoint.sh"]