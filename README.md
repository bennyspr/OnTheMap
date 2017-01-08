# OnTheMap

This iPhone app allows users to share their location and a URL with their fellow students. To visualize this data, On The Map uses a map with pins for location and pin annotations for student names and URLs, allowing students to place themselves “on the map,” so to speak. 
First, the user logs in to the app using their Udacity username and password. After login, the app downloads locations and links previously posted by other students. These links can point to any URL that a student chooses.
After viewing the information posted by other students, a user can post their own location and link. The locations are specified with a string and forward geocoded. They can be as specific as a full street address or as generic as “Costa Rica” or “Seattle, WA.”

### Prerequisites
In order to use the app you need to replace the following strings on the Constant.swift file: FACEBOOK_APP_ID, APPLICATION_ID, and REST_API_KEY.
```
struct Constant {
    struct Udacity {
        static let baseURL = "https://www.udacity.com/api/"
        static let facebookAppID = "FACEBOOK_APP_ID"
        static let signupURL = "https://www.udacity.com/account/auth#!/signup"
    }
    struct Parse {
        static let baseURL = "https://parse.udacity.com/parse/classes/"
        static let applicationID = "APPLICATION_ID"
        static let restAPIKey = "REST_API_KEY"
    }
}
```

<br><b>IDE:</b> Xcode 8.1+
<br><b>Language:</b> Swift 3
<br><b>iOS Deployment Target:</b> 9.2
<table>
<tr>
<td>
<kbd>
<img src="https://bennyspr.com/img/github/onTheMap/Simulator_Screen_Shot_1.png" width="300">
</kbd>
</td>
<td>
<kbd>
<img src="https://bennyspr.com/img/github/onTheMap/Simulator_Screen_Shot_2.png" width="300">
</kbd>
</td>
</tr>
<tr>
<td>
<kbd>
<img src="https://bennyspr.com/img/github/onTheMap/Simulator_Screen_Shot_3.png" width="300">
</kbd>
</td>
<td>
<kbd>
<img src="https://bennyspr.com/img/github/onTheMap/Simulator_Screen_Shot_4.png" width="300">
</kbd>
</td>
</tr>
<tr>
<td>
<kbd>
<img src="https://bennyspr.com/img/github/onTheMap/Simulator_Screen_Shot_5.png" width="300">
</kbd>
</td>
</tr>
</table>
