lazy val scala3 = "3.3.1"

ThisBuild / scalaVersion := scala3

lazy val V = new {
  val circe = "0.14.6"
  val cats = "2.12.0"
  val fs2 = "3.10.2"
  val catsEffect = "3.5.4"
  val kittens = "3.2.0"
  val literally = "1.1.0"
  val mouse = "1.3.0"
  val catsTime = "0.5.1"
  val scalaJavaTime = "2.5.0"
}

lazy val root =
  (project in file(".")).aggregate(module0.jvm, module1, module2)

lazy val module0 = crossProject(JVMPlatform, JSPlatform)
  .in(file("module0"))
  .settings(
    name := "module0",
    scalacOptions -= "-Xfatal-warnings",
    libraryDependencies ++= Seq(
      "io.github.cquiroz" %%% "scala-java-time" % V.scalaJavaTime
    )
  )

lazy val module1 = project
  .in(file("module1"))
  .settings(
    name := "module1",
    libraryDependencies ++=
      Seq(
        "io.circe" %% "circe-core" % V.circe,
        "io.circe" %% "circe-generic" % V.circe,
        "io.circe" %% "circe-literal" % V.circe,
        "io.circe" %% "circe-parser" % V.circe,
        "org.typelevel" %% "cats-core" % V.cats,
        "org.typelevel" %% "cats-effect" % V.catsEffect,
        "co.fs2" %% "fs2-core" % V.fs2,
        "co.fs2" %% "fs2-io" % V.fs2,
        "org.typelevel" %% "kittens" % V.kittens,
        "org.typelevel" %% "cats-time" % V.catsTime,
        "org.typelevel" %% "literally" % V.literally
      ),
    scalacOptions -= "-Xfatal-warnings"
  )
  .dependsOn(module0.jvm)

lazy val module2 = project
  .in(file("module2"))
  .settings(
    scalacOptions -= "-Xfatal-warnings"
  )
  .dependsOn(module1)
