# Docker Container Actionのサンプル(独習)
## 概要
git pushをトリガとし、Dockerコンテナを生成、日付と半固定テキストを出力する自動処理を実装した。
* ワークフローは1本のみ
* 処理の一部をアクションとして切り出している
* 処理コンテナは`Dockerfile`に基づき生成
* 処理本体はシェルスクリプト、`date`と`echo`を行うだけ
* `Hello world`が基本だが、`world`の部分は引数で与えられる。引数はワークフローファイル内に記述
* 出力をアーティファクトとしてアップロード、そしてダウンロードして表示する所まで行う
* Github-hosted runnerの他、Self-hosted runnerでも動作確認した

## 検証環境
* Windows 11 Pro 24H2
* WSL2.4.13.0
* Ubuntu 22.04.5 LTS
* Docker Engine v28.0.4

## ファイル説明
GitHub上でリモートリポジトリをfork作成または新規作成し、それをローカル環境にcloneする。cloneして出来たディレクトリがリポジトリルートとなる。  
※もちろんこのリポジトリを直接cloneしても良い。

例：~/dockeraction/

フォルダ構成：
```
~/dockeraction$ tree -a -I .git
.
├── .github
│   ├── actions
│   │   └── myhelloworld
│   │       ├── Dockerfile
│   │       ├── action.yml
│   │       └── entrypoint.sh
│   └── workflows
│       └── myhelloworld.yml
└── README.md
```

* ./REAMDE.md この説明文書
* ./.github/workflows/myhelloworld.yml メインのワークフロー（ワークフローはこれ1本）ここからアクションを呼び出している。
    * `who-to-greet: 'World from hogehoge'`の部分で引数指定。ここに記述した文字列が、Hello の後に付加される
* ./.github/actions/myhelloworld (注)
    * action.yml コンテナ生成、起動を司るアクション、本サンプルの肝の部分、引数の渡し方が少し面倒
    * Dockerfile コンテナ生成用ファイル、内部で`date`を使うので、タイムゾーンを設定している
    * entrypoint.sh 処理本体を記述したシェルスクリプト、中身は単純だが、出力先が重要(後述)
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

## Self-hosted runner(自己ホストランナー)
GitHub Actionsのジョブを自前(オンプレ)の環境で実行させる。設定は下記。

myhelloworld.yml の中で
```
runs-on: Ubuntu-latest
```
と記述されている部分を
```
runs-on: self-hosted
```
に書き換える。

Self-hosted runnerはインターネットを介してGitHubに繋がるマシンであれば良く、クライアントPCで良い。  
※GitHubサーバにhttpsでロングポーリングを行っている模様。

但しDockerを動かすのでLinuxマシンである必要がある(WSL可)。  
Docker Engineをインストールしておく必要もある。

また、Self-hosted runnerのソフトウェアは**リポジトリごとに独立したディレクトリ配下**にインストールし、稼働させる必要がある。

例：~/runner-dockeraction/

設置手順は下記の通り
1. GitHubで対象リポジトリを開く
2. Actionタブ→左側のRunners
3. Self-hosted runnersのタブを開き
4. New runner→Create New Runner
5. ランナーはLinuxで動かすので(WSL可)、メニューからLinuxを選択
6. WindowsならPowershell、Linuxならbash等を開き、GitHubのウェブ画面上に記された手順通りにコマンドをコピペ実行する。※各行ごとにコピーボタンがあるのでそれを使えば簡単。但し1番目だけは、上記で自分で決めたユニークなディレクトリを指定する必要がある。
    * 注1：手順1をそのままコピーすると同じディレクトリ名になってしまい、複数のランナーを作れない
    * 注2：ローカルリポジトリ(例：~/dockeraction)の下に作るのも一案だが、その場合ランナーのディレクトリは`.gitignore`で除外しておく事が望ましい。
7. `./configure`の所で幾つか質問されるが、基本的に全てデフォルト(Enter)で良い。全ての質問に答え終わるとコマンドプロンプトに戻るので、それを確認してから次のステップ(`./run.sh`)に進むこと。

なお、アーティファクトの項で述べた
`/github/workspace/`に対応するディレクトリは、  
`<ランナーディレクトリ>/<ワークディレクトリ>/<リポジトリ名>/<リポジトリ名>`  
と共有されていて、ここに出力されたファイル等はランナーのローカルファイルシステムから参照できる。

例：
```
$ cd ~/runner-dockeraction/_work/dockeraction/dockeraction
$ cat output.txt
Sun Jul 20 17:09:46 JST 2025
Hello World from hogehoge
```

以上