const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

// ==========================================
// 1. CALLABLE CLOUD FUNCTION
// ==========================================
/**
 * A simple callable function that greets a user
 * Can be invoked directly from Flutter app
 */
exports.sayHello = functions.https.onCall((data, context) => {
  console.log("sayHello function called with data:", data);

  const name = data.name || "User";
  const message = `Hello, ${name}! Welcome to EduTrack!`;

  return {
    success: true,
    message: message,
    timestamp: new Date().toISOString(),
  };
});

/**
 * A callable function that logs user activity
 * Stores the activity in Firestore and returns summary
 */
exports.logUserActivity = functions.https.onCall(async (data, context) => {
  try {
    console.log("logUserActivity function called with data:", data);

    // Check if user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError(
        "unauthenticated",
        "User must be authenticated to log activity"
      );
    }

    const userId = context.auth.uid;
    const { activityType, description } = data;

    if (!activityType) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "activityType is required"
      );
    }

    // Store activity in Firestore
    const db = admin.firestore();
    const activityRef = db.collection("activities").doc();

    await activityRef.set({
      userId: userId,
      activityType: activityType,
      description: description || "",
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      userEmail: context.auth.token.email || "unknown",
    });

    console.log(`Activity logged for user ${userId}: ${activityType}`);

    return {
      success: true,
      message: "Activity logged successfully",
      activityId: activityRef.id,
      timestamp: new Date().toISOString(),
    };
  } catch (error) {
    console.error("Error in logUserActivity:", error);
    throw new functions.https.HttpsError("internal", error.message);
  }
});

// ==========================================
// 2. EVENT-BASED CLOUD FUNCTION (Firestore Trigger)
// ==========================================
/**
 * Trigger: Firestore document creation in 'users' collection
 * This function runs automatically when a new user is created
 */
exports.onNewUserCreated = functions.firestore
  .document("users/{userId}")
  .onCreate(async (snap, context) => {
    try {
      const userId = context.params.userId;
      const data = snap.data();

      console.log(`New user created: ${userId}`, data);

      // 1. Initialize user profile with additional fields
      const db = admin.firestore();
      const userRef = db.collection("users").doc(userId);

      await userRef.update({
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        profileComplete: false,
        activityCount: 0,
        lastLogin: null,
        status: "active",
      });

      console.log(`User profile initialized for ${userId}`);

      // 2. Create a welcome activity log
      await db.collection("activities").add({
        userId: userId,
        activityType: "account_created",
        description: "User account created",
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Welcome activity logged for user ${userId}`);

      return null;
    } catch (error) {
      console.error("Error in onNewUserCreated:", error);
      return null;
    }
  });

/**
 * Trigger: Firestore document update in 'courses' collection
 * This function runs when a course document is updated
 * Use case: Notify enrolled students when course info changes
 */
exports.onCourseUpdated = functions.firestore
  .document("courses/{courseId}")
  .onUpdate(async (change, context) => {
    try {
      const courseId = context.params.courseId;
      const beforeData = change.before.data();
      const afterData = change.after.data();

      console.log(`Course updated: ${courseId}`);
      console.log("Before:", beforeData);
      console.log("After:", afterData);

      // Log the change
      const db = admin.firestore();
      await db.collection("course_changes").add({
        courseId: courseId,
        courseName: afterData.name || "Unknown",
        changes: {
          titleChanged: beforeData.title !== afterData.title,
          descriptionChanged:
            beforeData.description !== afterData.description,
          updatedFields: Object.keys(afterData).filter(
            (key) => beforeData[key] !== afterData[key]
          ),
        },
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log(`Course update logged for ${courseId}`);

      return null;
    } catch (error) {
      console.error("Error in onCourseUpdated:", error);
      return null;
    }
  });

/**
 * Trigger: Firestore document deletion in 'users' collection
 * This function runs when a user is deleted
 * Clean up associated data
 */
exports.onUserDeleted = functions.firestore
  .document("users/{userId}")
  .onDelete(async (snap, context) => {
    try {
      const userId = context.params.userId;
      const userData = snap.data();

      console.log(`User deleted: ${userId}`, userData);

      // Clean up user's related data
      const db = admin.firestore();

      // Delete user's activities
      const activities = await db
        .collection("activities")
        .where("userId", "==", userId)
        .get();

      activities.forEach((doc) => {
        db.collection("activities").doc(doc.id).delete();
      });

      console.log(`Cleaned up ${activities.size} activities for user ${userId}`);

      // Log deletion
      await db.collection("deleted_users").add({
        userId: userId,
        email: userData.email || "unknown",
        name: userData.name || "Unknown",
        deletedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      return null;
    } catch (error) {
      console.error("Error in onUserDeleted:", error);
      return null;
    }
  });

console.log("EduTrack Cloud Functions initialized successfully!");
