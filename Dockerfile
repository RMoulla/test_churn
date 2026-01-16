FROM python:3.12-slim

# Définir le répertoire de travail dans le conteneur
WORKDIR /app

# Copier le fichier des dépendances
COPY requirements.txt requirements.txt

# Installer les dépendances
RUN pip install --no-cache-dir -r requirements.txt

# Copier les fichiers nécessaires dans l'image Docker

COPY app.py app.py
COPY data data
COPY templates templates

EXPOSE 5000

ENV PYTHONPATH=/app

# Commande pour démarrer l'application Flask
CMD ["python", "app.py"]


#Choisir l'image de base Python 3.12.1
FROM python:3.12.1-slim
 
# 2️⃣ Définir le répertoire de travail dans le conteneur
WORKDIR /app
 
# 3️⃣ Copier le fichier requirements.txt dans le conteneur
COPY requirements.txt .
 
# 4️⃣ Installer les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt
 
# 5️⃣ Copier le reste du projet dans le conteneur
COPY . .
 
# 6️⃣ Exposer le port si tu utilises Flask
EXPOSE 5000
 
# 7️⃣ Définir la commande par défaut pour lancer ton application
CMD ["python", "app.py"]