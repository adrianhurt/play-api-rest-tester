name := """play-api-rest-tester"""

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.11.7"

scalacOptions ++= Seq("-feature", "-deprecation", "-unchecked", "-language:reflectiveCalls", "-language:postfixOps", "-language:implicitConversions")

resolvers += "scalaz-bintray" at "http://dl.bintray.com/scalaz/releases"

pipelineStages := Seq(rjs)

RjsKeys.mainModule := "main"

doc in Compile <<= target.map(_ / "none")

scalariformSettings

libraryDependencies ++= Seq(
  cache,
  ws,
  specs2 % Test,
  "org.webjars" % "jquery" % "3.1.0",
  "org.webjars" % "bootstrap" % "3.3.7-1" exclude("org.webjars", "jquery"),
  "org.webjars" % "requirejs" % "2.3.1",
	"org.webjars" % "jquery-jsonview" % "1.2.2" exclude("org.webjars", "jquery")
)