# Git 102

<walkthrough-tutorial-duration duration="30.0"></walkthrough-tutorial-duration>

## Description

Dans cet exercice, vous allez vous familiariser avec les opérations avancées de git.

## Etat initial

Un répertoire Git existant et disponible publiquement sur GitHub: <https://github.com/wescale/git-102-demo>

Clonez le:

```sh
git clone https://github.com/wescale/git-102-demo.git
cd git-102-demo
```

Son état git est le suivant:

* les branches main et develop sur le même commit `initial commit`
* 3 feature branches partant d'`initial commit`
  * feat-a: `init` et `fix impl`
  * feat-b: `init` et `fix impl`
  * feat-bc: `init` et `finish impl`

```sh
git log --all --decorate --oneline --graph
```

### Merge de type Fast-forward

Mergez la branche feat-a sur develop

```sh
git switch develop
git merge origin/feat-a
```

Visualisez le résultat 

```sh
git log --all --decorate --oneline --graph
```

La stratégie de merge par défault tente Fast-forward si c'est possible, ce qui est le cas ici.

Le résultat est similaire à un rebase: develop et feat-a sont au même commit, l'historique des commits a été réécrit sur develop.

Pas de commit de merge.

### Merge sans Fast Forward

Mergez la branche feat-b sur develop, sans fast-forward

```sh
git switch develop
git merge origin/feat-b --no-ff
```

Un terminal vous demande de saisir le message associé au commit de merge.

Visualisez le résultat

```sh
git log --all --decorate --oneline --graph
```

Le commit de merge est visible. On retrouve donc tout l'historique de la branche feat-b. C'est interessant pour des branches qui vivent longtemps et ont de nombreux commits.

### Rebase

L'opération de rebase est similaire au merge avec fast-forward.

Faites une rebase de main sur la branche develop

```sh
git switch main
git rebase develop
```

Visualisez le résultat:

```sh
git log --all --decorate --oneline --graph
```

main et develop sont au même niveau. On retrouve le commit de merge précedent de feat-b dans develop.

### Rebase interactif avec squash

Git squash permet modifier l'historique en compressant plusieurs commits en un seul.

C'est utile pour avoir un historique plus simple. Mais applicable si vous êtes seul (ou très peu de développeurs) sur votre branche.

Il n'y a de commande `squash`, cela passe par un rebase interactif.

Faites un git squash sur la branche feat-bc pour compresser les deux dernier commits en un seul:

```sh
git switch feat-bc
git rebase -i HEAD~2
```

Un terminal s'ouvre pour saisir les opérations. Les commit sont du plus ancien (haut), au plus récent (bas)

Sur la ligne `feat-bc: finish impl`, remplacez `pick` par `squash`:

```sh
squash 66e52f6 feat-bc: finish impl
```

Enregitrez la modification.

Vous avez maintenant la possibilité de modifier le message du commit. Editez le contenu pour avoir `Ceci est un squash de 2 commits`

Visualisez le résultat:

```sh
git log --all --decorate --oneline --graph
```

Un seul commit est bien visible pour la branche feat-bc: `Ceci est un squash de 2 commit`.

### Conflit de merge

Les branches feat-b et feat-bc ont modifié la même portion du même fichier sur des branches parallèles. Ainsi, si vous tentez un merge de la branch feat-bc avec develop qui a le commit modifiant feat-b, vous aurez un conflit.

Illustrez cela en faisant un merge de feat-bc dans develop

```sh
git switch develop
git merge feat-bc
```

Vous avez un message indiquant un conflit qui doit être résolu manuellement.

```sh
git status
```

Avec l'éditeur de fichier, cliquez sur le fichier feat-b.md puis `Open with / code editor`. Choisissez la version qui vous convient, voir la combinaison de versions.

Une fois enregistré, ajoutez les modifications à l'index puis terminez le merge `git commit`.

Visualisez le résultat
```sh
git log --all --decorate --oneline --graph
```

Le fast forward n'a pas été possible. Vous avez un commit de merge avec la résolution de conflit manuelle.

## Cherry-pick

Supposez que la production est basée sur la branche main.

Supposez que vous ayez un incident en production à cause de la fonction `feat-b` qui a été mergé dans main.

Vous devez faire un patch en urgence en créant une branche de hotfix:

```sh
git switch main
gco -b hotfix
```

Editez feat-b.md pour supprimer le contenu: `But it still has a bug!!` puis faites un commit:

```sh
git commit -a -m 'hotfix: feat-b bug in prod'
```

Maintenant, cette correction doit pêtre rapatriée sur les branches main.

Notez le commit ID du hotfix.

Puis basculez sur la branche `main`

```sh
git switch main
```

Et appliquez le commit unitaire:

```sh
git cherry-pick COMMIT_ID
```

Visualisez le résultat

```sh
git log --all --decorate --oneline --graph
```

Vous trouvez le commit `hotfix: feat-b bug in prod` présent deux fois: sur la branche main et sur la branche hotfix, avec deux ID différents.

Pour être propre, le branche de hotfix doit être supprimée `git branch -D hotfix` et le commit de correction devrait aussi être redescendu sur la branche develop.

## Félicitations

Vous avez terminé l'exercice!

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>
