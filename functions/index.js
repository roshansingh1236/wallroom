const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();

const db = admin.firestore();

// 1. Create User on Auth Signup
exports.createUserDocument = functions.auth.user().onCreate(async (user) => {
  try {
    const userRef = db.collection("users").doc(user.uid);
    await userRef.set({
      uid: user.uid,
      email: user.email || "",
      displayName: user.displayName || "Anonymous",
      photoURL: user.photoURL || "",
      coins: 10, // Initial bonus
      isAnonymous: user.providerData.length === 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    console.log(`User document created for ${user.uid}`);
  } catch (error) {
    console.error("Error creating user document", error);
  }
});

// 2. Generate Wallpaper (Mock AI Call)
exports.generateWallpaper = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be logged in.");
  }

  const { prompt, style, aspectRatio } = data;
  const uid = context.auth.uid;

  // TODO: Check daily limits or coin balance if paid
  // TODO: Actual API Call to Stable Diffusion / OpenAI
  // const response = await axios.post('API_URL', { ... });
  
  // Checking Ad revenue verification would happen here if we used Server-Side Verification (SSV) tokens
  // For now, we trust the client triggered the ad (Basic)

  try {
    // MOCKED RESPONSE
    const mockImageUrl = `https://picsum.photos/seed/${Math.floor(Math.random() * 1000)}/1080/1920`; // Random Portrait
    
    // Save metadata to Firestore
    const wallpaperRef = db.collection("wallpapers").doc();
    await wallpaperRef.set({
      id: wallpaperRef.id,
      creatorId: uid,
      prompt: prompt,
      style: style,
      aspectRatio: aspectRatio,
      imageUrl: mockImageUrl, // In real app, upload blob to Firebase Storage first
      thumbnailUrl: mockImageUrl,
      downloads: 0,
      likes: 0,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, wallpaperId: wallpaperRef.id, imageUrl: mockImageUrl };
  } catch (error) {
    console.error("AI Generation Failed", error);
    throw new functions.https.HttpsError("internal", "Generation failed");
  }
});

// 3. Download Handler (Reward Creator)
exports.onDownload = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
     throw new functions.https.HttpsError("unauthenticated", "User must be logged in.");
  }
  
  const { wallpaperId, creatorId } = data;
  
  // Prevent self-download rewards
  if (creatorId === context.auth.uid) {
    return { success: true, message: "Own wallpaper downloaded" };
  }

  const dbBatch = db.batch();

  // Increment download count
  const wallpaperRef = db.collection("wallpapers").doc(wallpaperId);
  dbBatch.update(wallpaperRef, {
    downloads: admin.firestore.FieldValue.increment(1)
  });

  // Credit Creator
  const creatorRef = db.collection("users").doc(creatorId);
  dbBatch.update(creatorRef, {
    coins: admin.firestore.FieldValue.increment(1) // 1 Coin per download
  });

  // Log Transaction
  const transactionRef = db.collection("transactions").doc();
  dbBatch.set(transactionRef, {
    userId: creatorId,
    amount: 1,
    type: "earning",
    source: "download",
    wallpaperId: wallpaperId,
    createdAt: admin.firestore.FieldValue.serverTimestamp()
  });

  await dbBatch.commit();
  return { success: true };
});
