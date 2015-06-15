xquery version "1.0-ml";

module namespace m = "http://marklogic.com/roxy/model/examples";

import module namespace c = "http://marklogic.com/roxy/config" at "/app/config/config.xqy";
    
import module namespace default = "http://marklogic.com/application/defaults" at 
    "/app/config/defaults.xqy";
    
declare variable $m:BASE_URI as xs:string := "/examples"; 


(:~
 : 
 : @param $document ID.
 : @param $document file format e.g. x3d, html, ...
 : @return the requested document or an empty sequence.
 :)
declare function m:get-asset($id as xs:string, $format as xs:string) 
    as document-node()? 
{
  let $uri as xs:string := $m:BASE_URI || '/' || $format || '/' || $id || '.' || $format
  return
    doc($uri)
}; 