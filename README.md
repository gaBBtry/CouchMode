# CouchMode

Turn a Mac connected to a TV into a plug-and-play couch gaming setup.

## État du projet

CouchMode débute comme une application macOS native dans la barre des menus. Le premier squelette permet d’activer ou de désactiver l’automatisation et conserve ce choix entre les lancements. Un service CoreGraphics énumère désormais les écrans connectés et signale leurs connexions et déconnexions.

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

Lors d’un lancement depuis Xcode, la console indique les écrans présents puis les événements de connexion et de déconnexion sous la forme `Display available`, `Display connected` et `Display disconnected`.

En ligne de commande :

```sh
xcodebuild -project CouchMode.xcodeproj -scheme CouchMode -destination 'platform=macOS' build
xcodebuild -project CouchMode.xcodeproj -scheme CouchMode -destination 'platform=macOS' test
```

## Architecture initiale

- `App/` contient le cycle de vie SwiftUI et le modèle d’application.
- `Models/` contient les préférences et les valeurs partagées.
- `Services/` définit les frontières remplaçables pour l’affichage, l’audio et Steam. Le watcher d’écrans encapsule le callback natif de reconfiguration de macOS.
- `UI/` contient l’interface de la barre des menus.

Les implémentations concrètes de la configuration d’affichage, de l’audio et de Steam arriveront dans les tickets suivants. Les détails de commande propres à BetterDisplay resteront derrière le protocole de configuration d’affichage.
