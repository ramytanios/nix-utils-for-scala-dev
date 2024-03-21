package module0

object Main extends App {

  sealed trait Position

  object Position {
    case object Junior extends Position
    case object Senior extends Position
  }

  case class Employee(name: String = "ramy", age: Int, position: Option[Position])

}
