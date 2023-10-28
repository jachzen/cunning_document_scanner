# cunning_document_scanner

A state of the art document scanner with automatic cropping function.

<img src="https://user-images.githubusercontent.com/1488063/167291601-c64db2d5-78ab-4781-bc7a-afe7eb93e083.png" height ="400" />
<img src="https://user-images.githubusercontent.com/1488063/167291821-3b66d0bb-b636-4911-a572-d2368dc95012.jpeg" height ="400" />
<img src="https://user-images.githubusercontent.com/1488063/167291827-fa0ae804-1b81-4ef4-8607-3b212c3ab1c0.jpeg" height ="400" />


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
    final imagesPath = await CunningDocumentScanner.getPicture(true)
```

The path's to the cropped Images will be returned.


## Contributing

### Step 1

- Fork this project's repo : 

### Step 2

-  Create a new pull request.



## License
This project is licensed under the MIT License - see the LICENSE.md file for details
