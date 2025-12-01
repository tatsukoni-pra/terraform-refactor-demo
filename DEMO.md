## やりたいこと

- ディレクトリ名変更
    - aws/before_project/ → aws/after_project/ に変更したい
- [main.tf](http://main.tf) 変更
    - terraform.backend.key を、`"aws/before_project/s3.tfstate"` → `"aws/after_project/s3.tfstate"` に変更したい

## 検証環境

- hashicorp/aws：`5.98.0`
- terraform：`v1.11.1`

## 実施手順

### 1：移行先のS3フォルダにtfstateをコピーする

```bash
$ aws s3 cp \
s3://tatsukoni-tfstates/aws/before_project/ \
s3://tatsukoni-tfstates/aws/after_project/ \
--recursive
```

### 2：terrfaorm ディレクトリ名を変更する

```bash
$ git mv aws/before_project aws/after_project

$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
  renamed:    aws/before_project/common/secretsmanager/.terraform.lock.hcl -> aws/after_project/common/secretsmanager/.terraform.lock.hcl
  renamed:    aws/before_project/common/secretsmanager/main.tf -> aws/after_project/common/secretsmanager/main.tf
  renamed:    aws/before_project/common/secretsmanager/secret.tf -> aws/after_project/common/secretsmanager/secret.tf
  renamed:    aws/before_project/s3/.terraform.lock.hcl -> aws/after_project/s3/.terraform.lock.hcl
  renamed:    aws/before_project/s3/main.tf -> aws/after_project/s3/main.tf
  renamed:    aws/before_project/s3/s3.tf -> aws/after_project/s3/s3.tf
  renamed:    aws/before_project/sns/.terraform.lock.hcl -> aws/after_project/sns/.terraform.lock.hcl
  renamed:    aws/before_project/sns/main.tf -> aws/after_project/sns/main.tf
  renamed:    aws/before_project/sns/secret_manager.tf -> aws/after_project/sns/secret_manager.tf
  renamed:    aws/before_project/sns/sns.tf -> aws/after_project/sns/sns.t
```

### 3：各main.tfの `key` 値を新しい値に変更する

```bash
$ find aws/after_project -name "main.tf" -exec sed -i '' 's|aws/before_project/|aws/after_project/|g' {} \;
```

```bash
$ git diff aws/after_project/common/secretsmanager/main.tf
diff --git a/aws/after_project/common/secretsmanager/main.tf b/aws/after_project/common/secretsmanager/main.tf
index 6f28699..0a8929b 100644
--- a/aws/after_project/common/secretsmanager/main.tf
+++ b/aws/after_project/common/secretsmanager/main.tf
@@ -7,7 +7,7 @@ terraform {
   }
   backend "s3" {
     bucket  = "tatsukoni-tfstates"
-    key     = "aws/before_project/common/secretsmanager.tfstate"
+    key     = "aws/after_projectcommon/secretsmanager.tfstate"
     region  = "ap-northeast-1"
     profile = "tatsukoni"
   }
@@ -18,7 +18,7 @@ provider "aws" {
   profile = "tatsukoni"
   default_tags {
     tags = {
-      RepositoryFilePath = "aws/before_project/common/secretsmanager"
+      RepositoryFilePath = "aws/after_projectcommon/secretsmanager"
     }
   }

$ git diff aws/after_project/s3/main.tf
diff --git a/aws/after_project/s3/main.tf b/aws/after_project/s3/main.tf
index c72dd1f..91605b9 100644
--- a/aws/after_project/s3/main.tf
+++ b/aws/after_project/s3/main.tf
@@ -7,7 +7,7 @@ terraform {
   }
   backend "s3" {
     bucket  = "tatsukoni-tfstates"
-    key     = "aws/before_project/s3.tfstate"
+    key     = "aws/after_projects3.tfstate"
     region  = "ap-northeast-1"
     profile = "tatsukoni"
   }
@@ -18,7 +18,7 @@ provider "aws" {
   profile = "tatsukoni"
   default_tags {
     tags = {
-      RepositoryFilePath = "aws/before_project/s3"
+      RepositoryFilePath = "aws/after_projects3"
     }
   }
 }
 
$ git diff aws/after_project/sns/main.tf
diff --git a/aws/after_project/sns/main.tf b/aws/after_project/sns/main.tf
index af26a42..94ab57b 100644
--- a/aws/after_project/sns/main.tf
+++ b/aws/after_project/sns/main.tf
@@ -7,7 +7,7 @@ terraform {
   }
   backend "s3" {
     bucket  = "tatsukoni-tfstates"
-    key     = "aws/before_project/sns.tfstate"
+    key     = "aws/after_projectsns.tfstate"
     region  = "ap-northeast-1"
     profile = "tatsukoni"
   }
@@ -18,7 +18,7 @@ provider "aws" {
   profile = "tatsukoni"
   default_tags {
     tags = {
-      RepositoryFilePath = "aws/before_project/sns"
+      RepositoryFilePath = "aws/after_projectsns"
     }
   }
 }
```

### 4：新しいディレクトリ（key値）にて、terraform init / plan を実行する

`.terraform` をコミットしている場合は、一度削除する。（backend設定が変わったため）

terraform init / plan を実行し、タグ設定（RepositoryFilePath）以外の差分がないことを確認する。

### 5：新しいディレクトリ（key値）にて、terraform apply を実行する

各リソースについて、タグ設定（RepositoryFilePath）のみ更新されたことを確認する

### 6：[動作確認] 新しいディレクトリ（key値）にて、適当な変更を実施して反映する

新しいディレクトリ（key値）にて、挙動影響を及ぼさない変更（リソースタグ追加など）を実施し、新規命名にてterraformが問題なく動作することを確認する

### 7：[後始末] 命名変更前のtfstateファイルを削除する

手順1で複製した、命名変更前のtfstateファイル群を削除する。

```bash
$ aws s3 rm \
s3://tatsukoni-tfstates/aws/before_project/ \
--recursive
```
