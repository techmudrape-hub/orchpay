# Activity Logs Enhancement

## Overview
Enhanced the Activity Logs section with pagination, advanced filtering, and export capabilities to improve usability and performance.

## New Features

### 1. Pagination
- **Records per page**: 20 (configurable, max 100)
- **Navigation**: Previous/Next buttons
- **Display**: Shows current page, total pages, and record range
- **Performance**: Loads only required records instead of all logs

### 2. Advanced Filters

#### Search Filter
- Search across action, IP address, and status fields
- Real-time filtering
- Press Enter to search

#### Date Range Filter
- **From Date**: Filter logs from a specific date
- **To Date**: Filter logs up to a specific date
- Supports any date range combination

#### Status Filter
- All Status (default)
- Success
- Failed
- Locked
- Inactive

#### Action Filter
- All Actions (default)
- Login
- Login Attempt
- Logout
- Change Password
- Change PIN

### 3. Export Options

#### CSV Download
- Downloads filtered logs as CSV file
- Includes all filtered records (not just current page)
- Filename format: `activity_logs_YYYYMMDD_HHMMSS.csv`
- Columns: ID, Admin ID, Action, Status, IP Address, User Agent, Date & Time (IST)

#### PDF Export
- Exports current page as PDF
- Includes filter information in header
- Professional formatting with grid layout
- Filename format: `activity-logs-YYYY-MM-DD.pdf`

### 4. IST Timezone
- All timestamps displayed in IST (Asia/Kolkata)
- Format: `DD MMM YYYY, HH:MM:SS IST`
- Example: `27 Feb 2026, 19:05:56 IST`

## Technical Implementation

### Backend Changes (`backend/app.py`)

#### Updated Endpoint: `GET /api/admin/activity-logs`
**Query Parameters:**
- `page` (int, default: 1): Page number
- `per_page` (int, default: 20, max: 100): Records per page
- `search` (string): Search term for action, IP, status
- `from_date` (string, YYYY-MM-DD): Start date filter
- `to_date` (string, YYYY-MM-DD): End date filter
- `status` (string): Status filter
- `action` (string): Action type filter

**Response:**
```json
{
  "success": true,
  "logs": [...],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_records": 150,
    "total_pages": 8,
    "has_next": true,
    "has_prev": false
  }
}
```

#### New Endpoint: `GET /api/admin/activity-logs/download`
**Query Parameters:** Same as above (except pagination)

**Response:** CSV file download

**Features:**
- Streams CSV file directly to browser
- Applies all active filters
- No pagination limit (downloads all filtered records)

### Frontend Changes

#### Updated Component: `moneyone_admin/src/pages/ActivityLogs.jsx`
**New Features:**
- Pagination controls with Previous/Next buttons
- Status and Action dropdown filters
- Enhanced search with Enter key support
- CSV download button
- Improved PDF export with filter info
- Record count display

#### Updated API: `moneyone_admin/src/api/admin_api.js`
**New Methods:**
- `getActivityLogs(params)`: Accepts filter parameters
- `downloadActivityLogs(params)`: Downloads CSV with filters

## Files Modified

### Backend
1. `backend/app.py`
   - Updated `get_activity_logs()` function with pagination and filters
   - Added `download_activity_logs()` function for CSV export

### Frontend
1. `moneyone_admin/src/pages/ActivityLogs.jsx`
   - Complete redesign with pagination
   - Added status and action filters
   - Enhanced export functionality

2. `moneyone_admin/src/api/admin_api.js`
   - Updated `getActivityLogs()` to accept parameters
   - Added `downloadActivityLogs()` method

3. `moneyone_admin/src/lib/utils.js`
   - Updated `formatDateTime()` for IST display

## Usage Guide

### Viewing Logs
1. Navigate to Activity Logs page
2. Logs are displayed 20 per page by default
3. Use Previous/Next buttons to navigate pages

### Filtering Logs
1. **Search**: Enter text in search box and press Enter or click Search
2. **Date Range**: Select From Date and/or To Date
3. **Status**: Choose from dropdown (Success, Failed, etc.)
4. **Action**: Choose from dropdown (Login, Logout, etc.)
5. Click "Search" to apply filters
6. Click "Clear" to reset all filters

### Exporting Logs

#### CSV Export (Filtered)
1. Apply desired filters
2. Click "Download CSV" button
3. All filtered records will be downloaded (not just current page)
4. File opens in Excel/Sheets

#### PDF Export (Current Page)
1. Navigate to desired page
2. Apply filters if needed
3. Click "Export PDF" button
4. Current page records exported with filter info

## Performance Improvements

### Before
- Loaded all logs (100 limit) on every request
- Client-side filtering only
- Slow with large datasets
- No pagination

### After
- Loads only 20 records per page
- Server-side filtering and pagination
- Fast response times
- Scalable to thousands of records

## Database Query Optimization

### Indexed Columns
Ensure these columns are indexed for optimal performance:
```sql
CREATE INDEX idx_admin_activity_logs_admin_id ON admin_activity_logs(admin_id);
CREATE INDEX idx_admin_activity_logs_created_at ON admin_activity_logs(created_at);
CREATE INDEX idx_admin_activity_logs_status ON admin_activity_logs(status);
CREATE INDEX idx_admin_activity_logs_action ON admin_activity_logs(action);
```

## Deployment

Run the deployment script:
```bash
bash deploy_activity_logs_timezone_fix.sh
```

## Testing Checklist

- [ ] Pagination works correctly
- [ ] Previous/Next buttons enable/disable properly
- [ ] Search filter works across action, IP, status
- [ ] Date range filter works (from, to, both)
- [ ] Status filter works (all options)
- [ ] Action filter works (all options)
- [ ] CSV download includes all filtered records
- [ ] CSV download respects active filters
- [ ] PDF export shows current page
- [ ] PDF export includes filter information
- [ ] Timestamps display in IST format
- [ ] Record count displays correctly
- [ ] Clear filters button resets everything
- [ ] Loading states work properly

## Future Enhancements

1. **Bulk Actions**: Delete multiple logs at once
2. **Advanced Search**: Regex or wildcard support
3. **Export All Pages**: Option to export all pages as PDF
4. **Custom Date Ranges**: Quick filters (Today, Last 7 days, Last 30 days)
5. **User Agent Parsing**: Display browser and OS info
6. **IP Geolocation**: Show location based on IP
7. **Real-time Updates**: WebSocket for live log updates
8. **Log Retention**: Automatic cleanup of old logs

## Notes

- Maximum 100 records per page (backend enforced)
- CSV download has no record limit
- PDF export limited to current page for performance
- All dates in IST timezone
- Filters are applied server-side for better performance
- Search is case-insensitive
