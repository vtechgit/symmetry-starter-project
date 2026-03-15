# Firebase Firestore Backend
In this folder are all the [Firebase Firestore](https://firebase.google.com/docs/firestore) related files. 
You will use this folder to add the schema of the *Articles* you want to upload for the app and to add the rules that enforce this schema. 

## DB Schema
**TODO: ADD YOUR DB SCHEMA (SCHEMA FOR "ARTICLES" AND ANY OTHER SCHEMAS) HERE**

## Getting Started
Before starting to work on the backend, you must have a Firebase project with the [Firebase Firestore](https://firebase.google.com/docs/firestore), [Firebase Cloud Storage](https://firebase.google.com/docs/storage) and [Firebase Local Emulator Suite](https://firebase.google.com/docs/emulator-suite) technologies enabled.
To do this, create a project but enable only Firebase Cloud Storage, Firebase Firestore, and Firebase Local Emulator Suite technologies.


## Deploying the Project
In order to deploy the Firestore rules from this repository to the [Firebase console](https://firebase.google.com/)  of your project, follow these steps:

### 1. Install firebase CLI
```
npm install -g firebase-tools
```
### 2. Login to your account
```
firebase login
```

### 3. Add your project id to the .firebasesrc file 
This corresponds to the project Id of the firebase project you created in the Firebase web-app.
[Change project id](.firebaserc)

### 4. Initialize the project
```
firebase init
```

You should leave everything as it is, choose:
- emulators
- firestore
- cloud storage

### 5. Deploy to firebase
```
firebase deploy
```
This will deploy all the rules you write in `firestore.rules` to your Firebase Firestore project.
Be careful becasuse it will overwrite the existing firestore.rules file of your project.

### 6. Apply Storage CORS configuration

Firebase Storage blocks image requests from the browser by default. You must apply the CORS policy once per Firebase project so that the Flutter Web app can load article thumbnails.

First, install the Google Cloud SDK if you don't have it (includes `gsutil`):
- [Download Google Cloud SDK](https://cloud.google.com/sdk/docs/install)

Then authenticate and apply the config:
```
gcloud auth login
gsutil cors set storage.cors.json gs://<your-project-id>.firebasestorage.app
```

Replace `<your-project-id>` with your Firebase project ID (same as in `.firebaserc`).

To verify it was applied:
```
gsutil cors get gs://<your-project-id>.firebasestorage.app
```

> This step is required only once per Firebase project. The `storage.cors.json` file in this folder contains the policy.

## Running the project in a local emulator
To run the application locally, use the following command:

```firebase emulators:start```
