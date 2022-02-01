# cunning_document_scanner

A state of the art document scanner with automatic cropping function.

## Getting Started

Handle camera access permission

### **IOS**

Add a String property to the app's Info.plist file with the key NSCameraUsageDescription and the value as the description for why your app needs camera access.

	<key>NSCameraUsageDescription</key>
	<string>Camera Permission Description</string>

### **Android**

minSdkVersion should be at least 21


## How to use ?

```
    final imagesPath = await CunningDocumentScanner.getPicture()
```

The path's to the cropped Images will be returned.


## Contributing

### Step 1

- Fork this project's repo : 

### Step 2

-  Create a new pull request.



## License
This project is licensed under the MIT License - see the LICENSE.md file for details
