# Essivivi Client

Application mobile client pour la gestion des livraisons Essivivi.

## Fonctionnalités

### 🔐 Authentification
- **Inscription** : Numéro de téléphone, nom, adresse
- **Connexion** : Numéro de téléphone et code PIN à 6 chiffres
- **Vérification SMS** : Code de vérification à 6 chiffres
- **Session persistante** : Connexion automatique

### 👤 Gestion du profil client
- Informations personnelles :
  - Nom du point de vente
  - Nom du responsable
  - Numéro de téléphone
  - Adresse complète
  - Coordonnées GPS (enregistrées automatiquement)
- Modification des informations
- Historique client

### 📦 Commande de livraison
#### Nouvelle commande
- Formulaire de commande :
  - Quantité souhaitée
  - Date/heure de livraison préférée
  - Adresse de livraison (par défaut : adresse enregistrée)
  - Instructions spéciales (optionnel)
- Validation de la commande
- Notification de confirmation

#### Suivi de commande
- Statut de la commande :
  - En attente
  - Acceptée
  - En cours de livraison
  - Livrée
  - Annulée
- Suivi en temps réel du livreur (si en cours)
- Temps estimé d'arrivée

### 📜 Historique des livraisons
- Liste de toutes les livraisons reçues
- Détails par livraison :
  - Date et heure
  - Quantité livrée
  - Montant payé
  - Agent commercial
  - Références GPS
- Filtres et recherche
- Export en PDF

### 💰 Facturation
- Consultation des factures
- Détail par période (jour, semaine, mois)
- Montant total dû
- Historique des paiements

### 🔔 Notifications
- Confirmation de commande
- Livraison en cours
- Livraison effectuée
- Rappels de paiement (si crédit autorisé)

### ⭐ Évaluation
- Noter la livraison (1 à 5 étoiles)
- Commenter le service
- Signaler un problème

## Design

L'application utilise un thème bleu professionnel avec :
- Couleur primaire : `#2C3E7D`
- Couleur secondaire : `#4A5FA8`
- Couleur claire : `#C5CCDF`

La page de connexion est inspirée du design fourni avec des cercles décoratifs.

## Installation

1. Cloner le repository
2. Installer les dépendances :
```bash
flutter pub get
```

3. Lancer l'application :
```bash
flutter run
```

## Configuration

### Permissions Android
Ajoutez dans `android/app/src/main/AndroidManifest.xml` :
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

### Permissions iOS
Ajoutez dans `ios/Runner/Info.plist` :
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette application a besoin d'accéder à votre position pour enregistrer l'adresse de livraison</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Cette application a besoin d'accéder à votre position pour le suivi des livraisons</string>
```

## Architecture

```
lib/
├── config/
│   └── theme.dart              # Thème de l'application
├── models/
│   ├── client.dart             # Modèle Client
│   ├── order.dart              # Modèle Commande
│   ├── invoice.dart            # Modèle Facture
│   └── rating.dart             # Modèle Évaluation
├── services/
│   ├── auth_service.dart       # Service d'authentification
│   ├── location_service.dart   # Service de géolocalisation
│   └── storage_service.dart    # Service de stockage local
├── pages/
│   ├── auth/
│   │   ├── login_page.dart     # Page de connexion
│   │   ├── register_page.dart  # Page d'inscription
│   │   ├── verification_page.dart  # Vérification SMS
│   │   └── set_pin_page.dart   # Définir code PIN
│   ├── home/
│   │   └── home_page.dart      # Page d'accueil
│   ├── profile/
│   │   └── profile_page.dart   # Page de profil
│   ├── orders/
│   │   ├── new_order_page.dart     # Nouvelle commande
│   │   └── order_tracking_page.dart # Suivi de commande
│   ├── history/
│   │   └── delivery_history_page.dart # Historique
│   ├── invoices/
│   │   └── invoices_page.dart  # Facturation
│   └── ratings/
│       └── rate_delivery_page.dart # Évaluation
└── main.dart                   # Point d'entrée
```

## Technologies utilisées

- **Flutter** : Framework UI
- **Provider** : Gestion d'état
- **SharedPreferences** : Stockage local
- **Geolocator** : Géolocalisation
- **Google Maps** : Cartes et navigation
- **Pinput** : Input code PIN
- **Intl** : Internationalisation et formatage
- **PDF** : Génération de PDF

## Développement futur

- [ ] Intégration API backend réelle
- [ ] Suivi en temps réel sur carte
- [ ] Notifications push
- [ ] Export PDF des factures
- [ ] Paiement en ligne
- [ ] Chat avec le livreur
- [ ] Multi-langue

## Auteur

Essivivi - Application Client Mobile

## Licence

Propriétaire
