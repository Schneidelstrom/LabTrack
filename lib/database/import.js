const admin = require('firebase-admin');
const fs = require('fs');

// 1. Load the Service Account Key
const serviceAccount = require('./labtrack.json');

// --- Configuration ---
// The path to your JSON data file (in the same folder)
const DATA_FILE_PATH = './users.json'; // Ensure this matches your filename
// The name of the collection in Firestore where the data will be stored
const COLLECTION_NAME = 'users'; 
// The JSON key to use as the unique Firestore Document ID
const ID_FIELD_NAME = 'sid'; 
// ---------------------

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // If using Realtime Database, uncomment and set your URL:
  // databaseURL: "https://YOUR-PROJECT-ID.firebaseio.com" 
});

const db = admin.firestore();

async function uploadData() {
  try {
    // 2. Read and parse the JSON file
    const fileContent = fs.readFileSync(DATA_FILE_PATH, 'utf8');
    const data = JSON.parse(fileContent);

    console.log(`Starting data upload to Firestore Collection: ${COLLECTION_NAME}...`);
    
    // Check for the expected array structure (using the top-level key)
    const transactions = data[COLLECTION_NAME];

    if (!transactions || !Array.isArray(transactions)) {
      console.error(`Error: JSON is not in the expected format. It must contain a top-level array with the key "${COLLECTION_NAME}".`);
      return;
    }

    const batch = db.batch();
    const collectionRef = db.collection(COLLECTION_NAME);
    let count = 0;

    // 3. Process each item in the array
    transactions.forEach((transaction) => {
      let docRef;
      const docId = transaction[ID_FIELD_NAME]; // *** CHANGE IS HERE: Use the ID_FIELD_NAME ***

      if (docId && typeof docId === 'string' && docId.trim().length > 0) {
        // Use the custom ID if it is a valid, non-empty string
        docRef = collectionRef.doc(docId); 
      } else {
        // If the ID is missing or invalid, generate an auto-ID instead
        docRef = collectionRef.doc(); 
        console.warn(`Item missing or invalid '${ID_FIELD_NAME}'. Using Auto-ID: ${docRef.id}`);
      }
      
      batch.set(docRef, transaction);
      count++;
    });

    // 4. Commit the batch write to Firestore
    await batch.commit();
    console.log(`\n✅ Successfully imported ${count} transactions to Firestore!`);

  } catch (error) {
    console.error('❌ An error occurred during the import process:', error.message);
  }
}

uploadData();
