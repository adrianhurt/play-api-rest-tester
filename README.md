# Play API REST Tester [Play 2.5 - Scala]

This is a companion project to test the example template [Play API REST Template](https://github.com/adrianhurt/play-api-rest-seed). It's ready to test every call of the API and lets you visualize all the data and headers.

Run first the API server (port 9000 as default):

    [play-api-rest-seed] $ run

Then run the tester on other port:

    [play-api-rest-tester] $ run -Dhttp.port=8999

Within your browser, go to `http://localhost:8999/` and play with the API.

To customize it and set your own prepared requests for your API calls, you only have to modify the `requests.coffee` file.

And please, don't forget starring this project if you consider it has been useful for you.


Also check my other projects:

* [Play-Bootstrap - Play library for Bootstrap [Scala & Java]](https://adrianhurt.github.io/play-bootstrap)
* [Play Multidomain Seed [Play 2.5 - Scala]](https://github.com/adrianhurt/play-multidomain-seed)
* [Play Silhouette Credentials Seed [Play 2.5 - Scala]](https://github.com/adrianhurt/play-silhouette-credentials-seed)
* [Play Multidomain Auth [Play 2.5 - Scala]](https://github.com/adrianhurt/play-multidomain-auth)