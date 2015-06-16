xquery version "1.0-ml";

module namespace c = "http://marklogic.com/roxy/controller/examples";
	
import module namespace ch = "http://marklogic.com/roxy/controller-helper" at 
    "/roxy/lib/controller-helper.xqy";
    
import module namespace default = "http://marklogic.com/application/defaults" at 
    "/app/config/defaults.xqy";
    
import module namespace error = "http://marklogic.com/roxy/error-lib" at 
    "/app/views/helpers/error-lib.xqy";
    
import module namespace http = "http://www.w3.org/Protocols/rfc2616" at 
    "/app/lib/lib-http.xqy";
    
import module namespace m = "http://marklogic.com/roxy/model/examples" at 
    "/app/models/examples.xqy";

(: The request library provides awesome helper methods to abstract get-request-field :)
import module namespace req = "http://marklogic.com/roxy/request" at 
    "/roxy/lib/request.xqy";
    
    


(:
 : Default function that returns an error message.
 :)
(:declare function c:main() as item()*
{
  error:error-handling(405, error:http-response(405, fn:concat("Method Not Allowed: ", req:get("method")), ()))
};:)
    

declare function c:index()
{
  ()
};


declare function c:create()
{
  ()
};


declare function c:retrieve()
{
  (: return the photo with the given id :)
  let $id := req:get("id")
  let $format := req:get("format")
  let $debug := xdmp:log('[XQuery][Web3D][examples] retrieving: ' || $id || ' as ' || $format, 'debug')
  return
    ( http:ok(m:get-asset($id), (), ()),
      ch:use-view('examples/retrieve', $default:XML_EXTENSION),
      ch:use-layout('x3d', $format) )
      
};


declare function c:update()
{
  (: update the photo with the given id :)
  let $id := req:get("id")
  let $body := xdmp:get-request-body()
  return
    ()
};


declare function c:delete()
{
  (: delete the photo with the given id :)
  let $id := req:get("id")
  return
    ()
};