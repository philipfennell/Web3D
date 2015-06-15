xquery version "1.0-ml" encoding "utf-8";

module namespace default = "http://marklogic.com/application/defaults";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

(:~ Supported Media Types. :)
declare variable $default:ATOM_MEDIA_TYPE as xs:string      := "application/atom+xml";
declare variable $default:ATOMCAT_MEDIA_TYPE as xs:string   := "application/atomcat+xml";
declare variable $default:ATOMSVC_MEDIA_TYPE as xs:string   := "application/atomsvc+xml";
declare variable $default:CSS_MEDIA_TYPE as xs:string 		  := "text/css";
declare variable $default:CSV_MEDIA_TYPE as xs:string       := "text/csv";
declare variable $default:XSLFO_MEDIA_TYPE as xs:string     := "application/fo+xml";
declare variable $default:FORM_DATA_MEDIA_TYPE as xs:string := "multipart/form-data";
declare variable $default:HTML_MEDIA_TYPE as xs:string      := "text/html";
declare variable $default:JPEG_MEDIA_TYPE as xs:string      := "image/jpeg";
declare variable $default:JS_MEDIA_TYPE as xs:string        := "text/javascript";
declare variable $default:JSON_MEDIA_TYPE as xs:string      := "application/json";
declare variable $default:OLD_XML_MEDIA_TYPE as xs:string   := "text/xml";
declare variable $default:PDF_MEDIA_TYPE as xs:string       := "application/pdf";
declare variable $default:PLAIN_TEXT_TYPE as xs:string      := "text/plain";
declare variable $default:PNG_MEDIA_TYPE as xs:string       := "image/png";
declare variable $default:SCH_MEDIA_TYPE as xs:string       := "application/sch+xml";
declare variable $default:SVG_MEDIA_TYPE as xs:string       := "image/svg+xml";
declare variable $default:XHTML_MEDIA_TYPE as xs:string     := "application/xhtml+xml";
declare variable $default:XML_MEDIA_TYPE as xs:string       := "application/xml";
declare variable $default:X3D_MEDIA_TYPE as xs:string       := "model/x3d+xml";
declare variable $default:X3DV_MEDIA_TYPE as xs:string      := "model/x3d-vrml";
declare variable $default:X3DB_MEDIA_TYPE as xs:string      := "model/x3d+fastinfoset";

(:~ Fallback when determining the preferred media type from the Accept header. :)
declare variable $default:MEDIA_TYPE as xs:string := $default:XML_MEDIA_TYPE;

declare variable $default:ATOM_EXTENSION as xs:string       := "atom";
declare variable $default:ATOMCAT_EXTENSION as xs:string    := "cats";
declare variable $default:ATOMSVC_EXTENSION as xs:string    := "svc";
declare variable $default:CSS_EXTENSION as xs:string        := "css";
declare variable $default:CSV_EXTENSION as xs:string        := "csv";
declare variable $default:HTML_EXTENSION as xs:string       := "html";
declare variable $default:JPEG_EXTENSION as xs:string       := "jpg";
declare variable $default:JS_EXTENSION as xs:string         := "js";
declare variable $default:JSON_EXTENSION as xs:string       := "json";
declare variable $default:PDF_EXTENSION as xs:string        := "pdf";
declare variable $default:PLAIN_TEXT_EXTENSION as xs:string := "txt";
declare variable $default:PNG_EXTENSION as xs:string        := "png";
declare variable $default:SCH_EXTENSION as xs:string        := "sch";
declare variable $default:SVG_EXTENSION as xs:string        := "svg";
declare variable $default:XHTML_EXTENSION as xs:string      := "xhtml";
declare variable $default:XML_EXTENSION as xs:string        := "xml";
declare variable $default:XSD_EXTENSION as xs:string        := "xsd";
declare variable $default:XSLFO_EXTENSION as xs:string      := "fo";
declare variable $default:XSLT_EXTENSION as xs:string       := "xsl";
declare variable $default:X3D_EXTENSION as xs:string        := "x3d";
declare variable $default:X3DV_EXTENSION as xs:string       := "x3dv";
declare variable $default:X3DB_EXTENSION as xs:string       := "x3db";

