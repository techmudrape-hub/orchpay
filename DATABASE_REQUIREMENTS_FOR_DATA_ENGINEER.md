# OrchPay/MoneyOne Database Requirements Document
## Complete MySQL Database Design Specification for Data Engineer

**Document Version:** 1.0  
**Date:** March 28, 2026  
**Project:** OrchPay Payment Gateway Platform  

---

## 1. DATABASE CONFIGURATION

### 1.1 Database Settings
- **Database Name:** `orchpay_db`
- **Database Type:** MySQL 8.0+ or MariaDB 10.5+
- **Storage Engine:** InnoDB (for ALL tables)
- **Character Set:** utf8mb4
- **Collation:** utf8mb4_unicode_ci
- **Default Timezone:** IST (Asia/Kolkata, UTC+05:30)
- **Transaction Isolation Level:** READ COMMITTED
- **Connection Pool Size:** Minimum 5, Maximum 20 connections

### 1.2 General Requirements
- All tables must use InnoDB engine
- All tables must use utf8mb4 character set
- All timestamps must be stored in IST timezone
- Auto-increment primary keys where applicable
- Foreign key constraints with appropriate CASCADE rules
- Indexes on frequently queried columns
- Unique constraints where business logic requires

---

## 2. TABLE SPECIFICATIONS

### TABLE 1: admin_users
**Purpose:** Store admin user authentication and account management

**Primary Key:** `admin_id` (VARCHAR 50)

**Columns:**
- `admin_id` - VARCHAR(50), PRIMARY KEY, NOT NULL, UNIQUE
- `password_hash` - VARCHAR(255), NOT NULL (bcrypt hashed)
- `pin_hash` - VARCHAR(255), NULL (bcrypt hashed 6-digit PIN)
- `is_active` - BOOLEAN, DEFAULT TRUE
- `must_change_password` - BOOLEAN, DEFAULT FALSE
- `login_attempts` - INT, DEFAULT 0
- `locked_until` - DATETIME, NULL
- `last_login` - DATETIME, NULL
- `password_changed_at` - DATETIME, NULL
- `pin_changed_at` - DATETIME, NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Indexes:**
- Index on `is_active`
- Index on `last_login`

**Business Rules:**
- Admin ID is immutable once created
- Password must be bcrypt hashed
- Account locks for 15 minutes after 5 failed login attempts
- PIN is optional but required for sensitive operations

---

### TABLE 2: admin_activity_logs
**Purpose:** Audit trail for all admin actions

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `admin_id` - VARCHAR(50), NOT NULL
- `action` - VARCHAR(255), NOT NULL
- `status` - VARCHAR(50), NOT NULL
- `ip_address` - VARCHAR(45), NULL (supports IPv4 and IPv6)
- `user_agent` - TEXT, NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

**Foreign Keys:**
- `admin_id` → `admin_users(admin_id)` ON DELETE CASCADE

**Indexes:**
- Index on `admin_id`
- Index on `created_at`
- Index on `action`
- Index on `status`

**Business Rules:**
- All admin actions must be logged
- Logs are immutable (no updates allowed)
- Minimum retention: 1 year
- Common actions: "login", "logout", "create_merchant", "approve_fund_request", "change_password"
- Common statuses: "success", "failed", "locked", "inactive"

---

### TABLE 3: commercial_schemes
**Purpose:** Define pricing schemes for merchants

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `scheme_name` - VARCHAR(100), NOT NULL, UNIQUE
- `is_active` - BOOLEAN, DEFAULT TRUE
- `created_by` - VARCHAR(50), NOT NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `created_by` → `admin_users(admin_id)`

**Indexes:**
- Index on `is_active`
- Index on `scheme_name`

**Unique Constraints:**
- `scheme_name` must be unique

**Business Rules:**
- Scheme names: "Standard", "Premium", "Enterprise", etc.
- Cannot delete scheme if merchants are using it
- Deactivating prevents new assignments only

---

### TABLE 4: commercial_charges
**Purpose:** Define charges for each scheme by service type and product

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `scheme_id` - INT, NOT NULL
- `service_type` - ENUM('PAYIN', 'PAYOUT'), NOT NULL
- `product_name` - VARCHAR(100), NOT NULL
- `min_amount` - DECIMAL(15, 2), NOT NULL, DEFAULT 0.00
- `max_amount` - DECIMAL(15, 2), NOT NULL
- `charge_value` - DECIMAL(10, 2), NOT NULL
- `charge_type` - ENUM('FIXED', 'PERCENTAGE'), NOT NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `scheme_id` → `commercial_schemes(id)` ON DELETE CASCADE

**Indexes:**
- Composite index on (`scheme_id`, `service_type`)
- Index on `product_name`

**Unique Constraints:**
- Unique combination of (`scheme_id`, `service_type`, `product_name`)

**Business Rules:**
- Product names: "UPI", "IMPS", "NEFT", "RTGS", "NETBANKING", "CARD", "WALLET"
- FIXED charge: flat fee in rupees
- PERCENTAGE charge: 0.00 to 100.00
- Amount ranges should not overlap for same scheme+service+product

---

### TABLE 5: merchants
**Purpose:** Store merchant account information and API credentials

**Primary Key:** `merchant_id` (VARCHAR 50)

**Columns:**
- `merchant_id` - VARCHAR(50), PRIMARY KEY, NOT NULL, UNIQUE
- `password_hash` - VARCHAR(255), NOT NULL (bcrypt hashed)
- `pin_hash` - VARCHAR(255), NULL (bcrypt hashed 6-digit PIN)
- `full_name` - VARCHAR(255), NOT NULL
- `email` - VARCHAR(255), NOT NULL, UNIQUE
- `mobile` - VARCHAR(15), NOT NULL
- `dob` - DATE, NULL
- `aadhar_card` - VARCHAR(12), NOT NULL
- `pan_no` - VARCHAR(10), NOT NULL
- `pincode` - VARCHAR(10), NOT NULL
- `state` - VARCHAR(100), NOT NULL
- `city` - VARCHAR(100), NOT NULL
- `address` - TEXT, NOT NULL
- `house_number` - VARCHAR(100), NULL
- `landmark` - VARCHAR(255), NULL
- `merchant_type` - ENUM('PAYIN', 'PAYOUT', 'BOTH'), NOT NULL
- `account_number` - VARCHAR(50), NOT NULL
- `ifsc_code` - VARCHAR(11), NOT NULL
- `gst_no` - VARCHAR(15), NULL
- `scheme_id` - INT, NOT NULL
- `authorization_key` - VARCHAR(255), NOT NULL, UNIQUE
- `module_secret` - VARCHAR(255), NOT NULL, UNIQUE
- `aes_key` - VARCHAR(255), NOT NULL
- `aes_iv` - VARCHAR(255), NOT NULL
- `is_active` - BOOLEAN, DEFAULT TRUE
- `created_by` - VARCHAR(50), NOT NULL
- `last_login` - DATETIME, NULL
- `password_changed_at` - DATETIME, NULL
- `pin_changed_at` - DATETIME, NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `scheme_id` → `commercial_schemes(id)`
- `created_by` → `admin_users(admin_id)`

**Indexes:**
- Index on `email`
- Index on `mobile`
- Index on `is_active`
- Index on `merchant_type`
- Index on `authorization_key`

**Unique Constraints:**
- `merchant_id` must be unique
- `email` must be unique
- `authorization_key` must be unique (32-character hex)
- `module_secret` must be unique (64-character hex)

**Business Rules:**
- Merchant ID format: "M" + 10 digits (e.g., "M1234567890")
- Aadhar: 12 digits
- PAN: 10 characters (format: ABCDE1234F)
- IFSC: 11 characters
- GST: 15 characters (optional)
- Merchant type determines API access
- Cannot delete merchant with existing transactions

---


### TABLE 6: merchant_documents
**Purpose:** Store file paths for merchant KYC documents

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `merchant_id` - VARCHAR(50), NOT NULL, UNIQUE
- `aadhar_front_path` - VARCHAR(500), NULL
- `aadhar_back_path` - VARCHAR(500), NULL
- `pan_card_path` - VARCHAR(500), NULL
- `gst_certificate_path` - VARCHAR(500), NULL
- `cancelled_cheque_path` - VARCHAR(500), NULL
- `shop_photo_path` - VARCHAR(500), NULL
- `profile_photo_path` - VARCHAR(500), NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE

**Unique Constraints:**
- `merchant_id` must be unique (one-to-one relationship)

**Business Rules:**
- All paths are relative from uploads directory
- Example path: "merchants/M1234567890/aadhar_front.jpg"
- Documents are optional but recommended
- Actual files stored in filesystem, not database

---

### TABLE 7: merchant_ip_whitelist
**Purpose:** IP-based security for merchant API access

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `merchant_id` - VARCHAR(50), NOT NULL
- `ip_address` - VARCHAR(45), NOT NULL (supports IPv4 and IPv6)
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE

**Indexes:**
- Index on `merchant_id`

**Unique Constraints:**
- Unique combination of (`merchant_id`, `ip_address`)

**Business Rules:**
- Merchants can whitelist multiple IPs
- If whitelist is empty, all IPs allowed
- If whitelist has entries, only those IPs can access API
- Supports both IPv4 and IPv6 formats

---

### TABLE 8: merchant_callbacks
**Purpose:** Store callback URLs for transaction notifications

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `merchant_id` - VARCHAR(50), NOT NULL, UNIQUE
- `payin_callback_url` - VARCHAR(500), NULL
- `payout_callback_url` - VARCHAR(500), NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE

**Unique Constraints:**
- `merchant_id` must be unique (one-to-one relationship)

**Business Rules:**
- URLs must be valid HTTPS endpoints
- Callbacks sent on transaction status changes
- Both URLs are optional
- Separate URLs for payin and payout services

---

### TABLE 9: merchant_banks
**Purpose:** Store merchant bank account details

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `merchant_id` - VARCHAR(50), NOT NULL
- `bank_name` - VARCHAR(255), NOT NULL
- `account_number` - VARCHAR(50), NOT NULL
- `ifsc_code` - VARCHAR(11), NOT NULL
- `account_holder_name` - VARCHAR(255), NOT NULL
- `account_type` - ENUM('SAVINGS', 'CURRENT'), NOT NULL
- `branch_name` - VARCHAR(255), NULL
- `tpin_hash` - VARCHAR(255), NULL (bcrypt hashed)
- `is_active` - BOOLEAN, DEFAULT TRUE
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE

**Indexes:**
- Index on `merchant_id`
- Index on `is_active`

**Business Rules:**
- Merchants can have multiple bank accounts
- Only one account can be active at a time per merchant
- IFSC code: 11 characters
- TPIN required for transactions from this account

---

### TABLE 10: admin_banks
**Purpose:** Store admin bank accounts for fund collection

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `admin_id` - VARCHAR(50), NULL
- `bank_name` - VARCHAR(255), NOT NULL
- `account_number` - VARCHAR(50), NOT NULL
- `ifsc_code` - VARCHAR(11), NOT NULL
- `account_holder_name` - VARCHAR(255), NOT NULL
- `account_type` - ENUM('SAVINGS', 'CURRENT'), NOT NULL
- `branch_name` - VARCHAR(255), NULL
- `tpin_hash` - VARCHAR(255), NULL (bcrypt hashed)
- `is_active` - BOOLEAN, DEFAULT TRUE
- `created_by` - VARCHAR(50), NOT NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `admin_id` → `admin_users(admin_id)` ON DELETE CASCADE
- `created_by` → `admin_users(admin_id)`

**Indexes:**
- Index on `is_active`

**Business Rules:**
- Multiple admin bank accounts can exist
- Merchants deposit funds to these accounts
- Used for fund requests and settlements

---

### TABLE 11: payin_transactions
**Purpose:** Store payment collection (money-in) transactions

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `txn_id` - VARCHAR(100), NOT NULL, UNIQUE
- `merchant_id` - VARCHAR(50), NOT NULL
- `order_id` - VARCHAR(100), NOT NULL
- `amount` - DECIMAL(15, 2), NOT NULL
- `charge_amount` - DECIMAL(15, 2), NOT NULL, DEFAULT 0.00
- `charge_type` - ENUM('PERCENTAGE', 'FIXED'), NOT NULL, DEFAULT 'FIXED'
- `net_amount` - DECIMAL(15, 2), NOT NULL
- `payee_name` - VARCHAR(255), NULL
- `payee_email` - VARCHAR(255), NULL
- `payee_mobile` - VARCHAR(20), NULL
- `product_info` - VARCHAR(500), NULL
- `udf1` - VARCHAR(255), NULL (user defined field 1)
- `udf2` - VARCHAR(255), NULL (user defined field 2)
- `udf3` - VARCHAR(255), NULL (user defined field 3)
- `udf4` - VARCHAR(255), NULL (user defined field 4)
- `udf5` - VARCHAR(255), NULL (user defined field 5)
- `status` - ENUM('INITIATED', 'PENDING', 'SUCCESS', 'FAILED', 'CANCELLED'), NOT NULL, DEFAULT 'INITIATED'
- `pg_partner` - VARCHAR(50), DEFAULT 'PayU'
- `pg_txn_id` - VARCHAR(100), NULL
- `bank_ref_no` - VARCHAR(100), NULL
- `payment_mode` - VARCHAR(50), NULL
- `payment_url` - VARCHAR(1000), NULL
- `error_message` - TEXT, NULL
- `remarks` - TEXT, NULL
- `callback_url` - VARCHAR(500), NULL
- `callback_sent` - BOOLEAN, DEFAULT FALSE
- `callback_response` - TEXT, NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- `completed_at` - TIMESTAMP, NULL

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE

**Indexes:**
- Index on `merchant_id`
- Index on `status`
- Index on `created_at`
- Index on `order_id`
- Index on `pg_txn_id`
- Index on `bank_ref_no`
- Composite index on (`merchant_id`, `status`)

**Unique Constraints:**
- `txn_id` must be unique across all payin transactions

**Business Rules:**
- Transaction ID format: "TXN" + timestamp + random (e.g., "TXN20260328123456789")
- Status flow: INITIATED → PENDING → SUCCESS/FAILED/CANCELLED
- net_amount = amount - charge_amount
- Merchant wallet credited only on SUCCESS
- completed_at set when status becomes SUCCESS/FAILED
- PG partners: PayU, Mudrape, Rang, Tourquest, Airpay, Viyonapay, Paytouch, Skrillpe, Vega
- Payment modes: UPI, NETBANKING, CARD, WALLET, QR

---

### TABLE 12: payout_transactions
**Purpose:** Store payment disbursement (money-out) transactions

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `txn_id` - VARCHAR(100), NOT NULL, UNIQUE
- `merchant_id` - VARCHAR(50), NOT NULL
- `reference_id` - VARCHAR(100), NOT NULL, UNIQUE
- `order_id` - VARCHAR(100), NULL
- `batch_id` - VARCHAR(100), NULL
- `amount` - DECIMAL(15, 2), NOT NULL
- `charge_amount` - DECIMAL(15, 2), NOT NULL, DEFAULT 0.00
- `charge_type` - ENUM('PERCENTAGE', 'FIXED'), NOT NULL, DEFAULT 'FIXED'
- `net_amount` - DECIMAL(15, 2), NOT NULL
- `bene_name` - VARCHAR(255), NOT NULL (beneficiary name)
- `bene_email` - VARCHAR(255), NULL
- `bene_mobile` - VARCHAR(20), NULL
- `bene_bank` - VARCHAR(255), NULL
- `ifsc_code` - VARCHAR(20), NULL
- `account_no` - VARCHAR(50), NULL
- `vpa` - VARCHAR(100), NULL (UPI ID)
- `payment_type` - ENUM('IMPS', 'NEFT', 'RTGS', 'UPI'), NOT NULL, DEFAULT 'IMPS'
- `purpose` - VARCHAR(500), NULL
- `status` - ENUM('INITIATED', 'QUEUED', 'INPROCESS', 'SUCCESS', 'FAILED', 'REVERSED'), NOT NULL, DEFAULT 'INITIATED'
- `pg_partner` - VARCHAR(50), DEFAULT 'PayU'
- `pg_txn_id` - VARCHAR(100), NULL
- `bank_ref_no` - VARCHAR(100), NULL
- `utr` - VARCHAR(100), NULL (Unique Transaction Reference)
- `name_with_bank` - VARCHAR(255), NULL
- `name_match_score` - INT, NULL
- `error_message` - TEXT, NULL
- `remarks` - TEXT, NULL
- `callback_url` - VARCHAR(500), NULL
- `callback_sent` - BOOLEAN, DEFAULT FALSE
- `callback_response` - TEXT, NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- `completed_at` - TIMESTAMP, NULL

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE

**Indexes:**
- Index on `merchant_id`
- Index on `status`
- Index on `created_at`
- Index on `reference_id`
- Index on `order_id`
- Index on `batch_id`
- Index on `pg_txn_id`
- Index on `utr`
- Composite index on (`merchant_id`, `status`)

**Unique Constraints:**
- `txn_id` must be unique
- `reference_id` must be unique
- Unique combination of (`merchant_id`, `order_id`)

**Business Rules:**
- Status flow: INITIATED → QUEUED → INPROCESS → SUCCESS/FAILED/REVERSED
- net_amount = amount + charge_amount (merchant pays the charge)
- Merchant wallet debited on INITIATED
- Either (account_no + ifsc_code) OR vpa must be provided
- UTR provided by bank on SUCCESS
- Payment types: IMPS (instant), NEFT (batch), RTGS (high value), UPI
- name_match_score: 0-100 (Penny drop verification)

---


### TABLE 13: merchant_wallet
**Purpose:** Store merchant main wallet balance

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `merchant_id` - VARCHAR(50), NOT NULL, UNIQUE
- `balance` - DECIMAL(15, 2), NOT NULL, DEFAULT 0.00
- `last_updated` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE

**Indexes:**
- Index on `balance`

**Unique Constraints:**
- `merchant_id` must be unique (one-to-one relationship)

**Business Rules:**
- One wallet per merchant
- Balance can be positive or zero, never negative
- Updated on every transaction
- Used for payout deductions

---

### TABLE 14: merchant_unsettled_wallet
**Purpose:** Store merchant unsettled balance (payin collections pending settlement)

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `merchant_id` - VARCHAR(50), NOT NULL, UNIQUE
- `balance` - DECIMAL(15, 2), NOT NULL, DEFAULT 0.00
- `last_updated` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE

**Indexes:**
- Index on `balance`

**Unique Constraints:**
- `merchant_id` must be unique (one-to-one relationship)

**Business Rules:**
- Credited when payin SUCCESS
- Debited when merchant requests settlement
- Cannot be used for payouts directly
- Must be settled to main wallet first

---

### TABLE 15: admin_wallet
**Purpose:** Store admin wallet balances (main and unsettled)

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `admin_id` - VARCHAR(50), NOT NULL, UNIQUE
- `main_balance` - DECIMAL(15, 2), NOT NULL, DEFAULT 0.00
- `unsettled_balance` - DECIMAL(15, 2), NOT NULL, DEFAULT 0.00
- `last_updated` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `admin_id` → `admin_users(admin_id)` ON DELETE CASCADE

**Indexes:**
- Index on `main_balance`

**Unique Constraints:**
- `admin_id` must be unique (one-to-one relationship)

**Business Rules:**
- main_balance: Admin's available funds
- unsettled_balance: Pending settlements from merchants
- Both balances updated on transactions
- Admin earns commission from merchant charges

---

### TABLE 16: wallet_transactions
**Purpose:** Transaction history for merchant wallets

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `merchant_id` - VARCHAR(50), NOT NULL
- `txn_id` - VARCHAR(100), NOT NULL
- `txn_type` - ENUM('CREDIT', 'DEBIT'), NOT NULL
- `amount` - DECIMAL(15, 2), NOT NULL
- `balance_before` - DECIMAL(15, 2), NOT NULL
- `balance_after` - DECIMAL(15, 2), NOT NULL
- `description` - VARCHAR(500), NULL
- `reference_id` - VARCHAR(100), NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE

**Indexes:**
- Index on `merchant_id`
- Index on `txn_type`
- Index on `created_at`
- Index on `reference_id`
- Composite index on (`merchant_id`, `txn_id`)
- Composite index on (`merchant_id`, `created_at`)

**Business Rules:**
- Every wallet balance change must have a transaction record
- CREDIT: Money added to wallet
- DEBIT: Money deducted from wallet
- balance_after = balance_before ± amount
- Immutable records (no updates/deletes)
- reference_id links to payin/payout transaction

---

### TABLE 17: admin_wallet_transactions
**Purpose:** Transaction history for admin wallets

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `admin_id` - VARCHAR(50), NOT NULL
- `txn_id` - VARCHAR(100), NOT NULL
- `wallet_type` - ENUM('MAIN', 'UNSETTLED'), NOT NULL
- `txn_type` - ENUM('CREDIT', 'DEBIT'), NOT NULL
- `amount` - DECIMAL(15, 2), NOT NULL
- `balance_before` - DECIMAL(15, 2), NOT NULL
- `balance_after` - DECIMAL(15, 2), NOT NULL
- `description` - VARCHAR(500), NULL
- `reference_id` - VARCHAR(100), NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

**Foreign Keys:**
- `admin_id` → `admin_users(admin_id)` ON DELETE CASCADE

**Indexes:**
- Index on `admin_id`
- Index on `wallet_type`
- Index on `txn_type`
- Index on `created_at`
- Index on `reference_id`
- Composite index on (`admin_id`, `wallet_type`)
- Composite index on (`admin_id`, `created_at`)

**Business Rules:**
- Tracks both MAIN and UNSETTLED wallet changes
- Every admin wallet change must be logged
- Immutable records

---

### TABLE 18: callback_logs
**Purpose:** Log all callback attempts to merchant URLs

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `merchant_id` - VARCHAR(50), NOT NULL
- `txn_id` - VARCHAR(100), NOT NULL
- `transaction_type` - ENUM('PAYIN', 'PAYOUT'), NOT NULL
- `callback_url` - VARCHAR(500), NOT NULL
- `request_data` - TEXT, NULL (JSON payload sent)
- `request_payload` - TEXT, NULL
- `response_code` - INT, NULL (HTTP status code)
- `response_status` - INT, NULL
- `response_data` - TEXT, NULL
- `response_body` - TEXT, NULL
- `attempt_number` - INT, DEFAULT 1
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE

**Indexes:**
- Index on `txn_id`
- Index on `transaction_type`
- Index on `created_at`
- Composite index on (`merchant_id`, `txn_id`)

**Business Rules:**
- Log every callback attempt (including retries)
- Store complete request and response
- Multiple attempts allowed per transaction
- Used for debugging callback issues

---

### TABLE 19: payu_webhook_config
**Purpose:** Configuration for PayU webhook endpoints

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `event_type` - VARCHAR(100), NOT NULL, UNIQUE
- `webhook_url` - VARCHAR(500), NOT NULL
- `secret_key` - VARCHAR(255), NULL
- `is_active` - BOOLEAN, DEFAULT TRUE
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Indexes:**
- Index on `event_type`

**Unique Constraints:**
- `event_type` must be unique

**Business Rules:**
- Event types: "payment.success", "payment.failed", "payout.success", etc.
- One configuration per event type
- webhook_url is where PayU sends notifications

---

### TABLE 20: payu_webhook_logs
**Purpose:** Log all PayU webhook notifications received

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `event_type` - VARCHAR(100), NOT NULL
- `merchant_ref_id` - VARCHAR(100), NULL
- `payu_ref_id` - VARCHAR(100), NULL
- `payload` - TEXT, NOT NULL (complete JSON payload)
- `signature` - VARCHAR(500), NULL
- `is_verified` - BOOLEAN, DEFAULT FALSE
- `status` - ENUM('RECEIVED', 'PROCESSED', 'FAILED'), NOT NULL, DEFAULT 'RECEIVED'
- `processed` - BOOLEAN, DEFAULT FALSE
- `error_message` - TEXT, NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `processed_at` - TIMESTAMP, NULL

**Indexes:**
- Index on `event_type`
- Index on `merchant_ref_id`
- Index on `created_at`
- Index on `processed`

**Business Rules:**
- Log every webhook received from PayU
- Verify signature before processing
- Status: RECEIVED → PROCESSED/FAILED
- Immutable logs

---

### TABLE 21: payu_tokens
**Purpose:** Store PayU OAuth access tokens

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `access_token` - TEXT, NOT NULL
- `refresh_token` - TEXT, NULL
- `token_type` - VARCHAR(50), NOT NULL
- `expires_at` - DATETIME, NOT NULL
- `user_uuid` - VARCHAR(100), NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Indexes:**
- Index on `expires_at`

**Business Rules:**
- Store latest valid token
- Refresh before expiry
- Used for PayU API authentication

---

### TABLE 22: service_routing
**Purpose:** Configure which payment gateway to use for transactions

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `merchant_id` - VARCHAR(50), NULL
- `service_type` - ENUM('PAYIN', 'PAYOUT'), NOT NULL
- `routing_type` - ENUM('SINGLE_USER', 'ALL_USERS', 'MERCHANT', 'GLOBAL'), NOT NULL
- `pg_partner` - VARCHAR(50), NOT NULL
- `is_active` - BOOLEAN, DEFAULT TRUE
- `priority` - INT, DEFAULT 1
- `created_by` - VARCHAR(50), NOT NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE
- `created_by` → `admin_users(admin_id)`

**Indexes:**
- Composite index on (`merchant_id`, `service_type`, `is_active`)
- Composite index on (`routing_type`, `service_type`, `is_active`)
- Index on `is_active`

**Unique Constraints:**
- Unique combination of (`merchant_id`, `service_type`, `routing_type`, `pg_partner`)

**Business Rules:**
- SINGLE_USER: Route specific merchant to specific gateway
- ALL_USERS/GLOBAL: Default gateway for all merchants
- pg_partner values: PayU, Mudrape, Rang, Tourquest, Airpay, Viyonapay, Paytouch, Paytouch2, Skrillpe, Vega, Paytouchpayin
- Priority determines order when multiple routes exist
- If merchant_id is NULL, applies to all merchants

---

### TABLE 23: fund_requests
**Purpose:** Manage merchant fund deposit and settlement requests

**Primary Key:** `id` (INT AUTO_INCREMENT)

**Columns:**
- `id` - INT, AUTO_INCREMENT, PRIMARY KEY
- `request_id` - VARCHAR(100), NOT NULL, UNIQUE
- `merchant_id` - VARCHAR(50), NOT NULL
- `amount` - DECIMAL(15, 2), NOT NULL
- `bank_id` - INT, NULL
- `utr_number` - VARCHAR(100), NULL
- `deposit_date` - DATE, NULL
- `deposit_slip_path` - VARCHAR(500), NULL
- `request_type` - ENUM('TOPUP', 'SETTLEMENT'), NOT NULL
- `status` - ENUM('PENDING', 'APPROVED', 'REJECTED'), NOT NULL, DEFAULT 'PENDING'
- `remarks` - TEXT, NULL
- `admin_remarks` - TEXT, NULL
- `requested_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `processed_at` - TIMESTAMP, NULL
- `processed_by` - VARCHAR(50), NULL
- `created_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP
- `updated_at` - TIMESTAMP, DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

**Foreign Keys:**
- `merchant_id` → `merchants(merchant_id)` ON DELETE CASCADE
- `bank_id` → `admin_banks(id)`
- `processed_by` → `admin_users(admin_id)`

**Indexes:**
- Index on `merchant_id`
- Index on `status`
- Index on `created_at`
- Composite index on (`merchant_id`, `status`)
- Composite index on (`status`, `requested_at`)

**Unique Constraints:**
- `request_id` must be unique

**Business Rules:**
- TOPUP: Merchant deposits money to main wallet
- SETTLEMENT: Merchant requests to settle unsettled balance
- Status flow: PENDING → APPROVED/REJECTED
- Only admin can approve/reject
- On APPROVED: Update merchant wallet
- UTR required for TOPUP requests

---


---

## 3. TABLE RELATIONSHIPS DIAGRAM

### Primary Relationships:

**Admin Hierarchy:**
- admin_users (1) → (many) admin_activity_logs
- admin_users (1) → (many) commercial_schemes
- admin_users (1) → (many) admin_banks
- admin_users (1) → (1) admin_wallet
- admin_users (1) → (many) admin_wallet_transactions
- admin_users (1) → (many) merchants (created_by)
- admin_users (1) → (many) service_routing (created_by)

**Commercial Scheme Hierarchy:**
- commercial_schemes (1) → (many) commercial_charges
- commercial_schemes (1) → (many) merchants

**Merchant Hierarchy:**
- merchants (1) → (1) merchant_documents
- merchants (1) → (many) merchant_ip_whitelist
- merchants (1) → (1) merchant_callbacks
- merchants (1) → (many) merchant_banks
- merchants (1) → (many) payin_transactions
- merchants (1) → (many) payout_transactions
- merchants (1) → (1) merchant_wallet
- merchants (1) → (1) merchant_unsettled_wallet
- merchants (1) → (many) wallet_transactions
- merchants (1) → (many) callback_logs
- merchants (1) → (many) fund_requests
- merchants (1) → (many) service_routing

**Transaction Relationships:**
- payin_transactions (1) → (many) callback_logs
- payout_transactions (1) → (many) callback_logs
- payin_transactions (1) → (1) wallet_transactions (via reference_id)
- payout_transactions (1) → (1) wallet_transactions (via reference_id)

**Bank Relationships:**
- admin_banks (1) → (many) fund_requests

---

## 4. INDEXES & PERFORMANCE REQUIREMENTS

### 4.1 Critical Performance Indexes

**Transaction Tables (High Priority):**
- payin_transactions: Composite index on (merchant_id, status, created_at)
- payout_transactions: Composite index on (merchant_id, status, created_at)
- payin_transactions: Index on order_id, pg_txn_id, bank_ref_no
- payout_transactions: Index on reference_id, order_id, batch_id, utr

**Wallet Tables:**
- wallet_transactions: Composite index on (merchant_id, created_at)
- admin_wallet_transactions: Composite index on (admin_id, wallet_type, created_at)

**Lookup Tables:**
- merchants: Index on email, mobile, authorization_key
- admin_activity_logs: Composite index on (admin_id, created_at)
- callback_logs: Composite index on (merchant_id, txn_id)

**Routing Tables:**
- service_routing: Composite index on (merchant_id, service_type, is_active)

### 4.2 Query Optimization Requirements
- All date range queries must use indexed created_at columns
- Status-based filtering must use indexed status columns
- Merchant-specific queries must use merchant_id indexes
- Transaction lookups by external IDs (order_id, pg_txn_id, utr) must be indexed

---

## 5. CONSTRAINTS & VALIDATIONS

### 5.1 Unique Constraints Summary
- admin_users: admin_id
- merchants: merchant_id, email, authorization_key, module_secret
- commercial_schemes: scheme_name
- commercial_charges: (scheme_id, service_type, product_name)
- merchant_documents: merchant_id
- merchant_ip_whitelist: (merchant_id, ip_address)
- merchant_callbacks: merchant_id
- merchant_wallet: merchant_id
- merchant_unsettled_wallet: merchant_id
- admin_wallet: admin_id
- payin_transactions: txn_id
- payout_transactions: txn_id, reference_id, (merchant_id, order_id)
- fund_requests: request_id
- service_routing: (merchant_id, service_type, routing_type, pg_partner)
- payu_webhook_config: event_type

### 5.2 ENUM Field Values

**merchant_type:**
- PAYIN
- PAYOUT
- BOTH

**service_type:**
- PAYIN
- PAYOUT

**charge_type:**
- FIXED
- PERCENTAGE

**account_type:**
- SAVINGS
- CURRENT

**payin_transaction status:**
- INITIATED
- PENDING
- SUCCESS
- FAILED
- CANCELLED

**payout_transaction status:**
- INITIATED
- QUEUED
- INPROCESS
- SUCCESS
- FAILED
- REVERSED

**payment_type (payout):**
- IMPS
- NEFT
- RTGS
- UPI

**txn_type (wallet):**
- CREDIT
- DEBIT

**wallet_type (admin):**
- MAIN
- UNSETTLED

**routing_type:**
- SINGLE_USER
- ALL_USERS
- MERCHANT
- GLOBAL

**request_type (fund_requests):**
- TOPUP
- SETTLEMENT

**fund_request status:**
- PENDING
- APPROVED
- REJECTED

**webhook status:**
- RECEIVED
- PROCESSED
- FAILED

### 5.3 Foreign Key Cascade Rules

**ON DELETE CASCADE (child deleted when parent deleted):**
- All merchant-related tables when merchant is deleted
- All admin-related tables when admin is deleted
- commercial_charges when scheme is deleted
- admin_activity_logs when admin is deleted
- wallet_transactions when merchant is deleted
- callback_logs when merchant is deleted

**ON DELETE RESTRICT (prevent deletion if children exist):**
- Cannot delete commercial_scheme if merchants are using it
- Cannot delete admin_users if they created merchants

---

## 6. DATA VALIDATION RULES

### 6.1 Numeric Validations
- All amount fields: DECIMAL(15, 2) - supports up to 9,99,99,99,999.99
- charge_value: DECIMAL(10, 2)
- Percentage values: 0.00 to 100.00
- All amounts must be non-negative
- Balance fields can be 0 but not negative

### 6.2 String Length Validations
- admin_id, merchant_id: VARCHAR(50)
- Email: VARCHAR(255), must be valid email format
- Mobile: VARCHAR(15), numeric only
- Aadhar: VARCHAR(12), exactly 12 digits
- PAN: VARCHAR(10), exactly 10 characters (format: ABCDE1234F)
- IFSC: VARCHAR(11), exactly 11 characters
- GST: VARCHAR(15), exactly 15 characters
- Transaction IDs: VARCHAR(100)
- URLs: VARCHAR(500) or VARCHAR(1000)
- Password hash: VARCHAR(255) (bcrypt output)

### 6.3 Date/Time Validations
- All timestamps in IST timezone
- created_at: Auto-set on insert
- updated_at: Auto-update on modification
- Date fields: DATE format (YYYY-MM-DD)
- DateTime fields: DATETIME format (YYYY-MM-DD HH:MM:SS)

### 6.4 Boolean Defaults
- is_active: DEFAULT TRUE
- must_change_password: DEFAULT FALSE
- callback_sent: DEFAULT FALSE
- is_verified: DEFAULT FALSE
- processed: DEFAULT FALSE

---

## 7. INITIAL DATA REQUIREMENTS

### 7.1 Default Admin User
**Required on database setup:**
- admin_id: "ADMIN001" (or as specified)
- password_hash: bcrypt hashed password
- is_active: TRUE
- Create corresponding admin_wallet record with 0 balance

### 7.2 Default Commercial Scheme
**Required on database setup:**
- scheme_name: "Standard"
- is_active: TRUE
- created_by: "ADMIN001"

### 7.3 Default Commercial Charges
**For Standard scheme, create charges for:**

**PAYIN charges:**
- UPI: 2% or ₹5 fixed
- NETBANKING: 2% or ₹10 fixed
- CARD: 2.5% or ₹10 fixed
- WALLET: 2% or ₹5 fixed

**PAYOUT charges:**
- IMPS: ₹5 fixed
- NEFT: ₹3 fixed
- RTGS: ₹25 fixed
- UPI: ₹3 fixed

### 7.4 Default Service Routing
**Create global routing for:**
- PAYIN → PayU (priority 1)
- PAYOUT → PayU (priority 1)

---

## 8. SECURITY REQUIREMENTS

### 8.1 Password Storage
- All passwords must be bcrypt hashed
- Salt rounds: 10 or higher
- Never store plain text passwords
- Fields: password_hash, pin_hash, tpin_hash

### 8.2 API Credentials
- authorization_key: 32-character hex string
- module_secret: 64-character hex string
- aes_key: 256-bit encryption key
- aes_iv: 128-bit initialization vector
- All must be unique per merchant

### 8.3 Sensitive Data
- Aadhar numbers: Encrypted at application level
- Bank account numbers: Encrypted at application level
- PAN numbers: Encrypted at application level
- API keys: Never logged in plain text

---

## 9. BACKUP & MAINTENANCE REQUIREMENTS

### 9.1 Backup Strategy
- Daily full database backup
- Transaction logs backed up every hour
- Retention: 30 days minimum
- Test restore monthly

### 9.2 Data Retention
- Transaction data: Permanent (never delete)
- Activity logs: Minimum 1 year
- Callback logs: Minimum 6 months
- Webhook logs: Minimum 3 months

### 9.3 Maintenance Windows
- Index optimization: Weekly
- Table statistics update: Daily
- Slow query analysis: Daily
- Disk space monitoring: Continuous

---

## 10. PERFORMANCE BENCHMARKS

### 10.1 Expected Load
- Concurrent users: 100-500
- Transactions per day: 10,000-50,000
- Peak TPS: 50-100 transactions per second
- Database size growth: ~1GB per month

### 10.2 Query Performance Targets
- Transaction lookup by ID: < 10ms
- Merchant dashboard load: < 100ms
- Report generation: < 5 seconds
- Wallet balance check: < 5ms

---

## 11. ADDITIONAL NOTES

### 11.1 Payment Gateway Partners
The system integrates with multiple payment gateways:
- PayU (primary)
- Mudrape
- Rang
- Tourquest
- Airpay
- Viyonapay
- Paytouch / Paytouch2
- Skrillpe
- Vega
- Paytouchpayin

### 11.2 Transaction Flow
**PAYIN Flow:**
1. Merchant initiates transaction via API
2. System creates payin_transaction (INITIATED)
3. Customer redirected to payment gateway
4. Payment gateway processes payment
5. Webhook/callback updates status to SUCCESS/FAILED
6. On SUCCESS: Credit merchant_unsettled_wallet
7. Send callback to merchant

**PAYOUT Flow:**
1. Merchant initiates payout via API
2. System validates merchant_wallet balance
3. Debit merchant_wallet immediately
4. Create payout_transaction (INITIATED → QUEUED)
5. Process with payment gateway (INPROCESS)
6. Gateway returns UTR on success
7. Update status to SUCCESS/FAILED
8. Send callback to merchant

### 11.3 Wallet System
**Two-wallet system for merchants:**
- **Main Wallet (merchant_wallet):** Used for payouts, can be topped up
- **Unsettled Wallet (merchant_unsettled_wallet):** Receives payin collections, requires settlement

**Admin wallet:**
- **Main Balance:** Admin's available funds
- **Unsettled Balance:** Pending merchant settlements

---

## 12. CONTACT & SUPPORT

For clarifications or additional requirements, contact:
- Project: OrchPay Payment Gateway
- Database: orchpay_db
- Version: 1.0
- Date: March 28, 2026

---

**END OF DOCUMENT**

**Total Tables: 23**
**Total Relationships: 30+**
**Total Indexes: 50+**
**Total Constraints: 25+**
