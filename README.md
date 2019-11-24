# somfy-ux-sound
Testing UX sound feedbacks for Somfy home automation Apps.

## SwiftUI and the Model

The `Session` is the main object of the model. 

This _ObservableObject_ manages the authentication state, the house information and the data provider (the `FishingRod` instance for API calls). 
Based on the authentication state of the Session, the SwiftUI `ContentView` displays either the `Home` view or the `Login` view.

Upon succesful Login, the Session is updated to use the selected server. 
The Session is stored in the view hierarchy (`@EnvironmentObject`) for usage in SwiftUI views. 
 
