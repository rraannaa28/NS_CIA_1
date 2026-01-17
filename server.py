import socket
import sqlite3

# =========================
# SERVER CONFIG
# =========================
HOST = "0.0.0.0"
PORT = 8080

# =========================
# MORSE DICTIONARY
# =========================
MORSE_DICT = {
    '.-': 'A', '-...': 'B', '-.-.': 'C', '-..': 'D',
    '.': 'E', '..-.': 'F', '--.': 'G', '....': 'H',
    '..': 'I', '.---': 'J', '-.-': 'K', '.-..': 'L',
    '--': 'M', '-.': 'N', '---': 'O', '.--.': 'P',
    '--.-': 'Q', '.-.': 'R', '...': 'S', '-': 'T',
    '..-': 'U', '...-': 'V', '.--': 'W', '-..-': 'X',
    '-.--': 'Y', '--..': 'Z',
    '-----': '0', '.----': '1', '..---': '2', '...--': '3',
    '....-': '4', '.....': '5', '-....': '6', '--...': '7',
    '---..': '8', '----.': '9'
}

# =========================
# MORSE DECODER FUNCTION
# =========================
def decode_morse(morse_code):
    words = morse_code.split(' / ')
    decoded_message = []

    for word in words:
        letters = word.split()
        decoded_word = ''.join(MORSE_DICT.get(letter, '') for letter in letters)
        decoded_message.append(decoded_word)

    return ' '.join(decoded_message)

# =========================
# DATABASE SETUP
# =========================
conn = sqlite3.connect("messages.db", check_same_thread=False)
cursor = conn.cursor()

cursor.execute("""
CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    client_ip TEXT,
    morse_code TEXT,
    decoded_message TEXT
)
""")
conn.commit()

print("[DATABASE] Connected and ready")

# =========================
# SOCKET SERVER SETUP
# =========================
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind((HOST, PORT))
server_socket.listen(5)

print(f"[SERVER] Morse Server listening on port {PORT}...")

# =========================
# MAIN SERVER LOOP
# =========================
while True:
    client_socket, client_address = server_socket.accept()
    print(f"\n[CONNECTED] Client from {client_address[0]}")

    try:
        data = client_socket.recv(4096).decode().strip()

        if not data:
            print("[WARNING] Empty data received")
            client_socket.close()
            continue

        print(f"[MORSE RECEIVED] {data}")

        decoded_message = decode_morse(data)
        print(f"[DECODED MESSAGE] {decoded_message}")

        cursor.execute(
            "INSERT INTO messages (client_ip, morse_code, decoded_message) VALUES (?, ?, ?)",
            (client_address[0], data, decoded_message)
        )
        conn.commit()

        print("[DATABASE] Message stored successfully")

        response = "ACK | Message decoded and stored successfully"
        client_socket.send(response.encode())

    except Exception as e:
        print("[ERROR]", e)

    finally:
        client_socket.close()
