### 📦 Suggested Name:

**ClarityCargo** — *A Decentralized Smart Contract for Secure Cargo Shipment Management*

---

### 📝 README for ClarityCargo

---

# ClarityCargo

**ClarityCargo** is a decentralized shipment tracking and credit-based settlement protocol built on the Stacks blockchain using the Clarity smart contract language. It facilitates secure cargo registration, dispatch, delivery verification, and insurance-based payments between senders and couriers in a transparent and trustless environment.

---

## 🚀 Features

* 📦 **Register Shipments** — Senders can register shipments with parameters like cargo value, insurance rate, and expected transit time.
* 🧾 **Credit System** — Senders and couriers use a virtual credit system to facilitate payments.
* 🧍 **Role Separation** — Only senders can register and complete deliveries, and only couriers can dispatch shipments.
* 🔒 **Dispatch Authorization** — Ensures only one courier can dispatch a shipment and only if they have enough credits.
* ⏳ **Transit Time Enforcement** — Guarantees that delivery completion is only allowed after the specified transit duration.
* 💰 **Insurance-based Payments** — Couriers receive cargo payment plus an insurance bonus upon successful and timely delivery.

---

## 📜 Smart Contract Functions

### 📦 Public Functions

* `register-shipment (cargo-amount uint) (insurance-rate uint) (transit-time uint)`

  * Registers a new shipment and returns a unique shipment ID.

* `dispatch-shipment (shipment-id uint)`

  * Allows a courier to dispatch a registered shipment if they have sufficient credits.

* `complete-delivery (shipment-id uint)`

  * Allows the sender to complete a shipment after transit time has passed and pays the courier accordingly.

### 👀 Read-only Functions

* `get-shipment (shipment-id uint)`

  * Fetches the shipment details.

* `get-credits (user principal)`

  * Returns the current credit balance of a user.

---

## 📘 Error Codes

| Code   | Meaning                |
| ------ | ---------------------- |
| `u100` | Not authorized         |
| `u101` | Already dispatched     |
| `u102` | Insufficient credits   |
| `u103` | Shipment not active    |
| `u104` | Shipment in transit    |
| `u105` | Invalid cargo amount   |
| `u106` | Invalid insurance rate |
| `u107` | Invalid transit time   |
| `u108` | Invalid shipment ID    |

---

## 🛠️ Data Maps

* **`cargo-shipments`**
  Stores all shipment metadata including sender, courier, amount, insurance, status, etc.

* **`credit-balances`**
  Tracks the credit balances of senders and couriers.

---

## 🧪 Example Flow

1. Sender calls `register-shipment` with parameters.
2. Courier checks available shipments and dispatches one with `dispatch-shipment`.
3. After the transit time, the sender calls `complete-delivery` to finalize the shipment and pay the courier.

