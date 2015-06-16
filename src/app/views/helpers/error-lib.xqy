xquery version "1.0-ml";

module namespace error = "http://marklogic.com/roxy/error-lib";

(: the controller helper library provides methods to control which view and template get rendered :)
import module namespace ch = "http://marklogic.com/roxy/controller-helper" at "/roxy/lib/controller-helper.xqy";

(: The request library provides awesome helper methods to abstract get-request-field :)
import module namespace req = "http://marklogic.com/roxy/request" at "/roxy/lib/request.xqy";

declare namespace err = "http://marklogic.com/xdmp/error";


(:~
 : Converts a standard MarkLogic error fragment into a simpler XML error fragment.
 : @param $error to be normalised.
 : @return simplifed error XML fragment
 :)
declare function error:normalise($error as element(err:error)) 
    as element(errors) 
{
  xdmp:xslt-invoke('/app/resources/xslt/errors.xsl', document { $error }, ())/errors
}; 


(:~
 : Builds an error message fragment for an HTTP error response.
 : @param $errorCode    HTTP response code
 : @param $errorPhrase  
 : @param $errorDetails 
 :)
declare function error:http-response($errorCode as xs:unsignedInt, $errorPhrase, $errorDetails as item()?) 
    as element() 
{
  <errors>
    <error type="HTTP" name="{$errorPhrase}" code="{fn:string($errorCode)}">
      <message>{$errorDetails}</message>
    </error>
  </errors>
}; 


(:~
 : Error handler function that takes a result XML structure as input and creates
 : error header information.
 : 
 : @param $error XML that contains the error details
 :)
declare function error:error-handling($error as item())
{
  xdmp:log($error),
  error:error-handling(500, $error)
};


(:~
 : Error handler function that creates error header information from given input
 : parameter.
 : 
 : @param $errorCode HTTP error number
 : @param $errorMessage HTTP error message
 :)
declare function error:error-handling( $errorCode as xs:unsignedInt, $errorMessage as item())
{
  ( ch:add-value("res-code", $errorCode),
    ch:add-value("res-message", $errorMessage),
    map:put($req:request,"format","xml"),
    ch:use-view("service-description/error", "xml") )
};
