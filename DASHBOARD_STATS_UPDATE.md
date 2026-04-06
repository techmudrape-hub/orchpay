# Dashboard Stats Update - Merchant Dashboard

## Changes Made

Updated the merchant dashboard to show clearer PayIN and Payout information in the top 3 stat cards.

### New Layout

```
┌─────────────────────────┐  ┌─────────────────────────┐  ┌─────────────────────────┐
│   Net PayIN             │  │   Total PayIN           │  │   Total Payout          │
│   ₹7,21,419.55          │  │   ₹7,70,003.00          │  │   ₹300.00               │
│                         │  │                         │  │                         │
│   Gross: ₹7,70,003.00   │  │   Gross amount before   │  │   Total settled to bank │
│   Charges: ₹48,583.45   │  │   charges               │  │                         │
└─────────────────────────┘  └─────────────────────────┘  └─────────────────────────┘
     (Green Border)              (Blue Border)               (Purple Border)
```

### Box 1: Net PayIN (Green)
- **Shows:** Net PayIN amount (after deducting charges)
- **Below:** Breakdown showing Gross amount and Charges
- **Formula:** Gross PayIN - Charges
- **Example:** ₹7,70,003 - ₹48,583.45 = ₹7,21,419.55

### Box 2: Total PayIN (Blue)
- **Shows:** Total PayIN (Gross amount before charges)
- **Below:** Description "Gross amount before charges"
- **This is:** The total amount received from customers

### Box 3: Total Payout (Purple)
- **Shows:** Total Payout amount
- **Below:** Description "Total settled to bank"
- **This is:** Total amount paid out to merchant's bank

## File Modified

**File:** `moneyone_client/src/pages/Dashboard.jsx`

### Changes:

1. **Updated walletData state:**
```javascript
const [walletData, setWalletData] = useState({
  balance: 0,
  netPayin: 0,        // Net PayIN (after charges)
  grossPayin: 0,      // Gross PayIN (before charges)
  payinCharges: 0,    // Total charges
  totalPayout: 0
})
```

2. **Updated data loading:**
```javascript
setWalletData({
  balance: walletResponse.data.balance || 0,
  netPayin: walletResponse.data.payin_amount || 0,
  grossPayin: walletResponse.data.gross_payin || 0,
  payinCharges: walletResponse.data.payin_charges || 0,
  totalPayout: walletResponse.data.total_settlements || 0
})
```

3. **Replaced stat cards with custom cards:**
- Box 1: Net PayIN with deductions breakdown
- Box 2: Total PayIN (Gross)
- Box 3: Total Payout

## Backend API (Already Provides This Data)

The wallet overview API already returns all required data:

**Endpoint:** `GET /api/wallet/merchant/overview`

**Response:**
```json
{
  "success": true,
  "data": {
    "balance": 1100.00,
    "payin_amount": 721419.55,      // Net PayIN (used in Box 1)
    "gross_payin": 770003.00,       // Gross PayIN (used in Box 2)
    "payin_charges": 48583.45,      // Charges (shown in Box 1)
    "total_settlements": 300.00     // Total Payout (used in Box 3)
  }
}
```

## Benefits

1. **Clear Breakdown:** Merchants can see gross amount, charges, and net amount
2. **Transparency:** All deductions are visible
3. **Easy Understanding:** Three clear boxes showing different aspects
4. **Color Coding:** 
   - Green = Money received (Net PayIN)
   - Blue = Total transactions (Gross PayIN)
   - Purple = Money paid out (Payout)

## Testing

1. **Clear browser cache**
2. **Login as merchant**
3. **Go to Dashboard**
4. **Verify:**
   - Box 1 shows Net PayIN with deductions below
   - Box 2 shows Total PayIN (Gross)
   - Box 3 shows Total Payout

## Example Data

For a merchant with:
- Gross PayIN: ₹7,70,003.00
- Charges: ₹48,583.45
- Net PayIN: ₹7,21,419.55
- Total Payout: ₹300.00

Dashboard will show:
```
Box 1 (Green):
  Net PayIN: ₹7,21,419.55
  Gross: ₹7,70,003.00 - Charges: ₹48,583.45

Box 2 (Blue):
  Total PayIN: ₹7,70,003.00
  Gross amount before charges

Box 3 (Purple):
  Total Payout: ₹300.00
  Total settled to bank
```

## Deployment

No backend changes needed. Only frontend update required.

```bash
# Navigate to frontend
cd moneyone_client

# Build (if needed)
npm run build

# Or just refresh the page if using dev server
```

## Status: ✅ COMPLETE

The dashboard now clearly shows:
1. Net PayIN with deductions breakdown
2. Total PayIN (Gross amount)
3. Total Payout

All information is sourced from the existing wallet API.
