FROM alpine

# タイムゾーンデータをインストール
RUN apk add --no-cache tzdata \
 && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime \
 && echo "Asia/Tokyo" > /etc/timezone

# エントリポイントスクリプトをコンテナにコピー
COPY entrypoint.sh /entrypoint.sh

# エントリポイントスクリプトを実行可能にする
RUN chmod +x /entrypoint.sh

# タイムゾーンを設定
ENV TZ=Asia/Tokyo

# コンテナ起動時に実行するコマンドを指定
ENTRYPOINT ["/entrypoint.sh"]