-- Performance Optimization Indexes
-- Run this on your RDS instance to improve query performance
-- Compatible with MySQL 8.4

USE moneyone_db;

-- Payin Transactions Indexes
CREATE INDEX IF NOT EXISTS idx_merchant_status ON payin_transactions (merchant_id, status);
CREATE INDEX IF NOT EXISTS idx_order_merchant ON payin_transactions (order_id, merchant_id);
CREATE INDEX IF NOT EXISTS idx_pg_txn ON payin_transactions (pg_txn_id);
CREATE INDEX IF NOT EXISTS idx_bank_ref ON payin_transactions (bank_ref_no);

-- Payout Transactions Indexes
CREATE INDEX IF NOT EXISTS idx_merchant_status ON payout_transactions (merchant_id, status);
CREATE INDEX IF NOT EXISTS idx_reference_merchant ON payout_transactions (reference_id, merchant_id);
CREATE INDEX IF NOT EXISTS idx_pg_txn ON payout_transactions (pg_txn_id);
CREATE INDEX IF NOT EXISTS idx_utr ON payout_transactions (utr);

-- Merchant Wallet Transactions Indexes
CREATE INDEX IF NOT EXISTS idx_merchant_created ON merchant_wallet_transactions (merchant_id, created_at);
CREATE INDEX IF NOT EXISTS idx_reference ON merchant_wallet_transactions (reference_id);
CREATE INDEX IF NOT EXISTS idx_txn_type ON merchant_wallet_transactions (txn_type);

-- Admin Wallet Transactions Indexes
CREATE INDEX IF NOT EXISTS idx_admin_created ON admin_wallet_transactions (admin_id, created_at);
CREATE INDEX IF NOT EXISTS idx_wallet_txn_type ON admin_wallet_transactions (wallet_type, txn_type);

-- Callback Logs Indexes
CREATE INDEX IF NOT EXISTS idx_merchant_created ON callback_logs (merchant_id, created_at);

-- Service Routing Indexes
CREATE INDEX IF NOT EXISTS idx_merchant_service ON service_routing (merchant_id, service_type, is_active);

-- Analyze tables to update statistics
ANALYZE TABLE payin_transactions;
ANALYZE TABLE payout_transactions;
ANALYZE TABLE merchant_wallet_transactions;
ANALYZE TABLE admin_wallet_transactions;
ANALYZE TABLE callback_logs;
ANALYZE TABLE service_routing;

-- Show index usage
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    SEQ_IN_INDEX,
    COLUMN_NAME,
    CARDINALITY
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'moneyone_db'
ORDER BY TABLE_NAME, INDEX_NAME, SEQ_IN_INDEX;
