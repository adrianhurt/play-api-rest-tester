name := """play-api-rest-tester"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.11.6"

libraryDependencies ++= Seq(
  jdbc,
  cache,
  ws,
  specs2 % Test,
	"org.webjars" % "jquery" % "2.1.4",
	"org.webjars" % "bootstrap" % "3.3.5" exclude("org.webjars", "jquery"),
	"org.webjars" % "requirejs" % "2.1.19"
)

resolvers += "scalaz-bintray" at "http://dl.bintray.com/scalaz/releases"

// Play provides two styles of routers, one expects its actions to be injected, the
// other, legacy style, accesses its actions statically.
routesGenerator := InjectedRoutesGenerator

pipelineStages := Seq(rjs)
RjsKeys.mainModule := "main"

scalariformSettings
