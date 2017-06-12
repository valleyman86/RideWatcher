# RideWatcher

RideWatcher is an app to track a users location if they are traveling more than 10 MPH. It uses core data for its data store.

I added an additional feature to show the users the map of their trip. You can see it by clicking on a cell and it will expand.

## Notes
I used a few different design patterns in the app but the main one I stuck with was MVVM for separating data and logic from the
viewController and cells. I used dependency injection for the location tracking and I used delegates for communication back to 
the viewController. I also used protocols in as many places as I could to allow for easily extending viewModels. I used a singleton
for the LocationDispatcher.

My intent was to allow someone to not have to care about how the viewController displays data as long as it gives the viewController
the correct data. This mostly uses a fetchController and core data to populate a tableView but this could easily be changed to using
a server or a fileSytem (or other persistant data source) by just creating a new viewModel adhiring to the proper protocol. I would
have liked to use structs more but dealing with CoreData was kinda putting a damper on that.

The LocationDispatcher is a generic singleton that monitors location updates from the devices. This class basically wraps CLLocationManager
and allows you to send location updates to any class that follows the protocol. This prevents having to have authorization code everywhere
in the app that needs updates and also allows more than one class to use location services.

The GPSTracker class is just the logic behind automatic tracking and is intended to be created wherever it is needed (in this app 
that is one location).

### Possible Improvements

These are ideas for things about the internal design that could have been changed or maybe improved on with a bit more work.

- Use a protocol for the LocationDispatcher rather than pass it directly to the GPSTracker and then we could do a bit more mocking for use in testing.

- Create a way for the header in the nav bar to be set via storyboard.

- Replace CLLocation throughout with a more simple and direct type

- Create a datasource for the viewmodels rather than letting them handle data updates. This could be like using the same
  viewModel but changing where its data comes from (server or coredate for example). This app was small and it would have just
  been more abstraction.
  
 - Write tests where possible







