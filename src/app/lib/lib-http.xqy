xquery version "1.0-ml";

(:~
 : HTTP library.
 : @author Philip Fennell
 : @version 0.1
 :)

module namespace http = "http://www.w3.org/Protocols/rfc2616";


(: The controller helper library provides methods to control which view and template get rendered :)
import module namespace ch = "http://marklogic.com/roxy/controller-helper" at 
    "/roxy/lib/controller-helper.xqy";


(:~
 : Sets an HTTP 200 'Ok' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:ok($resource as item()*, $resourceURI as xs:string?, 
    $contentType as xs:string?) 
{
  ( ch:add-value('RESOURCE', $resource),
    ch:add-value('res-code', 200),
    ch:add-value('res-message','Ok'),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()},
        ( if ($resourceURI) then 
            element Location {$resourceURI} 
          else () ),
        element Content-Type {$contentType}
      } ) )
};


(:~
 : Sets an HTTP 201 'Created' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:created($resource as node()*, $resourceURI as xs:string?, 
    $contentType as xs:string?) 
{
  ( ch:add-value('RESOURCE', $resource),
    ch:add-value('res-code', 201),
    ch:add-value('res-message','Created'),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()},
        element Location {$resourceURI},
        element Content-Type {$contentType}
      } ) )
};


(:~
 : Sets an HTTP 202 'Accepted' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:accepted($resource as node()*, $resourceURI as xs:string, 
    $contentType as xs:string) 
{
  ( ch:add-value('RESOURCE', $resource),
    ch:add-value('res-code', 202),
    ch:add-value('res-message','Accepted'),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()},
        element Content-Type {$contentType}
      } ) )
};


(:~
 : Sets an HTTP 204 'No Content' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:no-content($resource as node()*, $resourceURI as xs:string?, 
    $contentType as xs:string?) 
{
  ( ch:add-value('res-code', 204),
    ch:add-value('res-message','No Content'),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()}
      } ) )
};


(:~
 : Sets an HTTP 303 'See Other' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:see-other($resource as node()*, $resourceURI as xs:string?, 
    $contentType as xs:string?) 
{
  ( ch:add-value('res-code', 303),
    ch:add-value('res-message','See Other'),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()},
        element Location {$resourceURI}
      } ) )
};


(:~
 : Sets an HTTP 400 'Bad Request' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:bad-request($resource as node()*, $resourceURI as xs:string?, 
    $contentType as xs:string?, $message as xs:string?) 
{
  ( ch:add-value('RESOURCE', $resource),
    ch:add-value('res-code', 400),
    ch:add-value('res-message','Bad Request' || ' - ' || $message),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()}
      } ) )
};


(:~
 : Sets an HTTP 401 'Unauthorized' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:unauthorized($resource as node()*, $resourceURI as xs:string?, 
    $contentType as xs:string?) 
{
  ( ch:add-value('RESOURCE', $resource),
    ch:add-value('res-code', 401),
    ch:add-value('res-message','Unauthorized'),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()}
      } ) )
};


(:~
 : Sets an HTTP 404 'Not Found' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:not-found($resource as node()*, $resourceURI as xs:string?, 
    $contentType as xs:string?) 
{
  ( ch:add-value('res-code', 404),
    ch:add-value('res-message','Not Found'),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()}
      } ) )
};


(:~
 : Sets an HTTP 405 'Method Not Allowed' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:method-not-allowed($resource as node()*, $resourceURI as xs:string?, 
    $contentType as xs:string?) 
{
  ( ch:add-value('res-code', 405),
    ch:add-value('res-message','Method Not Allowed'),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()}
      } ) )
};


(:~
 : Sets an HTTP 400 'Conflict' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:conflict($resource as node()*, $resourceURI as xs:string?, 
    $contentType as xs:string?, $message as xs:string?) 
{
  ( ch:use-view('logs/create', 'html'),
    ch:use-layout('logs', 'html'),
    ch:add-value('RESOURCE', $resource),
    ch:add-value('res-code', 409),
    ch:add-value('res-message','Conflict' || ' - ' || $message),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()}
      } ) )
};


(:~
 : Sets an HTTP 500 'Internal Server Error' response.
 : @param $resource the resource to be returned in the response body.
 : @return Nothing.
 :)
declare function http:internal-server-error($resource as node()*, $resourceURI as xs:string?, 
    $contentType as xs:string?, $message as xs:string?) 
{
  ( ch:add-value('RESOURCE', $resource),
    ch:add-value('res-code', 500),
    ch:add-value('res-message','Internal Server Error' || ' - ' || $message),
    ch:add-value(
      'res-header', 
      element header {
        element Date {fn:current-dateTime()}
      } ) )
};


