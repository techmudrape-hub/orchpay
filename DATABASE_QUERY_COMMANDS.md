# Database Query Commands - PayIN & Payout Records

## Quick Access to MySQL

```bash
# Login to MySQL
mysql -u root -p

# Select database
USE moneyone_db;
```

---

## 📥 PAYIN QUERIES

### 1. Total PayIN Records (All Status)
```sql
SELECT 
    COUNT(*) as total_transactions,
    SUM(amount) as total_gross_amount,
    SUM(charge_amount) as total_charges,
    SUM(net_amount) as total_net_amount
FROM payin_transactions;
```

### 2. PayIN Records by Status
```sql
SELECT 
    status,
    COUNT(*) as count,
    SUM(amount) as gross_amount,
    SUM(charge_amount) as charges,
    SUM(net_amount) as net_amount
FROM payin_transactions
GROUP BY status
ORDER BY count DESC;
```

### 3. Successful PayIN Only
```sql
SELECT 
    COUNT(*) as success_count,
    SUM(amount) as gross_amount,
    SUM(charge_amount) as charges,
    SUM(net_amount) as net_amount
FROM payin_transactions
WHERE status = 'SUCCESS';
```

### 4. PayIN by Merchant
```sql
SELECT 
    merchant_id,
    COUNT(*) as transactions,
    SUM(amount) as gross_amount,
    SUM(charge_amount) as charges,
    SUM(net_amount) as net_amount
FROM payin_transactions
WHERE status = 'SUCCESS'
GROUP BY merchant_id
ORDER BY net_amount DESC;
```

### 5. PayIN by Service Provider
```sql
SELECT 
    service_name,
    COUNT(*) as transactions,
    SUM(amount) as gross_amount,
    SUM(net_amount) as net_amount
FROM payin_transactions
WHERE status = 'SUCCESS'
GROUP BY service_name
ORDER BY transactions DESC;
```

### 6. Recent PayIN Transactions (Last 10)
```sql
SELECT 
    txn_id,
    merchant_id,
    order_id,
    amount,
    charge_amount,
    net_amount,
    status,
    service_name,
    created_at
FROM payin_transactions
ORDER BY created_at DESC
LIMIT 10;
```

### 7. PayIN Today
```sql
SELECT 
    COUNT(*) as today_count,
    SUM(amount) as gross_amount,
    SUM(net_amount) as net_amount
FROM payin_transactions
WHERE DATE(created_at) = CURDATE()
AND status = 'SUCCESS';
```

### 8. PayIN This Month
```sql
SELECT 
    COUNT(*) as month_count,
    SUM(amount) as gross_amount,
    SUM(net_amount) as net_amount
FROM payin_transactions
WHERE MONTH(created_at) = MONTH(CURDATE())
AND YEAR(created_at) = YEAR(CURDATE())
AND status = 'SUCCESS';
```

### 9. PayIN Date Range
```sql
SELECT 
    COUNT(*) as count,
    SUM(amount) as gross_amount,
    SUM(net_amount) as net_amount
FROM payin_transactions
WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31'
AND status = 'SUCCESS';
```

### 10. PayIN with UTR (Bank Reference)
```sql
SELECT 
    txn_id,
    order_id,
    amount,
    net_amount,
    bank_ref_no as utr,
    status,
    created_at
FROM payin_transactions
WHERE bank_ref_no IS NOT NULL
ORDER BY created_at DESC
LIMIT 20;
```

---

## 📤 PAYOUT QUERIES

### 1. Total Payout Records (All Status)
```sql
SELECT 
    COUNT(*) as total_transactions,
    SUM(amount) as total_amount,
    SUM(charge_amount) as total_charges,
    SUM(net_amount) as total_net_amount
FROM payout_transactions;
```

### 2. Payout Records by Status
```sql
SELECT 
    status,
    COUNT(*) as count,
    SUM(amount) as total_amount,
    SUM(charge_amount) as charges,
    SUM(net_amount) as net_amount
FROM payout_transactions
GROUP BY status
ORDER BY count DESC;
```

### 3. Successful Payout Only
```sql
SELECT 
    COUNT(*) as success_count,
    SUM(amount) as total_amount,
    SUM(charge_amount) as charges,
    SUM(net_amount) as net_amount
FROM payout_transactions
WHERE status = 'SUCCESS';
```

### 4. Payout by Merchant
```sql
SELECT 
    merchant_id,
    COUNT(*) as transactions,
    SUM(amount) as total_amount,
    SUM(charge_amount) as charges,
    SUM(net_amount) as net_amount
FROM payout_transactions
WHERE status IN ('SUCCESS', 'QUEUED')
GROUP BY merchant_id
ORDER BY total_amount DESC;
```

### 5. Payout by Type
```sql
SELECT 
    payout_type,
    COUNT(*) as count,
    SUM(amount) as total_amount
FROM payout_transactions
WHERE status = 'SUCCESS'
GROUP BY payout_type;
```

### 6. Recent Payout Transactions (Last 10)
```sql
SELECT 
    txn_id,
    merchant_id,
    amount,
    charge_amount,
    net_amount,
    status,
    payout_type,
    account_number,
    ifsc_code,
    created_at
FROM payout_transactions
ORDER BY created_at DESC
LIMIT 10;
```

### 7. Payout Today
```sql
SELECT 
    COUNT(*) as today_count,
    SUM(amount) as total_amount,
    SUM(net_amount) as net_amount
FROM payout_transactions
WHERE DATE(created_at) = CURDATE()
AND status = 'SUCCESS';
```

### 8. Payout This Month
```sql
SELECT 
    COUNT(*) as month_count,
    SUM(amount) as total_amount,
    SUM(net_amount) as net_amount
FROM payout_transactions
WHERE MONTH(created_at) = MONTH(CURDATE())
AND YEAR(created_at) = YEAR(CURDATE())
AND status = 'SUCCESS';
```

### 9. Pending Payouts
```sql
SELECT 
    txn_id,
    merchant_id,
    amount,
    account_number,
    ifsc_code,
    status,
    created_at
FROM payout_transactions
WHERE status IN ('PENDING', 'QUEUED')
ORDER BY created_at DESC;
```

### 10. Failed Payouts
```sql
SELECT 
    txn_id,
    merchant_id,
    amount,
    status,
    error_message,
    created_at
FROM payout_transactions
WHERE status = 'FAILED'
ORDER BY created_at DESC
LIMIT 20;
```

---

## 💰 WALLET & FUND QUERIES

### 1. Merchant Wallet Balance (Calculated)
```sql
SELECT 
    merchant_id,
    (SELECT COALESCE(SUM(amount), 0) 
     FROM fund_requests 
     WHERE merchant_id = m.merchant_id AND status = 'APPROVED') as approved_topup,
    (SELECT COALESCE(SUM(amount), 0) 
     FROM payout_transactions 
     WHERE merchant_id = m.merchant_id AND status IN ('SUCCESS', 'QUEUED')) as total_payout,
    (SELECT COALESCE(SUM(amount), 0) 
     FROM fund_requests 
     WHERE merchant_id = m.merchant_id AND status = 'APPROVED') -
    (SELECT COALESCE(SUM(amount), 0) 
     FROM payout_transactions 
     WHERE merchant_id = m.merchant_id AND status IN ('SUCCESS', 'QUEUED')) as wallet_balance
FROM merchants m;
```

### 2. Fund Requests Summary
```sql
SELECT 
    status,
    COUNT(*) as count,
    SUM(amount) as total_amount
FROM fund_requests
GROUP BY status;
```

### 3. Approved Fund Requests
```sql
SELECT 
    request_id,
    merchant_id,
    amount,
    request_type,
    requested_at,
    processed_at
FROM fund_requests
WHERE status = 'APPROVED'
ORDER BY processed_at DESC
LIMIT 20;
```

### 4. Pending Fund Requests
```sql
SELECT 
    request_id,
    merchant_id,
    amount,
    request_type,
    remarks,
    requested_at
FROM fund_requests
WHERE status = 'PENDING'
ORDER BY requested_at DESC;
```

---

## 📊 COMBINED REPORTS

### 1. Overall Summary
```sql
SELECT 
    'PayIN' as type,
    COUNT(*) as transactions,
    SUM(amount) as gross_amount,
    SUM(net_amount) as net_amount
FROM payin_transactions
WHERE status = 'SUCCESS'
UNION ALL
SELECT 
    'Payout' as type,
    COUNT(*) as transactions,
    SUM(amount) as gross_amount,
    SUM(net_amount) as net_amount
FROM payout_transactions
WHERE status = 'SUCCESS';
```

### 2. Merchant-wise Summary
```sql
SELECT 
    m.merchant_id,
    m.full_name,
    (SELECT COUNT(*) FROM payin_transactions WHERE merchant_id = m.merchant_id AND status = 'SUCCESS') as payin_count,
    (SELECT COALESCE(SUM(net_amount), 0) FROM payin_transactions WHERE merchant_id = m.merchant_id AND status = 'SUCCESS') as payin_amount,
    (SELECT COUNT(*) FROM payout_transactions WHERE merchant_id = m.merchant_id AND status = 'SUCCESS') as payout_count,
    (SELECT COALESCE(SUM(amount), 0) FROM payout_transactions WHERE merchant_id = m.merchant_id AND status = 'SUCCESS') as payout_amount
FROM merchants m
ORDER BY payin_amount DESC;
```

### 3. Daily Transaction Summary (Last 7 Days)
```sql
SELECT 
    DATE(created_at) as date,
    COUNT(*) as payin_count,
    SUM(amount) as payin_gross,
    SUM(net_amount) as payin_net
FROM payin_transactions
WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
AND status = 'SUCCESS'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### 4. Admin Wallet Overview
```sql
SELECT 
    (SELECT COALESCE(SUM(net_amount), 0) FROM payin_transactions WHERE status = 'SUCCESS') as total_payin,
    (SELECT COALESCE(SUM(amount), 0) FROM fund_requests WHERE status = 'APPROVED') as total_topup,
    (SELECT COALESCE(SUM(amount), 0) FROM payout_transactions WHERE status = 'SUCCESS') as total_payout,
    (SELECT COALESCE(SUM(net_amount), 0) FROM payin_transactions WHERE status = 'SUCCESS') -
    (SELECT COALESCE(SUM(amount), 0) FROM fund_requests WHERE status = 'APPROVED') -
    (SELECT COALESCE(SUM(amount), 0) FROM payout_transactions WHERE status = 'SUCCESS') as admin_balance;
```

---

## 🔍 VERIFICATION QUERIES

### 1. Check Wallet Flow for Specific Merchant
```sql
SET @merchant = 'MERCHANT_ID_HERE';

SELECT 'PayIN Net Amount' as description, COALESCE(SUM(net_amount), 0) as amount
FROM payin_transactions WHERE merchant_id = @merchant AND status = 'SUCCESS'
UNION ALL
SELECT 'Approved Topup', COALESCE(SUM(amount), 0)
FROM fund_requests WHERE merchant_id = @merchant AND status = 'APPROVED'
UNION ALL
SELECT 'Total Payout', COALESCE(SUM(amount), 0)
FROM payout_transactions WHERE merchant_id = @merchant AND status IN ('SUCCESS', 'QUEUED')
UNION ALL
SELECT 'Wallet Balance', 
    (SELECT COALESCE(SUM(amount), 0) FROM fund_requests WHERE merchant_id = @merchant AND status = 'APPROVED') -
    (SELECT COALESCE(SUM(amount), 0) FROM payout_transactions WHERE merchant_id = @merchant AND status IN ('SUCCESS', 'QUEUED'));
```

### 2. Transactions Without UTR
```sql
SELECT 
    txn_id,
    merchant_id,
    order_id,
    amount,
    status,
    created_at
FROM payin_transactions
WHERE status = 'SUCCESS'
AND (bank_ref_no IS NULL OR bank_ref_no = '')
ORDER BY created_at DESC;
```

### 3. Duplicate Order IDs
```sql
SELECT 
    order_id,
    COUNT(*) as count
FROM payin_transactions
GROUP BY order_id
HAVING count > 1;
```

---

## 💡 QUICK ONE-LINERS

```bash
# Total successful PayIN
mysql -u root -p -D moneyone_db -e "SELECT COUNT(*) as count, SUM(net_amount) as total FROM payin_transactions WHERE status='SUCCESS';"

# Total successful Payout
mysql -u root -p -D moneyone_db -e "SELECT COUNT(*) as count, SUM(amount) as total FROM payout_transactions WHERE status='SUCCESS';"

# Today's PayIN
mysql -u root -p -D moneyone_db -e "SELECT COUNT(*) as count, SUM(net_amount) as total FROM payin_transactions WHERE DATE(created_at)=CURDATE() AND status='SUCCESS';"

# Today's Payout
mysql -u root -p -D moneyone_db -e "SELECT COUNT(*) as count, SUM(amount) as total FROM payout_transactions WHERE DATE(created_at)=CURDATE() AND status='SUCCESS';"

# Pending transactions
mysql -u root -p -D moneyone_db -e "SELECT 'PayIN' as type, COUNT(*) as pending FROM payin_transactions WHERE status='PENDING' UNION ALL SELECT 'Payout', COUNT(*) FROM payout_transactions WHERE status='PENDING';"
```

---

## 📝 Export to CSV

```bash
# Export PayIN records to CSV
mysql -u root -p -D moneyone_db -e "SELECT * FROM payin_transactions WHERE status='SUCCESS';" | sed 's/\t/,/g' > payin_records.csv

# Export Payout records to CSV
mysql -u root -p -D moneyone_db -e "SELECT * FROM payout_transactions WHERE status='SUCCESS';" | sed 's/\t/,/g' > payout_records.csv

# Export summary report
mysql -u root -p -D moneyone_db -e "
SELECT 
    DATE(created_at) as date,
    COUNT(*) as transactions,
    SUM(amount) as gross,
    SUM(net_amount) as net
FROM payin_transactions 
WHERE status='SUCCESS' 
GROUP BY DATE(created_at)
ORDER BY date DESC;" | sed 's/\t/,/g' > payin_summary.csv
```

---

## 🎯 Usage Tips

1. **Replace placeholders:**
   - `MERCHANT_ID_HERE` with actual merchant ID
   - Date ranges as needed

2. **Save frequently used queries:**
   ```bash
   # Create alias in ~/.bashrc
   alias payin-total="mysql -u root -p -D moneyone_db -e \"SELECT COUNT(*), SUM(net_amount) FROM payin_transactions WHERE status='SUCCESS';\""
   ```

3. **Use with watch for real-time monitoring:**
   ```bash
   watch -n 5 'mysql -u root -p[PASSWORD] -D moneyone_db -e "SELECT status, COUNT(*) FROM payin_transactions GROUP BY status;"'
   ```

4. **Backup before running UPDATE/DELETE queries:**
   ```bash
   mysqldump -u root -p moneyone_db > backup_$(date +%Y%m%d).sql
   ```
