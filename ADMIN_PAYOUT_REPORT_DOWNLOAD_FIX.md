# Admin Payout Report Download Fix

## Issue
When clicking "Download Filtered" button in the admin payout report page, it was showing:
- Error: "Failed to export filtered report"
- HTTP 500 Internal Server Error
- The download was not working

## Root Cause
The `/payout/admin/payout-report/all` endpoint was using `SELECT pt.*` which could cause issues if:
1. There are columns in the database that don't match the expected format
2. There are new columns added that aren't being handled properly
3. The wildcard selection causes ambiguity or data type issues

## Solution
Changed the SQL query from using `SELECT pt.*` to explicitly selecting all required columns:

```python
query = """
    SELECT 
        pt.id,
        pt.txn_id,
        pt.merchant_id,
        pt.admin_id,
        pt.reference_id,
        pt.batch_id,
        pt.amount,
        pt.charge_amount,
        pt.charge_type,
        pt.net_amount,
        pt.bene_name,
        pt.bene_email,
        pt.bene_mobile,
        pt.bene_bank,
        pt.ifsc_code,
        pt.account_no,
        pt.vpa,
        pt.payment_type,
        pt.purpose,
        pt.status,
        pt.pg_partner,
        pt.pg_txn_id,
        pt.bank_ref_no,
        pt.utr,
        pt.name_with_bank,
        pt.name_match_score,
        pt.error_message,
        pt.remarks,
        pt.callback_url,
        pt.created_at,
        pt.updated_at,
        pt.completed_at,
        m.full_name,
        m.mobile
    FROM payout_transactions pt
    LEFT JOIN merchants m ON pt.merchant_id = m.merchant_id
    WHERE 1=1
"""
```

## Benefits
1. Explicit column selection prevents issues with unexpected columns
2. Better control over what data is returned
3. Easier to debug if there are column-related issues
4. More maintainable code

## Files Modified
- `backend/payout_routes.py` - Updated `get_admin_payout_report_all()` function

## Deployment
Run the deployment script:
```bash
bash deploy_payout_report_fix.sh
```

## Testing
1. Login to admin panel
2. Navigate to Transactions > Payout Report
3. Apply any filters:
   - Status filter (e.g., SUCCESS, FAILED)
   - Search term (transaction ID, merchant name, etc.)
   - Date range (from date and to date)
4. Click "Download Filtered" button
5. Verify that CSV file downloads successfully with filtered data

## Expected Behavior
- When filters are applied, "Download Filtered" button should be enabled
- Clicking the button should fetch all matching records (not just the paginated view)
- CSV file should download with all filtered transactions
- File name format: `payout-report-filtered-YYYY-MM-DD.csv`

## Additional Features
The payout report page also has:
- "Today's Report" button - Downloads all today's payouts
- "Export All" button - Downloads currently visible paginated data
- "Download Filtered" button - Downloads all data matching current filters
