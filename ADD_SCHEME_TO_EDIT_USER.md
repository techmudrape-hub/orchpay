# Feature: Add Scheme Selection to Edit User

## Changes Made

### File: `moneyone_admin/src/pages/User/UserList.jsx`

#### 1. Added Schemes State
```javascript
const [schemes, setSchemes] = useState([])
```

#### 2. Added Load Schemes Function
```javascript
const loadSchemes = async () => {
  try {
    const response = await adminAPI.getSchemes()
    if (response.success) {
      setSchemes(response.schemes || [])
    }
  } catch (error) {
    console.error('Failed to load schemes:', error)
  }
}
```

#### 3. Load Schemes on Component Mount
```javascript
useEffect(() => {
  loadUsers()
  loadSchemes()  // Added this
}, [])
```

#### 4. Added Scheme Dropdown in Edit Modal
Added a new dropdown field in the Edit User modal that allows selecting a scheme:

```javascript
<div>
  <Label>Scheme *</Label>
  <select
    value={editFormData.scheme_id || ''}
    onChange={(e) => setEditFormData({ ...editFormData, scheme_id: e.target.value })}
    className="flex h-9 w-full rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm"
  >
    <option value="">Select Scheme</option>
    {schemes.map((scheme) => (
      <option key={scheme.id} value={scheme.id}>
        {scheme.scheme_name}
      </option>
    ))}
  </select>
</div>
```

## How It Works

1. When the UserList component loads, it fetches all available schemes from the API
2. When admin clicks "Edit" on a user, the edit modal opens with all user details
3. The scheme dropdown shows all available schemes
4. Admin can select a different scheme for the user
5. When "Save Changes" is clicked, the updated scheme_id is sent to the backend
6. Backend updates the user's scheme in the database

## Backend Support

The backend already supports updating the scheme through the `updateUser` API endpoint:
- Endpoint: `PUT /api/admin/users/{merchant_id}`
- The `scheme_id` field is included in the update payload

## User Interface

The scheme dropdown appears in the Edit User modal between "Merchant Type" and "Account Number" fields.

## Deployment

### Step 1: Build Admin Frontend
```bash
cd /var/www/moneyone/moneyone/moneyone_admin
npm run build
```

### Step 2: Verify Build
```bash
ls -lh dist/
```

### Step 3: Set Permissions
```bash
sudo chown -R www-data:www-data dist/
sudo chmod -R 755 dist/
```

### Step 4: Clear Browser Cache
Press `Ctrl + Shift + R` to hard refresh the browser

## Testing

1. Login to admin dashboard
2. Go to User Management → User List
3. Click "Edit" on any user
4. Verify the "Scheme" dropdown appears
5. Select a different scheme
6. Click "Save Changes"
7. Verify the user's scheme is updated in the database
8. Check the User List table - the "Scheme" column should show the updated scheme

## Database Schema

The `merchants` table has a `scheme_id` column that references the `commercial_schemes` table:

```sql
ALTER TABLE merchants 
ADD COLUMN scheme_id INT,
ADD FOREIGN KEY (scheme_id) REFERENCES commercial_schemes(id);
```

## API Endpoints Used

1. `GET /api/admin/commercials/schemes` - Fetch all schemes
2. `GET /api/admin/users/{merchant_id}` - Get user details (includes current scheme)
3. `PUT /api/admin/users/{merchant_id}` - Update user (includes scheme_id)

## Benefits

- Admins can now easily change a merchant's pricing scheme
- No need to manually update the database
- Scheme changes are logged through the admin activity system
- Immediate effect on merchant's transaction charges
