// Load environment variables from .env file (for local development)
if (process.env.NODE_ENV !== "production") {
  require("dotenv").config();
}

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");
const Replicate = require("replicate");

admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

// Initialize Replicate client
// API token can be set via Firebase Functions config or environment variable
const replicateApiToken =
  functions.config().replicate?.api_token || process.env.REPLICATE_API_TOKEN;
const replicate = replicateApiToken
  ? new Replicate({ auth: replicateApiToken })
  : null;

/**
 * Get the latest version of a model if no version is specified
 * @param {string} modelIdentifier - Model identifier (e.g., "stability-ai/sdxl" or "stability-ai/sdxl:version-id")
 * @returns {Promise<string>} - Model identifier with version (e.g., "stability-ai/sdxl:version-id")
 */
async function getModelWithVersion(modelIdentifier) {
  // If model already has a version specified, return as-is
  if (modelIdentifier.includes(":")) {
    return modelIdentifier;
  }

  try {
    // Try to fetch the model details from Replicate
    // The API might accept the full identifier or require owner/name split
    let model;
    try {
      // First, try with the full model identifier (some SDK versions support this)
      model = await replicate.models.get(modelIdentifier);
    } catch (firstError) {
      // If that fails, try splitting into owner and name
      const parts = modelIdentifier.split("/");
      if (parts.length !== 2) {
        throw new Error(
          `Invalid model identifier format: ${modelIdentifier}. Expected format: owner/name`
        );
      }
      const [owner, name] = parts;
      model = await replicate.models.get(owner, name);
    }

    // Check if model has a latest version
    if (model && model.latest_version && model.latest_version.id) {
      const versionedModel = `${modelIdentifier}:${model.latest_version.id}`;
      console.log(
        `Resolved model ${modelIdentifier} to latest version: ${versionedModel}`
      );
      return versionedModel;
    }

    // If we can't get the latest version, return the model name as-is
    console.warn(
      `Could not get latest version for ${modelIdentifier}. Using as-is.`
    );
    return modelIdentifier;
  } catch (error) {
    // If we can't get the latest version, return the model name as-is
    console.warn(
      `Error fetching latest version for ${modelIdentifier}: ${error.message}. Using as-is.`
    );
    return modelIdentifier;
  }
}

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

// 2. Generate Wallpaper using Replicate API
exports.generateWallpaper = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be logged in."
    );
  }

  const { prompt, style, aspectRatio, model } = data;
  const uid = context.auth.uid;

  if (!prompt) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Prompt is required"
    );
  }

  // Check if Replicate is configured
  if (!replicate) {
    throw new functions.https.HttpsError(
      "failed-precondition",
      "Replicate API token is not configured. Please set REPLICATE_API_TOKEN environment variable."
    );
  }

  // Use provided model or default to stability-ai/sdxl
  let modelIdentifier = model || "stability-ai/sdxl";

  // Get the latest version if no version is specified
  const aiModel = await getModelWithVersion(modelIdentifier);

  try {
    // Build the prompt with style if provided
    let fullPrompt = prompt;
    if (style) {
      fullPrompt = `${prompt}, ${style} style`;
    }

    // Prepare input parameters for Replicate
    const input = {
      prompt: fullPrompt,
    };

    // Add aspect ratio if provided (format depends on model)
    if (aspectRatio) {
      // For SDXL and most models, aspect ratio is typically a string like "1:1", "16:9", etc.
      input.aspect_ratio = aspectRatio;
    }

    console.log(
      `Generating wallpaper with model: ${aiModel}, prompt: ${fullPrompt}`
    );

    // Call Replicate API to generate image
    const output = await replicate.run(aiModel, { input });

    // Replicate returns an array of URLs for image outputs
    let imageUrl;
    if (Array.isArray(output)) {
      imageUrl = output[0];
    } else if (typeof output === "string") {
      imageUrl = output;
    } else {
      throw new Error("Unexpected output format from Replicate");
    }

    if (!imageUrl) {
      throw new Error("No image URL returned from Replicate");
    }

    console.log(`Image generated at: ${imageUrl}`);

    // Download the image from Replicate
    const imageResponse = await axios.get(imageUrl, {
      responseType: "arraybuffer",
      timeout: 30000, // 30 second timeout
    });

    const imageBuffer = Buffer.from(imageResponse.data);
    const imageExtension = imageUrl.split(".").pop().split("?")[0] || "png";
    const fileName = `wallpapers/${uid}/${Date.now()}.${imageExtension}`;

    // Upload to Firebase Storage
    const bucket = storage.bucket();
    const file = bucket.file(fileName);

    await file.save(imageBuffer, {
      metadata: {
        contentType:
          imageResponse.headers["content-type"] || `image/${imageExtension}`,
        metadata: {
          generatedBy: "replicate",
          model: aiModel,
          prompt: prompt,
        },
      },
    });

    // Make the file publicly accessible
    await file.makePublic();

    // Get public URL
    const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;

    // Save metadata to Firestore
    const wallpaperRef = db.collection("wallpapers").doc();
    // await wallpaperRef.set({
    //   id: wallpaperRef.id,
    //   creatorId: uid,
    //   prompt: prompt,
    //   style: style || null,
    //   aspectRatio: aspectRatio || null,
    //   model: aiModel,
    //   imageUrl: publicUrl,
    //   thumbnailUrl: publicUrl, // You can generate a thumbnail later if needed
    //   downloads: 0,
    //   likes: 0,
    //   createdAt: admin.firestore.FieldValue.serverTimestamp(),
    // });

    // console.log(`Wallpaper saved with ID: ${wallpaperRef.id}`);

    return {
      success: true,
      wallpaperId: wallpaperRef.id,
      imageUrl: publicUrl,
      prompt: prompt,
    };
  } catch (error) {
    console.error("AI Generation Failed", error);

    // Provide more specific error messages
    if (error.message.includes("timeout")) {
      throw new functions.https.HttpsError(
        "deadline-exceeded",
        "Image generation timed out"
      );
    } else if (
      error.message.includes("authentication") ||
      error.message.includes("API")
    ) {
      throw new functions.https.HttpsError(
        "permission-denied",
        "Replicate API authentication failed"
      );
    } else {
      throw new functions.https.HttpsError(
        "internal",
        `Generation failed: ${error.message}`
      );
    }
  }
});

// 3. Download Handler (Reward Creator)
exports.onDownload = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "User must be logged in."
    );
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
    downloads: admin.firestore.FieldValue.increment(1),
  });

  // Credit Creator
  const creatorRef = db.collection("users").doc(creatorId);
  dbBatch.update(creatorRef, {
    coins: admin.firestore.FieldValue.increment(1), // 1 Coin per download
  });

  // Log Transaction
  const transactionRef = db.collection("transactions").doc();
  dbBatch.set(transactionRef, {
    userId: creatorId,
    amount: 1,
    type: "earning",
    source: "download",
    wallpaperId: wallpaperId,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  await dbBatch.commit();
  return { success: true };
});
