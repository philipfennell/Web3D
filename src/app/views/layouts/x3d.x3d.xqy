(:
Copyright 2012-2015 MarkLogic Corporation

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
:)
xquery version "1.0-ml";
    
import module namespace default = "http://marklogic.com/application/defaults" at 
    "/app/config/defaults.xqy";
    
import module namespace vh = "http://marklogic.com/roxy/view-helper" at 
    "/roxy/lib/view-helper.xqy";

declare variable $view as item()* := vh:get("view");


( xdmp:add-response-header('content-type', $default:X3D_MEDIA_TYPE || '; charset=UTF-8'),
  $view )