import pandas as pd   
import numpy as np 
from sklearn.linear_model import LogisticRegression  
from sklearn.pipeline import Pipeline
import joblib                      
       
# Charger les données                                        
data = pd.read_csv('data/train_data.csv')                         


X = data[['Age', 'Account_Manager', 'Years', 'Num_Sites']] 

# Sélectionner la colonne cible
y = data['Churn']

# Entraîner le modèle de régression logistique
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('logit', LogisticRegression())
])

pipeline.fit(X_train, y_train)



# Sauvegarder le modèle entraîné avec joblib (sans dépendances pandas)
joblib.dump(pipeline, 'data/churn_model_clean.pkl')

print("Modèle de régression logistique entraîné et sauvegardé sous 'churn_model_clean.pkl'.")
