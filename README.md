# CouchMode

Turn a Mac connected to a TV into a plug-and-play couch gaming setup.

## État du projet

CouchMode débute comme une application macOS native dans la barre des menus. Le premier squelette permet d’activer ou de désactiver l’automatisation et conserve ce choix entre les lancements.

Le MVP utilisera BetterDisplay lorsqu’il est installé pour configurer l’affichage. BetterDisplay reste une dépendance externe et optionnelle : il n’est pas distribué avec CouchMode. Les fonctions nécessitant BetterDisplay Pro, comme le basculement HDR automatique, resteront des améliorations facultatives.

## Prérequis de développement

- Un Mac Apple Silicon
- macOS 13 ou version ultérieure
- Xcode 15 ou version ultérieure

Le projet ne dépend d’aucun paquet externe.

## Compiler et lancer

1. Ouvrir `CouchMode.xcodeproj` dans Xcode.
2. Sélectionner le schéma `CouchMode` et la destination `My Mac`.
3. Utiliser **Product > Run**.

Une icône de manette apparaît dans la barre des menus. Elle ouvre le contrôle d’activation de l’automatisation.

En ligne de commande :

```sh
xcodebuild -project CouchMode.xcodeproj -scheme CouchMode -destination 'platform=macOS' build
xcodebuild -project CouchMode.xcodeproj -scheme CouchMode -destination 'platform=macOS' test
```

## Architecture initiale

- `App/` contient le cycle de vie SwiftUI et le modèle d’application.
- `Models/` contient les préférences et les valeurs partagées.
- `Services/` définit les frontières remplaçables pour l’affichage, l’audio et Steam.
- `UI/` contient l’interface de la barre des menus.

Les implémentations concrètes des services arriveront dans les tickets suivants. Les détails de commande propres à BetterDisplay resteront derrière le protocole de configuration d’affichage.
