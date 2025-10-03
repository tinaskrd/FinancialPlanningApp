import asyncio
import json
import uvicorn
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Allow SwiftUI app to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Change to specific domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Store active WebSocket connections
connected_clients = set()

# Mock transaction history
mock_transactions = [
    {"date": "2025-01-01", "amount": -50.75, "description": "Grocery Store"},
    {"date": "2025-01-17", "amount": 1000.00, "description": "Salary Deposit"},
    {"date": "2025-02-02", "amount": 30.20, "description": "Tax refund"},
    {"date": "2025-02-15", "amount": 1000.00, "description": "Salary Deposit"},
    {"date": "2025-03-03", "amount": -15.50, "description": "Transport"},
    {"date": "2025-03-04", "amount": -80.00, "description": "Entertainment"},
    {"date": "2025-04-01", "amount": 1000.00, "description": "Salary Deposit"},
    {"date": "2025-04-02", "amount": -120.00, "description": "Shopping"},
]


@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """ WebSocket endpoint for real-time transaction updates """
    await websocket.accept()
    connected_clients.add(websocket)
    print("Client connected")

    try:
        while True:
            await asyncio.sleep(5)
            new_transaction = {
                "date": "2024-02-12",
                "amount": -30.00,
                "description": "Uber Ride"
            }
            mock_transactions.append(new_transaction)
            data = json.dumps(mock_transactions)

            print("Sending data to clients")  # ✅ Debugging print

            # Ensure all clients get the new transaction list
            for client in list(connected_clients):  # Use a copy to prevent set modification errors
                try:
                    await client.send_text(data)
                except Exception as e:
                    print(f"Error sending data: {e}")
                    connected_clients.remove(client)  # Remove disconnected clients

    except WebSocketDisconnect:
        print("Client disconnected")
        connected_clients.remove(websocket)


# Run the server when executing `python3 main.py`
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

