#!/bin/bash

# Configure Flask Backend Logging for Dozzle
# This script adds proper logging configuration to your Flask app

set -e

echo "=========================================="
echo "  Configure Backend Logging"
echo "=========================================="
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR=$(pwd)
BACKEND_DIR="$PROJECT_DIR/backend"

echo -e "${YELLOW}Creating enhanced logging configuration...${NC}"

# Create enhanced logging config file
cat > "$BACKEND_DIR/logging_setup.py" << 'EOF'
"""
Enhanced Logging Configuration for MoneyOne Backend
Provides structured logging with rotation and proper formatting
"""

import logging
from logging.handlers import RotatingFileHandler, TimedRotatingFileHandler
import os
from datetime import datetime

def setup_logging(app):
    """
    Configure comprehensive logging for Flask application
    """
    
    # Create logs directory
    log_dir = os.path.join(os.path.dirname(__file__), 'logs')
    os.makedirs(log_dir, exist_ok=True)
    
    # Remove default Flask handlers
    app.logger.handlers.clear()
    
    # Set logging level
    app.logger.setLevel(logging.INFO)
    
    # Create formatters
    detailed_formatter = logging.Formatter(
        '[%(asctime)s] %(levelname)s in %(module)s: %(message)s'
    )
    
    simple_formatter = logging.Formatter(
        '%(asctime)s - %(levelname)s - %(message)s'
    )
    
    # 1. Main Application Log (with rotation)
    app_handler = RotatingFileHandler(
        os.path.join(log_dir, 'app.log'),
        maxBytes=10485760,  # 10MB
        backupCount=10
    )
    app_handler.setLevel(logging.INFO)
    app_handler.setFormatter(detailed_formatter)
    app.logger.addHandler(app_handler)
    
    # 2. Error Log (errors only)
    error_handler = RotatingFileHandler(
        os.path.join(log_dir, 'error.log'),
        maxBytes=10485760,  # 10MB
        backupCount=5
    )
    error_handler.setLevel(logging.ERROR)
    error_handler.setFormatter(detailed_formatter)
    app.logger.addHandler(error_handler)
    
    # 3. API Request Log (daily rotation)
    api_handler = TimedRotatingFileHandler(
        os.path.join(log_dir, 'api_requests.log'),
        when='midnight',
        interval=1,
        backupCount=30
    )
    api_handler.setLevel(logging.INFO)
    api_handler.setFormatter(simple_formatter)
    
    # Create separate logger for API requests
    api_logger = logging.getLogger('api_requests')
    api_logger.setLevel(logging.INFO)
    api_logger.addHandler(api_handler)
    
    # 4. Transaction Log (for payment transactions)
    transaction_handler = TimedRotatingFileHandler(
        os.path.join(log_dir, 'transactions.log'),
        when='midnight',
        interval=1,
        backupCount=90  # Keep 90 days
    )
    transaction_handler.setLevel(logging.INFO)
    transaction_handler.setFormatter(detailed_formatter)
    
    transaction_logger = logging.getLogger('transactions')
    transaction_logger.setLevel(logging.INFO)
    transaction_logger.addHandler(transaction_handler)
    
    # Also log to console in development
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(simple_formatter)
    app.logger.addHandler(console_handler)
    
    app.logger.info('Logging system initialized')
    
    return app

def log_api_request(request, response_status=None, response_time=None):
    """
    Log API request details
    """
    api_logger = logging.getLogger('api_requests')
    
    log_data = {
        'method': request.method,
        'path': request.path,
        'ip': request.remote_addr,
        'user_agent': request.headers.get('User-Agent', 'Unknown'),
    }
    
    if response_status:
        log_data['status'] = response_status
    
    if response_time:
        log_data['response_time'] = f"{response_time:.3f}s"
    
    log_message = ' | '.join([f"{k}: {v}" for k, v in log_data.items()])
    api_logger.info(log_message)

def log_transaction(transaction_type, transaction_id, merchant_id, amount, status, details=None):
    """
    Log transaction details
    """
    transaction_logger = logging.getLogger('transactions')
    
    log_data = {
        'type': transaction_type,
        'txn_id': transaction_id,
        'merchant_id': merchant_id,
        'amount': amount,
        'status': status,
    }
    
    if details:
        log_data['details'] = details
    
    log_message = ' | '.join([f"{k}: {v}" for k, v in log_data.items()])
    transaction_logger.info(log_message)
EOF

echo -e "${GREEN}✓ Created logging_setup.py${NC}"

echo ""
echo -e "${YELLOW}Creating logging middleware...${NC}"

# Create middleware file
cat > "$BACKEND_DIR/logging_middleware.py" << 'EOF'
"""
Logging Middleware for Flask
Automatically logs all API requests and responses
"""

from flask import request, g
from functools import wraps
import time
import logging

api_logger = logging.getLogger('api_requests')

def log_requests(app):
    """
    Add request/response logging to Flask app
    """
    
    @app.before_request
    def before_request():
        """Log request start and store start time"""
        g.start_time = time.time()
        
        # Log incoming request
        app.logger.info(
            f"→ {request.method} {request.path} | "
            f"IP: {request.remote_addr} | "
            f"User-Agent: {request.headers.get('User-Agent', 'Unknown')[:50]}"
        )
    
    @app.after_request
    def after_request(response):
        """Log response details"""
        if hasattr(g, 'start_time'):
            response_time = time.time() - g.start_time
            
            # Log response
            app.logger.info(
                f"← {request.method} {request.path} | "
                f"Status: {response.status_code} | "
                f"Time: {response_time:.3f}s"
            )
            
            # Log errors separately
            if response.status_code >= 400:
                app.logger.warning(
                    f"Error Response: {request.method} {request.path} | "
                    f"Status: {response.status_code} | "
                    f"IP: {request.remote_addr}"
                )
        
        return response
    
    @app.errorhandler(Exception)
    def handle_exception(e):
        """Log unhandled exceptions"""
        app.logger.error(
            f"Unhandled Exception: {str(e)} | "
            f"Path: {request.path} | "
            f"Method: {request.method}",
            exc_info=True
        )
        return {"error": "Internal server error"}, 500

def log_transaction_decorator(func):
    """
    Decorator to log transaction operations
    """
    @wraps(func)
    def wrapper(*args, **kwargs):
        transaction_logger = logging.getLogger('transactions')
        
        # Log transaction start
        transaction_logger.info(f"Starting transaction: {func.__name__}")
        
        try:
            result = func(*args, **kwargs)
            transaction_logger.info(f"Transaction completed: {func.__name__}")
            return result
        except Exception as e:
            transaction_logger.error(
                f"Transaction failed: {func.__name__} | Error: {str(e)}",
                exc_info=True
            )
            raise
    
    return wrapper
EOF

echo -e "${GREEN}✓ Created logging_middleware.py${NC}"

echo ""
echo -e "${YELLOW}Creating app.py patch instructions...${NC}"

# Create instructions file
cat > "$BACKEND_DIR/APPLY_LOGGING_INSTRUCTIONS.md" << 'EOF'
# Apply Logging to app.py

Add these lines to your `backend/app.py` file:

## 1. Add imports at the top (after existing imports):

```python
from logging_setup import setup_logging
from logging_middleware import log_requests
```

## 2. After creating the Flask app and before registering blueprints, add:

```python
# Setup enhanced logging
setup_logging(app)
log_requests(app)

app.logger.info("MoneyOne Backend Starting...")
app.logger.info(f"Environment: {Config.FLASK_ENV}")
```

## 3. Example of logging in your routes:

```python
@app.route('/api/payin', methods=['POST'])
def create_payin():
    try:
        app.logger.info(f"Payin request received from {request.remote_addr}")
        # Your code here
        app.logger.info(f"Payin created successfully: {transaction_id}")
        return jsonify({"status": "success"})
    except Exception as e:
        app.logger.error(f"Payin failed: {str(e)}", exc_info=True)
        return jsonify({"error": str(e)}), 500
```

## 4. For transaction logging:

```python
from logging_setup import log_transaction

# In your payment processing code:
log_transaction(
    transaction_type='PAYIN',
    transaction_id=txn_id,
    merchant_id=merchant_id,
    amount=amount,
    status='SUCCESS',
    details='Payment processed via Mudrape'
)
```

## Quick Apply (Automatic):

Run: `python3 apply_logging_patch.py`

This will automatically add logging to your app.py file.
EOF

echo -e "${GREEN}✓ Created instructions at $BACKEND_DIR/APPLY_LOGGING_INSTRUCTIONS.md${NC}"

echo ""
echo -e "${YELLOW}Creating automatic patch script...${NC}"

# Create automatic patch script
cat > "$BACKEND_DIR/apply_logging_patch.py" << 'EOF'
#!/usr/bin/env python3
"""
Automatically patch app.py to add logging
"""

import os
import re

def patch_app_py():
    app_py_path = 'app.py'
    
    if not os.path.exists(app_py_path):
        print("❌ app.py not found in current directory")
        return False
    
    # Read current app.py
    with open(app_py_path, 'r') as f:
        content = f.read()
    
    # Check if already patched
    if 'from logging_setup import setup_logging' in content:
        print("✓ Logging already configured in app.py")
        return True
    
    # Backup original file
    with open('app.py.backup', 'w') as f:
        f.write(content)
    print("✓ Created backup: app.py.backup")
    
    # Find the line after Flask app creation
    # Look for: app = Flask(__name__)
    pattern = r'(app = Flask\(__name__\).*?\n)'
    
    if not re.search(pattern, content):
        print("❌ Could not find Flask app initialization")
        return False
    
    # Add logging imports after other imports
    import_addition = """
# Enhanced Logging Configuration
from logging_setup import setup_logging
from logging_middleware import log_requests
"""
    
    # Find last import statement
    import_pattern = r'(^import .*?\n|^from .*?\n)'
    imports = list(re.finditer(import_pattern, content, re.MULTILINE))
    
    if imports:
        last_import_end = imports[-1].end()
        content = content[:last_import_end] + import_addition + content[last_import_end:]
    
    # Add logging setup after app creation
    setup_addition = """
# Setup enhanced logging
setup_logging(app)
log_requests(app)
app.logger.info("="*50)
app.logger.info("MoneyOne Backend Starting...")
app.logger.info(f"Environment: {Config.FLASK_ENV if hasattr(Config, 'FLASK_ENV') else 'production'}")
app.logger.info("="*50)
"""
    
    # Add after CORS setup (which comes after app creation)
    cors_pattern = r'(jwt = JWTManager\(app\).*?\n)'
    content = re.sub(cors_pattern, r'\1' + setup_addition, content, count=1)
    
    # Write patched content
    with open(app_py_path, 'w') as f:
        f.write(content)
    
    print("✓ Successfully patched app.py")
    print("✓ Logging configuration added")
    return True

if __name__ == '__main__':
    print("Patching app.py with logging configuration...")
    print()
    
    if patch_app_py():
        print()
        print("="*50)
        print("✓ Logging configuration complete!")
        print("="*50)
        print()
        print("Next steps:")
        print("1. Restart your Flask backend")
        print("2. Check logs in backend/logs/ directory")
        print("3. View logs in Dozzle at http://YOUR_IP:8080")
    else:
        print()
        print("❌ Patching failed. Please apply changes manually.")
        print("See APPLY_LOGGING_INSTRUCTIONS.md for manual steps")
EOF

chmod +x "$BACKEND_DIR/apply_logging_patch.py"
echo -e "${GREEN}✓ Created automatic patch script${NC}"

echo ""
echo "=========================================="
echo -e "${GREEN}✓ Backend Logging Configuration Complete!${NC}"
echo "=========================================="
echo ""
echo "Choose one option:"
echo ""
echo "Option 1 - Automatic (Recommended):"
echo "  cd backend"
echo "  python3 apply_logging_patch.py"
echo ""
echo "Option 2 - Manual:"
echo "  Read: backend/APPLY_LOGGING_INSTRUCTIONS.md"
echo ""
echo "After applying, restart your backend:"
echo "  sudo systemctl restart backend"
echo "  # OR"
echo "  pkill -f 'python.*app.py' && cd backend && python3 app.py &"
echo ""
echo "=========================================="
