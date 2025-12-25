# Identifiants de Test

Pour tester l'application sans API backend, utilisez ces identifiants :

## Connexion Test

- **Numéro de téléphone** : `0600000000`
- **Code PIN** : `123456`

Un compte client de test sera automatiquement créé avec ces informations :
- Nom : Client Test
- Boutique : Boutique Test
- Responsable : Responsable Test
- Adresse : 123 Rue de Test, 75000 Paris
- GPS : 48.8566, 2.3522 (Paris)

## Inscription

Vous pouvez également créer un nouveau compte via l'inscription :
1. Remplissez le formulaire d'inscription
2. Le code SMS de vérification accepte n'importe quel code à 6 chiffres
3. Définissez votre code PIN à 6 chiffres
4. Connectez-vous avec votre numéro et votre PIN

## Fonctionnement

- **Authentification** : Stockage local avec SharedPreferences
- **Données** : Toutes les commandes, factures et évaluations sont stockées localement
- **GPS** : Utilise la vraie géolocalisation de l'appareil

## Prochaines étapes

Une fois l'interface validée, vous pourrez :
1. Connecter l'API backend
2. Remplacer les méthodes de service par des appels HTTP
3. Implémenter la vraie vérification SMS
4. Gérer l'authentification JWT/OAuth
5. Synchroniser les données avec le serveur

## Structure des services

Les services sont prêts pour l'intégration API :

### AuthService
- `register()` - À connecter à `POST /api/auth/register`
- `login()` - À connecter à `POST /api/auth/login`
- `verifySMS()` - À connecter à `POST /api/auth/verify-sms`

### StorageService
- `getOrders()` - À connecter à `GET /api/orders`
- `saveOrder()` - À connecter à `POST /api/orders`
- `getInvoices()` - À connecter à `GET /api/invoices`
- etc.

Tous les modèles (Client, Order, Invoice, Rating) ont déjà des méthodes `toJson()` et `fromJson()` pour faciliter la sérialisation/désérialisation avec l'API.
