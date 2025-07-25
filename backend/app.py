from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Load model and preprocessor
model = joblib.load('models/flight_price_model.pkl')
preprocessor = joblib.load('models/preprocessor.pkl')

@app.route('/predict_price', methods=['POST'])
def predict_price():
    try:
        data = request.json
        
        # Validate required fields
        required_fields = ['departure_time', 'airline', 'arrival_airport']
        if not all(field in data for field in required_fields):
            return jsonify({'error': 'Missing required fields', 'status': 'failed'}), 400

        # Create input DataFrame
        input_data = {
            'departure_hour': pd.to_datetime(data['departure_time']).hour,
            'days_until_departure': (pd.to_datetime(data['departure_time']) - datetime.now()).days,
            'airline': data['airline'],
            'arrival_airport': data['arrival_airport'],
            'stops': data.get('stops', 0),
            'flight_duration': data.get('flight_duration', 2.0)
        }
        df = pd.DataFrame([input_data])

        # Preprocess and predict
        X_processed = preprocessor.transform(df)
        prediction = model.predict(X_processed)[0]

        return jsonify({
            'predicted_price': round(float(prediction), 2),
            'currency': 'ZAR',
            'status': 'success'
        })

    except Exception as e:
        return jsonify({
            'error': str(e),
            'status': 'failed'
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)