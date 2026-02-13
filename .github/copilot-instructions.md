# Copilot Instructions: test_churn

## Project Overview
This is a customer churn prediction system: a Flask web application with a pre-trained scikit-learn LogisticRegression model. The architecture separates training (offline) from serving (online), with the model persisted as a joblib pickle file.

## Architecture & Data Flow
1. **Training Pipeline** (`train.py`): Loads `data/train_data.csv` → trains LogisticRegression on 4 customer features → saves to `data/churn_model_clean.pkl`
2. **Prediction Service** (`app.py`): Loads the pre-trained model at startup → exposes `/predict` endpoint that accepts form data → returns JSON prediction
3. **Frontend** (`templates/index.html`): Single-page form that submits customer features to `/predict` and displays the binary churn result

## Key Components & Responsibilities

### `train.py` - Model Training
- **Input**: `data/train_data.csv` with columns: Age, Account_Manager, Years, Num_Sites, Churn
- **Model**: LogisticRegression (binary classification)
- **Output**: `data/churn_model_clean.pkl` via joblib
- **Convention**: Run once to create the model; app.py assumes this artifact exists
- **Note**: No cross-validation or hyperparameter tuning; production should add these

### `app.py` - Flask API Server
- **Routes**:
  - `GET /`: Renders `index.html`
  - `POST /predict`: Accepts form fields (Age, Account_Manager, Years, Num_Sites) → returns `{"churn_prediction": 0 or 1}`
- **Model Loading**: Expects `data/churn_model_clean.pkl` to exist (raises error if missing)
- **Error Handling**: Returns JSON error message on invalid input
- **Features**: Must match training features exactly in order: Age, Account_Manager, Years, Num_Sites
- **Deployment**: Runs on `0.0.0.0:5000` with debug=True

### `tests/test_app.py` - API Tests
- **Fixture**: `client` fixture creates Flask test client with TESTING=True
- **Tests**: Home route (200 status), predict route with valid form data (returns churn_prediction key)
- **Pattern**: Uses Flask's `test_client()` and form-encoded POST data, not JSON

### `tests/test_train.py` - Training Validation
- **Tests**: Model file exists, is LogisticRegression type, can make predictions on training data
- **Location Assumption**: Tests expect `data/churn_model_clean.pkl` and `data/train_data.csv` in project root

## Critical Workflows

### Running the Model Training
```bash
python train.py  # Creates data/churn_model_clean.pkl
```
This must succeed before serving the app. If train_data.csv is missing or modified, adjust feature selection in train.py.

### Running the Flask Server
```bash
python app.py  # Start on http://localhost:5000
```
Requires `data/churn_model_clean.pkl` to exist. Will crash with FileNotFoundError if missing.

### Running Tests
```bash
pytest  # Runs all tests in tests/ directory
# or
pytest tests/test_app.py -v  # Test API endpoints
pytest tests/test_train.py -v  # Test model training
```

### Docker Deployment
```bash
docker build -t churn-app .
docker run -p 5000:5000 churn-app
```
Dockerfile copies model and data artifacts. Model must be pre-trained before image build.

## Project-Specific Conventions

### Code Style & Language
- **Comments**: All written in French (follow existing style)
- **Naming**: French variable names in some files (e.g., "churn" remains English as it's the domain term)

### Model & Feature Handling
- **Feature Order**: CRITICAL - features must always be in this exact order: `Age`, `Account_Manager`, `Years`, `Num_Sites`
- **Feature Types**: Age/Years are floats, Account_Manager/Num_Sites are integers
- **Prediction Output**: Returns 0 (no churn) or 1 (churn)
- **Model Persistence**: Always use joblib (not pickle) for sklearn models to avoid dependency serialization issues

### API Communication
- **Request Format**: Form-encoded POST (not JSON) at `/predict`
- **Response Format**: Always JSON, either `{"churn_prediction": int}` or `{"error": str}`
- **Error Convention**: Wrap exceptions as JSON error messages, don't return 500 status

### Testing Conventions
- **Test Client**: Always use Flask's built-in `test_client()` with TESTING=True config
- **Assertions**: Assert on response.status_code first, then get_json()
- **Fixtures**: Use pytest fixtures for client initialization; see test_app.py for pattern

## Dependencies & Environment
- **Python Version**: 3.12 (see Dockerfile)
- **Key Libraries**: Flask 3.1.2, scikit-learn 1.8.0, joblib 1.5.3, numpy 2.4.1
- **No ORM/Database**: Direct pandas CSV loading; no migrations needed
- **pytest.ini Config**: pythonpath=., testpaths=tests

## Integration Points to Watch

1. **Model Artifact Dependency**: app.py and all tests depend on `data/churn_model_clean.pkl` existing. Always run train.py before running app.py or tests (except test_train.py which validates the training process itself).

2. **HTML Form to API**: index.html form field names must exactly match the keys in app.py's `request.form[]` calls (Age, Account_Manager, Years, Num_Sites).

3. **Data File Path**: Both train.py and app.py use relative paths (`data/`). Ensure scripts run from project root, not from subdirectories.

4. **Feature Consistency**: If modifying training data or features, update both train.py (feature selection) and app.py (form field parsing and feature ordering) in lock-step.

## Common Pitfalls to Avoid
- ❌ Running app.py without first running train.py → FileNotFoundError
- ❌ Changing feature columns in CSV without updating train.py → incorrect model
- ❌ Mismatch feature order between train.py and app.py → wrong predictions
- ❌ JSON POST to `/predict` instead of form-encoded → 400 Bad Request
- ❌ Modifying model file destination without updating both scripts → broken integration

## Extending This Codebase
- **Add new features**: Update CSV, train.py feature selection, app.py parsing, tests, and form HTML
- **Improve model**: Replace LogisticRegression with another sklearn model in train.py (keep joblib for persistence)
- **Add validation**: Add data validation in app.py before prediction, or sklearn preprocessing in train.py
- **Database**: If needed, replace CSV with database adapter in train.py; keep rest of API stable
