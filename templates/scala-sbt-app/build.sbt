ThisBuild / scalaVersion := "2.13.12"

ThisBuild / scalafixDependencies += "com.github.liancheng" %% "organize-imports" % "0.6.0"

lazy val V = new {
  val circe = "0.14.6"
  val cats = "2.10.0"
}

lazy val circeVersion = "0.14.6"

lazy val root =
  (project in file(".")).aggregate(annotations.jvm, schema, examples)

lazy val module0 = crossProject(JVMPlatform, JSPlatform)
  .in(file("module0"))
  .settings(
    name := "module0",
    scalacOptions -= "-Xfatal-warnings"
  )

lazy val module1 = project
  .in(file("module1"))
  .settings(
    name := "module1",
    libraryDependencies ++=
      Seq(
        "io.circe" %% "circe-generic" % V.circe,
        "io.circe" %% "circe-literal" % V.circe,
        "io.circe" %% "circe-parser" % V.circe,
        "org.typelevel" %% "cats-core" % V.cats,
        "org.scala-lang" % "scala-reflect" % scalaVersion.value
      ),
    scalacOptions -= "-Xfatal-warnings",
    scalacOptions += "-Ywarn-macros:after",
    scalacOptions += "-Ymacro-annotations"
  )
  .dependsOn(module0.jvm)

lazy val module2 = project
  .in(file("module2"))
  .settings(
    scalacOptions -= "-Xfatal-warnings"
  )
  .dependsOn(module1)
