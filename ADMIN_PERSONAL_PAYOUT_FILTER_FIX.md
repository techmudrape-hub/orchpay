# Admin Personal Payout - Service Filter Fix

## Problem
All payin and payout services were appearing in the admin personal payout dropdown, instead of only payout services.

## Root Cause
The frontend was calling `/api/routing/services?service_type=PAYOUT&routing_type=ADMIN` but the backend endpoint was ignoring the query parameters and returning ALL service routing entries.

## Solution
Modified the `get_service_routing()` function in `backend/service_routing_routes.py` to:
1. Accept `service_type` and `routing_type` query parameters
2. Filter the database query based on these parameters
3. Return only matching routes

## Changes Made

### File: `backend/service_routing_routes.py`

**Before:**
```python
def get_service_routing():
    """Get all service routing configurations (admin only)"""
    # ... no parameter filtering
    cursor.execute("""
        SELECT sr.*, m.full_name as merchant_name
        FROM service_routing sr
        LEFT JOIN merchants m ON sr.merchant_id = m.merchant_id
        ORDER BY sr.service_type, sr.routing_type, sr.priority
    """)
```

**After:**
```python
def get_service_routing():
    """Get all service routing configurations (admin only) with optional filtering"""
    # Get query parameters for filtering
    service_type = request.args.get('service_type')
    routing_type = request.args.get('routing_type')
    
    # Build query with optional filters
    query = """
        SELECT sr.*, m.full_name as merchant_name
        FROM service_routing sr
        LEFT JOIN merchants m ON sr.merchant_id = m.merchant_id
        WHERE 1=1
    """
    params = []
    
    # Add filters if provided
    if service_type:
        query += " AND sr.service_type = %s"
        params.append(service_type)
    
    if routing_type:
        query += " AND sr.routing_type = %s"
        params.append(routing_type)
    
    query += " ORDER BY sr.service_type, sr.routing_type, sr.priority"
    
    # Execute query with parameters
    cursor.execute(query, params)
```

## How It Works

### Frontend Call (PersonalPayout.jsx)
```javascript
const response = await adminAPI.getServiceRouting('PAYOUT', 'ADMIN')
```

### API Call (admin_api.js)
```javascript
fetch(`${API_ROOT}/routing/services?service_type=PAYOUT&routing_type=ADMIN`)
```

### Backend Processing
1. Extracts `service_type=PAYOUT` and `routing_type=ADMIN` from query parameters
2. Builds SQL query with WHERE clauses
3. Returns only routes matching both criteria

## Expected Result

### Before Fix
Dropdown showed ALL services:
- ✗ Airpay (PAYIN)
- ✗ Rang (PAYIN)
- ✗ TourQuest (PAYIN)
- ✗ Vega (PAYIN)
- ✓ Mudrape (PAYOUT)
- ✓ PayTouch (PAYOUT)
- ✓ PayTouch2 (PAYOUT)

### After Fix
Dropdown shows ONLY payout services:
- ✓ Mudrape (PAYOUT)
- ✓ PayTouch (PAYOUT)
- ✓ PayTouch2 (PAYOUT)

## Testing

### 1. Test Locally
```bash
python3 backend/test_admin_payout_routing_fix.py
```

This will:
- Check database configuration
- Simulate the API query with filters
- Verify only PAYOUT services for ADMIN are returned
- Check for any PAYIN services incorrectly configured as ADMIN

### 2. Deploy to Production
```bash
bash deploy_admin_payout_routing_fix.sh
```

This will:
- Run the test script first
- Deploy to all backend instances
- Restart backend services
- Show deployment summary

### 3. Verify in UI
1. Login to Admin Panel
2. Navigate to Personal Payout
3. Check Payment Gateway dropdown
4. Should show only: Mudrape, PayTouch, PayTouch2 (or other configured payout services)
5. Should NOT show: Airpay, Rang, TourQuest, Vega (payin services)

## Database Configuration

For this fix to work correctly, ensure your `service_routing` table has proper entries:

### Correct Configuration
```sql
-- ADMIN PAYOUT entries (will appear in personal payout)
INSERT INTO service_routing (routing_type, service_type, pg_partner, is_active, priority)
VALUES 
  ('ADMIN', 'PAYOUT', 'Mudrape', TRUE, 1),
  ('ADMIN', 'PAYOUT', 'paytouch_truaxis', TRUE, 2),
  ('ADMIN', 'PAYOUT', 'paytouch2_truaxis', TRUE, 3);

-- MERCHANT PAYIN entries (will NOT appear in personal payout)
INSERT INTO service_routing (routing_type, service_type, pg_partner, merchant_id, is_active, priority)
VALUES 
  ('MERCHANT', 'PAYIN', 'Airpay', '9000000001', TRUE, 1),
  ('MERCHANT', 'PAYIN', 'Rang', '9000000001', TRUE, 2);
```

### Incorrect Configuration (DO NOT DO THIS)
```sql
-- ❌ WRONG: PAYIN services should NOT have routing_type = 'ADMIN'
INSERT INTO service_routing (routing_type, service_type, pg_partner, is_active, priority)
VALUES ('ADMIN', 'PAYIN', 'Airpay', TRUE, 1);  -- This will cause payin to appear in payout dropdown
```

## Files Modified
1. `backend/service_routing_routes.py` - Added query parameter filtering

## Files Created
1. `backend/test_admin_payout_routing_fix.py` - Test script
2. `deploy_admin_payout_routing_fix.sh` - Deployment script
3. `ADMIN_PERSONAL_PAYOUT_FILTER_FIX.md` - This documentation

## Impact
- ✅ Admin personal payout dropdown now shows only payout services
- ✅ No impact on other features (backward compatible)
- ✅ Service routing page still shows all routes when no filters applied
- ✅ Merchants' payin/payout routing unaffected

## Rollback
If needed, revert the changes in `backend/service_routing_routes.py` to remove the query parameter filtering. However, this will bring back the original issue.

## Notes
- The fix is backward compatible - if no query parameters are provided, it returns all routes (original behavior)
- The frontend already had the correct API call with parameters, it was just the backend ignoring them
- This fix also benefits any other future features that need filtered service routing
