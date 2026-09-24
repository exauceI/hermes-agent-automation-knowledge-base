# 7. Tests

Le test [`tests/test_verifier_installation.py`](../tests/test_verifier_installation.py) vérifie que l'exemple existe, a une syntaxe Bash valide et reste non destructif.

```bash
# Exécute les tests avec la bibliothèque standard Python, sans dépendance externe.
python -m unittest tests/test_verifier_installation.py -v
```

Ces tests ne prétendent pas simuler une installation Hermes complète. Ils protègent le contrat du cours : un script de diagnostic clair qui ne tente pas d'installer, supprimer ou modifier la machine.
