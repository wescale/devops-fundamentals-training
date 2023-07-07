# Git 101

<walkthrough-tutorial-duration duration="30.0"></walkthrough-tutorial-duration>

## Description

Dans cet exercice, vous allez vous familiariser avec les opérations de base git.

## Configuration des accès

Les instances CloudShell ont un client Git pré-installé. Il faut néamnoins le configurer.

Indiquez votre email et nom dans les commandes suivantes :

```sh
git config --global user.email "VOTRE_EMAIL"
git config --global user.name "VOTRE_NOM"
git config --global init.defaultBranch  main
git config --global pull.rebase true
```

## Initialisation d'un répertoire Git

```sh
git init my-project && cd my-project
```

Au sein d'un répertoire Git, vous pouvez à tout moment connaitre l'état avec la commande `git status` :

* Référence du commit HEAD (en général une branche)
* Différences entre l'index et le commit HEAD
* Différences entre les fichiers et l'index
* Fichiers non suivis dans l'index

```sh
git status
```

## Premier commit

```sh
echo "This is my shiny project"> README.md
```

Ce nouveau fichier apparait comme non suivi par l'index :

```sh
git status
```

Ajoutez-le à l'index:

```sh
git add README.md
```

Maintenant, le fichier est bien dans l'index :

```sh
git status
```

Vous pouvez commiter ces changements dans le répertoire local :

```sh
git commit -m "Create README."
```

## Ajout d'un second fichier

Créez le fichier <walkthrough-editor-open-file filePath="hello.rust">hello.rust</walkthrough-editor-open-file> pour insérer le contenu suivant:

```rust
fn main() {
  println("Hello, world");
}
```

Ajoutez ce fichier à l'index et faites un commit :

```sh
git add hello.rust && git commit -m "Add hello entry point."
```

## Utilisation de branches

Actuellement, vous travaillez sur la branche `main`. Vous allez modifiez un fichier suivi en utilisant une branche distincte.

Créez une nouvelle branche à partir du HEAD courant :

```sh
git branch french_translate
```

Basculez la référence HEAD sur cette nouvelle branche:

```sh
git switch french_translate
```

Les deux commandes ci-dessus peuvent etre groupees en une seule: `git checkout -b french_translate`

`git status` indique que vous êtes sur cette branche:

```sh
git status
```

Re-travaillez le fichier <walkthrough-editor-open-file filePath="my-project/hello.rust">my-project/hello.rust</walkthrough-editor-open-file> pour insérer le contenu "Bonjour La France".

Ajoutez les modifications à l'index et faites un commit. Notez l'option -a qui ajoute tous les fichier suivis :

```sh
git commit -a -m 'La France'
```

Vous pouvez consulter l'historique des commits par rapport à la référence HEAD:

```sh
git --no-pager log --graph
```

Récupérez l'ID du dernier (plus récent) commit. Visualisez son contenu:

```sh
git --no-pager show COMMIT_ID
```

Repassez sur la branche `main`. Vous ne devez pas voir le commit `La France` sur cette branche avec la commande `git --no-pager log --graph`.

Pour voir le commit de la branche `french_translate` il faudrait faire un merge ou un rebase, nous verrons cela plus tard.

Pour voir l'historique des diverses branches dans le répertoire local :

```sh
git log --all --decorate --oneline --graph
```

## Création de tags

Créez un tag `v1.0.0` sur le commit courant de la branche `main`:

```sh
git tag v1.0.0 main
```

Ce tag est maintenant visible dans l'historique :

```sh
git log --all --decorate --oneline --graph
```

## Connexion à un remote

Toutes les modifications que vous avez faites sont en local.
Il est temps de pousser ces modifications sur un serveur pour partage avec d'autres contributeurs.

Une instance GitLab avec un groupe de projets est à disposition sur l'URL <https://gitlab.dev.aws.wescale.fr/>.

Ouvrez l'URL et connectez vous avec les informations compte/mot de passe fournies par le formateur.

Avant d'aller plus loin, vous devez indiquez une clé SSH pour les opérations de pull et push. Allez dans les [préférences/SSH Keys](https://gitlab.dev.aws.wescale.fr/-/profile/keys) Cliquez sur le bouton `Add SSH Key`

Générez une nouvelle clé SSH sur CloudShell:

```sh
ssh-keygen
```

Laissez les choix par défaut.

Copiez le contenu de la clé publique dans gitlab:

```sh
cat ~/.ssh/id_rsa.pub
```

Créez un nouveau projet dans le groupe [git-101](https://gitlab.dev.aws.wescale.fr/devops-training/git-101):

* Nommez-le de manière univoque. Par exemple avec l'indentifiant qui vous a été donné **k8s-fund-trainee-X**.
* Assurez-vous que vous avez décoché: `Initialize repository with a README` pour avoir un répertoire vide

Notez l'URL du repository pour définir un nouveau remote:

```sh
git remote add origin git@gitlab.dev.aws.wescale.fr:devops-training/git-101/XXXXX.git
```

Vous pouvez maintenant pousser sur le remote.

Toutes les branches :

```sh
git push -u origin --all
```

Et les tags

```sh
git push origin --tags
```

Vous pouvez enfin récupérer les modifications du remote:

```sh
git pull
```

## Félicitations

Vous avez terminé l'exercice!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
