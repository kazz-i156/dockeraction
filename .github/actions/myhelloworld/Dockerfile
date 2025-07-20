FROM alpine

# タイムゾーンデータをインストール
RUN apk add --no-cache tzdata \
 && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && echo "Asia/Tokyo" > /etc/timezone

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENV TZ=Asia/Tokyo
ENTRYPOINT ["/entrypoint.sh"]