#!/usr/bin/env python3
"""
Create OrchPay Admin User
Creates admin user with email: admin@orchpay.in
"""

import sys
import os
from werkzeug.security import generate_password_hash
import mysql.connector
from mysql.connector import Error

# Add parent directory to path to import config
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    from config import Config
    DB_CONFIG = {
        'host': Config.DB_HOST,
        'user': Config.DB_USER,
        'password': Config.DB_PASSWORD,
        'database': Config.DB_NAME
    }
except ImportError:
    # Fallback to environment variables
    from dotenv import load_dotenv
    load_dotenv()
    
    DB_CONFIG = {
        'host': os.getenv('DB_HOST', 'localhost'),
        'user': os.getenv('DB_USER', 'root'),
        'password': os.getenv('DB_PASSWORD', ''),
        'database': os.getenv('DB_NAME', 'moneyone_db')
    }

def create_admin_user():
    """Create admin user in the database"""
    
    # Admin credentials
    admin_email = "admin@orchpay.in"
    admin_password = "Admin@123"
    admin_name = "OrchPay Admin"
    
    try:
        # Connect to database
        print(f"Connecting to database: {DB_CONFIG['database']} at {DB_CONFIG['host']}...")
        connection = mysql.connector.connect(**DB_CONFIG)
        cursor = connection.cursor(dictionary=True)
        
        # Check if admin_users table exists
        cursor.execute("SHOW TABLES LIKE 'admin_users'")
        if not cursor.fetchone():
            print("Error: admin_users table does not exist!")
            print("Please run the database migration first.")
            return False
        
        # Check if admin already exists
        cursor.execute("SELECT * FROM admin_users WHERE email = %s", (admin_email,))
        existing_admin = cursor.fetchone()
        
        if existing_admin:
            print(f"\n⚠️  Admin user already exists!")
            print(f"Email: {admin_email}")
            print(f"ID: {existing_admin['id']}")
            print(f"Name: {existing_admin['name']}")
            
            response = input("\nDo you want to reset the password? (yes/no): ")
            if response.lower() in ['yes', 'y']:
                # Update password
                hashed_password = generate_password_hash(admin_password)
                cursor.execute(
                    "UPDATE admin_users SET password = %s WHERE email = %s",
                    (hashed_password, admin_email)
                )
                connection.commit()
                print(f"\n✅ Password reset successfully!")
                print(f"\nLogin Credentials:")
                print(f"Email: {admin_email}")
                print(f"Password: {admin_password}")
                return True
            else:
                print("Operation cancelled.")
                return False
        
        # Hash the password
        hashed_password = generate_password_hash(admin_password)
        
        # Insert admin user
        insert_query = """
            INSERT INTO admin_users (name, email, password, role, status, created_at)
            VALUES (%s, %s, %s, %s, %s, NOW())
        """
        
        cursor.execute(insert_query, (
            admin_name,
            admin_email,
            hashed_password,
            'super_admin',
            'active'
        ))
        
        connection.commit()
        admin_id = cursor.lastrowid
        
        print(f"\n✅ Admin user created successfully!")
        print(f"\n{'='*50}")
        print(f"Admin User Details:")
        print(f"{'='*50}")
        print(f"ID: {admin_id}")
        print(f"Name: {admin_name}")
        print(f"Email: {admin_email}")
        print(f"Password: {admin_password}")
        print(f"Role: super_admin")
        print(f"Status: active")
        print(f"{'='*50}")
        
        print(f"\n📝 Login Instructions:")
        print(f"1. Go to: https://admin.orchpay.in")
        print(f"2. Email: {admin_email}")
        print(f"3. Password: {admin_password}")
        print(f"\n⚠️  IMPORTANT: Change this password after first login!")
        
        return True
        
    except Error as e:
        print(f"\n❌ Database Error: {e}")
        return False
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        return False
        
    finally:
        if 'cursor' in locals():
            cursor.close()
        if 'connection' in locals() and connection.is_connected():
            connection.close()
            print("\nDatabase connection closed.")

if __name__ == "__main__":
    print("="*50)
    print("OrchPay Admin User Creation")
    print("="*50)
    print(f"\nDatabase: {DB_CONFIG['database']}")
    print(f"Host: {DB_CONFIG['host']}")
    print(f"User: {DB_CONFIG['user']}")
    print("\nCreating admin user...")
    
    success = create_admin_user()
    
    if success:
        print("\n✅ Setup completed successfully!")
        sys.exit(0)
    else:
        print("\n❌ Setup failed!")
        sys.exit(1)
