# k8s-application-manifests

RaspberryPi で動かしている k3s 向けの Manifests を管理する場所

## Setup

### k3s のインストール

```
curl -sfL https://get.k3s.io | sh -
```

### SealedSecret のインストール

* 最新バージョンは https://github.com/bitnami-labs/sealed-secrets/releases を確認

```
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/${VERSION}/controller.yaml
```

#### (参考) Secret の SealedSecret 化

* SealedSecret のコマンドラインツールが必要

```
kubeseal --scope cluster-wide -o yaml < secret.yaml > sealedsecret.yaml
```

### ArgoCD のインストール

* Web UI 入れると妙に重いのでコア機能だけ入れる

```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/core-install.yaml
```

refs: https://argo-cd.readthedocs.io/en/stable/getting_started/

### ArgoCD へのリポジトリの登録

* ここからは ArgoCD のコマンドラインツールが必要
* あらかじめリポジトリに Deploy key の公開鍵を登録しておくこと

```
argocd login --core
kubectl config set-context --current --namespace=argocd
```

```
argocd repo add git@github.com:windyakin/k8s-application-manifests.git --ssh-private-key-path ${SSH_PRIVATE_KEY_PATH}
```

refs: https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_repo_add/

### ArgoCD のアプリケーション追加

```
argocd app create argocd-applications \
  --repo git@github.com:windyakin/k8s-application-manifests.git \
  --path argocd-application \
  --auto-prune \
  --dest-namespace default \
  --dest-server https://kubernetes.default.svc \
  --revision HEAD
```
