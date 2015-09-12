package controllers

import play.api._
import play.api.mvc._
import play.api.Play.current
import play.api.libs.ws._
import scala.concurrent.Future
import scala.concurrent.ExecutionContext.Implicits.global
import org.joda.time.DateTime
import org.joda.time.format.DateTimeFormat
import java.util.Locale
import play.api.libs.json._
import play.api.libs.json.Reads._
import play.api.libs.functional.syntax._

class Application extends Controller {

  final val dateTimeFormatter = DateTimeFormat.forPattern("E, dd MMM yyyy HH:mm:ss 'GMT'").withLocale(Locale.ENGLISH).withZoneUTC()
  def dateString: String = dateTimeFormatter.print(new DateTime())

  def index = Action { implicit request =>
    Ok(views.html.index(dateString))
  }

  /*
	* CROSS DOMAIN REQUEST (XDR)
	*
	* We need to implement a local proxy that handles the original request information and send it to other domain.
	* It is due to jQuery AJAX doesn't let us to send it directly.
	*/

  case class RequestInfo(url: String, method: String, headers: Map[String, String], body: String)

  implicit val reqInfoReads: Reads[RequestInfo] = (
    (__ \ "url").read[String] and
    (__ \ "method").read[String] and
    (__ \ "headers").read[Map[String, String]] and
    (__ \ "body").read[String]
  )(RequestInfo.apply _)

  def crossDomainProxy = Action.async(parse.json) { implicit request =>
    request.body.validate[RequestInfo].fold(
      errors => Future.successful(BadRequest(JsString("Malformed Request Info"))),
      reqInfo => {
        val holder = WS.url(reqInfo.url).withRequestTimeout(10000).withHeaders(reqInfo.headers.toSeq: _*)
        val futureResponse = reqInfo.method match {
          case "GET" => holder.get()
          case "POST" => holder.post(reqInfo.body)
          case "PUT" => holder.put(reqInfo.body)
          case "PATCH" => holder.patch(reqInfo.body)
          case "DELETE" => holder.delete()
        }
        futureResponse.map { implicit response =>
          val js = if (response.body.length > 0) response.json else JsNull
          (response.status match {
            case 200 => if (js == JsNull) Ok else Ok(js)
            case 201 => if (js == JsNull) Created else Created(js)
            case 202 => if (js == JsNull) Accepted else Accepted(js)
            case 204 => NoContent
            case 400 => BadRequest(js)
            case 401 => Unauthorized(js)
            case 403 => Forbidden(js)
            case 404 => NotFound(js)
            case s if s > 400 && s < 500 => BadRequest(js)
            case 500 => InternalServerError(js)
          }).withHeaders(response.allHeaders.map(h => (h._1, h._2.mkString(","))).toSeq: _*)
        }
      }
    )
  }
}