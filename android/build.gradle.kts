- name: Update app build.gradle
        run: |
          cat > android/app/build.gradle << 'EOF'
          plugins {
              id "com.android.application"
              id "kotlin-android"
              id "dev.flutter.flutter-gradle-plugin"
              id "com.google.gms.google-services"
          }
          android {
              namespace "com.company.storymotion_studio"
              compileSdk 34
              defaultConfig {
                  applicationId "com.company.storymotion_studio"
                  minSdk 21
                  targetSdk 34
                  versionCode 1
                  versionName "1.0.0"
                  multiDexEnabled true
              }
              compileOptions {
                  sourceCompatibility JavaVersion.VERSION_17
                  targetCompatibility JavaVersion.VERSION_17
              }
              kotlinOptions {
                  jvmTarget = "17"
              }
              buildTypes {
                  release {
                      signingConfig signingConfigs.debug
                  }
              }
          }
          flutter {
              source "../.."
          }
          dependencies {
              implementation platform("com.google.firebase:firebase-bom:33.0.0")
              implementation "com.google.firebase:firebase-analytics"
              implementation "com.google.firebase:firebase-auth"
              implementation "com.google.firebase:firebase-firestore"
              implementation "com.google.firebase:firebase-storage"
              implementation "androidx.multidex:multidex:2.0.1"
          }
          EOF
