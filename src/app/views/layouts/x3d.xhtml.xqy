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

import module namespace vh = "http://marklogic.com/roxy/view-helper" at 
    "/roxy/lib/view-helper.xqy";

declare variable $view as item()* := vh:get("view");
declare variable $title as xs:string? := (vh:get('title'), "Untitled")[1];


xdmp:add-response-header('content-type', 'application/xhtml+xml; charset=UTF-8'),
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta http-equiv="X-UA-Compatible" content="chrome=1" />
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
    <link rel="shortcut icon" href="/images/web3d/X3DtextIcon16.png" title="X3D" />
    <link rel="stylesheet" type="text/css" href="/lib/x3dom/x3dom.css" />
    <script type="text/javascript" src="/lib/x3dom/x3dom-full.js"></script>
  </head>
  <body>
    <h1>{$title}</h1>
    {$view}
  </body>
</html>