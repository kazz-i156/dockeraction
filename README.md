# Docker Container Actionのサンプル(独習)
## 概要
git pushに反応し、Dockerコンテナを生成、日付と半固定テキストを出力する処理を作成した。
* ワークフローは1本のみ
* 処理の一部をアクションとして切り出している
* 処理コンテナは`Dockerfile`に基づき生成
* 処理本体はシェルスクリプト、`date`と`echo`を行うだけ
* Hello, worldが基本だが、worldの部分は引数で与えられる。引数はワークフローファイル内に記述
* 出力をアーティファクトにアップロード、そしてダウンロードして表示する所まで行う
* Github-hosted runnerの他、Self-hosted runnerでも動作確認した。

## ファイル説明
GitHub上でリモートリポジトリを作成し、それをローカル環境にcloneする。cloneして出来たディレクトリがリポジトリルートとなる。※もちろんこのリポジトリを直接cloneしても良い。

例：~/dockeraction/

* ./REAMDE.md この説明文書
* ./.github/workflows/myhelloworld.yml メインのワークフロー（ワークフローはこれ1本）ここからアクションを呼び出している
    * `who-to-greet: 'World from PAS'`の部分で引数指定。ここに記述した文字列が、Hello, の後に付加される。
* ./.github/actions/myhelloworld (注)
    * action.yml コンテナ生成、起動を司るアクション、本サンプルの肝の部分、引数の渡し方が少し面倒
    * Dockerfile コンテナ生成用ファイル、内部で`date`を使うので、タイムゾーンを設定している
    * entrypoint.sh 処理本体を記述したシェルスクリプト、中身は単純だが、出力先がミソである
    * (注).github以下にアクションを置く場合、なぜかサブディレクトリを2段掘らないと動作しない。どうも裏技らしい(?)

## 出力結果のアーティファクト化
entrypoint.shからは、`/github/workspace`以下に出力を書き込んでいる。このディレクトリはホストとコンテナで共有できる。

`/github/workspace`はホストのワーキングディレクトリ(`./`)をマウントしているので、ワークフロー myhelloworld.yml において、  
`path: output.txt`  
のアップロードを行い(アーティファクト化)、続いて  
`./download`  
ディレクトリにダウンロード、最後に標準出力に印字している。

アーティファクトはGitHubのウェブ画面からzip形式でダウンロードが可能  
※アーティファクトはGitHubクラウドに保管される。期限付き

## Self-hosted runner
myhelloworld.yml の中で下記記述を行うと自己ホストランナー指定になる  
```
runs-on: self-hosted
```
なお、GitHubホステッドのランナーの場合は下記
```
runs-on: Ubuntu-latest
```
Self-hosted-runnerはGitHubに繋がるマシンで(クライアントPCで良い)、**リポジトリごとに**設置する必要がある。

設置手順は下記の通り
1. GitHubで対象リポジトリを開く
2. Actionタブ→左側のRunners
3. Self-hosted runnersのタブを開き
4. New runner→Create New Runner
5. ランナーをWindowsで動かすかLinux(WSL可)で動かすかを決め、メニューから選択
6. WindowsならPowershell、Linuxならbash等を開き、GitHubのウェブ画面上に記された手順通りにコマンドをコピペ実行する。※各行ごとにコピーボタンがあるのでそれを使えば簡単
7. `./configure`の所で幾つか質問されるが、基本的に全てデフォルト(Enter)で良い。

なお、アーティファクトの項で述べた
`/github/workspace/`に対応するディレクトリは、  
<ランナーディレクトリ>/<ワークディレクトリ>/<リポジトリ名>/<リポジトリ名>  
と共有されていて、ここに出力されたファイル等はランナーのローカルファイルシステムに残り続ける。

例：~/runner-dockeraction/_work/dockeraction/dockeraction