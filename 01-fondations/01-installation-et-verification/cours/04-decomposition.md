# 4. Décomposition bloc par bloc

## Vérification du PATH

`command -v hermes` répond si le shell peut trouver la commande. C'est le premier contrôle, car il évite un diagnostic confus lorsque l'installation n'est pas chargée dans le shell.

## Version réelle

`hermes --version` lit l'exécutable réellement utilisé, plutôt qu'une version supposée par un guide ou une note.

## Diagnostic

`hermes doctor` est la source de vérité pratique pour les prérequis et les problèmes locaux. Le script le lance sans interpréter ni masquer sa sortie.

## Identité Git

L'identité Git est seulement informative ici. Elle devient nécessaire lorsqu'un cours demande de commiter ou pousser un dépôt GitHub ; elle ne configure rien automatiquement.
