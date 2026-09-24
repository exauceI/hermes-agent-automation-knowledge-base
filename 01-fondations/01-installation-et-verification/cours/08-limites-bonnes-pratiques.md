# 8. Limites et bonnes pratiques

- Un diagnostic réussi ne garantit pas qu'un fournisseur de modèle, un token de bot ou un endpoint externe fonctionnera ; vérifier ensuite un chat réel.
- Utiliser `hermes setup` ou `hermes model` pour la configuration, pas des secrets copiés dans des scripts.
- Garder les clés et tokens dans les mécanismes de secrets prévus par Hermes, jamais dans Git.
- Tester un gateway en premier plan avant de l'installer comme service.
- Pour un déploiement, suivre la documentation de messaging et le guide de la plateforme cible ; les commandes de service sont susceptibles d'évoluer.
- Prévoir sauvegarde, accès restreint et mises à jour avant de rendre un agent accessible à plusieurs personnes.
