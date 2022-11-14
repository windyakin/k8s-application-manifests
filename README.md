# k8s-application-manifests

RaspberryPi で動かしている k3s 向けの Manifests を管理する場所

## Setup

### k3s のインストール

```
curl -sfL https://get.k3s.io | sh -
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
  --sync-policy auto \
  --auto-prune \
  --dest-namespace default \
  --dest-server https://kubernetes.default.svc \
  --revision HEAD
```

### External Secrets について

External Secrets の Provider には [Doppler](https://www.doppler.com/) を使っている

[SecretStore](https://external-secrets.io/latest/api/secretstore/) が参照する dopplerToken は Doppler から発行した Service Token を自前で追加する必要がある

```
kubectl create secret generic external-secrets-{{app_name}} -n default --from-literal doppler-token="dp.st.xxxx"
```
