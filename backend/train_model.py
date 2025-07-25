import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
import joblib
from datetime import datetime
import os

# Load and prepare data
df = pd.read_csv("flights.csv")

# Convert datetime columns
df['departure_time'] = pd.to_datetime(df['departure'])
df['arrival_time'] = pd.to_datetime(df['arrival'])

# Feature engineering
df['departure_hour'] = df['departure_time'].dt.hour
df['days_until_departure'] = (df['departure_time'] - datetime.now()).dt.days
df['flight_duration'] = (df['arrival_time'] - df['departure_time']).dt.total_seconds() / 3600

# Features and target
features = [
    'departure_hour',
    'days_until_departure',
    'airline',
    'to',  # Using 'to' instead of 'arrival_airport'
    'flight_duration'
]
X = df[features]
y = df['price']

# Preprocessing
preprocessor = ColumnTransformer(
    transformers=[
        ('cat', OneHotEncoder(handle_unknown='ignore'), ['airline', 'to'])
    ],
    remainder='passthrough'
)

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
X_processed = preprocessor.fit_transform(X_train)

# Train model
model = LinearRegression()
model.fit(X_processed, y_train)

# Save artifacts
os.makedirs('models', exist_ok=True)
joblib.dump(model, 'models/flight_price_model.pkl')
joblib.dump(preprocessor, 'models/preprocessor.pkl')

print("Model training complete!")
print(f"Model score: {model.score(X_processed, y_train):.2f}")