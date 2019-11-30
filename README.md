# somfy-ux-sound
Testing UX sound feedbacks for Somfy home automation Apps.
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=lzilber_somfy-ux-sound&metric=alert_status)](https://sonarcloud.io/dashboard?id=lzilber_somfy-ux-sound)

## Sound UX in Apps

### Why do we need sound for our Apps ?

When using two or more sensory channels (five senses of sight, sound, touch, smell and taste) to send information, we are more likely to gain our receiver's attention.

Sounds provide subtle feedback. In the communication between an App and a Home automation system, simple sound effects convey a more effective sense of the asynchronous nature of commands and feebacks.
They advantageously replace graphical UX elements like spinners or popups.

"Auditory" icons re-enforce the "physicality" of the interaction of the End User with the home.

And obviously sounds provide better accessibility.

### SwiftUI, sounds and the SF Symbols library 

This project uses the SwiftUI framework of declarative App interface to provide a simple visual user experience.
The goal is to focus on sounds. However a limited set of product category icons is provided by using symbols from the SF Symbols library (see the image in the  `CategoryLogo` view ) .

## SwiftUI and the Model

### Authentication

The `Session` is the main object of the model. 

This _ObservableObject_ manages the authentication state, the house information and the data provider (the `FishingRod` instance for API calls). 
Based on the authentication state of the Session, the SwiftUI `ContentView` displays either the `Home` view or the `Login` view.

Upon succesful Login, the Session is updated to use the selected server. 
The Session is stored in the view hierarchy (`@EnvironmentObject`) for usage in SwiftUI views. 
 
 ### Demo mode
 
 The demo mode uses a `DemoFishingRod` to load the JSON data of the house from a local file instead of making a call to the API. 

