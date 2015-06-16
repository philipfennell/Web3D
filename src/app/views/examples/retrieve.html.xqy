xquery version "1.0-ml";

import module namespace vh = "http://marklogic.com/roxy/view-helper" at 
    "/roxy/lib/view-helper.xqy";

import module namespace default = "http://marklogic.com/application/defaults" at 
    "/app/config/defaults.xqy";

declare option xdmp:mapping "false";

declare variable $RESOURCE := vh:required("RESOURCE");


$RESOURCE
