# Activity Logs Timezone Fix

## Problem
Activity logs were not displaying the correct IST (India Standard Time / Asia/Kolkata) timezone. The timestamps were being converted incorrectly due to browser timezone interpretation.

## Root Cause
1. Backend was sending datetime in ISO format with timezone info
2. Frontend's `new Date()` constructor was converting the ISO string to browser's local timezone
3. This caused incorrect time display for users in different timezones

## Solution

### Backend Changes (`backend/app.py`)
Modified the `get_activity_logs()` function to:
- Convert UTC datetime to IST using pytz
- Format as simple string: `YYYY-MM-DD HH:MM:SS`
- Add explicit `timezone: 'IST'` field to response
- This prevents browser from doing automatic timezone conversion

```python
# Convert to IST and format as string with IST timezone
ist_time = dt.astimezone(ist)
log['created_at'] = ist_time.strftime('%Y-%m-%d %H:%M:%S')
log['timezone'] = 'IST'
```

### Frontend Changes (`moneyone_admin/src/lib/utils.js`)
Updated `formatDateTime()` function to:
- Detect the `YYYY-MM-DD HH:MM:SS` format from backend
- Parse it directly without timezone conversion
- Format as: `DD MMM YYYY, HH:MM:SS IST`
- Fallback to `timeZone: 'Asia/Kolkata'` for other formats

```javascript
if (typeof date === 'string' && date.match(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/)) {
  const [datePart, timePart] = date.split(' ')
  const [year, month, day] = datePart.split('-')
  const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
  const monthName = monthNames[parseInt(month) - 1]
  
  return `${day} ${monthName} ${year}, ${timePart} IST`
}
```

## Display Format
- **Before**: Incorrect timezone based on browser location
- **After**: `27 Feb 2026, 19:05:56 IST` (strictly IST/Kolkata time)

## Files Modified
1. `backend/app.py` - Updated `get_activity_logs()` function
2. `moneyone_admin/src/lib/utils.js` - Updated `formatDateTime()` function

## Deployment
Run the deployment script:
```bash
bash deploy_activity_logs_timezone_fix.sh
```

## Testing
1. Login to admin panel: https://admin.moneyone.co.in
2. Navigate to Activity Logs page
3. Verify timestamps show IST time correctly
4. Check format: `DD MMM YYYY, HH:MM:SS IST`
5. Verify time matches current IST time (Asia/Kolkata timezone)

## Notes
- All activity log timestamps are now strictly in IST
- The fix ensures consistent time display regardless of user's browser timezone
- Database stores in UTC, conversion happens at API level
- Frontend displays the pre-converted IST time without further conversion
