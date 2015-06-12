<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright (c) 1995-2015 held by the author(s).  All rights reserved.
                          
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer
      in the documentation and/or other materials provided with the
      distribution.
    * Neither the names of the Naval Postgraduate School (NPS)
      Modeling Virtual Environments and Simulation (MOVES) Institute
      (http://www.nps.edu and http://www.MovesInstitute.org)
      nor the names of its contributors may be used to endorse or
      promote products derived from this software without specific
      prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
-->

<!--
    Document   : X3dSchematronValidityChecks.sch
    Created on : 19 October 2008
    Author     : Don Brutzman
    Description: define rules for X3D schematron validation testing
    References : TODO - ISO spec and references, schematron site, short cut, etc.

Rule TODOs:

ROUTE event typing
Component checks per X3D version number
X3D v3.3 nodes
Ensure DEF/USE only used by same type of node
Triangle and quad counting checks, including -1 sentinel
CAD, H-Anim parent-child relationships
containerField checks
ROUTE field matching
ProtoInstance fieldValue matching, especially "quoted" MFString types
check for comment immediately beginning with - or including double -
check for TimeSensor unable to start
check for proper escape characters in url (this needs to be in X3D-Edit also)
    http://bugzilla.xj3d.org/show_bug.cgi?id=514
Anchor url='#ViewpointName' points to existing Viewpoint DEF="ViewpointName"
colorPerVertex counting checks
check NurbsSet only points to proper nodes
add rules for Savage Modeling Analysis Language (SMAL) templates

utilize document() to check referenced documents
- url links each point to something that exists
- ExternProtoDeclare url links have #, includ and point to existing named ProtoDeclare
- Anchor url.x3d#ViewpointName points to url.x3d Viewpoint DEF="ViewpointName"
- check Inline IMPORT/EXPORT

Geospatial:
- ensure lat/long or UTM coordinates within bounds for given geoSystem
- check for mixed modes?  maybe GeoViewpoint inside another geo node, etc.?

<!DOCTYPE schema PUBLIC "http://www.ascc.net/xml/schematron"
   "http://www.ascc.net/xml/schematron/schematron1-5.dtd" [
-->

<!DOCTYPE schema [
    <!-- convenience macros -->
    <!ENTITY NodeDEFname          "&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt;">
    <!ENTITY NamedNodeDEFname     "&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt;">
    <!ENTITY TextNodeDEFname      "&lt;<name/> DEF='<value-of select='@DEF'/>' string='<value-of select='@string'/>'/&gt;">
    <!ENTITY WorldInfoNodeDEFname "&lt;<name/> DEF='<value-of select='@DEF'/>' info='<value-of select='@info'/>'/&gt;">
]>
<!--
<!DOCTYPE X3D PUBLIC "ISO//Web3D//DTD X3D 3.0//EN" "http://www.web3d.org/specifications/x3d-3.0.dtd">
<X3D profile='Core' version='3.0' xmlns:xsd='http://www.w3.org/2001/XMLSchema-instance' xsd:noNamespaceSchemaLocation='http://www.web3d.org/specifications/x3d-3.0.xsd'>

xmlns:xsi="http://www.w3.org/2000/10/XMLSchema-instance"
       xsi:schemaLocation="http://www.ascc.net/xml/schematron
          http://www.ascc.net/xml/schematron/schematron1-5.xsd"

<schema xmlns:xsi="http://www.w3.org/2000/10/XMLSchema-instance" xsi:schemaLocation="http://www.ascc.net/xml/schematron/schematron1-5.xsd">
-->
<schema xmlns="http://purl.oclc.org/dsdl/schematron">
  <title>X3D Graphics Validity Checks using Schematron</title>
  <!--<ns prefix="sch" uri="http://purl.oclc.org/dsdl/schematron"/>-->

  <pattern>
    <!-- ========= abstract: DEF, USE tests ========== -->
    <rule id="DEFtests" abstract="true">
      <let name="DEF" value="@DEF"/>
      <let name="USE" value="@USE"/>
      <let name="USEparentProtoName"  value="ancestor::ProtoDeclare/@name"/>
      <let name="DEFnode"      value="//*[@DEF=$USE]"/>
      <let name="NodeName"     value="local-name()"/>
      <let name="DEFNodeName"  value="local-name(//*[@DEF=$USE])"/>
      <let name="DEFparentProtoNode"  value="//ProtoDeclare[ProtoBody/descendant::*[@DEF=$USE]]"/>
      <let name="DEFparentProtoName"  value="$DEFparentProtoNode/@name"/>
      <extends rule="classTest"/>
      <report test="(@USE) and (string-length(@USE) > 0) and *" role="error">&lt;<name/> USE='<value-of select="@USE"/>'/&gt; USE elements cannot have any child nodes </report>
      <!-- empty @DEF or only single @DEF defined -->
      <assert test="not($DEF) or (count(//*[@DEF=$DEF]) = 1)" role="error">&NodeDEFname; has duplicated DEF </assert>
      <!-- no embedded space or quotation marks in @DEF or @USE    -->
      <assert test="not(contains($DEF,' '))" role="error">&NodeDEFname; has embedded space character(s) in DEF name </assert>
      <assert test="not(contains($DEF,'&quot;'))" role="error">&NodeDEFname; has embedded quotation mark(s) in DEF name </assert>
      <assert test="not(contains($USE,' '))" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt;  has embedded space character(s) in USE name </assert>
      <assert test="not(contains($USE,'&quot;'))" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; has embedded quotation mark(s) in USE name </assert>
      <!-- avoid reserved words.  TODO where does this rule exist?  Not found in X3D Specification 4.4.3 DEF/USE semantics -->
      <assert test="(($DEF!='AS') and ($DEF!='component') and ($DEF!='DEF') and ($DEF!='EXPORT') and ($DEF!='FALSE') and ($DEF!='false') and ($DEF!='') and
                     ($DEF!='head') and ($DEF!='IMPORT') and ($DEF!='initializeOnly') and ($DEF!='inputOnly') and ($DEF!='outputOnly') and ($DEF!='inputOutput') and
                     ($DEF!='IS') and ($DEF!='meta') and ($DEF!='NULL') and ($DEF!='PROTO') and ($DEF!='ROUTE') and ($DEF!='Scene') and ($DEF!='TO') and
                     ($DEF!='TRUE') and ($DEF!='true') and ($DEF!='USE') and ($DEF!='X3D'))
                    or not(@DEF)" role="error">&NodeDEFname; has DEF name that illegally overrides a reserved word from the X3D Specification </assert>
      <!-- cannot have both DEF and USE attributes -->
      <report test="@DEF and @USE" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' USE='<value-of select='@USE'/>'/&gt; cannot contain both DEF and USE in single node </report>
      <!-- USE must follow @DEF definition -->
      <assert test="not($DEF) or (count(preceding::*[@USE=$DEF]) = 0)" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; found prior USE='<value-of select='@DEF'/>' node that precedes this DEF node </assert>
      <report test="(@USE) and (count(//*[@DEF=$USE]) = 0)" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; USE node has no matching DEF node </report>
      <report test="(@USE) and (count(//*[@DEF=$USE]) = 1) and (count(preceding::*[@USE=$DEF]) > 0)" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; found USE node that precedes matching DEF node </report>
      <report test="(@USE) and (ancestor::*[@DEF=$USE]) and (local-name(..)!='field') and (local-name(..)!='fieldValue')" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; USE node cannot have matching DEF node as direct ancestor or parent, instead must be directed acyclic graph </report>
      <!-- USE must not have contained children -->
      <assert test="not(@USE) or not(*)" role="error">&lt;<name/> USE='<value-of select='@USE'/>'&gt; &lt;<value-of select='local-name(*[1])'/>/&gt; &lt;/<name/>&gt; USE node must not contain any child nodes </assert>
      <!-- USE must not have DEF as a direct ancestor (i.e. DEF node cannot contain a USE copy of itself, except for Script fields) -->
      <assert test="not(@USE) or (local-name(../..)='Script' and local-name(..)='field') or (count(ancestor::*[@DEF=$USE]) = 0)" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; USE node cannot be contained child descendant of its DEF node </assert>
      <!-- DEF and USE must both be outside ProtoDeclare or in same ProtoDeclare scope -->
      <!-- test for DEF/USE node match TODO apparently not working..-->
      <report test="(@USE) and (not($NodeName=$DEFNodeName) and (string-length($NodeName) > 0) and (string-length($DEFNodeName) > 0))" role="error">&lt;<value-of select='$NodeName'/> USE='<value-of select='@USE'/>'/&gt; node type must match node type of original &lt;<value-of select='$DEFNodeName'/> DEF='<value-of select='//*[@DEF=$USE]/@DEF'/>'/&gt; </report>
      <report test="(string-length(@USE) > 0) and (count(//*[@DEF=$USE]) = 1) and not($USEparentProtoName=$DEFparentProtoName) and (($USEparentProtoName) or ($DEFparentProtoName))" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; DEF and USE must both be outside ProtoDeclare or within same ProtoDeclare scope ($USEparentProtoName=<value-of select='$USEparentProtoName'/>, $DEFparentProtoName=<value-of select='$DEFparentProtoName'/>) </report>
      <report test="(@DEF) and ancestor::StaticGroup" role="warning">&lt;<value-of select='$NodeName'/> DEF='<value-of select='@DEF'/>'/&gt; cannot ROUTE or USE this DEF node because it is found inside of ancestor &lt;StaticGroup DEF='<value-of select='ancestor::StaticGroup/@DEF'/>'/&gt; (since any child nodes may get refactored inside StaticGroup) </report>
      <report test="(@USE) and ancestor::StaticGroup" role="error">&lt;<value-of select='$NodeName'/> USE='<value-of select='@USE'/>'/&gt; cannot USE this node because it is found inside of ancestor &lt;StaticGroup DEF='<value-of select='ancestor::StaticGroup/@DEF'/>'/&gt; (since any child nodes may get refactored inside StaticGroup) </report>
      <report test="(@USE) and (count(//*[@DEF=$USE]) = 0) and (count(//*[lower-case(@DEF)=lower-case($USE)]) > 0)" role="error">&lt;<value-of select='$NodeName'/> USE='<value-of select='@USE'/>'/&gt; USE value has mismatched case with corresponding &lt;<value-of select='local-name(//*[lower-case(@DEF)=lower-case($USE)])'/> DEF='<value-of select='//*[lower-case(@DEF)=lower-case($USE)]/@DEF'/>'/&gt;, best practice is to avoid dependencies on case sensitivity of DEF/USE names </report>
      <!-- TODO probably can't test for lack of other attributes since too many defaults exist
      <assert test="not(@USE) or not(@*[not(local-name()='USE') and not(local-name()='containerField')])" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; must not contain any other attributes besides containerField </assert>
      -->
      <!-- TODO test for legal characters, both from X3D and XML perspective, such as first character a number -->
      <!-- TODO test for DEF/USE from inside ProtoBody to outside ProtoBody -->
    </rule>

    <!-- ========= abstract: class ========== -->
    <rule id="classTest" abstract="true">
      <assert test="not(contains(@class,',')) and not(contains(@class,';'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' class='<value-of select="@class"/>' cannot contain commas or semicolons, instead separate class names using space characters </assert>
      <assert test="not(contains(@class,'/')) and not(contains(@class,'\')) and not(contains(@class,'*')) and not(contains(@class,'!')) and not(contains(@class,'@')) and not(contains(@class,'#')) and not(contains(@class,'$')) and not(contains(@class,'%')) and not(contains(@class,'&amp;'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' class='<value-of select="@class"/>' has type NMTOKENS and cannot contain illegal characters </assert>
    </rule>

    <!-- ========= abstract: X3Dversion3.3Deprecated ========== -->
    <rule id="X3Dversion3.3Deprecated" abstract="true">
      <assert test="(/X3D/@version='3.0') or (/X3D/@version='3.1') or (/X3D/@version='3.2')" role="error">&NodeDEFname; is deprecated in X3D version='<value-of select='/X3D/@version'/> and cannot be included. &NodeDEFname; is legal in lower versions but can be ignored.' </assert>
      <report test="(/X3D/@version='3.0') or (/X3D/@version='3.1') or (/X3D/@version='3.2')" role="warning">&NodeDEFname; is deprecated in X3D version 3.3. &NodeDEFname; is legal for version='<value-of select='/X3D/@version'/> but can be ignored.' </report>
    </rule>

    <!-- ========= abstract: X3Dversion3.4 ========== -->
    <rule id="X3Dversion3.4" abstract="true">
      <assert test="(/X3D/@version='3.4')" role="error">&NodeDEFname; requires X3D version 3.4, but found version='<value-of select='/X3D/@version'/>' </assert>
    </rule>
    <!-- TODO ensure all v3.3 nodes are covered -->

    <!-- ========= abstract: X3Dversion3.3 ========== -->
    <rule id="X3Dversion3.3" abstract="true">
      <assert test="(/X3D/@version='3.3') or (/X3D/@version='3.4')" role="error">&NodeDEFname; requires X3D version 3.3 or greater, but found version='<value-of select='/X3D/@version'/>' </assert>
    </rule>

    <!-- ========= abstract: X3Dversion3.2 ========== -->
    <rule id="X3Dversion3.2" abstract="true">
      <assert test="(/X3D/@version='3.2') or (/X3D/@version='3.3') or (/X3D/@version='3.4')" role="error">&NodeDEFname; requires X3D version 3.2 or greater, but found version='<value-of select='/X3D/@version'/>' </assert>
    </rule>

    <!-- ========= abstract: X3Dversion3.1 ========== -->
    <rule id="X3Dversion3.1" abstract="true">
      <assert test="(/X3D/@version='3.1') or (/X3D/@version='3.2') or (/X3D/@version='3.3') or (/X3D/@version='3.4')" role="error">&NodeDEFname; requires X3D version 3.1 or greater, but found version='<value-of select='/X3D/@version'/>' </assert>
    </rule>
    
    <!-- ========= abstract: noDEF ========== -->
    <rule id="noDEF" abstract="true">
      <!-- Not an X3D node, no fields, thus no attributes -->
      <assert test="not(@DEF)" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; but this element is not allowed to have a DEF attribute </assert>
      <assert test="not(@USE)" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; but this element is not allowed to have a USE attribute </assert>
    </rule>

    <!-- ========= abstract: NoChildNode ========== -->
    <rule id="NoChildNode" abstract="true">
      <assert test="not(*) or (IS and (count(*) = 1)) or (*[starts-with(name(),'Metadata')] and (count(*) = 1)) or (IS and *[starts-with(name(),'Metadata')] and (count(*) = 2)) or (ProtoInstance and (count(*) = 1))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; element has illegal child node (only single Metadata* node is allowed) </assert>
      <!-- TODO test contained metadata has proper containerField -->
    </rule>

    <!-- ========= abstract: NotX3dChildNode ========== -->
    <rule id="NotX3dChildNode" abstract="true">
      <report test="parent::Scene or parent::Anchor or parent::Billboard or parent::Collision or parent::Group or parent::StaticGroup or parent::LOD or parent::Switch or parent::Transform or parent::EspduTransform " role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; element has illegal parent node (<value-of select='local-name(..)'/>) </report>
    </rule>

    <!-- ========= abstract: NeedsChildNode ========== -->
    <rule id="NeedsChildNode" abstract="true">
      <!-- this warning can be silenced by contained comment -->
      <assert test="*[not(local-name()='ExternProtoDeclare') and not(local-name()='ProtoDeclare') and not(local-name()='ROUTE')] or (string-length(@USE) > 0) or (local-name(..)='LOD') or (local-name(..)='Switch') or comment() or ((local-name()='Group') and *[(local-name()='ExternProtoDeclare') or (local-name()='ProtoDeclare') or (local-name()='ROUTE')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; element has no child node </assert>
    </rule>

    <!-- ========= abstract: Metadata ========== -->
    <rule id="Metadata" abstract="true">
      <extends rule="DEFtests"/>
      <extends rule="recommendedName"/>
      <!-- Confirm that metadata node has containerField='value' if parent is MetadataSet, otherwiser containerField='metadata' -->
      <assert test="(@containerField='metadata') or (                                 @containerField='value') or not(@containerField) or (string-length(@containerField) = 0) " role="error">&NamedNodeDEFname; containerField='<value-of select='@containerField'/>' but must be containerField='metadata' (default), or else containerField='value' when parent node is MetadataSet </assert>
      <report test="   (parent::MetadataSet) and not((@containerField='metadata') or (@containerField='value') or not(@containerField) or (string-length(@containerField) = 0))" role="error">&NamedNodeDEFname; containerField='<value-of select='@containerField'/>' can only have containerField='metadata' or containerField='value' when parent node is MetadataSet </report>
      <report test="not(parent::MetadataSet) and     (@containerField='value')" role="error">&NamedNodeDEFname; containerField='<value-of select='@containerField'/>' is only allowed when parent node is MetadataSet </report>
      <!-- TODO consider checking reference field -->
    </rule>

    <!-- ========= abstract: boundingBoxTests ========== -->
    <rule id="boundingBoxTests" abstract="true">
      <let name="bboxSize"          value="normalize-space(translate(@bboxSize, ',',' '))"/>
      <let name="bboxCenter"        value="normalize-space(translate(@bboxCenter,',',' '))"/>
      <let name="bboxSizeCount"     value="string-length($bboxSize)    - string-length(translate($bboxSize,  ' ','')) + 1"/>
      <let name="bboxCenterCount"   value="string-length($bboxCenter)  - string-length(translate($bboxCenter,' ','')) + 1"/>
      <let name="bboxSizeResidue"   value="translate($bboxSize,        '+-0123456789Ee., ','')"/>
      <let name="bboxCenterResidue" value="translate($bboxCenter,      '+-0123456789Ee., ','')"/>
      <assert test="not(@bboxSize)   or (string-length($bboxSize)   = 0) or ($bboxSizeCount   = 0) or ($bboxSizeCount   = 3)"  role="error">&NodeDEFname; has illegal number of values (<value-of select='$bboxSizeCount'/>) in bboxSize field </assert>
      <assert test="not(@bboxCenter) or (string-length($bboxCenter) = 0) or ($bboxCenterCount = 0) or ($bboxCenterCount = 3)"  role="error">&NodeDEFname; has illegal number of values (<value-of select='$bboxCenterCount'/>) in bboxCenter field </assert>
      <assert test="string-length($bboxSizeResidue)   = 0" role="error">&NodeDEFname; has illegal character <value-of select='$bboxSizeResidue'/> in bboxSize field </assert>
      <assert test="string-length($bboxCenterResidue) = 0" role="error">&NodeDEFname; has illegal character <value-of select='$bboxCenterResidue'/> in bboxCenter field </assert>
      <assert test="($bboxSize = '-1 -1 -1') or ($bboxSize = '-1. -1. -1.') or ($bboxSize = '-1.0 -1.0 -1.0') or ($bboxSize = '-1E0 -1E0 -1E0') or ($bboxSize = '-1.0E0 -1.0E0 -1.0E0') or not(contains($bboxSize,'-')) or contains($bboxSize,'E-')" role="error">&NodeDEFname; bboxSize='<value-of select='@bboxSize'/>' must not include negative values unless using sentinel value '-1 -1 -1' (which indicates that no bounding box hint provided, X3D player can compute value)</assert>
    </rule>

    <!-- ========= abstract: sizeTests ========== -->
    <rule id="sizeTests" abstract="true">
      <!-- derived from boundingBoxTests -->
      <let name="size"          value="normalize-space(translate(@size, ',',' '))"/>
      <let name="sizeCount"     value="string-length($size)    - string-length(translate($size,  ' ','')) + 1"/>
      <let name="sizeResidue"   value="translate($size,        '+-0123456789Ee., ','')"/>
      <assert test="not(@size)   or (string-length($size)   = 0) or ($sizeCount   = 0) or ($sizeCount   = 3)"  role="error">&NodeDEFname; has illegal number of values (<value-of select='$sizeCount'/>) in size field </assert>
      <assert test="string-length($sizeResidue)   = 0" role="error">&NodeDEFname; has illegal character <value-of select='$sizeResidue'/> in size field </assert>
      <report test="contains($size,'-') and not(contains($size,'E-') or contains($size,'e-'))" role="error">&NodeDEFname; size='<value-of select='@size'/>' must not include negative values </report>
    </rule>

    <!-- ========= abstract: requiredName ========== -->
    <rule id="requiredName" abstract="true">
      <let name="name" value="@name"/>
      <let name="nodeName" value="local-name()"/>
      <assert test="($name and string-length($name) > 0) or @USE" role="error">&NodeDEFname; is required to have a name field </assert>
      <report test="($name and string-length($name) > 0) and @USE" role="error">&NodeDEFname; is a USE node and should not include a name field </report>
      <report test="(following::*[local-name() = $nodeName][@name = $name])" role="error">&NodeDEFname; has the same name='<value-of select='@name'/>' as a following <name/> node </report>
      <report test="(preceding::*[local-name() = $nodeName][@name = $name])" role="error">&NodeDEFname; has the same name='<value-of select='@name'/>' as a preceding <name/> node </report>
      <!-- X3D Specification does not require checking for uniqueness, might not make sense anyway -->
      <!-- TODO inconsistency problem in ProtoInstance DTD, schema for USE instances -->
    </rule>

    <!-- ========= abstract: recommendedName ========== -->
    <rule id="recommendedName" abstract="true">
      <assert test="@name or @USE" role="warning">&NodeDEFname; is recommended to have a name field </assert>
      <report test="@name and @USE" role="error">&NodeDEFname; is a USE node and should not include a name field </report>
      <!-- X3D Specification does not require checking for uniqueness among name values, might not make sense anyway -->
    </rule>

    <!-- ========= abstract: optionalName ========== -->
    <rule id="optionalName" abstract="true">
      <assert test="@name or @USE or IS/connect" role="info">&NodeDEFname; does not have a name field </assert>
      <report test="@name and @USE" role="error">&NodeDEFname; is a USE node and should not include a name field </report>
      <!-- X3D Specification does not require checking for uniqueness, might not make sense anyway -->
    </rule>

    <!-- ========= abstract: uniqueName ========== -->
    <rule id="uniqueName" abstract="true">
      <let name="nameAttribute" value="@name"/>
      <assert test="@USE or  (@name and (string-length(@name) > 0) and not(preceding::*[@name = $nameAttribute]) and not(following::*[@name = $nameAttribute]))" role="error">&NodeDEFname; name='<value-of select='@name'/>' is not unique </assert>
      <report test="@USE and (@name and  string-length(@name) > 0)" role="error">&NodeDEFname; is a USE node and should not include a name field </report>
    </rule>

    <!-- ========= abstract: hasUrl ========== -->
    <rule id="hasUrl" abstract="true">
      <!-- some of these rules are modified to run in ExternProtoDeclare, which cannot test @USE -->
      <let name="url"          value="normalize-space(translate(@url, ',',' '))"/>
      <let name="urlCount"     value="string-length($url)    - string-length(translate($url,  ' ','')) + 1"/>
      <let name="stringResidueApos" value="translate(@url,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="stringResidue" value='translate($stringResidueApos,"&apos;","")'/>
      <let name="quoteCount" value="string-length($stringResidue)"/>
      <let name="normalizedStringUrl" value="normalize-space(@url)"/>
      <let name="lastCharacter" value="substring($normalizedStringUrl,string-length($normalizedStringUrl))"/>
      <let name="initialUrl" value="substring-before(substring-after(@url,'&quot;'),'&quot;')"/>
      <let name="remainingUrls" value="substring-after(@url,$initialUrl)"/>
      <!-- TODO match node name for preceding url match -->
      <report test="not(local-name()='Anchor') and (string-length($normalizedStringUrl) > 0) and preceding::*[normalize-space(@url) = $normalizedStringUrl] and (count(preceding::*[local-name()=$NodeName][normalize-space(@url) = $normalizedStringUrl]) > 0)" role="warning">&NodeDEFname; url array address(es) duplicate the url definition found in a preceding node, consider DEF/USE to reduce download delays and memory requirements for url content (url='<value-of select='@url'/>') </report>
      <assert test="@USE or @url or boolean(IS/connect[@nodeField='url']) or (local-name()='Script') or contains(local-name(),'Shader')" role="error">&NodeDEFname; has no value(s) in url='' array </assert>
      <assert test="($urlCount  &gt; 0)"  role="error">&NodeDEFname; has illegal number of values in url array (url='<value-of select='@url'/>') </assert>
      <assert test="not(contains($url,'&quot;&quot;'))"  role="error">&NodeDEFname; url array has adjacent &quot;quote marks&quot; unseparated by other characters (url='<value-of select='@url'/>') </assert>
      <report test="(@url) and not(@USE) and not(contains(@url,'http')) and not((local-name()='Anchor') and contains(@url,'#')) and not((local-name()='Script') and contains(@url,'ecmascript:'))" role="info">&NodeDEFname; url array address(es) missing online http/https references (url='<value-of select='@url'/>') </report>
      <report test="contains(substring-after(@url,'.wrl&quot;'),'.x3d&quot;') or contains(substring-after(@url,'.wrl#'),'.x3d#')" role="warning">&NodeDEFname; url array has .wrl scene reference before .x3d scene reference (url='<value-of select='@url'/>')</report>
      <report test="contains(@url,'\')" role="error">&NodeDEFname; url array contains backslash \ character(s) (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,'&quot;/')" role="warning">&NodeDEFname; url array contains contains entry starting at root directory / (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,':///')" role="warning">&NodeDEFname; url array contains triple forward-slash :/// characters (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,'file:/')" role="warning">&NodeDEFname; url array contains file:/ local address, not portable across Web servers (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,'http:/')  and not(contains(@url,'http://'))"  role="warning">&NodeDEFname; url array contains http:/ rather than http:// (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,'https:/') and not(contains(@url,'https://'))" role="warning">&NodeDEFname; url array contains https:/ rather than https:// (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,':/') and not(contains(@url,'://')) and not(contains(@url,'http://')) and not(contains(@url,'https://'))" role="warning">&NodeDEFname; url array contains :/ rather than :// (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,'.wrl') and not(contains(@url,'.x3d'))" role="warning">&NodeDEFname; url array contains .wrl link without corresponding .x3d version, some browsers may fail (url='<value-of select='@url'/>') </report>
      <report test="not(@USE) and contains($normalizedStringUrl,'&quot;&quot;') and not($normalizedStringUrl='&quot;&quot;') and not(contains($normalizedStringUrl,'\&quot;&quot;') or contains($normalizedStringUrl,'&quot;\&quot;') or contains($normalizedStringUrl,'&quot;&quot; &quot;') or contains($normalizedStringUrl,'&quot; &quot;&quot;'))"  role="error">&TextNodeDEFname; string array has questionable line-break &quot;&quot; quote marks (url='<value-of select='@url'/>') </report>
      <report test="not(@USE) and (@url) and not(contains(@url,'&quot;'))"    role="error">&NodeDEFname; url string array needs to begin and end with &quot;quote marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' url=&apos;&quot;<value-of select='(@url)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@url) and    (contains(@url,'&quot;')) and (($quoteCount div 2)!=round($quoteCount div 2)) and not(contains(@url,'\&quot;'))"    role="error">&NodeDEFname; string array has <value-of select='($quoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) (url='<value-of select='@url'/>') </report>
      <report test="not(@USE) and (@url) and (contains(@url,'\&quot;'))"    role="warning">&NodeDEFname; has <value-of select='($quoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched (url='<value-of select='@url'/>') </report>
      <report test="not(@USE) and ($normalizedStringUrl) and not(starts-with($normalizedStringUrl,'&quot;')) and not($lastCharacter='&quot;') and (contains(@url,'&quot;'))"    role="error">&NodeDEFname; array of string values needs to begin and end with &quot;quote marks&quot; (url='<value-of select='@url'/>') </report>
      <report test="not(@USE) and ($normalizedStringUrl) and not(starts-with($normalizedStringUrl,'&quot;')) and    ($lastCharacter='&quot;')"                                     role="error">&NodeDEFname; array of string values needs to begin with quote mark &quot; (url='<value-of select='@url'/>') </report>
      <report test="not(@USE) and ($normalizedStringUrl) and    (starts-with($normalizedStringUrl,'&quot;')) and not($lastCharacter='&quot;')"                                     role="error">&NodeDEFname; array of string values needs to end with quote mark &quot; (url='<value-of select='@url'/>') </report>
      <!-- trace: MFString array checks -->
      <report test="false()" role="trace">$quoteCount=<value-of select='$quoteCount'/>, $stringResidue=<value-of select='$stringResidue'/>, $stringResidueApos=<value-of select='$stringResidueApos'/> , $lastCharacter=<value-of select='$lastCharacter'/> </report>
      <!-- case mismatch with initial url value - TODO problem with fn:
      <report test="contains(fn:lower-case($remainingUrls),fn:lower-case($initialUrl)) and not(contains($remainingUrls,$initialUrl))" role="error">&TextNodeDEFname; file and directory names in similar url array entries must match case (url='<value-of select='@url'/>') </report>
      -->
      <!-- TODO check for duplicate array entries using regex -->
    </rule>

    <!-- ========= abstract: nameNotReservedWord (for ProtoDeclare, ExternProtoDeclare, ProtoInstance) ========== -->
    <rule id="nameNotReservedWord" abstract="true">
      <assert test="@name" role="error">&lt;<value-of select='local-name()'/> DEF='<value-of select='@DEF'/>'> must have name </assert>
      <assert test="((@name!='AS') and (@name!='component') and (@name!='DEF') and (@name!='EXPORT') and (@name!='FALSE') and (@name!='false') and (@name!='') and
                     (@name!='head') and (@name!='IMPORT') and (@name!='initializeOnly') and (@name!='inputOnly') and (@name!='outputOnly') and (@name!='inputOutput') and
                     (@name!='IS') and (@name!='meta') and (@name!='NULL') and (@name!='PROTO') and (@name!='ROUTE') and (@name!='Scene') and (@name!='TO') and
                     (@name!='TRUE') and (@name!='true') and (@name!='USE') and (@name!='X3D'))" role="error">&lt;<value-of select='local-name()'/> name='<value-of select='@name'/>' DEF='<value-of select='@DEF'/>'/&gt; has name that illegally overrides a reserved word from the X3D Specification </assert>
    </rule>

    <!-- ========= abstract: fieldNameNotReservedWord (for field, fieldValue) ========== -->
    <rule id="fieldNameNotReservedWord" abstract="true">
      <let name="fieldLabel" value="concat('&lt;',local-name(..),' name=&quot;',../@name,'&quot; DEF=&quot;',../@DEF,'&quot;&gt; &lt;',local-name(),' name=&quot;',@name,'&quot;')"/>
      <assert test="not(@name) or
                    ((@name!='AS') and (@name!='component') and (@name!='DEF') and (@name!='EXPORT') and (@name!='FALSE') and (@name!='false') and (@name!='') and
                     (@name!='head') and (@name!='IMPORT') and (@name!='initializeOnly') and (@name!='inputOnly') and (@name!='outputOnly') and (@name!='inputOutput') and
                     (@name!='IS') and (@name!='meta') and (@name!='NULL') and (@name!='PROTO') and (@name!='ROUTE') and (@name!='Scene') and (@name!='TO') and
                     (@name!='TRUE') and (@name!='true') and (@name!='USE') and (@name!='X3D'))" role="error"><value-of select='$fieldLabel'/>/&gt; has name that illegally overrides a reserved word from the X3D Specification </assert>
      <report test="(@value='TRUE')"  role="error"><value-of select='$fieldLabel'/> value='<value-of select='@value'/>'/&gt; contains boolean constant TRUE, use lower-case 'true' instead to match XML rules </report>
      <report test="(@value='FALSE')" role="error"><value-of select='$fieldLabel'/> value='<value-of select='@value'/>'/&gt; contains boolean constant FALSE, use lower-case 'false' instead to match XML rules </report>
    </rule>

    <!-- ========= abstract: NoLodSwitchParent ========== -->
    <rule id="NoLodSwitchParent" abstract="true">
      <assert test="not(ancestor::LOD)" role="error">&NodeDEFname; description='<value-of select='@description'/>' behavior not guaranteed as child (or descendant) of LOD node, use ViewpointGroup instead of LOD </assert>
      <assert test="not(ancestor::Switch)" role="error">&NodeDEFname; description='<value-of select='@description'/>' behavior not guaranteed as child (or descendant) of Switch node, use ViewpointGroup instead of LOD </assert>
    </rule>

    <!-- ========= abstract: creaseAngle ========== -->
    <rule id="creaseAngle" abstract="true">
      <report test="contains(@creaseAngle,'-')" role="info">&NodeDEFname; creaseAngle='<value-of select='@creaseAngle'/>' cannot be negative </report>
    </rule>

    <!-- ========= abstract: descriptionTests ========== -->
    <rule id="descriptionTests" abstract="true">
      <let name="description"     value="normalize-space(@description)"/>
      <!-- TimeSensor and other listed sensors do not include description field, or are not draggable -->
      <assert test="@description or (@USE) or boolean(IS/connect/@nodeField='description') or (local-name()='TimeSensor') or (local-name()='ProximitySensor') or (local-name()='TransformSensor') or (local-name()='VisibilitySensor') or (local-name()='KeySensor') or (local-name()='StringSensor') or (local-name()='LoadSensor') or (local-name()='Viewpoint') or (local-name()='AudioClip')" role="warning">&NodeDEFname; missing description.  Example: description='touch to activate' </assert>
      <report test="(local-name()='Viewpoint') and (string-length(@description) &lt; 1) and not(@USE) and not(boolean(IS/connect/@nodeField='description'))" role="warning">&NodeDEFname; missing description, which is needed for usability.  Example: description='default view, rotate to examine object' </report>
      <report test="(local-name()='AudioClip') and (string-length(@description) &lt; 1) and not(@USE) and not(boolean(IS/connect/@nodeField='description'))" role="warning">&NodeDEFname; missing description, which is needed for usability.  Example: description='AudioClip sound of ___ is playing...' </report>
      <assert test="not(@description = @DEF) or (string-length(@description) = 0)" role="hint">&NodeDEFname; description should be different than DEF, provide a descriptive phrase for description instead </assert>
      <assert test="contains(@description,' ') or (string-length(@description) &lt; 14) or (@description = @DEF) or (@description = //meta[@content='title']/@value)" role="hint">&NodeDEFname; description='<value-of select='@description'/>' can include space characters in description </assert>
      <report test="starts-with(normalize-space($description),'&quot;') or ends-with(normalize-space($description),'&quot;')" role="hint">&NodeDEFname; description='<value-of select='@description'/>' does not need wrapper quotes</report>
    </rule>

    <!-- ========= abstract: enabledTests ========== -->
    <rule id="enabledTests" abstract="true">
      <report test="(@enabled='false') and not(//ROUTE[@toNode=$DEF][(@toField='enabled') or (@toField='set_enabled')] or (IS/connect[nodeField='enabled']))" role="warning">&NodeDEFname; is inactive since enabled='false' (and no ROUTE is provided to change this value) </report>
      <report test="(@enabled='TRUE' )" role="error">&NodeDEFname; enabled='TRUE' is incorrect, define enabled='true' instead</report>
      <report test="(@enabled='FALSE')" role="error">&NodeDEFname; enabled='FALSE' is incorrect, define enabled='false' instead</report>
    </rule>

    <!-- ========= X3D ========== -->
    <rule context="X3D">
      <let name="xsltVersion"     value="system-property('xsl:version')"/>
      <let name="xsltVendor"      value="system-property('xsl:vendor')"/>
      <extends rule="noDEF"/>
      <extends rule="profileTests"/>
      <!-- Debug statement: set test="true()" to enable, test="false()" to disable -->
      <report test="false()" role="diagnostic">XSLT stylesheet information:  xsl:version=<value-of select='$xsltVersion'/>, xsl:vendor=<value-of select='$xsltVendor'/> </report>
      <!-- TODO check for presence and correctness of DTD -->
      <!-- TODO check for presence and correctness of stylesheet PI -->
      <assert test="@version" role="error">X3D root element must include version number. </assert>
      <assert test="(@version='3.0') or (@version='3.1') or (@version='3.2') or (@version='3.3') or (@version='3.4')" role="error">X3D version must be 3.0, 3.1, 3.2, 3.3 or 3.4 </assert>
      <!-- X3D version 3.0, 3.1, 3.2, 3.3, 3.4 checks for illegal nodes handled on node-by-node basis -->
      <!-- TODO xmlns -->
    </rule>

    <!-- ========= Scene ========== -->
    <rule context="Scene">
      <extends rule="noDEF"/>
    </rule>

    <!-- ========= head, meta ========== -->
    <rule context="head">
      <let name="title"       value="meta[@name='title']/@content"/>
      <let name="identifier"  value="meta[@name='identifier']/@content"/>
      <let name="created"     value="meta[@name='creator']/@created"/>
      <let name="modified"    value="meta[@name='creator']/@modified"/>
      <let name="translated"  value="meta[@name='creator']/@translated"/>
      <extends rule="noDEF"/>
      <report test="meta/@content[starts-with(.,'*enter')]" role="warning">Update all meta tag(s) with content='*enter new value...'</report>
      <assert test="(meta/@name='title')" role="warning">Missing X3D filename in meta tag, should appear as &lt;meta name='title' content='FileName.x3d'/&gt; </assert>
      <assert test="(meta/@name='identifier')" role="warning">url for X3D file should appear in &lt;meta name='identifier' content='http://someAddress/somePath/FileName.x3d'/&gt; </assert>
      <report test="(meta/@name='identifier') and (string-length($title) > 0) and not(contains($identifier, $title))" role="warning">X3D/head/meta title (i.e. filename '<value-of select='$title'/>') is expected at end of identifier (url) value </report>
      <assert test="(string-length($identifier)=0) or starts-with($identifier, 'http://') or starts-with($identifier, 'https://')" role="warning">X3D/head/meta identifier (url) content should start with http:// or 'https:// </assert>
      <assert test="(meta/@name='creator')" role="info">Missing name of X3D scene author in meta tag, add &lt;meta name='creator' content='Author Name'/&gt; </assert>
      <assert test="(meta/@name='description')" role="info">Missing X3D scene description in meta tag, should appear as &lt;meta name='description' content='topic sentence plus good summary'/&gt; </assert>
      <assert test="(meta/@name='generator')" role="info">It is good practice to identify editor used, for example &lt;meta name='generator' content='X3D-Edit, https://savage.nps.edu/X3D-Edit'/&gt; </assert>
      <!-- TODO regex for ## Month #### -->
    </rule>

    <!-- Report all meta errors, warnings, hints and info as diagnostics -->
    <rule context="meta[(@name='error') or (@name='warning') or (@name='hint') or (@name='info')]">
      <report test="true()" role="diagnostic">&lt;meta name='<value-of select='@name'/>' content='<value-of select='@content'/>'/&gt;</report>
      <assert test="@content" role="error">&lt;meta name='<value-of select='@name'/>' content=''/> is missing required value for content</assert>
    </rule>

    <rule context="meta">
      <assert test="@content" role="error">&lt;meta name='<value-of select='@name'/>' content=''/> is missing required value for content</assert>
      <assert test="@name or @http-equiv"    role="error">&lt;meta name='<value-of select='@name'/>' content='<value-of select='@content'/>'/> is missing required value for name (or possibly http-equiv)</assert>
      <report test="@name and @http-equiv"   role="error">&lt;meta name='<value-of select='@name'/>' http-equiv='<value-of select='@http-equiv'/>'/>'/> meta name and http-equiv attributes cannot both be provided at one time, only use one (together with an optional content attribute)</report>
      <report test="(@name='image')"  role="warning">&lt;meta name='<value-of select='@name'/>' content='<value-of select='@content'/>'/> capitalization mismatch, use keyword name='Image' </report>
      <report test="(@name='movingImage') or (@name='movingimage')"  role="warning">&lt;meta name='<value-of select='@name'/>' content='<value-of select='@content'/>'/> capitalization mismatch, use keyword name='MovingImage' </report>
      <report test="(@name='sound')"  role="warning">&lt;meta name='<value-of select='@name'/>' content='<value-of select='@content'/>'/> capitalization mismatch, use keyword name='Sound' </report>
    </rule>

    <!-- ========= component ========== -->
    <rule context="component">
      <extends rule="noDEF"/>
      <!-- check for legal level values for each component -->
      <!-- TODO note these values are for X3D v3.2 and do not include checks for X3D version differences -->
      <assert test="@name"  role="error">&lt;component name='' level='<value-of select='@level'/>'/&gt; is required to have a value for name field </assert>
      <assert test="@level" role="error">&lt;component name='<value-of select='@name'/>' level=''/&gt; is required to have a value for level field </assert>
      <assert test="(@name='Core'                 and (@level='1' or @level='2')) or
                    (@name='Time'                 and (@level='1' or @level='2')) or
                    (@name='Networking'           and (@level='1' or @level='2' or @level='3' or @level='4')) or
                    (@name='Grouping'             and (@level='1' or @level='2' or @level='3')) or
                    (@name='Rendering'            and (@level='1' or @level='2' or @level='3' or @level='4' or @level='5')) or
                    (@name='Shape'                and (@level='1' or @level='2' or @level='3' or @level='4')) or
                    (@name='Geometry3D'           and (@level='1' or @level='2' or @level='3' or @level='4')) or
                    (@name='Geometry2D'           and (@level='1' or @level='2')) or
                    (@name='Text'                 and (@level='1')) or
                    (@name='Sound'                and (@level='1')) or
                    (@name='Lighting'             and (@level='1' or @level='2' or @level='3')) or
                    (@name='Texturing'            and (@level='1' or @level='2' or @level='3')) or
                    (@name='Interpolation'        and (@level='1' or @level='2' or @level='3' or @level='4' or @level='5')) or
                    (@name='PointingDeviceSensor' and (@level='1')) or
                    (@name='KeyDeviceSensor'      and (@level='1' or @level='2')) or
                    (@name='EnvironmentalSensor'  and (@level='1' or @level='2' or @level='3')) or
                    (@name='Navigation'           and (@level='1' or @level='2' or @level='3')) or
                    (@name='EnvironmentalEffects' and (@level='1' or @level='2' or @level='3' or @level='4')) or
                    (@name='Geospatial'           and (@level='1' or @level='2')) or
                    (@name='H-Anim'               and (@level='1')) or
                    (@name='NURBS'                and (@level='1' or @level='2' or @level='3' or @level='4')) or
                    (@name='DIS'                  and (@level='1' or @level='2')) or
                    (@name='Scripting'            and (@level='1')) or
                    (@name='EventUtilities'       and (@level='1')) or
                    (@name='Shaders'              and (@level='1')) or
                    (@name='CADGeometry'          and (@level='1' or @level='2')) or
                    (@name='Texturing3D'          and (@level='1' or @level='2')) or
                    (@name='CubeMapTexturing'     and (@level='1' or @level='2' or @level='3')) or
                    (@name='Layering'             and (@level='1')) or
                    (@name='Layout'               and (@level='1' or @level='2')) or
                    (@name='RigidBodyPhysics'     and (@level='1' or @level='2')) or
                    (@name='Picking'              and (@level='1' or @level='2' or @level='3')) or
                    (@name='Followers'            and (@level='1')) or
                    (@name='ParticleSystems'      and (@level='1' or @level='2' or @level='3')) or
                    (@name='VolumeRendering'      and (@level='1' or @level='2' or @level='3' or @level='4'))" role="error">&lt;component&gt; name='<value-of select='@name'/>' has invalid value (too high or undefined) for level='<value-of select='@level'/>' </assert>
    </rule>

    <!-- ========= unit ========== -->
    <rule context="unit">
      <extends rule="noDEF"/>
      <!-- cannot use rule="X3Dversion3.3" since no DEF is allowed for unit command -->
      <assert test="(/X3D/@version='3.3') or (/X3D/@version='3.4')" role="error">&lt;unit /&gt; command requires X3D version='3.3' or greater, but found version='<value-of select='/X3D/@version'/>' </assert>
      <assert test="(@conversionFactor > 0)" role="error">&lt;unit conversionFactor='<value-of select='@conversionFactor'/>'/&gt; must be positive</assert>
      <!-- TODO value checks, order is component/unit/meta, conversionFactor positive -->
    </rule>

    <!-- ========= Body ========== -->
    <rule context="Body">
      <extends rule="noDEF"/>
      <assert test="*" role="warning"> Body of scene has no content, so there is nothing to render </assert>
    </rule>

    <!-- ========= XML comment() ==========
    <rule context="comment()">
      TODO not working?! comments seem to be ignored
      <report test="true()" role="diagnostic">found XML comment... </report>
      TODO these XML comment tests are likely superfluous, since input document with hyphen problems fails XML well-formed test and thus remains unchecked by schematron XSLT
      TODO remove space between hyphens - -
      <assert test="not(starts-with(.,'-'))" role="error">XML comment cannot start with - character: &lt;!- -<value-of select='.'/>- -&gt; </assert>
      <assert test="not(contains(.,'- -'))" role="error">XML comment cannot include - - characters: &lt;!- -<value-of select='.'/>- -&gt; </assert>
    </rule>
     -->

    <!-- ========= Shape ========== -->
    <rule context="Shape">
      <extends rule="DEFtests"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="NeedsChildNode"/>
      <!-- XML comment can silence warning about empty Shape (which is sometimes needed) -->
      <assert test="((@USE) and (string-length(@USE) > 0)) or comment() or boolean(Appearance | ProtoInstance | descendant::Color | descendant::ColorRGBA | IS | parent::ProtoBody | parent::field | parent::fieldValue) or ((local-name(..)='Collision') and (@containerField='proxy')) or ((local-name(..)='LOD') and not(*)) or ((local-name(..)='Switch') and not(*))" role="warning">&NodeDEFname; found without child Appearance or Color </assert>
      <report test="(count(*)=1) and (ProtoInstance) and not(parent::ProtoBody) and not(parent::field) and not(parent::fieldValue) and not(IS)" role="warning">&NodeDEFname; found with single ProtoInstance child, need to add Appearance or geometry node </report>
      <report test="(count(*)=2) and not(Appearance) and not(ProtoInstance) and not(parent::ProtoBody) and not(parent::field) and not(parent::fieldValue) and not(IS)" role="warning">&NodeDEFname; found without child geometry node </report>
    </rule>

    <!-- ========= Appearance ========== -->
    <rule context="Appearance">
      <extends rule="DEFtests"/>
      <assert test="parent::Shape | parent::ProtoBody | parent::field | parent::fieldValue" role="error">&NodeDEFname; found outside of a parent Shape, ProtoBody, field or fieldValue element </assert>
      <assert test="((@USE) and (string-length(@USE) > 0)) or (Material | TwoSidedMaterial | ImageTexture | MovieTexture | PixelTexture | MultiTexture | */Color | */ColorRGBA | ProtoInstance | IS | parent::ProtoBody | parent::field | parent::fieldValue)" role="warning">&NodeDEFname; found without child Material, TwoSidedMaterial, Color or texture node </assert>
    </rule>
    
    <!-- ========= abstract: materialNode ========== -->
    <rule id="materialNode" abstract="true">
      <let name="diffuseColor"                     value="concat(' ',normalize-space(translate(@diffuseColor, ',',' ')))"/>
      <let name="diffuseColorCount"                value="string-length($diffuseColor)              - string-length(translate($diffuseColor,  ' ',''))"/>
      <let name="emissiveColor"                    value="concat(' ',normalize-space(translate(@emissiveColor, ',',' ')))"/>
      <let name="emissiveColorCount"               value="string-length($emissiveColor)              - string-length(translate($emissiveColor,  ' ',''))"/>
      <let name="specularColor"                    value="concat(' ',normalize-space(translate(@specularColor, ',',' ')))"/>
      <let name="specularColorCount"               value="string-length($specularColor)              - string-length(translate($specularColor,  ' ',''))"/>
      <extends rule="DEFtests"/>
      <report test="contains($diffuseColor,'-')"  role="warning">&NodeDEFname; diffuseColor='<value-of select='@diffuseColor'/>' contains a negative value </report>
      <!-- the following test does not catch values between 1.0 and 1.1 -->
      <report test="contains($diffuseColor,' 2') or contains($diffuseColor,' 3') or contains($diffuseColor,' 4') or contains($diffuseColor,' 5') or contains($diffuseColor,' 6') or contains($diffuseColor,' 7') or contains($diffuseColor,' 8') or contains($diffuseColor,' 9') or contains($diffuseColor,' 1.1') or contains($diffuseColor,' 1.2') or contains($diffuseColor,' 1.3') or contains($diffuseColor,' 1.4') or contains($diffuseColor,' 1.5') or contains($diffuseColor,' 1.6') or contains($diffuseColor,' 1.7') or contains($diffuseColor,' 1.8') or contains($diffuseColor,' 1.9')"  role="warning">&NodeDEFname; diffuseColor='<value-of select='@diffuseColor'/>' contains a value greater than 1 </report>
      <report test="(string-length(normalize-space($diffuseColor)) > 0) and ($diffuseColorCount != 3)"    role="warning">&NodeDEFname; diffuseColor='<value-of select='@diffuseColor'/>' has <value-of select='($diffuseColorCount)'/> values instead of 3 </report>
      <report test="contains($emissiveColor,'-')"  role="warning">&NodeDEFname; emissiveColor='<value-of select='@emissiveColor'/>' contains a negative value </report>
      <!-- the following test does not catch values between 1.0 and 1.1 -->
      <report test="contains($emissiveColor,' 2') or contains($emissiveColor,' 3') or contains($emissiveColor,' 4') or contains($emissiveColor,' 5') or contains($emissiveColor,' 6') or contains($emissiveColor,' 7') or contains($emissiveColor,' 8') or contains($emissiveColor,' 9') or contains($emissiveColor,' 1.1') or contains($emissiveColor,' 1.2') or contains($emissiveColor,' 1.3') or contains($emissiveColor,' 1.4') or contains($emissiveColor,' 1.5') or contains($emissiveColor,' 1.6') or contains($emissiveColor,' 1.7') or contains($emissiveColor,' 1.8') or contains($emissiveColor,' 1.9')"  role="warning">&NodeDEFname; emissiveColor='<value-of select='@emissiveColor'/>' contains a value greater than 1 </report>
      <report test="(string-length(normalize-space($emissiveColor)) > 0) and ($emissiveColorCount != 3)"   role="warning">&NodeDEFname; emissiveColor='<value-of select='@emissiveColor'/>' has <value-of select='($emissiveColorCount)'/> values instead of 3 </report>
      <report test="contains($specularColor,'-')"  role="warning">&NodeDEFname; specularColor='<value-of select='@specularColor'/>' contains a negative value </report>
      <!-- the following test does not catch values between 1.0 and 1.1 -->
      <report test="contains($specularColor,' 2') or contains($specularColor,' 3') or contains($specularColor,' 4') or contains($specularColor,' 5') or contains($specularColor,' 6') or contains($specularColor,' 7') or contains($specularColor,' 8') or contains($specularColor,' 9') or contains($specularColor,' 1.1') or contains($specularColor,' 1.2') or contains($specularColor,' 1.3') or contains($specularColor,' 1.4') or contains($specularColor,' 1.5') or contains($specularColor,' 1.6') or contains($specularColor,' 1.7') or contains($specularColor,' 1.8') or contains($specularColor,' 1.9')"  role="warning">&NodeDEFname; specularColor='<value-of select='@specularColor'/>' contains a value greater than 1 </report>
      <report test="(string-length(normalize-space($specularColor)) > 0) and ($specularColorCount != 3)"   role="warning">&NodeDEFname; specularColor='<value-of select='@specularColor'/>' has <value-of select='($specularColorCount)'/> values instead of 3 </report>
      <!-- unnecesarily verbose
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and (../../Appearance/ImageTexture or ../../Appearance/MovieTexture or ../../Appearance/PixelTexture or ../../Appearance/MultiTexture or ../../Appearance/ProtoInstance)"  role="info">&NodeDEFname; values are overridden by accompanying texture node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and (../../Appearance/ImageTexture or ../../Appearance/MovieTexture or ../../Appearance/PixelTexture or ../../Appearance/MultiTexture or ../../Appearance/ProtoInstance)"  role="info">&lt;<name/> USE='<value-of select='@USE'/>' values are overridden by accompanying texture node </report>
      -->
    </rule>

    <!-- ========= Material ========== -->
    <rule context="Material">
      <extends rule="materialNode"/>
      <assert test="parent::Appearance | parent::ProtoBody | parent::field | parent::fieldValue | parent::ShadedVolumeStyle" role="error">&NodeDEFname; found outside of a parent Appearance, ProtoBody, field, fieldValue or ShadedVolumeStyle element </assert>
      <!-- matching Material attribute DEF/USE tests? -->
    </rule>

    <!-- ========= TwoSidedMaterial ========== -->
    <rule context="TwoSidedMaterial">
      <extends rule="materialNode"/>
      <extends rule="X3Dversion3.2"/>
      <assert test="parent::Appearance | parent::ProtoBody | parent::field | parent::fieldValue | parent::ShadedVolumeStyle" role="error">&NodeDEFname; found outside of a parent Appearance, ProtoBody, field, fieldValue or ShadedVolumeStyle element </assert>
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='Shape'][number(@level) ge 4]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Shape' level='4'/&gt; or &lt;X3D profile='Full'/&gt; </report>
      <!-- matching Material attribute DEF/USE tests? -->
      <!-- back tests -->
      <assert test="(@separateBackColor='true') or
                    ((@backDiffuseColor=''       or @backDiffuseColor ='0.8 0.8 0.8') and
                     (@backEmissiveColor=''      or @backEmissiveColor='0.8 0.8 0.8') and
                     (@backSpecularColor=''      or @backSpecularColor ='0.8 0.8 0.8') and
                     (@backAmbientIntensity=''   or @backAmbientIntensity='0.2') and
                     (@backTransparency=''       or @backTransparency='0.0' or @backTransparency='0') and
                     (@backShininess=''          or @backShininess='0.2'))" role="warning">&NodeDEFname; needs separateBackColor='true' or else the provided backside Material values are ignored </assert>
    </rule>

    <!-- ========= Sensor nodes ========== -->

    <rule id="NeedsInputROUTE" abstract="true">
      <assert test="(@DEF) or (string-length(@USE) > 0) or (local-name(..)='field') or (local-name(..)='fieldValue') or IS/connect" role="warning">&lt;<name/>/&gt; must have DEF name in order to ROUTE input events </assert>
      <assert test="not(@DEF) or //ROUTE[@toNode=$DEF]  or (local-name(..)='field') or (local-name(..)='fieldValue') or IS/connect" role="warning">&NodeDEFname; missing ROUTE to receive input events </assert>
    </rule>

    <rule id="NeedsOutputROUTE" abstract="true">
      <!-- TouchSensor, GeoTouchSensor sometimes used to provide tooltip popup message (similar to HTML title attribute) -->
      <let name="touchSensorNoDEF"          value="contains(local-name(),'TouchSensor') and (not(@DEF) or (string-length(@DEF) = 0))"/>
      <let name="touchSensorHasDescription" value="contains(local-name(),'TouchSensor') and (string-length(@description) > 0)"/>
      <report test="   (local-name()='TouchSensor') and not((string-length(@DEF) > 0) or (string-length(@description) > 0))" role="warning">&lt;<name/> description='<value-of select='@description'/>'/&gt; must have DEF name in order to ROUTE output events, or a description field as a user tooltip for sibling geometry </report>
      <report test="not(local-name()='TouchSensor') and not((string-length(@DEF) > 0) or (string-length(@description) > 0))" role="warning">&lt;<name/>/&gt; must have DEF name in order to ROUTE output events </report> <!-- most Sensor nodes do not have description field -->
      <assert test="    $touchSensorNoDEF  or $touchSensorHasDescription or not(@DEF) or //ROUTE[@fromNode=$DEF] or (local-name(..)='field') or (local-name(..)='fieldValue') or IS/connect" role="warning">&NodeDEFname; missing ROUTE to send output events </assert>
      <!-- essentially same rule follows, but different output message was provided for TouchSensor nodes -->
      <assert test="not($touchSensorNoDEF) or $touchSensorHasDescription or not(@DEF) or //ROUTE[@fromNode=$DEF] or (local-name(..)='field') or (local-name(..)='fieldValue') or IS/connect" role="warning">&NodeDEFname; missing ROUTE to send output events, or description field as a user tooltip for sibling geometry </assert>
    </rule>

    <rule id="NeedsInputOutputROUTEs" abstract="true">
      <assert test="(@DEF)  or (string-length(@USE) > 0) or (local-name(..)='field') or (local-name(..)='fieldValue') or IS/connect" role="warning">&lt;<name/>/&gt; must have DEF name in order to ROUTE input and output events </assert>
      <assert test="not(@DEF) or //ROUTE[@toNode=$DEF]   or (local-name(..)='field') or (local-name(..)='fieldValue') or IS/connect" role="warning">&NodeDEFname; missing ROUTE to receive input events </assert>
      <assert test="not(@DEF) or //ROUTE[@fromNode=$DEF] or (local-name(..)='field') or (local-name(..)='fieldValue') or IS/connect" role="warning">&NodeDEFname; missing ROUTE to send output events </assert>
    </rule>

    <!-- ========= BooleanFilter, BooleanTrigger ========== -->
    <rule context="BooleanFilter | BooleanTrigger">
      <extends rule="DEFtests"/>
      <extends rule="NeedsInputOutputROUTEs"/>
    </rule>

    <!-- ========= BooleanToggle ========== -->
    <rule context="BooleanToggle">
      <extends rule="DEFtests"/>
      <extends rule="NeedsInputOutputROUTEs"/>
      <report test="(@toggle='TRUE' )"    role="error">&NodeDEFname; toggle='TRUE' is incorrect, define toggle='true' instead</report>
      <report test="(@toggle='FALSE')"    role="error">&NodeDEFname; toggle='FALSE' is incorrect, define toggle='false' instead</report>
    </rule>

    <!-- ========= ProximitySensor,  VisibilitySensor,  TransformSensor ========== -->
    <rule context="ProximitySensor | VisibilitySensor | TransformSensor">
      <extends rule="DEFtests"/>
      <extends rule="enabledTests"/>
      <extends rule="sizeTests"/>
      <extends rule="NeedsOutputROUTE"/>
      <report test="(local-name()='ProximitySensor')  and not(/X3D[(@profile='Interactive') or (@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='EnvironmentalSensor'][number(@level) ge 1] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='EnvironmentalSensor' level='1'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
      <report test="(local-name()='VisibilitySensor') and not(/X3D[                            (@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='EnvironmentalSensor'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='EnvironmentalSensor' level='2'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
      <report test="(local-name()='TransformSensor')  and not(/X3D[                                                      (@profile='Full')] or /X3D/head/component[@name='EnvironmentalSensor'][number(@level) ge 3] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='EnvironmentalSensor' level='3'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= IMPORT ========== -->
    <rule context="IMPORT">
      <let name="NodeName"     value="local-name()"/>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Networking'][number(@level) ge 3] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Networking' level='3'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= EXPORT ========== -->
    <rule context="EXPORT">
      <let name="NodeName"     value="local-name()"/>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Networking'][number(@level) ge 3] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Networking' level='3'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= LoadSensor ========== -->
    <rule context="LoadSensor">
      <extends rule="DEFtests"/>
      <extends rule="enabledTests"/>
      <extends rule="NeedsOutputROUTE"/>
      <report test="*[not(@containerField='watchList')][not(starts-with(local-name(),'Metadata'))]" role="error">&NodeDEFname; children must have containerField='watchList' </report>
      <report test="*[not(starts-with(local-name(),'Metadata')) and not(contains(local-name(),'Texture')) and not(contains(local-name(),'Background')) and not(local-name()='Inline') and not(local-name()='AudioClip') and not(local-name()='Script') and not(local-name()='ProtoInstance')]" role="error">&NodeDEFname; children must be X3DUrlObject node(s) </report>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Networking'][number(@level) ge 3] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Networking' level='3'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- Merge first DEF-less rule into second.  Include checks on routing sensor output to set_offset -->
    <!-- TODO need rules with explicit node names (TouchSensor et al.), and no constraints, to avoid triggering mispelled node-name rule -->
    <!-- TODO detect if peer sensors are interfering with each other -->

    <rule context="TouchSensor | CylinderSensor | PlaneSensor | SphereSensor">
      <!-- *[contains(local-name(),'Sensor')][not(@USE) and not(@DEF) and not(IS) and not(parent::field)]"> -->
      <extends rule="DEFtests"/>
      <extends rule="enabledTests"/>
      <extends rule="NoChildNode"/>
      <extends rule="NeedsOutputROUTE"/>
      <extends rule="descriptionTests"/>
      <report test="(@cycleInterval='0') or (@cycleInterval='0.0') or (contains(@cycleInterval,'-') and not(contains(@cycleInterval,'E-')))" role="warning">&lt;<name/>/&NodeDEFname; cycleInterval must be greater than 0 </report>
      <report test="(@autoOffset='TRUE' )" role="error">&NodeDEFname; autoOffset='TRUE'  autoOffset='true' instead</report>
      <report test="(@autoOffset='FALSE')" role="error">&NodeDEFname; autoOffset='FALSE'  autoOffset='false' instead</report>
      <report test="(@loop='TRUE' )" role="error">&NodeDEFname; loop='TRUE'  loop='true' instead</report>
      <report test="(@loop='FALSE')" role="error">&NodeDEFname; loop='FALSE'  loop='false' instead</report>
    </rule>

    <rule id="DefaultSensorNode" context="*[contains(local-name(),'Sensor')][not(@USE) and string-length(@DEF)>1]">
      <extends rule="DEFtests"/>
      <extends rule="enabledTests"/>
      <extends rule="NoChildNode"/>
      <extends rule="NeedsOutputROUTE"/>
      <!-- Not all Sensor nodes include a description field, X3D v3.3 Specification change proposed. The following rule checks for proper node types. -->
      <extends rule="descriptionTests"/>
      <report test="(@cycleInterval='0') or (@cycleInterval='0.0') or (contains(@cycleInterval,'-') and not(contains(@cycleInterval,'E-')))" role="warning">&lt;<name/>/&NodeDEFname; cycleInterval must be greater than 0 </report>
      <report test="(@autoOffset='TRUE' )" role="error">&NodeDEFname; autoOffset='TRUE'  autoOffset='true' instead</report>
      <report test="(@autoOffset='FALSE')" role="error">&NodeDEFname; autoOffset='FALSE'  autoOffset='false' instead</report>
      <report test="(@loop='TRUE' )" role="error">&NodeDEFname; loop='TRUE'  loop='true' instead</report>
      <report test="(@loop='FALSE')" role="error">&NodeDEFname; loop='FALSE'  loop='false' instead</report>
    </rule>
    
    <!-- TODO TimeSensor tests:
    - probably needs separate rule, rather than just DefaultSensorNode above
    - timing relationships, values
    - do not IS/connect set_startTime set_cycleInterval or related/munged field names, they can cause big problems
    -->

    <!-- ========= Trigger nodes ========== -->
    <rule context="IntegerTrigger | TimeTrigger">
      <extends rule="DEFtests"/>
      <extends rule="NoChildNode"/>
      <extends rule="NeedsInputOutputROUTEs"/>
    </rule>

    <!-- ========= Interpolator nodes ========== -->

    <rule id="InterpolatorNode" abstract="true">
      <let name="key"             value="normalize-space(translate(@key,     ',',' '))"/>
      <let name="keyValue"        value="concat(' ',normalize-space(translate(@keyValue,',',' ')))"/>
      <let name="keyCount"        value="string-length($key)      - string-length(translate($key,     ' ','')) + 1"/>
      <let name="keyValueCount"   value="string-length($keyValue) - string-length(translate($keyValue,' ',''))"/>
      <let name="keyResidue"      value="translate($key,     '+-0123456789Ee., ','')"/>
      <let name="keyValueResidue" value="translate(normalize-space($keyValue),'+-0123456789Ee., ','')"/>
      <extends rule="DEFtests"/>
      <extends rule="NoChildNode"/>
      <extends rule="NeedsInputOutputROUTEs"/>
      <assert test="(string-length(normalize-space($key))      > 0) or (@USE) or (//Script/field/*[@USE=$DEF])" role="error">&NodeDEFname; missing key array </assert>
      <assert test="(string-length(normalize-space($keyValue)) > 0) or (@USE) or (//Script/field/*[@USE=$DEF])" role="error">&NodeDEFname; missing keyValue array </assert>
      <report test="(string-length($key) > 0) and not($keyCount >= 2)" role="error">&NodeDEFname; key array length <value-of select='$keyCount'/> (and corresponding keyValue array length) needs to be 2 or greater </report>
      <assert test="string-length($keyResidue)      = 0"               role="error">&NodeDEFname; has illegal character <value-of select='$keyResidue'/> in key array </assert>
      <assert test="string-length($keyValueResidue) = 0"               role="error">&NodeDEFname; has illegal character <value-of select='$keyValueResidue'/> in keyValue array </assert>
    </rule>

    <rule context="ScalarInterpolator">
      <extends rule="InterpolatorNode"/>
      <assert test="(@USE) or (IS) or (parent::field) or (not($key) and not($keyValue)) or $keyCount=$keyValueCount" role="error">&NodeDEFname; key array (size=<value-of select="$keyCount"/>) must match keyValue array (size=<value-of select="$keyValueCount"/> values) </assert>
    </rule>
    <rule context="PositionInterpolator2D">
      <extends rule="InterpolatorNode"/>
      <assert test="(@USE) or (IS) or (parent::field) or (not($key) and not($keyValue)) or (2 * $keyCount)=$keyValueCount" role="error">&NodeDEFname; key array (size=<value-of select="$keyCount"/>) must match keyValue array (size=<value-of select="$keyValueCount div 2"/> sets of 2-tuple values) </assert>
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='Interpolation'][number(@level) ge 3]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Interpolation' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>
    <rule context="ColorInterpolator">
      <extends rule="InterpolatorNode"/>
      <!-- check for legal color values -->
      <report test="contains($keyValue,'-')"  role="warning">&NodeDEFname; contains a negative color array value, keyValue='<value-of select='@keyValue'/>' </report>
      <!-- the following test does not catch values between 1.0 and 1.1 -->
      <report test="contains($keyValue,' 2') or contains($keyValue,' 3') or contains($keyValue,' 4') or contains($keyValue,' 5') or contains($keyValue,' 6') or contains($keyValue,' 7') or contains($keyValue,' 8') or contains($keyValue,' 9') or contains($keyValue,' 1.1') or contains($keyValue,' 1.2') or contains($keyValue,' 1.3') or contains($keyValue,' 1.4') or contains($keyValue,' 1.5') or contains($keyValue,' 1.6') or contains($keyValue,' 1.7') or contains($keyValue,' 1.8') or contains($keyValue,' 1.9')"  role="warning">&NodeDEFname; contains a color array value greater than 1, keyValue='<value-of select='@keyValue'/>' </report>
      <assert test="(@USE) or (IS) or (parent::field) or (not($key) and not($keyValue)) or (3 * $keyCount)=$keyValueCount" role="error">&NodeDEFname; key array (size=<value-of select="$keyCount"/>) must match keyValue array (size=<value-of select="$keyValueCount div 3"/> sets of 3-tuple values) </assert>
    </rule>
    <rule context="NormalInterpolator">
      <extends rule="InterpolatorNode"/>
      <assert test="(@USE) or (IS) or (parent::field) or (not($key) and not($keyValue)) or round($keyValueCount div $keyCount)=($keyValueCount div $keyCount)" role="error">&NodeDEFname; key array (size=<value-of select="$keyCount"/>) does not evenly divide keyValue array (size=<value-of select="$keyValueCount div 3"/> sets of 3-tuple values) </assert>
      <!-- TODO check for legal normal values -->
    </rule>
    <rule context="PositionInterpolator">
      <extends rule="InterpolatorNode"/>
      <assert test="(@USE) or (IS) or (parent::field) or (not($key) and not($keyValue)) or (3 * $keyCount)=$keyValueCount" role="error">&NodeDEFname; key array (size=<value-of select="$keyCount"/>) must match keyValue array (size=<value-of select="$keyValueCount div 3"/> sets of 3-tuple values) </assert>
    </rule>
    <rule context="OrientationInterpolator">
      <extends rule="InterpolatorNode"/>
      <assert test="(@USE) or (IS) or (parent::field) or (not($key) and not($keyValue)) or (4 * $keyCount)=$keyValueCount" role="error">&NodeDEFname; key array (size=<value-of select="$keyCount"/>) must match keyValue array (size=<value-of select="$keyValueCount div 4"/> sets of 4-tuple values) </assert>
      <!-- TODO check for legal axis values, i.e. not 0 0 0 -->
    </rule>
    <rule context="CoordinateInterpolator">
      <extends rule="InterpolatorNode"/>
      <assert test="(@USE) or (IS) or (parent::field) or (not($key) and not($keyValue)) or round($keyValueCount div $keyCount)=($keyValueCount div $keyCount)" role="error">&NodeDEFname; key array (size=<value-of select="$keyCount"/>) does not evenly divide keyValue array (size=<value-of select="$keyValueCount"/> values) </assert>
    </rule>
    <rule context="CoordinateInterpolator2D">
      <extends rule="InterpolatorNode"/>
      <assert test="(@USE) or (IS) or (parent::field) or (not($key) and not($keyValue)) or round($keyValueCount div $keyCount div 2)=($keyValueCount div $keyCount div 2)" role="error">&NodeDEFname; key array (size=<value-of select="$keyCount"/>) does not evenly divide keyValue array (size=<value-of select="$keyValueCount div 2"/> sets of 2-tuple values) </assert>
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='Interpolation'][number(@level) ge 3]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Interpolation' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>
    
    <!-- TODO handle other cases for the above nodes? -->

    <!-- TODO other Interpolators: EaseInEaseOut, SplinePositionInterpolator, SplinePositionInterpolator2D, SplineScalarInterpolator, SquadOrientationInterpolator -->

    <!-- ========= Sequencer nodes ========== -->

    <rule id="SequencerNode" abstract="true">
      <let name="key"             value="normalize-space(translate(@key,',',' '))"/>
      <let name="keyValue"        value="normalize-space(translate(@keyValue,',',' '))"/>
      <let name="keyCount"        value="string-length($key)      - string-length(translate($key,' ',''))      + 1"/>
      <let name="keyValueCount"   value="string-length($keyValue) - string-length(translate($keyValue,' ','')) + 1"/>
      <let name="keyResidue"      value="translate($key,     '+-0123456789Ee., ','')"/>
      <let name="keyValueResidueBoolean" value="translate(normalize-space($keyValue),'truefalse, ','')"/>
      <let name="keyValueResidueInteger" value="translate(normalize-space($keyValue),'+-0123456789Ee, ','')"/>
      <extends rule="DEFtests"/>
      <extends rule="NoChildNode"/>
      <extends rule="NeedsInputOutputROUTEs"/>
      <assert test="$key      and not($key=' ')      and not (//Script/field/*[@USE=$DEF])" role="error">&NodeDEFname; missing key array </assert>
      <assert test="$keyValue and not($keyValue=' ') and not (//Script/field/*[@USE=$DEF])" role="error">&NodeDEFname; missing keyValue array </assert>
      <report test="(string-length($key) > 0) and not($keyCount >= 2)" role="error">&NodeDEFname; key array length <value-of select='$keyCount'/> (and corresponding keyValue array length) needs to be 2 or greater </report>
      <!-- both BooleanSequencer and IntegerSequencer have singleton keyValue array types -->
      <assert test="(not($key) and not($keyValue)) or $keyCount=$keyValueCount" role="error">&NodeDEFname; key array (size=<value-of select="$keyCount"/>) must match keyValue array (size=<value-of select="$keyValueCount"/>) </assert>
    </rule>

    <rule context="BooleanSequencer">
      <extends rule="SequencerNode"/>
      <assert test="string-length($keyResidue)             = 0" role="error">&NodeDEFname; includes illegal character <value-of select='$keyResidue'     /> in key array </assert>
      <assert test="string-length($keyValueResidueBoolean) = 0" role="error">&NodeDEFname; includes illegal character <value-of select='$keyValueResidueBoolean'/> in keyValue array </assert>
      <report test="contains(keyValue,'TRUE' )"    role="error">&NodeDEFname; keyValue 'TRUE' values are incorrect, use 'true' instead</report>
      <report test="contains(keyValue,'FALSE')"    role="error">&NodeDEFname; keyValue 'FALSE' values are incorrect, use 'false' instead</report>
   </rule>

    <rule context="IntegerSequencer">
      <extends rule="SequencerNode"/>
      <assert test="string-length($keyResidue)             = 0" role="error">&NodeDEFname; includes illegal character <value-of select='$keyResidue'     /> in key array </assert>
      <assert test="string-length($keyValueResidueInteger) = 0" role="error">&NodeDEFname; includes illegal character <value-of select='$keyValueResidueInteger'/> in keyValue array </assert>
   </rule>

    <!-- ========= field element ========== -->
    <rule context="field">
      <let name="fieldName" value="@name"/>
      <let name="hasIS" value="boolean(..//IS/connect[@nodeField = $fieldName])"/>
      <let name="valueRequired" value="(@accessType='initializeOnly' or @accessType='inputOutput') and not(@type='SFNode') and not(@type='SFString') and not(starts-with(@type,'MF')) and not($hasIS) and not(local-name(..)='ExternProtoDeclare')"/>
      <let name="MFBoolValueResidue" value="translate(normalize-space(@value),'truefalse, ','')"/>
      <let name="IntegerValueResidue" value="translate(normalize-space(@value),'0123456789+-Ee, ','')"/>
      <let name="FloatValueResidue" value="translate(normalize-space(@value),'0123456789.+-Ee, ','')"/>
      <let name="ImageValueResidue" value="translate(normalize-space(@value),'0123456789+-Ee, 0xABCDEFabcdef','')"/>
      <let name="embeddedWhiteSpaceCount" value="string-length(normalize-space(translate(@value,',',' '))) - string-length(translate(normalize-space(translate(@value,',',' ')),' ',''))"/>
      <let name="embeddedPeriodCount" value="string-length(@value) - string-length(translate(@value,'.',''))"/>
      <let name="CDATAblock" value="normalize-space(..)"/>
      <let name="parentName" value="local-name(..)"/>
      <extends rule="noDEF"/>
      <extends rule="fieldNameNotReservedWord"/>
      <assert test="@name"       role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>' name='<value-of select='../@name'/>'> &lt;<name/> type='<value-of select='@type'/>' accessType='<value-of select='@accessType'/>'/&gt; field must have name defined </assert>
      <report test="not(@type)       and not(local-name(..)='ProtoInstance')" role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>' name='<value-of select='../@name'/>'> &lt;<name/> name='<value-of select='@name'/>'/&gt; field must have type defined </report>
      <report test="not(@accessType) and not(local-name(..)='ProtoInstance')" role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>' name='<value-of select='../@name'/>'> &lt;<name/> name='<value-of select='@name'/>'/&gt; field must have accessType defined </report>
      <!-- do not initialize fields which have IS/connect, results undefined: 4.4.4.3 PROTO definition semantics -->
      <report test="(string-length(normalize-space(@value)) > 0) and $hasIS" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; field initialization not allowed when IS/connect is also defined </report>
      <!-- test for duplicate definition -->
      <report test="(count(preceding-sibling::*[@name=$fieldName])!=0) and (local-name(..)='Script')"             role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>'&gt; has duplicate field declarations with the same name defined &lt;<name/> name='<value-of select='@name'/>'/&gt; </report>
      <report test="(count(preceding-sibling::*[@name=$fieldName])!=0) and (local-name(..)='ExternProtoDeclare')" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>'&gt; has duplicate field declarations with the same name defined &lt;<name/> name='<value-of select='@name'/>'/&gt; </report>
      <report test="(count(preceding-sibling::*[@name=$fieldName])!=0) and (local-name(../..)='ProtoDeclare')"    role="error">&lt;<value-of select='local-name(../..)'/> name='<value-of select='../../@name'/>'&gt; has duplicate field declarations with the same name defined &lt;<name/> name='<value-of select='@name'/>'/&gt; </report>
      <!-- check accessType initializations -->
      <!-- check for initialization values/nodes present.  note SFNode can have value='NULL' -->
      <report test="(@type='SFBool') and $valueRequired and not(local-name(..)='ExternProtoDeclare') and not(@value='true' or @value='false')" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; SFBool field must have value='true' or value='false' </report>
      <report test="not(@type='SFBool') and $valueRequired and not(local-name(..)='ExternProtoDeclare') and not(@value)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; field declaration is missing initialization value </report>
      <!-- check for proper characters in initialization values -->
      <report test="(local-name(..)='ExternProtoDeclare') and (string-length(@value) &gt; 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; cannot be initialized inside ExternProtoDeclare </report>
      <report test="(@type='MFBool') and (string-length($MFBoolValueResidue) &gt; 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; MFBool field must only include values of true or false </report>
      <!-- TODO are hex values allowed for integers and floats? -->
      <report test="contains(@type,'FInt32') and $valueRequired and (string-length($IntegerValueResidue) &gt; 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal characters in value: <value-of select='$IntegerValueResidue'/> </report>
      <report test="(contains(@type,'Float') or contains(@type,'Rotation') or contains(@type,'FVec') or contains(@type,'Color') or contains(@type,'Time') or contains(@type,'Matrix')) and $valueRequired and (string-length($FloatValueResidue) &gt; 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal characters in value: <value-of select='$FloatValueResidue'/> </report>
      <report test="contains(@type,'Image') and $valueRequired and (string-length($ImageValueResidue) &gt; 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>'> DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal characters in value: <value-of select='$ImageValueResidue'/> </report>
      <!-- check for proper number of initialization values.  whitespace includes commas. -->
      <!--
      <report test="true()" role="diagnostic">name='<value-of select='@name'/>', @type=<value-of select='@type'/>, $valueRequired=<value-of select='$valueRequired'/>, $hasIS=<value-of select='$hasIS'/>, $embeddedWhiteSpaceCount=<value-of select='$embeddedWhiteSpaceCount'/> </report>
      -->
      <report test="(string-length(@value) > 0) and ((@type='SFBool') or (@type='SFInt32') or (@type='SFFloat') or (@type='SFDouble') or (@type='SFTime')) and ($embeddedWhiteSpaceCount!=0) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for type <value-of select='@type'/> </report>
      <report test="(string-length(@value) > 0) and ((@type='SFVec2f') or (@type='SFVec2d')) and ($embeddedWhiteSpaceCount!=1) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for 2-tuple type <value-of select='@type'/> </report>
      <report test="(string-length(@value) > 0) and ((@type='SFVec3f') or (@type='SFVec3d') or (@type='SFColor')) and ($embeddedWhiteSpaceCount!=2) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for 3-tuple type <value-of select='@type'/> </report>
      <report test="(string-length(@value) > 0) and ((@type='SFVec4f') or (@type='SFVec4d') or (@type='SFRotation') or (@type='SFColorRGBA')) and ($embeddedWhiteSpaceCount!=3) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for 4-tuple type <value-of select='@type'/> </report>
      <report test="(string-length(@value) > 0) and ((@type='SFMatrix3f') or (@type='SFMatrix3d')) and ($embeddedWhiteSpaceCount!=8) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for 9-tuple type <value-of select='@type'/> </report>
      <report test="(string-length(@value) > 0) and ((@type='SFMatrix4f') or (@type='SFMatrix4d')) and ($embeddedWhiteSpaceCount!=15) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for 16-tuple type <value-of select='@type'/> </report>
      <!-- array tuple counts -->
      <report test="(string-length(@value) > 0) and ((@type='MFVec2f') or (@type='MFVec2d')) and ((($embeddedWhiteSpaceCount + 1) mod 2) != 0) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 2)'/>) for 2-tuple type <value-of select='@type'/> </report>
      <report test="(string-length(@value) > 0) and ((@type='MFVec3f') or (@type='MFVec3d') or (@type='MFColor')) and ((($embeddedWhiteSpaceCount + 1) mod 3) != 0) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 3)'/>) for 3-tuple type <value-of select='@type'/> </report>
      <report test="(string-length(@value) > 0) and ((@type='MFVec4f') or (@type='MFVec4d') or (@type='MFRotation') or (@type='MFColorRGBA')) and ((($embeddedWhiteSpaceCount + 1) mod 4) != 0) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 4)'/>'/>) for 4-tuple type <value-of select='@type'/> </report>
      <report test="(string-length(@value) > 0) and ((@type='MFMatrix3f') or (@type='SFMatrix3d')) and ((($embeddedWhiteSpaceCount + 1) mod 9) != 0) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 9)'/>) for 9-tuple type <value-of select='@type'/> </report>
      <report test="(string-length(@value) > 0) and ((@type='MFMatrix4f') or (@type='MFMatrix4d')) and ((($embeddedWhiteSpaceCount + 1) mod 16) != 0) and $valueRequired" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 16)'/>'/>) for 16-tuple type <value-of select='@type'/> </report>
      <report test="($embeddedPeriodCount > $embeddedWhiteSpaceCount + 1) and not(contains(@type,'FString'))" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has excess number of periods (<value-of select='$embeddedPeriodCount'/>) compared to whitespace-separated values <value-of select='($embeddedWhiteSpaceCount + 1)'/> </report>
      <!-- check for function definitions and assignments -->
      <!-- <report test="parent::Script" role='diagnostic'>$CDATAblock=<value-of select='$CDATAblock'/></report> -->
      <report test="parent::Script and not(../@url) and  (@accessType='inputOnly')    and not(contains($CDATAblock,concat('function ',    @name))) and (../IS/connect/@nodeField != @name)"            role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' accessType='<value-of select='@accessType'/>'/&gt; must define function <value-of select='@name'/> (newValue) </report>
      <report test="parent::Script and not(../@url) and  (@accessType='inputOutput')  and not(contains($CDATAblock,concat('function set_',@name))) and (../IS/connect/@nodeField != @name)"            role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' accessType='<value-of select='@accessType'/>'/&gt; must define function set_<value-of select='@name'/> (newValue) </report>
      <report test="parent::Script and not(../@url) and  (@accessType='inputOnly')    and     contains(substring-after($CDATAblock,concat('function ',@name)),    concat('function ',@name, '('))"     role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' accessType='<value-of select='@accessType'/>'/&gt; function <value-of select='@name'/>() defined more than once </report>
      <report test="parent::Script and not(../@url) and  (@accessType='inputOnly')    and     contains(substring-after($CDATAblock,concat('function ',@name)),    concat('function ',@name,' ('))"     role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' accessType='<value-of select='@accessType'/>'/&gt; function <value-of select='@name'/>() defined more than once </report>
      <report test="parent::Script and not(../@url) and  (@accessType='inputOutput')  and     contains(substring-after($CDATAblock,concat('function set_',@name)),concat('function set_',@name, '('))" role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' accessType='<value-of select='@accessType'/>'/&gt; function set_<value-of select='@name'/>() defined more than once </report>
      <report test="parent::Script and not(../@url) and  (@accessType='inputOutput')  and     contains(substring-after($CDATAblock,concat('function set_',@name)),concat('function set_',@name,' ('))" role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' accessType='<value-of select='@accessType'/>'/&gt; function set_<value-of select='@name'/>() defined more than once </report>
      <report test="parent::Script and not(../@url) and ((@accessType='initializeOnly') or (@accessType='outputOnly'))  and     contains($CDATAblock,concat('function ',@name))"  role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' accessType='<value-of select='@accessType'/>'/&gt; cannot define function <value-of select='@name'/>() unless accessType is inputOnly or inputOutput</report>
      <!-- SFVec*f assignment might include subscript, e.g. value_changed [0] = ___ -->
      <report test="parent::Script and not(../@url) and ((@accessType='outputOnly')     or (@accessType='inputOutput')) and not(starts-with(@type,'MF')) and not(contains($CDATAblock,concat(' ',@name,'='))) and not(contains($CDATAblock,concat(' ',@name,' ='))) and not(contains($CDATAblock,concat(' ',@name,'['))) and not(contains($CDATAblock,concat(' ',@name,' [')))" role="warning">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' accessType='<value-of select='@accessType'/>'/&gt; does not send output event via assignment statement <value-of select='@name'/>=___; </report>
      <!-- TODO check setting of individual MF[index] values, if possible -->
      <!-- TODO check ROUTE types; need to fix, very rough
      <let name="fieldID" value="$parentName DEF="<value-of select='../@DEF'/>"&gt; &lt;<name/> name="<value-of select='@name'/>"/&gt;"/>
      <report test="parent::Script and not(@url) and ((@accessType='inputOnly) or (@accessType='inputOutput)) and not(//ROUTE[@toNode=$DEF])" role="error"><value-of select='$fieldID'/> must have accessType defined </report>
      -->
      <report test="ROUTE" role="hint">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; cannot be contained inside of &lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>' name='<value-of select='../@name'/>'> &lt;field name='<value-of select='@name'/>' type='<value-of select='@type'/>' accessType='<value-of select='@accessType'/>'/&gt; field /&gt; </report>
      <!-- no need to reiterate warning about profile/component -->
    </rule>

    <!-- ========= fieldValue element ========== -->
    <rule context="fieldValue">
      <let name="prototypeName"    value="../@name"/>
      <let name="fieldValueName"   value="@name"/>
      <let name="protoFound"       value="boolean(//ProtoDeclare[@name = $prototypeName])"/>
      <let name="externProtoFound" value="boolean(//ExternProtoDeclare[@name = $prototypeName])"/>
      <!-- field definition is found in ProtoDeclare or ExternProtoDeclare (but not both) so catenate them together to get single value from single query -->
      <let name="type"       value="concat((//ExternProtoDeclare[@name = $prototypeName]/field[@name = $fieldValueName]/@type),      (//ProtoDeclare[@name = $prototypeName]/ProtoInterface/field[@name = $fieldValueName]/@type))"/>
      <let name="accessType" value="concat((//ExternProtoDeclare[@name = $prototypeName]/field[@name = $fieldValueName]/@accessType),(//ProtoDeclare[@name = $prototypeName]/ProtoInterface/field[@name = $fieldValueName]/@accessType))"/>
      <let name="inputOutputOnly" value="(      $protoFound and       //ProtoDeclare[@name=$prototypeName]/field[@name=$fieldValueName][@accessType='inputOnly' or @accessType='outputOnly']) or
                                         ($externProtoFound and //ExternProtoDeclare[@name=$prototypeName]/field[@name=$fieldValueName][@accessType='inputOnly' or @accessType='outputOnly'])"/>
      <let name="simpleType"      value="(      $protoFound and       //ProtoDeclare[@name=$prototypeName]/field[@name=$fieldValueName][@accessType='initializeOnly' or @accessType='inputOutput'][starts-with(@type,'SF') and @type!='SFNode']) or
                                         ($externProtoFound and //ExternProtoDeclare[@name=$prototypeName]/field[@name=$fieldValueName][@accessType='initializeOnly' or @accessType='inputOutput'][starts-with(@type,'SF') and @type!='SFNode'])"/>
      <let name="MFBoolValueResidue" value="translate(normalize-space(@value),'truefalse, ','')"/>
      <let name="IntegerValueResidue" value="translate(normalize-space(@value),'0123456789+-Ee, ','')"/>
      <let name="FloatValueResidue" value="translate(normalize-space(@value),'0123456789.+-Ee, ','')"/>
      <let name="ImageValueResidue" value="translate(normalize-space(@value),'0123456789+-Ee, 0xABCDEFabcdef','')"/>
      <let name="embeddedWhiteSpaceCount" value="string-length(normalize-space(translate(@value,',',' '))) - string-length(translate(normalize-space(translate(@value,',',' ')),' ',''))"/>
      <let name="embeddedPeriodCount" value="string-length(@value) - string-length(translate(@value,'.',''))"/>
      <let name="parentName" value="local-name(..)"/>
      <extends rule="noDEF"/>
      <extends rule="fieldNameNotReservedWord"/>
      <!--
      <report test="true()" role="diagnostic">$prototypeName=<value-of select='$prototypeName'/>, $fieldValueName=<value-of select='$fieldValueName'/>, $protoFound=<value-of select='$protoFound'/>, $externProtoFound=<value-of select='$externProtoFound'/>, $type=<value-of select='$type'/>, $accessType=<value-of select='$accessType'/> </report>
      -->
      <assert test="parent::ProtoInstance" role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>' name='<value-of select='../@name'/>'> &lt;<name/> value='<value-of select='value'/>'&gt; fieldValue must have parent ProtoInstance </assert>
      <assert test="@name"       role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>' name='<value-of select='../@name'/>'> &lt;<name/> value='<value-of select='value'/>'&gt; fieldValue must have name defined </assert>
      <assert test="(string-length(@value) &gt; 0) or (count(*) &gt; 0) or ($type='SFString') or starts-with($type,'MF')" role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>' name='<value-of select='../@name'/>'> &lt;<name/> name='<value-of select='@name'/>'/&gt; fieldValue with corresponding type='<value-of select='$type'/>' must have initialization value </assert>
      <!-- test for duplicate definition -->
      <assert test="count(preceding-sibling::*[@name=$fieldValueName])=0" role="error">&lt;ProtoInstance name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; has duplicate fieldValue declarations with the same name defined &lt;<name/> name='<value-of select='@name'/>'/&gt; </assert>
      <assert test="not(@name) or not($protoFound)       or       //ProtoDeclare[@name=$prototypeName]/ProtoInterface/field[@name=$fieldValueName]" role="error">&lt;ProtoInstance name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;fieldValue name='<value-of select='@name'/>'/&gt; has no matching &lt;field name='<value-of select='@name'/>'/&gt; in corresponding &lt;ProtoDeclare/&gt; </assert>
      <assert test="not(@name) or not($externProtoFound) or //ExternProtoDeclare[@name=$prototypeName]/field[@name=$fieldValueName]"                role="error">&lt;ProtoInstance name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;fieldValue name='<value-of select='@name'/>'/&gt; has no matching &lt;field name='<value-of select='@name'/>'/&gt; in corresponding &lt;ExternProtoDeclare/&gt; </assert>
      <!-- TODO test for value attribute or contained node -->
      <report test="@value and *" role="error">&lt;ProtoInstance name='<value-of select='../@name'/>' name='<value-of select='@name'/>'/&gt; cannot have both attribute value='<value-of select='@value'/>' and contained node content </report>
      <report test="$inputOutputOnly" role="error">&lt;ProtoInstance name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>'/&gt; initialization not allowed for accessType inputOnly/outputOnly </report>
      <report test="$simpleType and (@value= '' or not(@value)) and not($type='SFString')" role="error">&lt;ProtoInstance name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>'/&gt; has $simpleType=<value-of select='$simpleType'/> but is missing attribute value=&apos;&apos; </report>
      <!-- check accessType initializations -->
      <!-- check for initialization values/nodes present.  note SFNode can have value='NULL' -->
      <report test="($type='SFBool') and not(@value='true' or @value='false')" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; SFBool field must have value='true' or value='false' </report>
      <!-- check for proper characters in initialization values -->
      <report test="($type='MFBool') and (string-length($MFBoolValueResidue) &gt; 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; MFBool field must only include values of true or false </report>
      <!-- TODO are hex values allowed for integers and floats? -->
      <report test="contains($type,'FInt32') and (string-length($IntegerValueResidue) &gt; 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; integer field has illegal characters in value: <value-of select='$IntegerValueResidue'/> </report>
      <report test="(contains($type,'Float') or contains($type,'Rotation') or contains($type,'FVec') or contains($type,'Color') or contains($type,'Time') or contains($type,'Matrix')) and (string-length($FloatValueResidue) &gt; 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; floating-point field has illegal characters in value: <value-of select='$FloatValueResidue'/> </report>
      <report test="contains($type,'Image') and (string-length($ImageValueResidue) &gt; 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; image field has illegal characters in value: <value-of select='$ImageValueResidue'/> </report>
      <!-- check for proper number of initialization values.  whitespace includes commas. -->
      <!--
      <report test="true()" role="diagnostic">field name='<value-of select='@name'/>' $embeddedWhiteSpaceCount=<value-of select='$embeddedWhiteSpaceCount'/> </report>
      -->
      <report test="(string-length(@value) > 0) and (($type='SFBool') or ($type='SFInt32') or ($type='SFFloat') or ($type='SFDouble') or ($type='SFTime')) and ($embeddedWhiteSpaceCount!=0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for type <value-of select='$type'/> </report>
      <report test="(string-length(@value) > 0) and (($type='SFVec2f') or ($type='SFVec2d')) and ($embeddedWhiteSpaceCount!=1)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for 2-tuple type <value-of select='$type'/> </report>
      <report test="(string-length(@value) > 0) and (($type='SFVec3f') or ($type='SFVec3d') or ($type='SFColor')) and ($embeddedWhiteSpaceCount!=2)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for 3-tuple type <value-of select='$type'/> </report>
      <report test="(string-length(@value) > 0) and (($type='SFVec4f') or ($type='SFVec4d') or ($type='SFRotation') or ($type='SFColorRGBA')) and ($embeddedWhiteSpaceCount!=3)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for 4-tuple type <value-of select='$type'/> </report>
      <report test="(string-length(@value) > 0) and (($type='SFMatrix3f') or ($type='SFMatrix3d')) and ($embeddedWhiteSpaceCount!=8)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for 9-tuple type <value-of select='$type'/> </report>
      <report test="(string-length(@value) > 0) and (($type='SFMatrix4f') or ($type='SFMatrix4d')) and ($embeddedWhiteSpaceCount!=15)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='$embeddedWhiteSpaceCount + 1'/>) for 16-tuple type <value-of select='$type'/> </report>
      <!-- array tuple counts -->
      <report test="(string-length(@value) > 0) and (($type='MFVec2f') or ($type='MFVec2d')) and ((($embeddedWhiteSpaceCount + 1) mod 2) != 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 2)'/>) for 2-tuple type <value-of select='$type'/> </report>
      <report test="(string-length(@value) > 0) and (($type='MFVec3f') or ($type='MFVec3d') or ($type='MFColor')) and ((($embeddedWhiteSpaceCount + 1) mod 3) != 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 3)'/>) for 3-tuple type <value-of select='$type'/> </report>
      <report test="(string-length(@value) > 0) and (($type='MFVec4f') or ($type='MFVec4d') or ($type='MFRotation') or ($type='MFColorRGBA')) and ((($embeddedWhiteSpaceCount + 1) mod 4) != 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 4)'/>) for 4-tuple type <value-of select='$type'/> </report>
      <report test="(string-length(@value) > 0) and (($type='MFMatrix3f') or ($type='SFMatrix3d')) and ((($embeddedWhiteSpaceCount + 1) mod 9) != 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 9)'/>) for 9-tuple type <value-of select='$type'/> </report>
      <report test="(string-length(@value) > 0) and (($type='MFMatrix4f') or ($type='MFMatrix4d')) and ((($embeddedWhiteSpaceCount + 1) mod 16) != 0)" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 16)'/>) for 16-tuple type <value-of select='$type'/> </report>
      <report test="($embeddedPeriodCount > $embeddedWhiteSpaceCount + 1) and not(contains($type,'FString'))" role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has excess number of periods (<value-of select='$embeddedPeriodCount'/>) compared to whitespace-separated values (<value-of select='($embeddedWhiteSpaceCount + 1)'/>) </report>
      <report test="$protoFound and (@value=(//ProtoDeclare[@name = $prototypeName]/ProtoInterface/field[@name = $fieldValueName]/@value)) and (string-length(@value) > 0)" role="hint">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt; has default value and is optional </report>
      <!--
      <report test="true()" role="diagnostic">$prototypeName=<value-of select='$prototypeName'/>, $fieldValueName=<value-of select='$fieldValueName'/>, @value=<value-of select='@value'/>, $protoFound=<value-of select='$protoFound'/>, (//ProtoDeclare[@name = $prototypeName]/ProtoInterface/field[@name = $fieldValueName]/@value)=<value-of select='(//ProtoDeclare[@name = $prototypeName]/ProtoInterface/field[@name = $fieldValueName]/@value)'/> </report>
      -->
      <report test="ROUTE" role="hint">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; cannot be contained inside of &lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>' name='<value-of select='../@name'/>'> &lt;fieldValue name='<value-of select='@name'/>' value='<value-of select='@value'/>'/&gt;  </report>
      <!-- no need to reiterate warning about profile/component -->
   </rule>

    <!-- ========= Script node ==========  -->
    <rule context="Script">
      <let name="CDATAblock"         value=          "normalize-space(.)"/>
      <let name="CDATAblockNoSpaces" value="translate(normalize-space(.),' ','')"/>
      <extends rule="DEFtests"/>
      <extends rule="hasUrl"/>
      <!-- TODO check miscapitalization of data types, MFVec3F etc. -->
      <!-- TODO check external script -->
      <!--
      <let name="firstScriptUrl"  value="substring-before(substring-after($normalizedString,'&quot;'),'&quot;')"/>
      <report test="true()" role="trace">$firstScriptUrl=<value-of select='$firstScriptUrl'/> </report>
      OK so far...  however document() does not resolve to correct directory :(
      <let name="firstScriptUrlDocument"  value="document($firstScriptUrl)"/>
      <report test="true()" role="trace">$firstScriptUrlDocument=&#10;<value-of select='$firstScriptUrlDocument'/> </report>
      -->
      <!-- support for text() or . seems inconsistent, so check both -->
      <!-- <let name="CDATAtext" value="normalize-space(text())"/> -->
      <!-- <report test="true()"  role="diagnostic">$CDATAblock=<value-of select='$CDATAblock'/> </report> -->
      <assert test="@DEF or @USE or (local-name(..)='ProtoBody') or contains(translate($CDATAblock,' ',''),'initialize()')" role="warning">&lt;<name/>/&gt; must have DEF name in order to ROUTE events </assert>
      <assert test="@url or @USE or boolean(IS/connect[@nodeField='url']) or (string-length($CDATAblock) &gt; 1)" role="error">&NodeDEFname; needs url or contained CDATA source </assert>
      <assert test="@url or @USE or boolean(IS/connect[@nodeField='url']) or (string-length($CDATAblock) &lt; 2) or starts-with($CDATAblock,'ecmascript:')" role="error">&NodeDEFname; contained CDATA source block must start with 'ecmascript:'</assert> <!-- "<value-of select='$CDATAblock'/>" -->
      <assert test="@url or @USE or boolean(IS/connect[@nodeField='url']) or (string-length($CDATAblock) &lt; 2) or field or contains($CDATAblock,'initialize()')" role="warning">&NodeDEFname; contained CDATA source block needs initialize() method when no fields and no url are defined, otherwise has no action </assert>
      <!-- Xj3D and others say that var declarations are OK
      <report test="contains($CDATAblock,'var ')" role="error">&NodeDEFname; contains var declarations, use &lt;field /&gt; declarations for variables instead </report>
      -->
      <report test="contains(@url,'ecmascript:')  and contains(@url,'//')" role="error">&NodeDEFname; url='ecmascript: ...' also contains // inline comments, which can hide all source code that follows </report>
      <report test="contains($CDATAblock,'TRUE')  and not(contains($CDATAblock,'createVrmlFromString'))" role="error">&NodeDEFname; source code contains boolean constant TRUE, use lower-case 'true' instead to match XML and JavaScript/ECMAScript rules </report>
      <report test="contains($CDATAblock,'FALSE') and not(contains($CDATAblock,'createVrmlFromString'))" role="error">&NodeDEFname; source code contains boolean constant FALSE, use lower-case 'false' instead to match XML and JavaScript/ECMAScript rules </report>
      <report test="contains($CDATAblock,'TRUE')  and     contains($CDATAblock,'function initialize')  and not(contains($CDATAblockNoSpaces,'functioninitialize()'))" role="error">&NodeDEFname; initialize() method in contained CDATA source block cannot have any calling parameters </report>
      <!-- TODO check ROUTEs in/out for matching DEF name -->
      <assert test="(not(//ROUTE[@toNode=$DEF]) and not(//ROUTE[@fromNode=$DEF])) or field" role="error">&NodeDEFname; missing field definition to receive ROUTE events </assert>
      <report test="fieldValue" role="error">&NodeDEFname; contains &lt;fieldValue name='<value-of select='fieldValue/@name'/>/&gt; but instead should be &lt;field name='<value-of select='fieldValue/@name'/>/&gt; </report>
      <!-- TODO check ROUTEs in/out for accessType -->
      <!-- TODO DEF/USE for a Script seems questionable... maybe passed as a parameter? -->
      <report test="(string-length($CDATAblock) > 2) and (string-length(normalize-space(@url)) > 2)"  role="warning">&NodeDEFname; contains both internal CDATA source and external url reference, note that external url takes precedence </report>
      <!-- file extension checks -->
      <report test="(string-length(@url) > 2) and not(contains(@url,'ecmascript:')) and not(contains(@url,'.js')) and not(contains(@url,'.class')) and not(contains(@url,'.jar'))" role="warning">&NodeDEFname; url array does not contains link to .js .class or .jar scripts, browsers not required to support other scripting languages (url='<value-of select='@url'/>') </report>
      <report test="(@directOutput='TRUE' )" role="error">&NodeDEFname; directOutput='TRUE'  directOutput='true' instead</report>
      <report test="(@directOutput='FALSE')" role="error">&NodeDEFname; directOutput='FALSE'  directOutput='false' instead</report>
      <report test="(@mustEvaluate='TRUE' )" role="error">&NodeDEFname; mustEvaluate='TRUE'  mustEvaluate='true' instead</report>
      <report test="(@mustEvaluate='FALSE')" role="error">&NodeDEFname; mustEvaluate='FALSE'  mustEvaluate='false' instead</report>
      <!-- TODO XSLT 2.0:
      and not(contains(@url,'.js&quot;')) and not(contains(@url,'.class&quot;')) and not(contains(@url,'.jar&quot;'))
                                                                                    and not(ends-with(@url,'.js'))      and not(ends-with(@url,'.class'))      and not(ends-with(@url,'.jar')) -->    
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Scripting'][number(@level) ge 1] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Scripting' level='1'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= IS element ========== -->
    <rule context="IS">
      <extends rule="noDEF"/>
      <assert test="ancestor::ProtoDeclare" role="error">&lt;<value-of select='local-name(..)'/> DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/>/&gt; must have ancestor::ProtoDeclare </assert>
      <!-- no need to reiterate warning about profile/component -->
    </rule>

    <!-- ========= connect element ========== -->
    <rule context="connect">
      <let name="nodeField" value="@nodeField"/>
      <extends rule="noDEF"/>
      <assert test="parent::IS" role="error">&lt;<name/> nodeField=<value-of select='@nodeField'/> protoField=<value-of select='@protoField'/>/&gt; must have parent IS </assert>
      <!-- test for multiple definitions fanning into a single nodeField -->
      <report test="(preceding-sibling::connect[@nodeField=$nodeField]) and not(following-sibling::connect[@nodeField=$nodeField])" role="error">&lt;<name/> nodeField=<value-of select='@nodeField'/>/&gt; cannot have multiple definitions to a single field of this node</report>
      <!-- no need to reiterate warning about profile/component -->
    </rule>

    <!-- ========= ProtoDeclare element ========== -->
    <rule context="ProtoDeclare">
      <let name="name" value="@name"/>
      <let name="NodeName"                  value="local-name()"/>
      <let name="priorProtoFound"           value="preceding::ProtoDeclare[@name = $name]"/>
      <let name="externProtoFound"          value="     ExternProtoDeclare[@name = $name]"/>
      <let name="ProtoDeclareLabel"   value="concat('&lt;ProtoDeclare name=&quot;',$name,'&quot;/&gt;')"/>
      <extends rule="noDEF"/>
      <extends rule="nameNotReservedWord"/>
      <assert test="$name"  role="error">&lt;ProtoDeclare name=''/>'/&gt; is required to have a name </assert>
      <assert test="ProtoBody" role="error"><value-of select='$ProtoDeclareLabel'/> must include ProtoBody </assert>
      <report test="//ProtoInstance and not(//ProtoInstance[@name=$name])" role="warning"><value-of select='$ProtoDeclareLabel'/> has no corresponding &lt;ProtoInstance name='<value-of select='@name'/>'/&gt; </report>
      <report test="$priorProtoFound"   role="error"><value-of select='$ProtoDeclareLabel'/> has multiple ProtoDeclare definitions with same name </report>
      <report test="$externProtoFound"  role="error"><value-of select='$ProtoDeclareLabel'/> has both ProtoDeclare and ExternProtoDeclare definitions with same name </report>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Core'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Core' level='2'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= ProtoInterface element ========== -->
    <rule context="ProtoInterface">
      <extends rule="noDEF"/>
      <assert test="*" role="error">&lt;ProtoDeclare name='<value-of select='../@name'/>'&gt; ProtoInterface, if used, must contain one or more field declarations </assert>
      <assert test="count(*)=count(field)" role="error">&lt;ProtoDeclare name='<value-of select='../@name'/>'&gt; ProtoInterface can only contain field declarations or comments </assert>
      <report test="fieldValue" role="error">&lt;ProtoDeclare name='<value-of select='../@name'/>'&gt; ProtoInterface contains &lt;fieldValue name='<value-of select='fieldValue/@name'/>/&gt; rather than &lt;field name='<value-of select='fieldValue/@name'/>/&gt; </report>
      <!-- no need to reiterate warning about profile/component -->
    </rule>

    <!-- ========= ProtoBody element ========== -->
    <rule context="ProtoBody">
      <extends rule="noDEF"/>
      <!-- TODO ensure ROUTE source and target nodes within ProtoBody scope -->
      <assert test="node()" role="error">&lt;ProtoDeclare name='<value-of select='../@name'/>'&gt; ProtoBody must contain at least one node </assert>
      <report test="not(ProtoBody/comment()[position()=1]) and not(ProtoBody/comment()[position()=2]) and (ProtoBody/Shape[position()>1] or ProtoBody/*[position()>1]//Shape)" role="error">&lt;ProtoDeclare name='<value-of select='../@name'/>'&gt; ProtoBody child (or descendant) Shape following first child will not be rendered, since the first child determines node type. (Authors can silence this warning by placing a comment as second child.) </report>
      <!-- no need to reiterate warning about profile/component -->
    </rule>

    <!-- ========= ExternProtoDeclare element ========== -->
    <rule context="ExternProtoDeclare">
      <let name="name" value="@name"/>
      <let name="url" value="normalize-space(translate(@url, ',',' '))"/>
      <let name="NodeName"                  value="local-name()"/>
      <let name="protoFound"                value="                 ProtoDeclare[@name = $name]"/>
      <let name="priorExternProtoNameFound" value="preceding::ExternProtoDeclare[@name = $name]"/>
      <let name="priorExternProtoUrlFound"  value="preceding::ExternProtoDeclare[normalize-space(@url) = normalize-space($url)]"/>
      <let name="ExternProtoDeclareLabel"   value="concat('&lt;ExternProtoDeclare name=&quot;',$name,'&quot;/&gt;')"/>
      <let name="urlCount"     value="string-length($url)    - string-length(translate($url,  ' ','')) + 1"/>
      <extends rule="noDEF"/>
      <extends rule="nameNotReservedWord"/>
      <!-- illegal:  no DEF in ExternProtoDeclare <extends rule="hasUrl"/> -->
      <assert test="$name"  role="error">&lt;ExternProtoDeclare name=''/>'/&gt; is required to have a name, but name is missing </assert>
      <assert test="//ProtoInstance[@name=$name]" role="warning"><value-of select='$ExternProtoDeclareLabel'/> has no corresponding ProtoInstance </assert>
      <report test="$priorExternProtoNameFound"     role="error"><value-of select='$ExternProtoDeclareLabel'/> has multiple ExternProtoDeclare declarations with same name </report>
      <report test="$priorExternProtoUrlFound"      role="error"><value-of select='$ExternProtoDeclareLabel'/> has a prior ExternProtoDeclare declaration with same url </report>
      <report test="$protoFound"                    role="error"><value-of select='$ExternProtoDeclareLabel'/> has both ProtoDeclare or ExternProtoDeclare declarations with same name </report>
      <assert test="@url"                           role="error"><value-of select='$ExternProtoDeclareLabel'/> must contain url array address(es) to find external prototype declaration </assert>
      <report test="(@url) and not(contains(@url,'#'))" role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array address(es) missing #<value-of select='$name'/> appended </report>
      <report test="(@url) and contains(@url,'#') and not(contains(@url,concat('#',$name)))" role="info"><value-of select='$ExternProtoDeclareLabel'/> url array references remote prototype name different from #<value-of select='$name'/> </report>
      <report test="(@url) and contains(@url,'#&quot;')" role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array contains url ending with # reference to a specific prototype, but without required #PrototypeName </report>
      <!-- the following rules are adapted from hasUrl -->
      <assert test="($urlCount  &gt; 0)"  role="error"><value-of select='$ExternProtoDeclareLabel'/> has illegal number of values in url array </assert>
      <assert test="not(contains($url,'&quot;&quot;'))"  role="error"><value-of select='$ExternProtoDeclareLabel'/> url array has adjacent &quot;quote marks&quot; unseparated by other characters </assert>
      <report test="contains(substring-after(@url,'.wrl&quot;'),'.x3d#')" role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array has .wrl scene reference before .x3d scene reference </report>
      <report test="(@url) and not(contains(@url,'http'))" role="info"><value-of select='$ExternProtoDeclareLabel'/> url array address(es) missing online http references </report>
      <report test="contains(@url,':///')" role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array contains triple forward-slash :/// characters </report>
      <report test="contains(@url,':/') and not(contains(@url,'://'))" role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array contains :/ rather than :// </report>
      <report test="contains(@url,'\')" role="error"><value-of select='$ExternProtoDeclareLabel'/> url array contains backslash \ character(s) (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,'&quot;/')" role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array contains contains entry starting at root directory / (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,'file:/')" role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array contains file:/ local address, not portable across Web servers (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,'http:/')  and not(contains(@url,'http://'))"  role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array contains http:/ rather than http:// (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,'https:/') and not(contains(@url,'https://'))" role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array contains https:/ rather than https:// (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,':/') and not(contains(@url,'://')) and not(contains(@url,'http://')) and not(contains(@url,'https://'))" role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array contains :/ rather than :// (url='<value-of select='@url'/>') </report>
      <report test="contains(@url,'.wrl') and not(contains(@url,'.x3d'))" role="warning"><value-of select='$ExternProtoDeclareLabel'/> url array contains .wrl link without corresponding .x3d version, some browsers may fail (url='<value-of select='@url'/>') </report>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Core'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Core' level='2'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= ProtoInstance node ========== -->
    <rule context="ProtoInstance">
      <let name="name" value="@name"/>
      <let name="NodeName"                  value="local-name()"/>
      <let name="DEFUSElabel"               value="concat('DEF=&quot;',@DEF,'&quot; USE=&quot;',@USE,'&quot;')"/>
      <let name="protoFound"                value="      //ProtoDeclare[@name = $name]"/>
      <let name="externProtoFound"          value="//ExternProtoDeclare[@name = $name]"/>
      <let name="declarationFound"          value="$protoFound or $externProtoFound"/>
      <let name="doubleDeclaration"         value="not($externProtoFound and $protoFound)"/>
      <let name="precedingProtoFound"       value="preceding::ProtoDeclare[@name = $name]"/>
      <let name="precedingExternProtoFound" value="preceding::ExternProtoDeclare[@name = $name]"/>
      <let name="nodeLabel"                 value="concat('&lt;ProtoInstance name=&quot;',$name,'&quot; ',$DEFUSElabel,'/&gt;')"/>
      <extends rule="DEFtests"/>
      <extends rule="nameNotReservedWord"/>
      <assert test="$name"  role="error">&lt;ProtoInstance name='' DEF='<value-of select='@DEF'/>'/>'/&gt; is required to have a name </assert>
      <assert test="$declarationFound"  role="error"><value-of select='$nodeLabel'/> has no ProtoDeclare or ExternProtoDeclare with same name </assert>
      <assert test="$doubleDeclaration" role="error"><value-of select='$nodeLabel'/> has both ProtoDeclare and ExternProtoDeclare with same name </assert>
      <report test="$declarationFound and not($externProtoFound) and $protoFound and not($precedingProtoFound)"       role="error"><value-of select='$nodeLabel'/> precedes &lt;ProtoDeclare name='<value-of select='$name'/> </report>
      <report test="$declarationFound and not($protoFound) and $externProtoFound and not($precedingExternProtoFound)" role="error"><value-of select='$nodeLabel'/> precedes &lt;ExternProtoDeclare name='<value-of select='$name'/> </report>
      <report test="field" role="error"><value-of select='$nodeLabel'/> contains &lt;field name='<value-of select='$name'/>/&gt; rather than &lt;fieldValue name='<value-of select='$name'/>/&gt; </report>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Core'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Core' level='2'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= Extrusion ========== -->
    <rule context="Extrusion">
      <let name="crossSection"             value="normalize-space(translate(@crossSection,',',' '))"/>
      <let name="spine"                    value="normalize-space(translate(@spine,       ',',' '))"/>
      <let name="scale"                    value="normalize-space(translate(@scale,       ',',' '))"/>
      <let name="orientation"              value="normalize-space(translate(@orientation, ',',' '))"/>
      <let name="crossSectionCount"        value="string-length($crossSection)      - string-length(translate($crossSection,' ','')) + 1"/>
      <let name="spineCount"               value="string-length($spine)             - string-length(translate($spine,       ' ','')) + 1"/>
      <let name="scaleCount"               value="string-length($scale)             - string-length(translate($scale,       ' ','')) + 1"/>
      <let name="orientationCount"         value="string-length($orientation)       - string-length(translate($orientation, ' ','')) + 1"/>
      <let name="crossSectionResidue"      value="translate($crossSection,     '+-0123456789Ee., ','')"/>
      <let name="spineResidue"             value="translate($spine,            '+-0123456789Ee., ','')"/>
      <let name="scaleResidue"             value="translate($scale,            '+-0123456789Ee., ','')"/>
      <let name="orientationResidue"       value="translate($orientation,      '+-0123456789Ee., ','')"/>
      <extends rule="geometryNode"/>
      <extends rule="NoChildNode"/>
      <extends rule="creaseAngle"/>
      <report test="($crossSectionCount = 0)" role="warning">&NodeDEFname; missing crossSection </report>
      <report test="($spineCount = 0)"        role="warning">&NodeDEFname; missing spine </report>
      <assert test="string-length($crossSectionResidue) = 0" role="error">&NodeDEFname; has illegal character <value-of select='$crossSectionResidue'/> in crossSection array (crossSection='<value-of select='@crossSection'/>') </assert>
      <assert test="string-length($scaleResidue)        = 0" role="error">&NodeDEFname; has illegal character <value-of select='$scaleResidue'/> in scale array (scale='<value-of select='@scale'/>') </assert>
      <assert test="string-length($spineResidue)        = 0" role="error">&NodeDEFname; has illegal character <value-of select='$spineResidue'/> in spine array (spine='<value-of select='@spine'/>') </assert>
      <assert test="string-length($orientationResidue)  = 0" role="error">&NodeDEFname; has illegal character <value-of select='$orientationResidue'/> in orientation array (orientation='<value-of select='@orientation'/>') </assert>
      <!-- check for legal array tuples -->
      <assert test="(($crossSectionCount mod 2) = 0)" role="warning">&NodeDEFname; crossSection array size <value-of select='$crossSectionCount div 2'/> does not have legal number of MFVec2f values, must be evenly divisible by 2 (crossSection='<value-of select='@crossSection'/>') </assert>
      <assert test="(($scaleCount mod 2)        = 0)" role="warning">&NodeDEFname; scale array size <value-of select='$scaleCount div 2'/> does not have legal number of MFVec2f values, must be evenly divisible by 2 (scale='<value-of select='@scale'/>') </assert>
      <assert test="(($spineCount mod 3)        = 0)" role="warning">&NodeDEFname; spine array size <value-of select='$spineCount div 3'/> does not have legal number of MFVec3f values, must be evenly divisible by 3 (spine='<value-of select='@spine'/>') </assert>
      <assert test="(($orientationCount mod 4)  = 0)" role="warning">&NodeDEFname; orientation array size <value-of select='$orientationCount div 4'/> does not have legal number of MFRotation values, must be evenly divisible by 4 (orientation='<value-of select='@orientation'/>') </assert>
      <!-- check for sufficient array size -->
      <assert test="(($spineCount = 0)      or ($spineCount &gt; 5))" role="error">&NodeDEFname; spine array size of <value-of select='$spineCount'/> is insufficient to define a line segment, must have 6 or more values (spine='<value-of select='@spine'/>') </assert>
      <!-- check for matching array sizes -->
      <assert test="($scaleCount = 0)       or ($scaleCount = 2)       or (($scaleCount div 2)       = ($spineCount div 3))" role="warning">&NodeDEFname; scale array size <value-of select='$scaleCount div 2'/> (scale='<value-of select='@scale'/>') must match spine array size <value-of select='$spineCount div 3'/> </assert>
      <assert test="($orientationCount = 0) or ($orientationCount = 4) or (($orientationCount div 4) = ($spineCount div 3))" role="warning">&NodeDEFname; orientation array size <value-of select='$orientationCount div 4'/> (orientation='<value-of select='@orientation'/>') must match spine array size <value-of select='$spineCount div 3'/> </assert>
      <report test="(@beginCap='TRUE' )" role="error">&NodeDEFname; beginCap='TRUE'  beginCap='true' instead</report>
      <report test="(@beginCap='FALSE')" role="error">&NodeDEFname; beginCap='FALSE'  beginCap='false' instead</report>
      <report test="(@endCap='TRUE'   )" role="error">&NodeDEFname; endCap='TRUE'  endCap='true' instead</report>
      <report test="(@endCap='FALSE'  )" role="error">&NodeDEFname; endCap='FALSE'  endCap='false' instead</report>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Geometry3D'][number(@level) ge 4] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Geometry3D' level='4'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= Text ========== -->
    <rule context="Text">
      <let name="stringResidueApos" value="translate(@string,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="stringResidue" value='translate($stringResidueApos,"&apos;","")'/>
      <!-- this approach to counting quotation marks supports internationalization I18N, but doesn't count escaped quotes -->
      <let name="quot" value="substring('&quot;&quot;',1,1)"/>
      <let name="unquotedString" value="translate(@string,$quot,'')"/>
      <let name="escapedQuoteCharacters" value='concat("\\",$quot)'/> 
      <!-- TODO no apparent way to count $escapedQuoteCharacters substrings;  + count(@string,$escapedQuoteCharacters) &#92; \ Backslash; #34; amp; -->
      <let name="quoteCount" value='string-length(@string) - string-length($unquotedString)'/>
      <let name="normalizedString" value="normalize-space(@string)"/>
      <let name="lastCharacter" value="substring($normalizedString,string-length($normalizedString))"/>
      <extends rule="geometryNode"/>
      <report test="(@lineBounds) and (/X3D[@version='3.0'])" role="warning">&NodeDEFname; lineBounds='<value-of select='@lineBounds'/>' requires &lt;X3D version=&apos;3.1&apos;&gt; or higher, but found version='<value-of select='/X3D/@version'/>' </report>
      <report test="(@textBounds) and (/X3D[@version='3.0'])" role="warning">&NodeDEFname; textBounds='<value-of select='@textBounds'/>' requires &lt;X3D version=&apos;3.1&apos;&gt; or higher, but found version='<value-of select='/X3D/@version'/>' </report>
      <assert test="@USE or @string or (@string = ' ') or //ROUTE[@toNode=$DEF] or boolean(IS/connect[@nodeField='string']) or (//ProtoDeclare/ProtoInterface/field/*[@USE=$DEF]) or (//Script/field/*[@USE=$DEF])" role="warning">&TextNodeDEFname; has no value(s) in string='' array </assert>
      <!-- TODO need fn:count function <let name="quoteCount" value="count(@string,'&quot;') - count(@string,'\&quot;')"/> -->
      <report test="false()" role="trace">$quoteCount=<value-of select='$quoteCount'/>, $quot=<value-of select='$quot'/>, $escapedQuoteCharacters=<value-of select='$escapedQuoteCharacters'/>, $unquotedString=<value-of select='$unquotedString'/>, $stringResidueApos=<value-of select='$stringResidueApos'/> , $lastCharacter=<value-of select='$lastCharacter'/> </report>
      <!-- MFString array checks -->
      <report test="not(@USE) and contains($normalizedString,'&quot;&quot;') and not(contains($normalizedString,'\&quot;&quot;') or contains($normalizedString,'&quot;\&quot;') or contains($normalizedString,'&quot;&quot; &quot;') or contains($normalizedString,'&quot; &quot;&quot;'))"  role="error">&TextNodeDEFname; string array has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@string) and not(contains(@string,'&quot;'))"    role="error">&TextNodeDEFname; string array needs to begin and end with &quot;quote marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' string=&apos;&quot;<value-of select='(@string)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@string) and    (contains(@string,'&quot;')) and (($quoteCount div 2)!=round($quoteCount div 2)) and not(contains(@string,'\&quot;'))"    role="error">&TextNodeDEFname; string array has <value-of select='($quoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@string) and (contains(@string,'\&quot;'))"    role="warning">&TextNodeDEFname; has <value-of select='($quoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;') and (contains(@string,'&quot;'))"    role="error">&TextNodeDEFname; array of string values needs to begin and end with &quot;quote marks&quot; </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and    ($lastCharacter='&quot;')"                                     role="error">&TextNodeDEFname; array of string values needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($normalizedString) and    (starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;')"                                     role="error">&TextNodeDEFname; array of string values needs to end with quote mark &quot; </report>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Text'][number(@level) ge 1] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Text' level='1'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= FontStyle ========== -->
    <rule context="FontStyle">
      <let name="stringResidueApos" value="translate(@family,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="stringResidue" value='translate($stringResidueApos,"&apos;","")'/>
      <let name="quoteCount" value="string-length($stringResidue)"/>
      <let name="normalizedString" value="normalize-space(@family)"/>
      <let name="lastCharacter" value="substring($normalizedString,string-length($normalizedString))"/>
      <let name="justifyStringResidueApos" value="translate(@justify,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="justifyStringResidue" value='translate($justifyStringResidueApos,"&apos;","")'/>
      <let name="justifyQuoteCount" value="string-length($justifyStringResidue)"/>
      <let name="justifyNormalizedString" value="normalize-space(@justify)"/>
      <let name="justifyLastCharacter" value="substring($justifyNormalizedString,string-length($justifyNormalizedString))"/>
      <let name="justifyValuesResidue" value="translate(@justify,' ,BEGINENDFIRSTMIDDLE&quot;','')"/>
      <let name="justifyIllegalValue" value="not(@USE) and (@justify) and (string-length($justifyValuesResidue) > 0)"/>
      <extends rule="DEFtests"/>
      <report test="not(parent::Text) and not(parent::field) and not(parent::fieldValue)" role="error">&NodeDEFname; has parent <value-of select='local-name(..)'/> node, must be contained by Text node </report>
      <!-- family field MFString array checks -->
      <report test="false()" role="trace">$quoteCount=<value-of select='$quoteCount'/>, $stringResidue=<value-of select='$stringResidue'/>, $stringResidueApos=<value-of select='$stringResidueApos'/> , $lastCharacter=<value-of select='$lastCharacter'/> </report>
      <report test="not(@USE) and contains($normalizedString,'&quot;&quot;') and not(contains($normalizedString,'\&quot;&quot;') or contains($normalizedString,'&quot;\&quot;') or contains($normalizedString,'&quot;&quot; &quot;') or contains($normalizedString,'&quot; &quot;&quot;'))"  role="error">&NodeDEFname; array family='<value-of select='@family'/>' has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@family) and not(contains(@family,'&quot;'))"    role="error">&NodeDEFname; array family='<value-of select='@family'/>' needs to begin and end with &quot;quote marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' family=&apos;&quot;<value-of select='(@family)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@family) and    (contains(@family,'&quot;')) and (($quoteCount div 2)!=round($quoteCount div 2)) and not(contains(@family,'\&quot;'))"    role="error">&NodeDEFname; array family='<value-of select='@family'/>' has <value-of select='($quoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@family) and (contains(@family,'\&quot;'))"    role="warning">&NodeDEFname; array family='<value-of select='@family'/>' has <value-of select='($quoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;') and (contains(@family,'&quot;'))"    role="error">&NodeDEFname; array family='<value-of select='@family'/>' needs to begin and end with &quot;quote marks&quot; </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and    ($lastCharacter='&quot;')"                                     role="error">&NodeDEFname; array family='<value-of select='@family'/>' needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($normalizedString) and    (starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;')"                                     role="error">&NodeDEFname; array family='<value-of select='@family'/>' needs to end with quote mark &quot; </report>
      <!-- justify field MFString array checks -->
      <report test="false()" role="trace">$justifyQuoteCount=<value-of select='$justifyQuoteCount'/>, $justifyStringResidue=<value-of select='$justifyStringResidue'/>, $justifyStringResidueApos=<value-of select='$justifyStringResidueApos'/> , $justifyLastCharacter=<value-of select='$justifyLastCharacter'/> </report>
      <report test="not(@USE) and contains($justifyNormalizedString,'&quot;&quot;') and not(contains($justifyNormalizedString,'\&quot;&quot;') or contains($justifyNormalizedString,'&quot;\&quot;') or contains($justifyNormalizedString,'&quot;&quot; &quot;') or contains($justifyNormalizedString,'&quot; &quot;&quot;'))"  role="error">&NodeDEFname; array justify has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@justify) and not(contains(@justify,'&quot;'))"    role="error">&NodeDEFname; array justify needs to begin and end with &quot;quote marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' justify=&apos;&quot;<value-of select='(@justify)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@justify) and    (contains(@justify,'&quot;')) and (($justifyQuoteCount div 2)!=round($justifyQuoteCount div 2)) and not(contains(@justify,'\&quot;'))"    role="error">&NodeDEFname; array justify has <value-of select='($justifyQuoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@justify) and (contains(@justify,'\&quot;'))"    role="warning">&NodeDEFname; has <value-of select='($justifyQuoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($justifyNormalizedString) and not(starts-with($justifyNormalizedString,'&quot;')) and not($justifyLastCharacter='&quot;') and (contains(@justify,'&quot;'))"    role="error">&NodeDEFname; array justify needs to begin and end with &quot;quote marks&quot; </report>
      <report test="not(@USE) and ($justifyNormalizedString) and not(starts-with($justifyNormalizedString,'&quot;')) and    ($justifyLastCharacter='&quot;')"                                     role="error">&NodeDEFname; array justify needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($justifyNormalizedString) and    (starts-with($justifyNormalizedString,'&quot;')) and not($justifyLastCharacter='&quot;')"                                     role="error">&NodeDEFname; array justify needs to end with quote mark &quot; </report>
      <!-- additional checks -->
      <report test="(@family) and not(contains(@family,'SANS')) and not(contains(@family,'SERIF')) and not(contains(@family,'TYPEWRITER'))"    role="warning">&NodeDEFname; array family='<value-of select='@family'/>' does not contain any of the guaranteed-support fonts (&quot;SANS&quot; &quot;SERIF&quot; or &quot;TYPEWRITER&quot;) </report>
      <report test="$justifyIllegalValue"    role="error">&NodeDEFname; array justify='<value-of select='@justify'/>' has illegal value, need to include 2 legal values: &quot;BEGIN&quot; &quot;END&quot; &quot;FIRST&quot; &quot;MIDDLE&quot; </report>
      <report test="contains(@family, ' ') and not(contains(@family, '&quot; &quot;'))"    role="error">&NodeDEFname; array family='<value-of select='@family'/>' values must each be quoted </report>
      <report test="contains(@justify,' ') and not(contains(@justify,'&quot; &quot;'))"    role="error">&NodeDEFname; array justify='<value-of select='@justify'/>' values must each be quoted, need to include 2 legal values: &quot;BEGIN&quot; &quot;END&quot; &quot;FIRST&quot; &quot;MIDDLE&quot; </report>
      <report test="contains(upper-case(@justify),'LEFT')" role="error">&NodeDEFname; array justify='<value-of select='@justify'/>' value &quot;LEFT&quot; is not allowed, use &quot;BEGIN&quot; instead (legal values: &quot;BEGIN&quot; &quot;END&quot; &quot;FIRST&quot; &quot;MIDDLE&quot;) </report>
      <report test="contains(upper-case(@justify),'RIGHT')" role="error">&NodeDEFname; array justify='<value-of select='@justify'/>' value &quot;RIGHT&quot; is not allowed, use &quot;END&quot; instead (legal values: &quot;BEGIN&quot; &quot;END&quot; &quot;FIRST&quot; &quot;MIDDLE&quot;) </report>
      <report test="contains(upper-case(@justify),'TOP')" role="error">&NodeDEFname; array justify='<value-of select='@justify'/>' value &quot;TOP&quot; is not allowed, use &quot;BEGIN&quot; instead (legal values: &quot;BEGIN&quot; &quot;END&quot; &quot;FIRST&quot; &quot;MIDDLE&quot;) </report>
      <report test="contains(upper-case(@justify),'BOTTOM')" role="error">&NodeDEFname; array justify='<value-of select='@justify'/>' value &quot;BOTTOM&quot; is not allowed, use &quot;END&quot; instead (legal values: &quot;BEGIN&quot; &quot;END&quot; &quot;FIRST&quot; &quot;MIDDLE&quot;) </report>
      <report test="contains(upper-case(@justify),'CENTER')" role="error">&NodeDEFname; array justify='<value-of select='@justify'/>' value &quot;CENTER&quot; is not allowed, use &quot;MIDDLE&quot; instead (legal values: &quot;BEGIN&quot; &quot;END&quot; &quot;FIRST&quot; &quot;MIDDLE&quot;) </report>
      <report test="not(@USE) and (@justify) and not($justifyIllegalValue) and not(@justify='&quot;BEGIN&quot;') and ($justifyQuoteCount = 2)"  role="warning">&NodeDEFname; array justify='<value-of select='@justify'/>' has only 1 value for major-axis justification, add another value for minor-axis justification:  &quot;BEGIN&quot; &quot;END&quot; &quot;FIRST&quot; &quot;MIDDLE&quot; (default is &quot;FIRST&quot;)</report>
      <report test="not(@USE) and (@justify) and ($justifyQuoteCount > 4)"  role="warning">&NodeDEFname; array justify='<value-of select='@justify'/>' has too many values, only 2 quoted values are needed: &quot;BEGIN&quot; &quot;END&quot; &quot;FIRST&quot; &quot;MIDDLE&quot; </report>
      <report test="(@horizontal='TRUE' )"  role="error">&NodeDEFname; horizontal='TRUE'  horizontal='true' instead</report>
      <report test="(@horizontal='FALSE')"  role="error">&NodeDEFname; horizontal='FALSE'  horizontal='false' instead</report>
      <report test="(@leftToRight='TRUE' )" role="error">&NodeDEFname; leftToRight='TRUE'  leftToRight='true' instead</report>
      <report test="(@leftToRight='FALSE')" role="error">&NodeDEFname; leftToRight='FALSE'  leftToRight='false' instead</report>
      <report test="(@topToBottom='TRUE' )" role="error">&NodeDEFname; topToBottom='TRUE'  topToBottom='true' instead</report>
      <report test="(@topToBottom='FALSE')" role="error">&NodeDEFname; topToBottom='FALSE'  topToBottom='false' instead</report>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@language, '&quot;')" role="error">&NodeDEFname; language='<value-of select='@language'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="contains(@style,    '&quot;')" role="error">&NodeDEFname; style='<value-of select='@style'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Text'][number(@level) ge 1] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Text' level='1'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= FillProperties ========== -->
    <rule context="FillProperties">
      <extends rule="DEFtests"/>
      <report test="(@hatchStyle &lt; 1)" role="warning">&NodeDEFname; hatchStyle='<value-of select='@hatchStyle'/>' is less than minimum defined value of 1 </report>
      <report test="(@hatchStyle > 19)" role="warning">&NodeDEFname; hatchStyle='<value-of select='@hatchStyle'/>' is greater than maximum defined value of 19 </report>
      <report test="(@filled='TRUE' )" role="error">&NodeDEFname; filled='TRUE'  filled='true' instead</report>
      <report test="(@filled='FALSE')" role="error">&NodeDEFname; filled='FALSE'  filled='false' instead</report>
      <report test="(@hatched='TRUE' )" role="error">&NodeDEFname; hatched='TRUE'  hatched='true' instead</report>
      <report test="(@hatched='FALSE')" role="error">&NodeDEFname; hatched='FALSE'  hatched='false' instead</report>
      <assert test="((/X3D[@profile='Full']) or (/X3D/head/component[@name='Shape'][number(@level) ge 3]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Shape' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>

    <!-- ========= LineProperties ========== -->
    <rule context="LineProperties">
      <extends rule="DEFtests"/>
      <report test="(@lineType &lt; 1)" role="warning">&NodeDEFname; lineType='<value-of select='@lineType'/>' is less than minimum defined value of 1 </report>
      <report test="(@lineType > 19)" role="warning">&NodeDEFname; lineType='<value-of select='@lineType'/>' is greater than maximum defined value of 19 </report>
      <report test="(@applied='TRUE' )" role="error">&NodeDEFname; applied='TRUE'  applied='true' instead</report>
      <report test="(@applied='FALSE')" role="error">&NodeDEFname; applied='FALSE'  applied='false' instead</report>
      <assert test="((/X3D[@profile='Full']) or (/X3D/head/component[@name='Shape'][number(@level) ge 2]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Shape' level='2'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>

    <!-- ========= Sound ========== -->
    <rule context="Sound">
      <extends rule="DEFtests"/>
      <assert test="@USE or AudioClip or MovieTexture" role="warning">&NodeDEFname; has no child AudioClip or MovieTexture node </assert>
      <report test="(@spatialize='TRUE' )" role="error">&NodeDEFname; spatialize='TRUE'  spatialize='true' instead</report>
      <report test="(@spatialize='FALSE')" role="error">&NodeDEFname; spatialize='FALSE'  spatialize='false' instead</report>
      <report test="not(@USE) and (contains(@location,' 0 ') or contains(@location,' 0.0 ')) and not(parent::Transform)" role="warning">&NodeDEFname; location='<value-of select='@location'/>' has height of sound ellipse centered on ground plane, consider changing location y-value to 1.6 in order to match typical avatar height (in meters) </report>
      <report test="not(@USE) and ((0 > @minBack)  or (0 > @maxBack))"  role="warning">&NodeDEFname; minBack='<value-of select='@minBack'/>' maxBack='<value-of select='@maxBack'/>' has negative value for distance along back direction </report>
      <report test="not(@USE) and ((0 > @minFront) or (0 > @maxFront))" role="warning">&NodeDEFname; minFront='<value-of select='@minFront'/>' maxFront='<value-of select='@maxFront'/>' has negative value for distance along front direction </report>
      <report test="not(@USE) and (@minBack  > @maxBack)  and (@minBack  > 0) and (@maxBack  > 0)" role="warning">&NodeDEFname; minBack='<value-of select='@minBack'/>' maxBack='<value-of select='@maxBack'/>' has minBack value greater than maxBack value </report>
      <report test="not(@USE) and (@minBack  > 10) and (string-length(@maxBack)=0)"  role="warning">&NodeDEFname; minBack='<value-of select='@minBack'/>' maxBack='<value-of select='@maxBack'/>' has minBack value greater than default maxBack value of 10</report>
      <report test="not(@USE) and (@minFront > @maxFront) and (@minFront > 0) and (@maxFront > 0)" role="warning">&NodeDEFname; minFront='<value-of select='@minFront'/>' maxFront='<value-of select='@maxFront'/>' has minFront value greater than maxFront value </report>
      <report test="not(@USE) and (@minFront > 10) and (string-length(@maxFront)=0)" role="warning">&NodeDEFname; minFront='<value-of select='@minFront'/>' maxFront='<value-of select='@maxFront'/>' has minFront value greater than default maxFront value of 10</report>
      <report test="not(@USE) and (1 > @maxBack ) and (@maxBack  > 0) and (string-length(@minBack)=0)"  role="warning">&NodeDEFname; minBack='<value-of select='@minBack'/>' maxBack='<value-of select='@maxBack'/>' has maxBack value less than default minBack value of 1</report>
      <report test="not(@USE) and (1 > @maxFront) and (@maxFront > 0) and (string-length(@minFront)=0)" role="warning">&NodeDEFname; minFront='<value-of select='@minFront'/>' maxFront='<value-of select='@maxFront'/>' has maxFront value less than default minFront value of 1</report>
      <!-- TODO check other fields -->
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Sound'][number(@level) ge 1] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Sound' level='1'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= AudioClip ========== -->
    <rule context="AudioClip">
      <extends rule="DEFtests"/>
      <extends rule="hasUrl"/>
      <extends rule="descriptionTests"/>
      <report test="../Sound and not(@containerField='source') and not(@containerField='')"  role="error">&NodeDEFname; has illegal @containerField=<value-of select='@containerField'/>, must use @containerField=&apos;source&apos; when parent node is &lt;Sound&gt; </report>
      <report test="not(parent::LoadSensor) and not(parent::Sound) and not(parent::field) and not(parent::fieldValue)" role="error">&NodeDEFname; has parent <value-of select='local-name(..)'/> node, must be contained by Sound or LoadSensor node (or else within field declaration or fieldValue initialization) </report>
      <!-- file extension checks -->
      <report test="(string-length(@url) > 2) and not(contains(@url,'.wav')) and not(contains(@url,'.mid')) and not(contains(@url,'.midi'))" role="warning">&NodeDEFname; url array does not contains link to .wav or .midi sound files, browsers not required to support other formats (url='<value-of select='@url'/>') </report>
      <report test="(@loop='TRUE' )" role="error">&NodeDEFname; loop='TRUE'  loop='true' instead</report>
      <report test="(@loop='FALSE')" role="error">&NodeDEFname; loop='FALSE'  loop='false' instead</report>
      <!-- TODO XSLT 2.0:
      and not(contains(@url,'.wav&quot;')) and not(contains(@url,'.midi&quot;'))
                                              and not(ends-with(@url,'.wav'))      and not(ends-with(@url,'.midi'))
      -->
      <!-- TODO test other parameters -->
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Sound'][number(@level) ge 1] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Sound' level='1'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= ImageTexture | MovieTexture ========== -->
    <rule context="ImageTexture | MovieTexture">
      <extends rule="DEFtests"/>
      <extends rule="hasUrl"/>
      <report test="(parent::Shape)" role="error">&NodeDEFname; has parent <value-of select='local-name(..)'/> node, but must be contained by Appearance node </report>
      <report test="(local-name()='ImageTexture') and not(parent::Shape) and not(parent::Appearance) and not(parent::LoadSensor) and not(parent::MultiTexture) and not(parent::TextureBackground)                        and not(parent::field) and not(parent::fieldValue)" role="error">&NodeDEFname; has parent <value-of select='local-name(..)'/> node, but must be contained by Appearance, LoadSensor, MultiTexture or TextureBackground node (or else within field declaration or fieldValue initialization) </report>
      <report test="(local-name()='MovieTexture') and not(parent::Shape) and not(parent::Appearance) and not(parent::LoadSensor) and not(parent::MultiTexture) and not(parent::TextureBackground) and not(parent::Sound) and not(parent::field) and not(parent::fieldValue)" role="error">&NodeDEFname; has parent <value-of select='local-name(..)'/> node, but must be contained by Appearance, LoadSensor, MultiTexture, Sound or TextureBackground node (or else within field declaration or fieldValue initialization) </report>
      <report test="../Appearance and not(@containerField='texture') and not(@containerField='')"  role="error">&NodeDEFname; has illegal @containerField=<value-of select='@containerField'/>, must use @containerField=&apos;texture&apos; when parent node is &lt;Appearance&gt; </report>
      <report test="../Sound and not(@containerField='source') and (local-name()='MovieTexture')"  role="error">&NodeDEFname; has illegal @containerField=<value-of select='@containerField'/>, must use @containerField=&apos;source&apos; when parent node is &lt;Sound&gt; </report>
      <report test="../TextureBackground and not(@containerField='topTexture') and not(@containerField='bottomTexture') and not(@containerField='leftTexture') and not(@containerField='rightTexture') and not(@containerField='topTexture') and not(@containerField='bottomTexture')"  role="error">&NodeDEFname; has illegal @containerField=<value-of select='@containerField'/>, must use @containerField=&apos;topTexture&apos; (bottomTexture leftTexture rightTexture frontTexture or backTexture) when parent node is &lt;TextureBackground&gt; </report>
      <!-- file extension checks -->
      <report test="(local-name()='ImageTexture') and (string-length(@url) > 2) and not(contains(@url,'.png')) and not(contains(@url,'.PNG')) and not(contains(@url,'.JPG')) and not(contains(@url,'.jpg'))and not(contains(@url,'.jpg')) and not(contains(@url,'.jpg')) and not(contains(@url,'.JPG')) " role="warning">&NodeDEFname; url array does not contains link to .png .jpg or .gif image(s), browsers not required to support other formats (url='<value-of select='@url'/>') </report>
      <!-- TODO XSLT 2.0:
      and not(contains(@url,'.png&quot;')) and not(contains(@url,'.jpg&quot;')) and not(contains(@url,'.gif&quot;'))
                                                                       and not(ends-with(@url,'.png'))      and not(ends-with(@url,'.jpg'))      and not(ends-with(@url,'.gif'))
      -->
      <report test="(local-name()='MovieTexture') and (string-length(@url) > 2) and not(contains(@url,'.mpg'))" role="warning">&NodeDEFname; url array does not contain link to .mpg movie(s), browsers not required to support other formats (url='<value-of select='@url'/>') </report>
      <report test="(@repeatS='TRUE' )" role="error">&NodeDEFname; repeatS='TRUE'  repeatS='true' instead</report>
      <report test="(@repeatS='FALSE')" role="error">&NodeDEFname; repeatS='FALSE'  repeatS='false' instead</report>
      <report test="(@repeatT='TRUE' )" role="error">&NodeDEFname; repeatT='TRUE'  repeatT='true' instead</report>
      <report test="(@repeatT='FALSE')" role="error">&NodeDEFname; repeatT='FALSE'  repeatT='false' instead</report>
      <!-- TODO XSLT 2.0:
      and not(contains(@url,'.mpg&quot;')) and not(ends-with(@url,'.mpg'))
      -->
      <!-- TODO test other parameters -->
      <report test="(local-name()='MovieTexture') and not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Texturing'][number(@level) ge 3] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Texturing' level='3'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= PixelTexture ========== -->
    <rule context="PixelTexture">
      <let name="image"             value="@image"/>
      <let name="width"             value="substring-before(@image,' ')"/>
      <let name="height"            value="substring-before(substring-after(@image,' '),' ')"/>
      <let name="components"        value="substring-before(substring-after(substring-after(@image,' '),' '),' ')"/>
      <let name="nonNumericResidue" value="translate(normalize-space(@image),'+-0123456789ABCDEFabcdef#x, ','')"/>
      <let name="defaultImage"      value="(normalize-space(@image)='0 0 0') or (normalize-space(@image)=' ') or (normalize-space(@image)='')"/>
      <let name="valueCount"    value="string-length($image)  - string-length(translate($image,  ' ','')) + 1 - 3"/>
      <extends rule="DEFtests"/>
      <report test="(parent::Shape)" role="error">&NodeDEFname; has parent <value-of select='local-name(..)'/> node, but must be contained by Appearance node </report>
      <report test="not(parent::Shape) and not(parent::Appearance) and not(parent::MultiTexture) and not(parent::TextureBackground) and not(parent::field) and not(parent::fieldValue)" role="error">&NodeDEFname; has parent <value-of select='local-name(..)'/> node, but must be contained by Appearance, MultiTexture or TextureBackground node (or else within field declaration or fieldValue initialization) </report>
      <assert test="@image"  role="error">&NodeDEFname; has no image array for pixel values </assert>
      <report test="not(@USE) and ($defaultImage)"  role="warning">&lt;<name/> DEF='<value-of select='$DEF'/>' image='<value-of select='(@image)'/>'/&gt; has empty or default image array values </report>
      <report test="not(@USE) and ($image) and not ($defaultImage) and preceding::PixelTexture[@image=$image] and not //ROUTE[@toField=$DEF] and not(ancestor::ProtoDeclare) and not(parent::field or parent::fieldValue)"  role="warning">&NodeDEFname; has identical image array matching a preceding PixelTexture, consider DEF/USE to avoid duplication (image='<value-of select='substring(@image,0,40)'/>') </report>
      <assert test="not(@image) or $defaultImage or ($width &gt;= 0)"  role="error">&NodeDEFname; illegal value for image width: <value-of select='$width'/> </assert>
      <assert test="not(@image) or $defaultImage or ($height &gt;= 0)" role="error">&NodeDEFname; illegal value for image height: <value-of select='$height'/> </assert>
      <assert test="not(@image) or $defaultImage or ($components='0' or $components='1' or $components='2' or $components='3' or $components='4')" role="error">&NodeDEFname; illegal value for image component count: <value-of select='$components'/> (must be 0..4) </assert>
      <assert test="not(@image) or ($nonNumericResidue='')"  role="error">&NodeDEFname; illegal non-numeric characters in image array: <value-of select='$nonNumericResidue'/> </assert>
      <!-- array-size counting checks, adjusted to remove first three array-size values -->
      <assert test="($valueCount = ($width * $height)) or (($height=0) and ($width=0) and ($valueCount=0))"  role="error">&NodeDEFname; illegal number of image values (expected <value-of select='($width * $height)'/> values after initial 3 array-size parameters, found <value-of select='$valueCount'/>) </assert>
      <report test="(local-name()='MovieTexture') and (string-length(@url) > 2) and not(contains(@url,'.mpg'))" role="warning">&NodeDEFname; url array does not contain link to .mpg movie(s), browsers not required to support other formats (url='<value-of select='@url'/>') </report>
      <report test="(@repeatS='TRUE' )" role="error">&NodeDEFname; repeatS='TRUE'  repeatS='true' instead</report>
      <report test="(@repeatS='FALSE')" role="error">&NodeDEFname; repeatS='FALSE'  repeatS='false' instead</report>
      <report test="(@repeatT='TRUE' )" role="error">&NodeDEFname; repeatT='TRUE'  repeatT='true' instead</report>
      <report test="(@repeatT='FALSE')" role="error">&NodeDEFname; repeatT='FALSE'  repeatT='false' instead</report>
    </rule>

    <!-- ========= Anchor ========== -->
    <rule context="Anchor">
      <let name="bookmark"  value="translate(substring-after(normalize-space(@url),'#'),'&quot;','')"/>
      <let name="parameterStringResidueApos" value="translate(@parameter,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="parameterStringResidue" value='translate($parameterStringResidueApos,"&apos;","")'/>
      <let name="parameterQuoteCount" value="string-length($parameterStringResidue)"/>
      <let name="parameterNormalizedString" value="normalize-space(@parameter)"/>
      <let name="parameterLastCharacter" value="substring($parameterNormalizedString,string-length($parameterNormalizedString))"/>
      <extends rule="DEFtests"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="NeedsChildNode"/>
      <extends rule="hasUrl"/>
      <!-- test bookmark -->
      <report test="(string-length(@url) > 2) and starts-with(normalize-space(@url),'#') and not(//Viewpoint[@DEF=$bookmark]) and not(//OrthoViewpoint[@DEF=$bookmark]) and not(//ProtoInstance[@DEF=$bookmark])"  role="warning">&NodeDEFname; with bookmark url='<value-of select='@url'/>' does not have corresponding &lt;Viewpoint DEF='<value-of select='$bookmark'/>'/&gt;, OrthoViewpoint or ProtoInstance node </report>
      <!-- parameter field MFString array checks -->
      <report test="false()" role="trace">$parameterQuoteCount=<value-of select='$parameterQuoteCount'/>, $parameterStringResidue=<value-of select='$parameterStringResidue'/>, $parameterStringResidueApos=<value-of select='$parameterStringResidueApos'/> , $parameterLastCharacter=<value-of select='$parameterLastCharacter'/> </report>
      <report test="not(@USE) and contains($parameterNormalizedString,'&quot;&quot;') and not(contains($parameterNormalizedString,'\&quot;&quot;') or contains($parameterNormalizedString,'&quot;\&quot;') or contains($parameterNormalizedString,'&quot;&quot; &quot;') or contains($parameterNormalizedString,'&quot; &quot;&quot;'))"  role="error">&NodeDEFname; array parameter='<value-of select='@parameter'/>' has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@parameter) and not(contains(@parameter,'&quot;'))"    role="error">&NodeDEFname; array parameter='<value-of select='@parameter'/>' needs to begin and end with &quot;quote marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' parameter=&apos;&quot;<value-of select='(@parameter)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@parameter) and    (contains(@parameter,'&quot;')) and (($parameterQuoteCount div 2)!=round($parameterQuoteCount div 2)) and not(contains(@parameter,'\&quot;'))"    role="error">&NodeDEFname; array parameter='<value-of select='@parameter'/>' has <value-of select='($parameterQuoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@parameter) and (contains(@parameter,'\&quot;'))"    role="warning">&NodeDEFname; array parameter='<value-of select='@parameter'/>' has <value-of select='($parameterQuoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($parameterNormalizedString) and not(starts-with($parameterNormalizedString,'&quot;')) and not($parameterLastCharacter='&quot;') and (contains(@parameter,'&quot;'))"    role="error">&NodeDEFname; array parameter='<value-of select='@parameter'/>' needs to begin and end with &quot;quote marks&quot; </report>
      <report test="not(@USE) and ($parameterNormalizedString) and not(starts-with($parameterNormalizedString,'&quot;')) and    ($parameterLastCharacter='&quot;')"                                     role="error">&NodeDEFname; array parameter='<value-of select='@parameter'/>' needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($parameterNormalizedString) and    (starts-with($parameterNormalizedString,'&quot;')) and not($parameterLastCharacter='&quot;')"                                     role="error">&NodeDEFname; array parameter='<value-of select='@parameter'/>' needs to end with quote mark &quot; </report>
    </rule>

    <!-- ========= Inline ========== -->
    <rule context="Inline">
      <extends rule="DEFtests"/>
      <extends rule="NoChildNode"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="hasUrl"/>
      <!-- file extension checks -->
      <report test="(string-length(@url) > 2) and not(contains(@url,'.x3d')) and not(contains(@url,'.x3dv')) and not(contains(@url,'.x3db')) and not(contains(@url,'.wrl'))" role="warning">&NodeDEFname; url array does not contains link to .x3d .x3dv .x3db or .wrl scenes, browsers not required to support other scene formats (url='<value-of select='@url'/>') </report>
      <report test="(@load='TRUE' )" role="error">&NodeDEFname; load='TRUE'  load='true' instead</report>
      <report test="(@load='FALSE')" role="error">&NodeDEFname; load='FALSE'  load='false' instead</report>
      <!-- TODO XSLT 2.0:
      and not(contains(@url,'.x3d&quot;')) and not(contains(@url,'.x3dv&quot;')) and not(contains(@url,'.x3db&quot;')) and not(contains(@url,'.wrl&quot;'))
                                              and not(ends-with(@url,'.x3d'))      and not(ends-with(@url,'.x3dv'))      and not(ends-with(@url,'.x3db'))      and not(ends-with(@url,'.wrl'))
      -->
      <!-- TODO Check for proper X3D version within Inline that is less than or equal to parent scene.  XSLT v2.0 only
      <let name="x3dVersion"        value="//X3D/@version"/>
      <let name="firstUrl"          value="substring-before(substring-after(@url,'&quot;'),'&quot;')"/>
      <let name="httpUrl"           value="concat('http',substring-before(substring-after(@url,'&quot;http'),'&quot;'))"/>
      <report test="true()" role="diagnostic"> firstUrl=<value-of select='$firstUrl'/>, httpUrl=<value-of select='$httpUrl'/> </report>
      <let name="httpUrlAvailable"  value="doc-available($httpUrl)"/>
      <let name="httpUrlDocument"  value="document($httpUrl)"/>
      <let name="httpUrlDocumentX3dVersion"          value="if (not($httpUrl='http')) then "/>
      <report test="not($httpUrl='http')" role="trace"> httpUrlDocument X3D version=<value-of select='document($httpUrl)//X3D/@version'/> </report>
      <report test="not($httpUrl='http') and not($x3dVersion=document($httpUrl)//X3D/@version)" role="error">Parent document X3D version='<value-of select='$x3dVersion'/>' containing &NodeDEFname; must match Inline X3D version='<value-of select='document($httpUrl)//X3D/@version'/>' </report>
      -->
      <!-- TODO test load and other parameters -->
      <!-- TODO test profile match with external files, both for Inline and ExternProtoDeclare, possibly using document() function -->
      <report test="not(/X3D[(@profile='Interactive') or (@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Networking'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Networking' level='2'/&gt; or &lt;X3D profile='Interactive'/&gt; </report>
    </rule>

    <!-- ========= Billboard ========== -->
    <rule context="Billboard">
      <extends rule="DEFtests"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="NeedsChildNode"/>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Navigation'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Navigation' level='2'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= Collision ========== -->
    <rule context="Collision">
      <extends rule="DEFtests"/>
      <extends rule="enabledTests"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="NeedsChildNode"/>
      <report test="count(*/@containerField='proxy') > 1" role="warning">&NodeDEFname; has <value-of select="count(*/@containerField='proxy')"/> child nodes with containerField='proxy' but no more than one is allowed </report>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Navigation'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Navigation' level='2'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= Group ========== -->
    <rule context="Group">
      <extends rule="DEFtests"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="NeedsChildNode"/>
    </rule>

    <!-- ========= StaticGroup ========== -->
    <rule context="StaticGroup">
      <!-- DEFtests include checks to avoid DEF or USE nodes under a StaticGroup -->
      <extends rule="DEFtests"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="NeedsChildNode"/>
      <assert test="((/X3D[@profile='Full']) or (/X3D/head/component[@name='Grouping'][number(@level) ge 3]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Grouping' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
      <!-- ROUTE rules test that no events connect from/to StaticGroup descendants -->
    </rule>

    <!-- ========= LOD ========== -->
    <rule context="LOD">
      <extends rule="DEFtests"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="NeedsChildNode"/>
      <report test="(@forceTransitions='true') and (/X3D[@version='3.0'])" role="error">&NodeDEFname; forceTransitions='<value-of select='@forceTransitions'/>' requires &lt;X3D version=&apos;3.1&apos;&gt; or higher, but found version='<value-of select='/X3D/@version'/>' </report>
      <report test="(@forceTransitions='TRUE' )" role="error">&NodeDEFname; forceTransitions='TRUE'  forceTransitions='true' instead</report>
      <report test="(@forceTransitions='FALSE')" role="error">&NodeDEFname; forceTransitions='FALSE'  forceTransitions='false' instead</report>
      <!-- TODO test range array and number of children -->
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Navigation'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Navigation' level='2'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= Switch ========== -->
    <rule context="Switch">
      <let name="parentName" value="local-name(..)"/>
      <extends rule="DEFtests"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="NeedsChildNode"/>
      <report test="ExternProtoDeclare" role="warning">&NodeDEFname; child element ExternProtoDeclare is ambiguous since it is not a node and not a switchable child</report>
      <report test="ProtoDeclare" role="warning">&NodeDEFname; child element ProtoDeclare is ambiguous since it is not a node and not a switchable child</report>
      <report test="ROUTE" role="warning">&NodeDEFname; child element ROUTE  is ambiguous since it is not a node and not a switchable child...</report>
      <report test="ROUTE" role="hint">&lt;ROUTE fromNode='<value-of select='ROUTE/@fromNode'/>' fromField='<value-of select='ROUTE/@fromField'/>' toNode='<value-of select='ROUTE/@toNode'/>' toField='<value-of select='ROUTE/@toField'/>'/&gt; cannot be contained inside of &NodeDEFname; </report>
      <assert test="(/X3D[(@profile='Interactive') or (@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Grouping'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Grouping' level='2'/&gt; or &lt;X3D profile='Interactive'/&gt; </assert>
      <!-- TODO test whichChoice value and number of children -->
    </rule>

    <!-- ========= Transform ========== -->
    <rule context="Transform">
      <extends rule="DEFtests"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="NeedsChildNode"/>
      <report test="contains(normalize-space(@rotation),'0 0 0 ') or contains(normalize-space(@rotation),'0.0 0.0 0.0 ')" role="error">&NodeDEFname; rotation='<value-of select='@rotation'/>' has illegal zero-magnitude axis values</report>
      <report test="contains(normalize-space(@scaleOrientation),'0 0 0 ') or contains(normalize-space(@scaleOrientation),'0.0 0.0 0.0 ')" role="error">&NodeDEFname; scaleOrientation='<value-of select='@scaleOrientation'/>' has illegal zero-magnitude axis values</report>
    </rule>

    <!-- ========= abstract: backgroundNode ========== -->
    <rule id="backgroundNode" abstract="true">
      <let name="skyColor"                     value="concat(' ',normalize-space(translate(@skyColor, ',',' ')))"/>
      <let name="skyColorCount"                value="string-length($skyColor)              - string-length(translate($skyColor,  ' ',''))"/>
      <let name="groundColor"                  value="concat(' ',normalize-space(translate(@groundColor, ',',' ')))"/>
      <let name="groundColorCount"             value="string-length($groundColor)              - string-length(translate($groundColor,  ' ',''))"/>
      <extends rule="DEFtests"/>
      <extends rule="NoChildNode"/>
      <extends rule="NoLodSwitchParent"/>
      <report test="contains($skyColor,'-')"  role="warning">&NodeDEFname; contains a negative skyColor array value, skyColor='<value-of select='@skyColor'/>' </report>
      <!-- the following test does not catch values between 1.0 and 2.0 -->
      <report test="contains($skyColor,' 2') or contains($skyColor,' 3') or contains($skyColor,' 4') or contains($skyColor,' 5') or contains($skyColor,' 6') or contains($skyColor,' 7') or contains($skyColor,' 8') or contains($skyColor,' 9') or contains($skyColor,' 1.1') or contains($skyColor,' 1.2') or contains($skyColor,' 1.3') or contains($skyColor,' 1.4') or contains($skyColor,' 1.5') or contains($skyColor,' 1.6') or contains($skyColor,' 1.7') or contains($skyColor,' 1.8') or contains($skyColor,' 1.9')"  role="warning">&NodeDEFname; skyColor='<value-of select='@skyColor'/>' contains a value greater than 1 </report>
      <report test="(string-length(normalize-space($skyColor)) > 0) and (($skyColorCount div 3)!=round($skyColorCount div 3))"    role="warning">&NodeDEFname; skyColor array has <value-of select='($skyColorCount div 3)'/> triples, likely has incorrect number of values or missing whitespace </report>
      <report test="contains($groundColor,'-')"  role="warning">&NodeDEFname; contains a negative groundColor array value, groundColor='<value-of select='@groundColor'/>' </report>
      <!-- the following test does not catch values between 1.0 and 2.0 -->
      <report test="contains($groundColor,' 2') or contains($groundColor,' 3') or contains($groundColor,' 4') or contains($groundColor,' 5') or contains($groundColor,' 6') or contains($groundColor,' 7') or contains($groundColor,' 8') or contains($groundColor,' 9') or contains($groundColor,' 1.1') or contains($groundColor,' 1.2') or contains($groundColor,' 1.3') or contains($groundColor,' 1.4') or contains($groundColor,' 1.5') or contains($groundColor,' 1.6') or contains($groundColor,' 1.7') or contains($groundColor,' 1.8') or contains($groundColor,' 1.9')"  role="warning">&NodeDEFname; groundColor='<value-of select='@groundColor'/>' contains a value greater than 1 </report>
      <report test="(string-length(normalize-space($groundColor)) > 0) and (($groundColorCount div 3)!=round($groundColorCount div 3))"    role="warning">&NodeDEFname; groundColor array has <value-of select='($groundColorCount div 3)'/> triples, likely has incorrect number of values or missing whitespace </report>
      <!-- TODO if geospatial scene, ensure proper parent node -->
      <!-- TODO comparison counting checks between corresponding Color and Angle arrays -->
    </rule>

    <!-- ========= Background ========== -->
    <rule context="Background">
      <extends rule="backgroundNode"/>
    </rule>

    <!-- ========= TextureBackground ========== -->
    <rule context="TextureBackground">
      <extends rule="backgroundNode"/>
      <!-- check for containerField mixup, Background and TextureBackground -->
      <report test="(*[@containerField='texture'])"   role="error">&NodeDEFname; child node with default containerField='texture' attribute needs to be renamed containerField='frontTexture', backTexture, leftTexture, rightTexture, topTexture or bottomTexture </report>
      <report test="(*[@containerField='frontUrl'])"  role="error">&NodeDEFname; child node with containerField='frontUrl' attribute needs to be renamed containerField='frontTexture'</report>
      <report test="(*[@containerField='backUrl'])"   role="error">&NodeDEFname; child node with containerField='backUrl' attribute needs to be renamed containerField='backTexture'</report>
      <report test="(*[@containerField='leftUrl'])"   role="error">&NodeDEFname; child node with containerField='leftUrl' attribute needs to be renamed containerField='leftTexture'</report>
      <report test="(*[@containerField='rightUrl'])"  role="error">&NodeDEFname; child node with containerField='rightUrl' attribute needs to be renamed containerField='rightTexture'</report>
      <report test="(*[@containerField='topUrl'])"    role="error">&NodeDEFname; child node with containerField='topUrl' attribute needs to be renamed containerField='topTexture'</report>
      <report test="(*[@containerField='bottomUrl'])" role="error">&NodeDEFname; child node with containerField='bottomUrl' attribute needs to be renamed containerField='bottomTexture'</report>
      <!-- X3D v3.0 but requires extra component statement even for Immersive profile -->
      <assert test="((/X3D[@profile='Full']) or (/X3D/head/component[@name='EnvironmentalEffects'][number(@level) ge 3]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='EnvironmentalEffects' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>
    
    <!-- ========= abstract: fogNode ========== -->
    <rule id="fogNode" abstract="true">
      <!--<let name="color"                     value="normalize-space(translate(@color, ',',' '))"/>
      <let name="colorCount"                value="string-length($color)              - string-length(translate($color,  ' ','')) + 1"/>
      <extends rule="DEFtests"/>-->
      <extends rule="colorField"/>
      <extends rule="NoChildNode"/>
      <extends rule="NoLodSwitchParent"/>
      <report test="(string-length(normalize-space($color)) > 0)  and ($colorCount != 3)"    role="warning">&NodeDEFname; color='<value-of select='@color'/>' has <value-of select='($colorCount)'/> values instead of 3 </report>
    </rule>

    <!-- ========= Fog ========== -->
    <rule context="Fog">
      <extends rule="fogNode"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@fogType, '&quot;')" role="error">&NodeDEFname; fogType='<value-of select='@fogType'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="not(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='EnvironmentalEffects'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='EnvironmentalEffects' level='2'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
    </rule>

    <!-- ========= LocalFog ========== -->
    <rule context="LocalFog">
      <extends rule="fogNode"/>
      <extends rule="X3Dversion3.1"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@fogType, '&quot;')" role="error">&NodeDEFname; fogType='<value-of select='@fogType'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <assert test="((/X3D[@profile='Full']) or (/X3D/head/component[@name='EnvironmentalEffects'][number(@level) ge 4]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='EnvironmentalEffects' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>

    <!-- ========= FogCoordinate ========== -->
    <rule context="FogCoordinate">
      <extends rule="DEFtests"/>
      <extends rule="NoChildNode"/>
      <!-- TODO depth is MFFloat array with length matching number of vertices -->
      <assert test="((/X3D[@profile='Full']) or (/X3D/head/component[@name='EnvironmentalEffects'][number(@level) ge 4]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='EnvironmentalEffects' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>

    <!-- ========= NavigationInfo ========== -->
    <rule context="NavigationInfo">
      <let name="stringResidueApos" value="translate(@type,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="stringResidue" value='translate($stringResidueApos,"&apos;","")'/>
      <let name="quoteCount" value="string-length($stringResidue)"/>
      <let name="normalizedString" value="normalize-space(@type)"/>
      <let name="lastCharacter" value="substring($normalizedString,string-length($normalizedString))"/>
      <let name="transitionTypeStringResidueApos" value="translate(@transitionType,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="transitionTypeStringResidue" value='translate($transitionTypeStringResidueApos,"&apos;","")'/>
      <let name="transitionTypeQuoteCount" value="string-length($transitionTypeStringResidue)"/>
      <let name="transitionTypeNormalizedString" value="normalize-space(@transitionType)"/>
      <let name="transitionTypeLastCharacter" value="substring($transitionTypeNormalizedString,string-length($transitionTypeNormalizedString))"/>
      <!-- TODO split out individual values from avatarSize array and then check them, e.g. Octaga rule that avatarSize[2] step <= [1] height - [0] collision distance -->
      <extends rule="DEFtests"/>
      <extends rule="NoChildNode"/>
      <extends rule="NoLodSwitchParent"/>
      <!-- type MFString array checks -->
      <report test="false()" role="trace">$quoteCount=<value-of select='$quoteCount'/>, $stringResidue=<value-of select='$stringResidue'/>, $stringResidueApos=<value-of select='$stringResidueApos'/> , $lastCharacter=<value-of select='$lastCharacter'/> </report>
      <report test="not(@USE) and contains($normalizedString,'&quot;&quot;') and not(contains($normalizedString,'\&quot;&quot;') or contains($normalizedString,'&quot;\&quot;') or contains($normalizedString,'&quot;&quot; &quot;') or contains($normalizedString,'&quot; &quot;&quot;'))"  role="error">&NodeDEFname; array type='<value-of select='@type'/>' has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@type) and not(contains(@type,'&quot;'))"    role="error">&NodeDEFname; array type='<value-of select='@type'/>' needs to begin and end with &quot;quote&quot; &quot;marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' type=&apos;&quot;<value-of select='(@type)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@type) and    (contains(@type,'&quot;')) and (($quoteCount div 2)!=round($quoteCount div 2)) and not(contains(@type,'\&quot;'))"    role="error">&NodeDEFname; array type='<value-of select='@type'/>' has <value-of select='($quoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@type) and (contains(@type,'\&quot;'))"    role="warning">&NodeDEFname; array type='<value-of select='@type'/>' has <value-of select='($quoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;') and (contains(@type,'&quot;'))"    role="error">&NodeDEFname; array type='<value-of select='@type'/>' needs to begin and end with &quot;quote&quot; &quot;marks&quot; </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and    ($lastCharacter='&quot;')"                                     role="error">&NodeDEFname; array type='<value-of select='@type'/>' needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($normalizedString) and    (starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;')"                                     role="error">&NodeDEFname; array type='<value-of select='@type'/>' needs to end with quote mark &quot; </report>
      <!-- transitionTime SFTime checks -->
      <report test="not(@USE) and (@transitionTime &lt; 0)"    role="error">&NodeDEFname; transitionTime='<value-of select='@transitionTime'/>' cannot be negative </report>
      <!-- transitionType MFString array checks -->
      <report test="false()" role="trace">$transitionTypeQuoteCount=<value-of select='$transitionTypeQuoteCount'/>, $transitionTypeStringResidue=<value-of select='$transitionTypeStringResidue'/>, $transitionTypeStringResidueApos=<value-of select='$transitionTypeStringResidueApos'/> , $transitionTypeLastCharacter=<value-of select='$transitionTypeLastCharacter'/> </report>
      <report test="not(@USE) and contains($transitionTypeNormalizedString,'&quot;&quot;') and not(contains($transitionTypeNormalizedString,'\&quot;&quot;') or contains($transitionTypeNormalizedString,'&quot;\&quot;') or contains($transitionTypeNormalizedString,'&quot;&quot; &quot;') or contains($transitionTypeNormalizedString,'&quot; &quot;&quot;'))"  role="error">&NodeDEFname; transitionType='<value-of select='@transitionType'/>' array has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@transitionType) and not(contains(@transitionType,'&quot;'))"    role="error">&NodeDEFname; array transitionType='<value-of select='@transitionType'/>' needs to begin and end with &quot;quote&quot; &quot;marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' transitionType=&apos;&quot;<value-of select='(@transitionType)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@transitionType) and    (contains(@transitionType,'&quot;')) and (($transitionTypeQuoteCount div 2)!=round($transitionTypeQuoteCount div 2)) and not(contains(@transitionType,'\&quot;'))"    role="error">&NodeDEFname; array transitionType='<value-of select='@transitionType'/>' has <value-of select='($transitionTypeQuoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@transitionType) and (contains(@transitionType,'\&quot;'))"    role="warning">&NodeDEFname; transitionType='<value-of select='@transitionType'/>' has <value-of select='($transitionTypeQuoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($transitionTypeNormalizedString) and not(starts-with($transitionTypeNormalizedString,'&quot;')) and not($transitionTypeLastCharacter='&quot;') and (contains(@transitionType,'&quot;'))"    role="error">&NodeDEFname; array of transitionType values needs to begin and end with &quot;quote&quot; &quot;marks&quot; </report>
      <report test="not(@USE) and ($transitionTypeNormalizedString) and not(starts-with($transitionTypeNormalizedString,'&quot;')) and    ($transitionTypeLastCharacter='&quot;')"                                     role="error">&NodeDEFname; transitionType='<value-of select='@transitionType'/>' array needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($transitionTypeNormalizedString) and    (starts-with($transitionTypeNormalizedString,'&quot;')) and not($transitionTypeLastCharacter='&quot;')"                                     role="error">&NodeDEFname; transitionType='<value-of select='@transitionType'/>' array needs to end with quote mark &quot; </report>
      <!-- additional checks -->
      <report test="not(@USE) and (@type) and ((/X3D[@version='3.0']) or (/X3D[@version='3.1']) or (/X3D[@version='3.2'])) and not(contains(@type,'EXAMINE')) and not(contains(@type,'ANY')) and not(contains(@type,'WALK')) and not(contains(@type,'FLY')) and not(contains(@type,'LOOKAT')) and not(contains(@type,'NONE'))"                                    role="warning">&NodeDEFname; array type='<value-of select='@type'/>' does not contain any of the guaranteed-support values (&quot;EXAMINE&quot; &quot;ANY&quot; or &quot;WALK&quot; &quot;FLY&quot; &quot;LOOKAT&quot; &quot;NONE&quot;) </report>
      <report test="not(@USE) and (@type) and ((/X3D[@version='3.3']) or (/X3D[@version='3.4']))                           and not(contains(@type,'EXAMINE')) and not(contains(@type,'ANY')) and not(contains(@type,'WALK')) and not(contains(@type,'FLY')) and not(contains(@type,'LOOKAT')) and not(contains(@type,'NONE')) and not(contains(@type,'EXPLORE'))" role="warning">&NodeDEFname; array type='<value-of select='@type'/>' does not contain any of the guaranteed-support values (&quot;EXAMINE&quot; &quot;ANY&quot; or &quot;WALK&quot; &quot;FLY&quot; &quot;LOOKAT&quot; &quot;EXPLORE&quot; &quot;NONE&quot;) </report>
      <report test="not(@USE) and (@transitionType) and not(contains(@transitionType,'LINEAR')) and not(contains(@transitionType,'TELEPORT')) and not(contains(@transitionType,'ANIMATE'))"    role="warning">&NodeDEFname; array transitionType='<value-of select='@transitionType'/>' does not contain any of the guaranteed-support values (default &quot;LINEAR&quot; or &quot;TELEPORT&quot; &quot;ANIMATE&quot;) </report>
      <report test="not(/X3D[(@profile='Interchange') or (@profile='Interactive') or (@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Navigation'][number(@level) ge 1] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Navigation' level='1'/&gt; or &lt;X3D profile='Interchange'/&gt; </report>
      <!-- TODO  fine-tuned guidance regarding attributes for level 1 versus level 2 -->
    </rule>

    <!-- ========= Viewpoint | OrthoViewpoint ========== -->
    <rule context="Viewpoint | OrthoViewpoint">
      <extends rule="DEFtests"/>
      <extends rule="NoChildNode"/>
      <extends rule="NoLodSwitchParent"/>
      <extends rule="descriptionTests"/>
      <report test="(@retainUserOffsets='true') and not(/X3D[@version='3.2'] or /X3D[@version='3.3'] or /X3D[@version='3.4'])" role="error">&NodeDEFname; retainUserOffsets='<value-of select='@retainUserOffsets'/>' requires &lt;X3D version=&apos;3.2&apos;&gt; or higher, but found version='<value-of select='/X3D/@version'/>' </report>
      <report test="(local-name()='OrthoViewpoint') and not((/X3D[@profile='Full']) or (/X3D/head/component[@name='Navigation'][number(@level) ge 3])) or (count(preceding::*[local-name()='OrthoViewpoint']) > 0)" role="error">OrthoViewpoint requires at least &lt;component name='Navigation' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </report>
      <report test="contains(normalize-space(@orientation),'0 0 0 ') or contains(normalize-space(@orientation),'0.0 0.0 0.0 ')" role="error">&NodeDEFname; orientation='<value-of select='@orientation'/>' has illegal zero-magnitude axis values</report>
      <report test="(@jump='TRUE' )" role="error">&NodeDEFname; jump='TRUE'  jump='true' instead</report>
      <report test="(@jump='FALSE')" role="error">&NodeDEFname; jump='FALSE'  jump='false' instead</report>
      <report test="(@retainUserOffsets='TRUE' )" role="error">&NodeDEFname; retainUserOffsets='TRUE'  retainUserOffsets='true' instead</report>
      <report test="(@retainUserOffsets='FALSE')" role="error">&NodeDEFname; retainUserOffsets='FALSE'  retainUserOffsets='false' instead</report>
      <!-- (preceding-sibling::HAnimHumanoid or following-sibling::HAnimHumanoid) equivalent to (../HAnimHumanoid) also note that there is no XPath axis for sibling per se -->
      <report test="(preceding-sibling::HAnimHumanoid or following-sibling::HAnimHumanoid) and (not(@centerOfRotation) or (string-length(@centerOfRotation)=0) or (@centerOfRotation = '0 0 0') or (@centerOfRotation = '0.0 0.0 0.0'))" role="error">&NodeDEFname; centerOfRotation='<value-of select='@centerOfRotation'/>', consider setting centerOfRotation to value of sibling &lt;HAnimHumanoid DEF='<value-of select='@DEF'/>' name='HumanoidRoot' center='<value-of select='../HAnimHumanoid/@center'/>'/&gt;</report>
      <!-- HAnim warnings -->
      <report test="(parent::HAnimSite) and ((@position='0 0 10') or (@position='0.0 0.0 10.0'))" role="error">&NodeDEFname; position='<value-of select='@position'/>' default value is unusual as child of HAnimSite, usually set position='0 0 0' </report>
      <!-- TODO warn if Wiewpoint too close and clipping occurs due to NavigationInfo avatarSize defaults -->
      <report test="(local-name()='Viewpoint')      and not(/X3D[(@profile='Interchange') or (@profile='Interactive') or (@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Navigation'][number(@level) ge 1] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Navigation' level='1'/&gt; or &lt;X3D profile='Interchange'/&gt; </report>
      <report test="(local-name()='OrthoViewpoint') and not(/X3D[                                                                                  (@profile='Full')] or /X3D/head/component[@name='Navigation'][number(@level) ge 3] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Navigation' level='3'/&gt; or &lt;X3D profile='Immersive'/&gt; </report>
      <!-- TODO  fine-tuned guidance regarding Viewpoint attributes for level 1 versus level 2 -->
    </rule>

    <!-- ========= ViewpointGroup ========== -->
    <rule context="ViewpointGroup">
      <extends rule="DEFtests"/>
      <extends rule="NoLodSwitchParent"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="descriptionTests"/>
      <extends rule="sizeTests"/>
      <assert test="not(*) or *[(local-name()='Viewpoint') or (local-name()='ViewpointGroup') or (local-name()='ProtoInstance') or (local-name()='IS') or starts-with(local-name(),'Metadata')]" role="error">&NodeDEFname; can only contain Viewpoint, ViewpointGroup, ProtoInstance or Metadata nodes </assert>
      <report test="(@displayed='TRUE' )" role="error">&NodeDEFname; displayed='TRUE'  displayed='true' instead</report>
      <report test="(@displayed='FALSE')" role="error">&NodeDEFname; displayed='FALSE'  displayed='false' instead</report>
      <report test="(@retainUserOffsets='TRUE' )" role="error">&NodeDEFname; retainUserOffsets='TRUE'  retainUserOffsets='true' instead</report>
      <report test="(@retainUserOffsets='FALSE')" role="error">&NodeDEFname; retainUserOffsets='FALSE'  retainUserOffsets='false' instead</report>
      <assert test="((/X3D[@profile='Full']) or (/X3D/head/component[@name='Navigation'][number(@level) ge 3]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">ViewpointGroup requires at least &lt;component name='Navigation' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>

    <!-- ========= WorldInfo ========== -->
    <rule context="WorldInfo">
      <let name="stringResidueApos" value="translate(@info,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="stringResidue" value='translate($stringResidueApos,"&apos;","")'/>
      <let name="quoteCount" value="string-length($stringResidue)"/>
      <let name="normalizedString" value="normalize-space(@info)"/>
      <let name="lastCharacter" value="substring($normalizedString,string-length($normalizedString))"/>
      <extends rule="DEFtests"/>
      <extends rule="NoChildNode"/>
      <!-- TODO name-value pair tests? -->
      <!-- MFString array checks -->
      <report test="false()" role="trace">$quoteCount=<value-of select='$quoteCount'/>, $stringResidue=<value-of select='$stringResidue'/>, $stringResidueApos=<value-of select='$stringResidueApos'/> , $lastCharacter=<value-of select='$lastCharacter'/> </report>
      <report test="not(@USE) and contains($normalizedString,'&quot;&quot;') and not(contains($normalizedString,'\&quot;&quot;') or contains($normalizedString,'&quot;\&quot;') or contains($normalizedString,'&quot;&quot; &quot;') or contains($normalizedString,'&quot; &quot;&quot;'))"  role="error">&WorldInfoNodeDEFname; string array has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@info) and not(contains(@info,'&quot;'))"    role="error">&WorldInfoNodeDEFname; info string array needs to begin and end with &quot;quote marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' info=&apos;&quot;<value-of select='(@info)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@info) and    (contains(@info,'&quot;')) and (($quoteCount div 2)!=round($quoteCount div 2)) and not(contains(@info,'\&quot;'))"    role="error">&WorldInfoNodeDEFname; string array has <value-of select='($quoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@info) and (contains(@info,'\&quot;'))"    role="warning">&WorldInfoNodeDEFname; has <value-of select='($quoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;') and (contains(@info,'&quot;'))"    role="error">&WorldInfoNodeDEFname; array of string values needs to begin and end with &quot;quote marks&quot; </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and    ($lastCharacter='&quot;')"                                     role="error">&WorldInfoNodeDEFname; array of string values needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($normalizedString) and    (starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;')"                                     role="error">&WorldInfoNodeDEFname; array of string values needs to end with quote mark &quot; </report>
      <!-- if two titles found, output prior WorldInfo before current WorldInfo to match document order -->
      <report test="not(@USE) and (string-length(@title) &gt; 0) and (string-length(preceding::WorldInfo/@title) &gt; 0)" role="warning">&lt;WorldInfo DEF='<value-of select='preceding::WorldInfo/@DEF'/>' title='<value-of select='preceding::WorldInfo/@title'/>'/&gt; and &lt;WorldInfo DEF='<value-of select='@DEF'/>' title='<value-of select='@title'/>'/&gt; have both defined window title</report>
    </rule>

    <!-- ========= ROUTE ========== -->
    <rule context="ROUTE">
      <let name="fromNode"  value="normalize-space(@fromNode)"/>
      <let name="fromField" value="normalize-space(@fromField)"/>
      <let name=  "toNode"  value="normalize-space(@toNode)"/>
      <let name=  "toField" value="normalize-space(@toField)"/>
      <extends rule="noDEF"/>
      <extends rule="NoChildNode"/>
      <!-- bad field names -->
      <report test="contains(@fromField,'set_')" role="error">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; should not have 'set_' in event-source fromField name</report>
      <report test="starts-with(@toField,'_changed')" role="error">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; should not have '_changed' in event-destination toField name</report>
      <!-- TODO alert if finding strictly inputOnly fields with set_ or strictly outputOnly fields with _changed.  TODO also X3D Tidy -->
      <report test="(@fromField = 'touchTime_changed')" role="error">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; event-source fromField name 'touchTime_changed' is illegal, use  'touchTime' instead </report>
      <!-- report if ROUTE targets missing -->
      <report test="not(//*[@DEF=$fromNode])" role="error">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; has no corresponding fromNode with DEF='<value-of select='@fromNode'/>' </report>
      <report test="not(//*[@DEF=$toNode  ])" role="error">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; has no corresponding toNode with DEF='<value-of select='@toNode'/>' </report>
      <!-- report if ROUTE precedes targets -->
      <report test="(following::*[@DEF=$fromNode])" role="error">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; precedes target fromNode &lt;<value-of select='local-name(following::*[@DEF=$fromNode])'/> DEF='<value-of select='(following::*[@DEF=$fromNode]/@DEF)'/>'/&gt; </report>
      <report test="(following::*[@DEF=$toNode  ])" role="error">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; precedes target toNode &lt;<value-of select='local-name(following::*[@DEF=$toNode])'/> DEF='<value-of select='(following::*[@DEF=$toNode]/@DEF)'/>'/&gt; </report>
      <!-- report first of duplicated ROUTEs (if any) -->
      <report test="(count(following::ROUTE[@fromNode=$fromNode][@fromField=$fromField][@toNode=$toNode][@toField=$toField]) > 0) and (count(preceding::ROUTE[@fromNode=$fromNode][@fromField=$fromField][@toNode=$toNode][@toField=$toField]) = 0)" role="error">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; has a total of <value-of select='count(//ROUTE[@fromNode=$fromNode][@fromField=$fromField][@toNode=$toNode][@toField=$toField])'/> duplicate(s), remove copies while keeping the remaining ROUTE after fromNode and toNode targets </report>
      <!-- report if ROUTE targets are beneath a StaticGroup node -->
      <report test="(//*[@DEF=$fromNode][ancestor::StaticGroup])" role="error">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; ROUTE error, fromNode='<value-of select='@fromNode'/>' has ancestor StaticGroup, such children cannot produce events (since any child nodes may get refactored inside StaticGroup) </report>
      <report test="(//*[@DEF=$toNode  ][ancestor::StaticGroup])" role="error">&lt;ROUTE fromNode='<value-of select='@fromNode'/>' fromField='<value-of select='@fromField'/>' toNode='<value-of select='@toNode'/>' toField='<value-of select='@toField'/>'/&gt; ROUTE error, toNode='<value-of select='@toNode'/>' has ancestor StaticGroup, such children cannot receive events (since any child nodes may get refactored inside StaticGroup) </report>
    </rule>

    <!-- Rigid Body Physics Component -->

    <!-- ========= abstract: X3DNBodyCollidableNode ========== -->
    <rule id="X3DNBodyCollidableNode" abstract="true">
      <extends rule="enabledTests"/>
      <extends rule="boundingBoxTests"/>
      <report test="contains(normalize-space(@rotation),'0 0 0 ') or contains(normalize-space(@rotation),'0.0 0.0 0.0 ')" role="error">&NodeDEFname; rotation='<value-of select='@rotation'/>' has illegal zero-magnitude axis values</report>
    </rule>

    <!-- ========= abstract: X3DNBodyCollisionSpaceNode ========== -->
    <rule id="X3DNBodyCollisionSpaceNode" abstract="true">
      <extends rule="enabledTests"/>
      <extends rule="boundingBoxTests"/>
    </rule>

    <!-- ========= abstract: X3DRigidJointNode ========== -->
    <rule id="X3DRigidJointNode" abstract="true">
      <assert test="RigidBody[@containerField='body1']" role="warning">&NodeDEFname; missing child &lt;RigidBody containerField=&apos;body1&apos;/&gt; </assert>
      <assert test="RigidBody[@containerField='body2']" role="warning">&NodeDEFname; missing child &lt;RigidBody containerField=&apos;body2&apos;/&gt; </assert>
      <report test="(count(RigidBody[@containerField='body1']) > 1)" role="error">&NodeDEFname; includes more than one child &lt;RigidBody containerField=&apos;body1&apos;/&gt; </report>
      <report test="(count(RigidBody[@containerField='body2']) > 1)" role="error">&NodeDEFname; includes more than one child &lt;RigidBody containerField=&apos;body2&apos;/&gt; </report>
      <report test="(string-length(@mustOutput) > 0)" role="error">&NodeDEFname; mustOutput='<value-of select='@mustOutput'/>' needs to be renamed as field forceOutput</report>
    </rule>

    <!-- ========= BallJoint ========== -->
    <rule context="BallJoint">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="X3DRigidJointNode"/>
    </rule>

    <!-- ========= CollidableOffset ========== -->
    <rule context="CollidableOffset">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="X3DNBodyCollidableNode"/>
    </rule>

    <!-- ========= CollidableShape ========== -->
    <rule context="CollidableShape">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="X3DNBodyCollidableNode"/>
    </rule>

    <!-- ========= CollisionCollection ========== -->
    <rule context="CollisionCollection">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <!-- TODO SFVec2f frictionCoefficients [0,unbounded] -->
    </rule>

    <!-- ========= CollisionSensor ========== -->
    <rule context="CollisionSensor">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <!-- X3DSensorNode -->
      <extends rule="NeedsOutputROUTE"/>
      <report test="not(CollisionCollection[@containerField='collider'])" role="error">&NodeDEFname; is missing child &lt;CollisionCollection containerField=&apos;collider&apos;/&gt; </report>
    </rule>

    <!-- ========= CollisionSpace ========== -->
    <rule context="CollisionSpace">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="X3DNBodyCollidableNode"/>
      <report test="(@useGeometry='TRUE' )" role="error">&NodeDEFname; useGeometry='TRUE' is incorrect, define useGeometry='true' instead</report>
      <report test="(@useGeometry='FALSE')" role="error">&NodeDEFname; useGeometry='FALSE' is incorrect, define useGeometry='false' instead</report>
    </rule>

    <!-- ========= Contact ========== -->
    <rule context="Contact">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <assert test="RigidBody[@containerField='body1']" role="warning">&NodeDEFname; missing child &lt;RigidBody containerField=&apos;body1&apos;/&gt; </assert>
      <assert test="RigidBody[@containerField='body2']" role="warning">&NodeDEFname; missing child &lt;RigidBody containerField=&apos;body2&apos;/&gt; </assert>
      <report test="(count(RigidBody[@containerField='body1']) > 1)" role="error">&NodeDEFname; includes more than one child &lt;RigidBody containerField=&apos;body1&apos;/&gt; </report>
      <report test="(count(RigidBody[@containerField='body2']) > 1)" role="error">&NodeDEFname; includes more than one child &lt;RigidBody containerField=&apos;body2&apos;/&gt; </report>
      <report test="(count(*[@containerField='geometry1']) > 1)" role="error">&NodeDEFname; includes more than one geometry child with containerField=&apos;geometry1&apos; </report>
      <report test="(count(*[@containerField='geometry2']) > 1)" role="error">&NodeDEFname; includes more than one geometry child with containerField=&apos;geometry2&apos; </report>
      <report test="contains(normalize-space(@contactNormal),'0 0 0') or contains(normalize-space(@contactNormal),'0.0 0.0 0.0')" role="error">&NodeDEFname; contactNormal='<value-of select='@contactNormal'/>' normal vector has illegal zero-magnitude axis values, use a non-zero vector direction instead</report>
      <report test="contains(normalize-space(@frictionDirection),'0 0 0') or contains(normalize-space(@frictionDirection),'0.0 0.0 0.0')" role="error">&NodeDEFname; frictionDirection='<value-of select='@frictionDirection'/>' vector has illegal zero-magnitude axis values, use a non-zero vector direction instead </report>
      <!-- TODO SFVec2f frictionCoefficients [0,unbounded] -->
    </rule>

    <!-- ========= DoubleAxisHingeJoint ========== -->
    <rule context="DoubleAxisHingeJoint">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="X3DRigidJointNode"/>
      <!-- spec comment submitted that 0 0 0 is an illegal axis value -->
      <report test="contains(normalize-space(@axis1),'0 0 0') or contains(normalize-space(@axis1),'0.0 0.0 0.0')" role="error">&NodeDEFname; axis1='<value-of select='@axis1'/>' normal vector has illegal zero-magnitude axis values, use a non-zero vector direction instead </report>
      <report test="contains(normalize-space(@axis2),'0 0 0') or contains(normalize-space(@axis2),'0.0 0.0 0.0')" role="error">&NodeDEFname; axis2='<value-of select='@axis2'/>' normal vector has illegal zero-magnitude axis values, use a non-zero vector direction instead </report>
    </rule>

    <!-- ========= MotorJoint ========== -->
    <rule context="MotorJoint">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="X3DRigidJointNode"/>
      <report test="(@autoCalc='TRUE' )" role="error">&NodeDEFname; autoCalc='TRUE' is incorrect, define autoCalc='true' instead</report>
      <report test="(@autoCalc='FALSE')" role="error">&NodeDEFname; autoCalc='FALSE' is incorrect, define autoCalc='false' instead</report>
    </rule>

    <!-- ========= RigidBody ========== -->
    <rule context="RigidBody">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="enabledTests"/>
      <report test="contains(normalize-space(@finiteRotationAxis),'0 0 0') or contains(normalize-space(@finiteRotationAxis),'0.0 0.0 0.0')" role="warning">&NodeDEFname; finiteRotationAxis='<value-of select='@finiteRotationAxis'/>' is illegal axis value, use a non-zero vector direction instead </report>
      <report test="contains(normalize-space(@orientation),'0 0 0 ') or contains(normalize-space(@orientation),'0.0 0.0 0.0 ')" role="error">&NodeDEFname; orientation='<value-of select='@orientation'/>' has illegal zero-magnitude axis values</report>
      <report test="(@autoDamp='TRUE' )" role="error">&NodeDEFname; autoDamp='TRUE' is incorrect, define autoDamp='true' instead</report>
      <report test="(@autoDamp='FALSE')" role="error">&NodeDEFname; autoDamp='FALSE' is incorrect, define autoDamp='false' instead</report>
      <report test="(@autoDisable='TRUE' )" role="error">&NodeDEFname; autoDisable='TRUE' is incorrect, define autoDisable='true' instead</report>
      <report test="(@autoDisable='FALSE')" role="error">&NodeDEFname; autoDisable='FALSE' is incorrect, define autoDisable='false' instead</report>
      <report test="(@fixed='TRUE' )" role="error">&NodeDEFname; fixed='TRUE' is incorrect, define fixed='true' instead</report>
      <report test="(@fixed='FALSE')" role="error">&NodeDEFname; fixed='FALSE' is incorrect, define fixed='false' instead</report>
      <report test="(@useFiniteRotation ='TRUE' )" role="error">&NodeDEFname; useFiniteRotation ='TRUE' is incorrect, define useFiniteRotation ='true' instead</report>
      <report test="(@useFiniteRotation ='FALSE')" role="error">&NodeDEFname; useFiniteRotation ='FALSE' is incorrect, define useFiniteRotation ='false' instead</report>
      <report test="(@useGlobalGravity ='TRUE' )" role="error">&NodeDEFname; useGlobalGravity ='TRUE' is incorrect, define useGlobalGravity ='true' instead</report>
      <report test="(@useGlobalGravity ='FALSE')" role="error">&NodeDEFname; useGlobalGravity ='FALSE' is incorrect, define useGlobalGravity ='false' instead</report>
      <report test="(   Box[not(@containerField ='massDensityModel')])" role="error">&NodeDEFname; contained Box must have containerField ='massDensityModel'</report>
      <report test="(  Cone[not(@containerField ='massDensityModel')])" role="error">&NodeDEFname; contained Cone must have containerField ='massDensityModel'</report>
      <report test="(Sphere[not(@containerField ='massDensityModel')])" role="error">&NodeDEFname; contained Sphere must have containerField ='massDensityModel'</report>
    </rule>

    <!-- ========= RigidBodyCollection ========== -->
    <rule context="RigidBodyCollection">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="enabledTests"/>
      <report test="(@autoDisable ='TRUE' )" role="error">&NodeDEFname; autoDisable ='TRUE' is incorrect, define autoDisable ='true' instead</report>
      <report test="(@autoDisable ='FALSE')" role="error">&NodeDEFname; autoDisable ='FALSE' is incorrect, define autoDisable ='false' instead</report>
      <report test="(@preferAccuracy ='TRUE' )" role="error">&NodeDEFname; preferAccuracy ='TRUE' is incorrect, define preferAccuracy ='true' instead</report>
      <report test="(@preferAccuracy ='FALSE')" role="error">&NodeDEFname; preferAccuracy ='FALSE' is incorrect, define preferAccuracy ='false' instead</report>
    </rule>

    <!-- ========= SingleAxisHingeJoint ========== -->
    <rule context="SingleAxisHingeJoint">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="X3DRigidJointNode"/>
      <report test="contains(normalize-space(@axis),'0 0 0') or contains(normalize-space(@axis),'0.0 0.0 0.0')" role="warning">&NodeDEFname; axis='<value-of select='@axis'/>' is illegal axis value, use a non-zero vector direction instead </report>
    </rule>
    
    <!-- ========= SliderJoint ========== -->
    <rule context="SliderJoint">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="X3DRigidJointNode"/>
      <report test="contains(normalize-space(@axis),'0 0 0') or contains(normalize-space(@axis),'0.0 0.0 0.0')" role="warning">&NodeDEFname; axis='<value-of select='@axis'/>' is illegal axis value, use a non-zero vector direction instead </report>
    </rule>
    
    <!-- ========= UniversalJoint ========== -->
    <rule context="UniversalJoint">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="X3DRigidJointNode"/>
      <!-- spec comment submitted that 0 0 0 is an illegal axis value -->
      <report test="contains(normalize-space(@axis1),'0 0 0') or contains(normalize-space(@axis1),'0.0 0.0 0.0')" role="error">&NodeDEFname; axis1='<value-of select='@axis1'/>' normal vector has illegal zero-magnitude axis values, use a non-zero vector direction instead </report>
      <report test="contains(normalize-space(@axis2),'0 0 0') or contains(normalize-space(@axis2),'0.0 0.0 0.0')" role="error">&NodeDEFname; axis2='<value-of select='@axis2'/>' normal vector has illegal zero-magnitude axis values, use a non-zero vector direction instead </report>
    </rule>

    <!-- CAD component:  CADLayer, CADAssembly, CADPart, CADFace -->

    <!-- ========= CADLayer ========== -->
    <rule context="CADLayer">
      <let name="MFBoolValueResidue" value="translate(normalize-space(@visible),'truefalse, ','')"/>
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.1"/>
      <extends rule="optionalName"/>
      <!-- CADLayer might contain other CADLayer as well as CADAssembly nodes -->
      <report test="(ancestor::CADAssembly)" role="error">&lt;CADLayer DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot have an ancestor CADAssembly </report>
      <report test="(ancestor::CADPart)"     role="error">&lt;CADLayer DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot have an ancestor CADPart </report>
      <report test="(ancestor::CADFace)"     role="error">&lt;CADLayer DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot have an ancestor CADFace </report>
      <report test="(string-length($MFBoolValueResidue) &gt; 0)" role="error">&lt;CADLayer DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; MFBool visible field must only include values of true or false </report>
      <!-- not-very strict content model checked by DTD, Schema since CADAssembly is a Grouping node -->
    </rule>

    <!-- ========= CADAssembly ========== -->
    <rule context="CADAssembly">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.1"/>
      <extends rule="optionalName"/>
      <!-- CADAssembly can (optionally) be in different layers or be a subassembly -->
      <report test="(ancestor::CADPart)"     role="error">&lt;CADAssembly DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot have an ancestor CADPart </report>
      <report test="(ancestor::CADFace)"     role="error">&lt;CADAssembly DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot have an ancestor CADFace </report>
      <!-- not-very strict content model checked by DTD, Schema since CADAssembly is a Grouping node -->
    </rule>

    <!-- ========= CADPart ========== -->
    <rule context="CADPart">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.1"/>
      <extends rule="optionalName"/>
      <!-- CADPart is usually found in a CADAssembly -->
      <report test="not(ancestor::CADAssembly)" role="error">&lt;CADPart DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; does not have an ancestor CADCADAssembly </report>
      <report test="(ancestor::CADPart)"        role="error">&lt;CADPart DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot have an ancestor CADPart </report>
      <report test="(ancestor::CADFace)"        role="error">&lt;CADPart DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot have an ancestor CADFace </report>
      <!-- fairly strict content model checked by DTD, Schema: CADPart is a Grouping node but can only contain Metadata node and CADFace|ProtoInstance -->
    </rule>

    <!-- ========= CADFace ========== -->
    <rule context="CADFace">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.1"/>
      <extends rule="optionalName"/>
      <!-- CADFace is found in a CADPart -->
      <report test="not(parent::CADPart)" role="error">&lt;CADFace DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; does not have an parent CADPart </report>
      <report test="(ancestor::CADFace)"    role="error">&lt;CADFace DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot have an ancestor CADFace </report>
      <!-- fairly strict content model checked by DTD, Schema: CADFace should only contain Metadata or else a single Shape or LOD node with containerField='shape' -->
      <report test="    Shape[not(@containerField='shape')]" role="error">&lt;CADFace DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; contains Shape node that has incorrect containerField='<value-of select='@containerField'/>', should be containerField='shape' </report>      
      <report test="Transform[not(@containerField='shape')]" role="error">&lt;CADFace DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; contains Transform node that has incorrect containerField='<value-of select='@containerField'/>', should be containerField='shape' </report>      
      <report test="      LOD[not(@containerField='shape')]" role="error">&lt;CADFace DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; contains LOD node that has incorrect containerField='<value-of select='@containerField'/>', should be containerField='shape' </report>      
      <!-- should only allow one active Shape at a time -->
      <report test="boolean(    *[not(starts-with(local-name(),'Metadata')) and not(local-name() = 'Shape') and not(local-name() = 'LOD') and not(local-name() = 'Transform')])" role="error">&lt;CADFace DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; contains illegal child node, can only hold one Shape or one LOD or one Transform inside CADFace </report>
      <report test="boolean(LOD/*[not(starts-with(local-name(),'Metadata')) and not(local-name() = 'Shape')])" role="error">&lt;CADFace DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; contains LOD with illegal child node, since child LOD inside CADFace can only display one Shape node at a time </report>
      <report test="boolean(Transform/*[not(starts-with(local-name(),'Metadata')) and not(local-name() = 'Shape')])" role="error">&lt;CADFace DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; contains Transform with illegal child node, since child LOD inside CADFace can only display one Shape node at a time </report>
    </rule>

    <!-- ========= IndexedQuadSet ========== -->
    <rule context="IndexedQuadSet">
      <extends rule="geometryNode"/>
      <extends rule="ChildDataCounts"/>
      <extends rule="X3Dversion3.1"/>
      <extends rule="indexedPolyTests"/>
      <report test="contains(@index,'-1')" role="error">&NodeDEFname; index='<value-of select='@index'/>' must not contain -1 sentinel values </report>
    </rule>

    <!-- ========= QuadSet ========== -->
    <rule context="QuadSet">
      <extends rule="geometryNode"/>
      <extends rule="ChildDataCounts"/>
      <extends rule="X3Dversion3.1"/>
    </rule>

    <!-- ========= ClipPlane ========== -->
    <!-- http://www.web3d.org/files/specifications/19775-1/V3.3/Part01/components/rendering.html#ClipPlane  -->
    <rule context="ClipPlane">
      <let name="plane"                     value="concat(' ',normalize-space(translate(@plane, ',',' ')))"/>
      <let name="planeCount"                value="string-length($plane)              - string-length(translate($plane,  ' ',''))"/>
      <extends rule="DEFtests"/>
      <extends rule="enabledTests"/>
      <extends rule="X3Dversion3.2"/>
      <report test="(string-length(normalize-space(@plane)) > 0) and ($planeCount != 4)"    role="warning">&NodeDEFname; plane attribute has <value-of select='$planeCount'/> values, 4 are required for a valid plane equation </report>
      <!-- the following test does not catch values between 1.0 and 1.1 -->
      <report test="contains($plane,' 2') or contains($plane,' 3') or contains($plane,' 4') or contains($plane,' 5') or contains($plane,' 6') or contains($plane,' 7') or contains($plane,' 8') or contains($plane,' 9') or contains($plane,' 1.1') or contains($plane,' 1.2') or contains($plane,' 1.3') or contains($plane,' 1.4') or contains($plane,' 1.5') or contains($plane,' 1.6') or contains($plane,' 1.7') or contains($plane,' 1.8') or contains($plane,' 1.9')" role="warning">&NodeDEFname; contains a plane equation value greater than 1, plane='<value-of select='@plane'/>' </report>
      <!-- the following test does not catch values between -1.0 and -1.1 -->
      <report test="contains($plane,' -2') or contains($plane,' -3') or contains($plane,' -4') or contains($plane,' -5') or contains($plane,' -6') or contains($plane,' -7') or contains($plane,' -8') or contains($plane,' -9') or contains($plane,' -1.1') or contains($plane,' -1.2') or contains($plane,' -1.3') or contains($plane,' -1.4') or contains($plane,' -1.5') or contains($plane,' -1.6') or contains($plane,' -1.7') or contains($plane,' -1.8') or contains($plane,' -1.9')" role="warning">&NodeDEFname; contains a plane equation value less than -1, plane='<value-of select='@plane'/>' </report>
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='Rendering'][number(@level) ge 5]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Rendering' level='5'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>

    <!-- ========= Geometry data nodes ========== -->

    <!-- check parent nodes -->
    <rule id="X3DCoordinateNode" abstract="true">
      <assert test="contains(local-name(..),'Indexed') or contains(local-name(..),'Triangle') or contains(local-name(..),'Quad') or (local-name(..)='PointSet') or contains(local-name(..),'Line') or contains(local-name(..),'field') or contains(local-name(..),'fieldValue') or (local-name(..)='HAnimHumanoid') or (local-name(..)='HAnimSegment') or contains(local-name(..),'Nurbs')" role="error">&NodeDEFname; has parent <value-of select='local-name(..)'/>, instead needs to have a geometry node as a parent </assert>
    </rule>

    <!-- ========= Coordinate ========== -->
    <rule context="Coordinate">
      <let name="point"         value="normalize-space(translate(@point, ',',' '))"/>
      <let name="pointCount"    value="string-length($point)  - string-length(translate($point,  ' ','')) + 1"/>
      <extends rule="DEFtests"/>
      <extends rule="X3DCoordinateNode"/>
      <assert test="@point or (@USE) or //ROUTE[@toNode=$DEF] or boolean(IS/connect[@nodeField='point']) or (//ProtoDeclare/ProtoInterface/field/*[@USE=$DEF])"    role="warning">&NodeDEFname; contains no point data </assert>
      <!-- TODO also test preceding not inside ProtoDeclare -->
      <report test="not(@USE) and ($point) and preceding::Coordinate[normalize-space(translate(@point, ',',' '))=$point] and not //ROUTE[@toField=$DEF] and not(ancestor::ProtoDeclare) and not(parent::field or parent::fieldValue)"  role="warning">&NodeDEFname; has identical point array matching a preceding Coordinate node, consider DEF/USE to avoid duplication (point='<value-of select='substring(@point,0,40)'/>') </report>
      <report test="(string-length(normalize-space($point)) > 0) and (($pointCount div 3)!=round($pointCount div 3))"    role="warning">&NodeDEFname; point array has <value-of select='($pointCount div 3)'/> triples, likely has incorrect number of values or missing whitespace (point='<value-of select='substring(@point,0,40)'/>') </report>
      <!-- common scene-graph hierarchy errors -->
    </rule>

    <!-- ========= CoordinateDouble ========== -->
    <rule context="CoordinateDouble">
      <let name="point"         value="normalize-space(translate(@point, ',',' '))"/>
      <let name="pointCount"    value="string-length($point)  - string-length(translate($point,  ' ','')) + 1"/>
      <extends rule="DEFtests"/>
      <extends rule="X3DCoordinateNode"/>
      <assert test="@point or (@USE) or boolean(IS/connect[@nodeField='point'])"    role="warning">&NodeDEFname; contains no point data </assert>
      <!-- TODO also test preceding not inside ProtoDeclare -->
      <report test="not(@USE) and ($point) and preceding::CoordinateDouble[normalize-space(translate(@point, ',',' '))=$point] and not //ROUTE[@toField=$DEF] and not(ancestor::ProtoDeclare) and not(parent::field or parent::fieldValue)"  role="warning">&NodeDEFname; has identical point array matching a preceding CoordinateDouble node, consider DEF/USE to avoid duplication (point='<value-of select='substring(@point,0,40)'/>') </report>
      <report test="(string-length(normalize-space($point)) > 0) and (($pointCount div 3)!=round($pointCount div 3))"    role="warning">&NodeDEFname; point array has <value-of select='($pointCount div 3)'/> triples, likely has incorrect number of values or missing whitespace (point='<value-of select='substring(@point,0,40)'/>') </report>
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='NURBS'][number(@level) ge 1]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='NURBS' level='1'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>

    <!-- ========= abstract: colorField ========== -->
    <rule id="colorField" abstract="true">
      <!-- these rules should work identically with SFColor or MFColor color fields -->
      <!-- prepend blank to color for simplification of illegal-value tests -->
      <let name="color"                     value="concat(' ',normalize-space(translate(@color, ',',' ')))"/>
      <let name="colorCount"                value="string-length($color)              - string-length(translate($color,  ' ',''))"/>
      <extends rule="DEFtests"/>
      <report test="contains($color,'-')"  role="warning">&NodeDEFname; contains a negative color array value, color='<value-of select='@color'/>' </report>
      <!-- the following test does not catch values between 1.0 and 1.1 -->
      <report test="contains($color,' 2') or contains($color,' 3') or contains($color,' 4') or contains($color,' 5') or contains($color,' 6') or contains($color,' 7') or contains($color,' 8') or contains($color,' 9') or contains($color,' 1.1') or contains($color,' 1.2') or contains($color,' 1.3') or contains($color,' 1.4') or contains($color,' 1.5') or contains($color,' 1.6') or contains($color,' 1.7') or contains($color,' 1.8') or contains($color,' 1.9')" role="warning">&NodeDEFname; contains a color array value greater than 1, color='<value-of select='@color'/>' </report>
     </rule>

    <!-- ========= abstract: colorNode ========== -->
    <rule id="colorNode" abstract="true">
      <extends rule="colorField"/>
      <assert test="(string-length($color) > 1) or (@USE) or boolean(IS/connect[@nodeField='color'])"    role="warning">&NodeDEFname; contains no color array data </assert>
      <report test="not(@USE) and ($color) and preceding::Color[normalize-space(translate(@color, ',',' '))=$color] and not //ROUTE[@toField=$DEF] and not(ancestor::ProtoDeclare) and not(parent::field or parent::fieldValue)"  role="warning">&NodeDEFname; has identical color array matching a preceding Color node, consider DEF/USE to avoid duplication (color='<value-of select='substring(@color,0,40)'/>') </report>
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../Coordinate) and not(../CoordinateDouble) and not(local-name(..)='ElevationGrid')"  role="warning">&NodeDEFname; has no accompanying Coordinate (or CoordinateDouble) node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../Coordinate) and not(../CoordinateDouble) and not(local-name(..)='ElevationGrid')"  role="warning">&lt;<name/> USE='<value-of select='@USE'/>' has no accompanying Coordinate (or CoordinateDouble) node </report>
      <!-- parent checks similar to X3DCoordinateNode -->
      <assert test="contains(local-name(..),'Indexed') or contains(local-name(..),'Triangle') or contains(local-name(..),'Quad') or (local-name(..)='PointSet') or contains(local-name(..),'Line') or contains(local-name(..),'field') or contains(local-name(..),'fieldValue') or contains(local-name(..),'ElevationGrid') or (local-name(..)='HAnimSegment') or contains(local-name(..),'Nurbs')" role="error">&NodeDEFname; has parent <value-of select='local-name(..)'/>, instead needs to have a geometry node as a parent </assert>
      <!-- unnecesarily verbose
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and (../../Appearance/ImageTexture or ../../Appearance/MovieTexture or ../../Appearance/PixelTexture or ../../Appearance/MultiTexture or ../../Appearance/ProtoInstance)"  role="warning">&NodeDEFname; values are overridden by accompanying texture node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and (../../Appearance/ImageTexture or ../../Appearance/MovieTexture or ../../Appearance/PixelTexture or ../../Appearance/MultiTexture or ../../Appearance/ProtoInstance)"  role="warning">&lt;<name/> USE='<value-of select='@USE'/>' values are overridden by accompanying texture node </report>
      -->
    </rule>

    <!-- ========= Color ========== -->
    <rule context="Color">
      <extends rule="colorNode"/>
      <report test="(string-length(normalize-space($color)) > 0) and (($colorCount div 3)!=round($colorCount div 3))"    role="warning">&NodeDEFname; color array has <value-of select='($colorCount div 3)'/> triples, likely has incorrect number of values or missing whitespace </report>
    </rule>

    <!-- ========= ColorRGBA ========== -->
    <rule context="ColorRGBA">
      <extends rule="colorNode"/>
      <report test="(string-length(normalize-space($color)) > 0) and (($colorCount div 4)!=round($colorCount div 4))"    role="warning">&NodeDEFname; color array has <value-of select='($colorCount div 4)'/> 4-tuples, likely has incorrect number of values or missing whitespace </report>
   </rule>

    <!-- ========= Normal ========== -->
    <rule context="Normal">
      <let name="vector"                   value="normalize-space(translate(@vector, ',',' '))"/>
      <let name="vectorCount"              value="string-length($vector)            - string-length(translate($vector,  ' ','')) + 1"/>
      <extends rule="DEFtests"/>
      <!-- parent checks similar to X3DCoordinateNode -->
      <assert test="contains(local-name(..),'Indexed') or contains(local-name(..),'Triangle') or contains(local-name(..),'Quad') or (local-name(..)='PointSet') or contains(local-name(..),'Line') or contains(local-name(..),'field') or contains(local-name(..),'fieldValue') or contains(local-name(..),'ElevationGrid') or (local-name(..)='HAnimHumanoid')" role="error">&NodeDEFname; has parent <value-of select='local-name(..)'/>, instead needs to have a geometry node as a parent </assert>
      <assert test="@vector or (string-length(@USE) > 0) or boolean(IS/connect[@nodeField='point'])"    role="warning">&NodeDEFname; contains no vector data </assert>
      <report test="not(@USE) and ($vector) and preceding::Normal[normalize-space(translate(@vector, ',',' '))=$vector] and not //ROUTE[@toField=$DEF] and not(ancestor::ProtoDeclare) and not(parent::field or parent::fieldValue)"  role="warning">&NodeDEFname; has identical vector array matching a preceding Normal node, consider DEF/USE to avoid duplication (vector='<value-of select='substring(@vector,0,40)'/>') </report>
      <report test="(string-length(normalize-space($vector)) > 0) and (($vectorCount div 3)!=round($vectorCount div 3))"    role="warning">&NodeDEFname; vector array has <value-of select='($vectorCount div 3)'/> triples, likely has incorrect number of values or missing whitespace </report>
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../Coordinate) and not(../CoordinateDouble) and not(local-name(..)='ElevationGrid')"  role="warning">&NodeDEFname; has no accompanying Coordinate (or CoordinateDouble) node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../Coordinate) and not(../CoordinateDouble) and not(local-name(..)='ElevationGrid')"  role="warning">&lt;<name/> USE='<value-of select='@USE'/>' has no accompanying Coordinate (or CoordinateDouble) node </report>
    </rule>

    <!-- ========= TextureCoordinate ========== -->
    <rule context="TextureCoordinate">
      <let name="point"         value="normalize-space(translate(@point, ',',' '))"/>
      <let name="pointCount"    value="string-length($point)  - string-length(translate($point,  ' ','')) + 1"/>
      <extends rule="DEFtests"/>
      <!-- TODO parent checks similar to X3DCoordinateNode -->
      <assert test="@point or (@USE) or boolean(IS/connect[@nodeField='point'])"    role="warning">&NodeDEFname; contains no point data </assert>
      <report test="not(@USE) and ($point) and preceding::TextureCoordinate[normalize-space(translate(@point, ',',' '))=$point] and not //ROUTE[@toField=$DEF] and not(ancestor::ProtoDeclare) and not(parent::field or parent::fieldValue)"  role="warning">&NodeDEFname; has identical point array matching a preceding TextureCoordinate node, consider DEF/USE to avoid duplication (point='<value-of select='substring(@point,0,40)'/>') </report>
      <report test="(string-length(normalize-space($point)) > 0) and (($pointCount div 2)!=round($pointCount div 2))"    role="warning">&NodeDEFname; point array has <value-of select='($pointCount div 2)'/> 2-tuples, likely has incorrect number of values or missing whitespace (point='<value-of select='substring(@point,0,40)'/>') </report>
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../Coordinate) and not(../CoordinateDouble) and not(local-name(..)='ElevationGrid') and not(local-name(..)='MultiTextureCoordinate')"  role="warning">&NodeDEFname; has no accompanying Coordinate (or CoordinateDouble) node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../Coordinate) and not(../CoordinateDouble) and not(local-name(..)='ElevationGrid') and not(local-name(..)='MultiTextureCoordinate')"  role="warning">&lt;<name/> USE='<value-of select='@USE'/>' has no accompanying Coordinate (or CoordinateDouble) node </report>
    </rule>

    <!-- ========= TextureCoordinateGenerator ========== -->
    <rule context="TextureCoordinateGenerator">
      <let name="parameterSpaceCount" value="string-length(normalize-space(translate(@parameter,',',' '))) - string-length(translate(normalize-space(translate(@parameter,',',' ')),' ',''))"/>
      <extends rule="DEFtests"/>
      <!-- TODO parent checks similar to X3DCoordinateNode -->
      <!-- default mode is SPHERE with no parameter -->
      <assert test="not(@USE) and (not(@mode) or (@mode='') or (@mode='SPHERE') or (@mode='CAMERASPACENORMAL') or (@mode='CAMERASPACEPOSITION') or (@mode='CAMERASPACEREFLECTIONVECTOR') or (@mode='SPHERE-LOCAL') or (@mode='COORD') or (@mode='COORD-EYE') or (@mode='NOISE') or (@mode='NOISE-EYE') or (@mode='SPHERE-REFLECT') or (@mode='SPHERE-REFLECT-LOCAL'))" role="error">&lt;<name/> DEF='<value-of select='$DEF'/>' mode='<value-of select='@mode'/>'/&gt; mode attribute has illegal enumeration value, mode must be one of SPHERE CAMERASPACENORMAL CAMERASPACEPOSITION CAMERASPACEREFLECTIONVECTOR SPHERE-LOCAL COORD COORD-EYE NOISE NOISE-EYE SPHERE-REFLECT or SPHERE-REFLECT-LOCAL </assert>
      <!-- parameter count checks:  see Table 18.6 -->
      <report test="not(@USE) and (@mode='NOISE')                and (string-length(normalize-space(@parameter)) > 0) and ($parameterSpaceCount != 2)" role="warning">&lt;<name/> DEF='<value-of select='$DEF'/>' mode=&apos;<value-of select='(@mode)'/>&apos; parameter=&apos;<value-of select='(@parameter)'/>&apos;/&gt; parameter count is <value-of select='$parameterSpaceCount + 1'/> instead of 6 (for scale and translation x y z values) in this mode </report>
      <report test="not(@USE) and (@mode='SPHERE-REFLECT')       and (string-length(normalize-space(@parameter)) > 0) and ($parameterSpaceCount  > 0)" role="warning">&lt;<name/> DEF='<value-of select='$DEF'/>' mode=&apos;<value-of select='(@mode)'/>&apos; parameter=&apos;<value-of select='(@parameter)'/>&apos;/&gt; parameter count is <value-of select='$parameterSpaceCount + 1'/> instead of 0 or 1 (for optional index of refraction value) in this mode </report>
      <report test="not(@USE) and (@mode='SPHERE-REFLECT-LOCAL') and (string-length(normalize-space(@parameter)) > 0) and ($parameterSpaceCount != 0)" role="warning">&lt;<name/> DEF='<value-of select='$DEF'/>' mode=&apos;<value-of select='(@mode)'/>&apos; parameter=&apos;<value-of select='(@parameter)'/>&apos;/&gt; parameter count is <value-of select='$parameterSpaceCount + 1'/> instead of 4 (for index of refraction value and x y z eye-point values in local coordinate system) in this mode </report>
      <report test="not(@USE) and not(@mode='NOISE') and not(@mode='SPHERE-REFLECT') and not(@mode='SPHERE-REFLECT-LOCAL') and (string-length(normalize-space(@parameter)) > 0)" role="warning">&lt;<name/> DEF='<value-of select='$DEF'/>' mode=&apos;<value-of select='(@mode)'/>&apos; parameter=&apos;<value-of select='(@parameter)'/>&apos;/&gt; no parameters are defined for this mode </report>
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../Coordinate) and not(../CoordinateDouble) and not(local-name(..)='ElevationGrid') and not(local-name(..)='MultiTextureCoordinate')"  role="warning">&NodeDEFname; has no accompanying Coordinate (or CoordinateDouble) node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../Coordinate) and not(../CoordinateDouble) and not(local-name(..)='ElevationGrid') and not(local-name(..)='MultiTextureCoordinate')"  role="warning">&lt;<name/> USE='<value-of select='@USE'/>' has no accompanying Coordinate (or CoordinateDouble) node </report>
    </rule>

    <!-- ========= TextureTransform ========== -->
    <rule context="TextureTransform">
      <extends rule="DEFtests"/>
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../ImageTexture) and not(../MovieTexture) and not(../PixelTexture) and not(../MultiTexture)"  role="warning">&NodeDEFname; has no accompanying ImageTexture, MovieTexture, PixelTexture or MultiTexture node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../ImageTexture) and not(../MovieTexture) and not(../PixelTexture) and not(../MultiTexture)"  role="warning">&lt;<name/> USE='<value-of select='@USE'/>' has no accompanying ImageTexture, MovieTexture, PixelTexture or MultiTexture node </report>
    </rule>
    
    <!-- TODO MultiTextureCoordinate and MultiTextureTransform -->

    <!-- ========= MultiTexture ========== -->
    <rule context="MultiTexture">
      <let name="mode1"     value="substring-before(concat(normalize-space(translate(@mode,'&quot;',' ')),' '),' ')"/>
      <let name="function1" value="substring-before(concat(normalize-space(translate(@function,'&quot;',' ')),' '),' ')"/>
      <!-- TODO truncate before ending quote -->
      <let name="mode2"     value="normalize-space(substring-after(normalize-space(translate(@mode,'&quot;',' ')),' '))"/>
      <let name="function2" value="normalize-space(substring-after(normalize-space(translate(@function,'&quot;',' ')),' '))"/>
      <!-- TODO mode3, mode4 etc. -->
      <!-- TODO warn number of child textures is different than number of mode values -->
      <let name="modeQuoteCount"     value="string-length(@mode)     - string-length(translate(@mode,'&quot;',''))"/>
      <let name="functionQuoteCount" value="string-length(@function) - string-length(translate(@function,'&quot;',''))"/>
      <!-- set value="true()" to enable, value="false()" to disable -->
      <let name="trace" value="false()"/>
      <extends rule="DEFtests"/>
      <report test="MultiTexture"  role="error">&NodeDEFname; is not allowed to contain another MultiTexture node </report>
      <report test="  not(ImageTexture) and not(MovieTexture) and not(PixelTexture) and not(ProtoInstance)"  role="warning">&NodeDEFname; does not contain any texture nodes </report>
      <report test="(count(ImageTexture) + count(MovieTexture) + count(PixelTexture) + count(ProtoInstance)) = 1"  role="warning">&NodeDEFname; only contains one texture node </report>
      <!-- mode -->
      <report test="$trace" role="trace">  $mode1=<value-of select='$mode1'/>, $mode2=<value-of select='$mode2'/>, $modeQuoteCount=<value-of select='$modeQuoteCount'/> </report>
      <assert test="(@USE) or not(@mode) or ($modeQuoteCount = 2) or ($modeQuoteCount = 4) or ($modeQuoteCount = 6)"    role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' mode='<value-of select='@mode'/>'/&gt; mode attribute has illegal number of quotation marks </assert>
      <report test="not(@USE) and (string-length(normalize-space($mode1)) > 0)     and not($mode1='MODULATE') and not($mode1='REPLACE') and not($mode1='MODULATE2X') and not($mode1='MODULATE4X') and not($mode1='ADD') and not($mode1='ADDSIGNED') and not($mode1='ADDSIGNED2X') and not($mode1='SUBTRACT') and not($mode1='ADDSMOOTH ') and not($mode1='BLENDDIFFUSEALPHA') and not($mode1='BLENDTEXTUREALPHA') and not($mode1='BLENDFACTORALPHA') and not($mode1='BLENDCURRENTALPHA') and not($mode1='MODULATEALPHA_ADDCOLOR') and not($mode1='MODULATEINVALPHA_ADDCOLOR') and not($mode1='MODULATEINVCOLOR_ADDALPHA') and not($mode1='OFF') and not($mode1='SELECTARG1') and not($mode1='SELECTARG2') and not($mode1='DOTPRODUCT3')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' mode='<value-of select='@mode'/>'/&gt; initial mode attribute &quot;<value-of select='@mode1'/>&quot; has illegal enumeration value, must be one of MODULATE REPLACE MODULATE2X MODULATE4X ADD ADDSIGNED ADDSIGNED2X SUBTRACT ADDSMOOTH  BLENDDIFFUSEALPHA BLENDTEXTUREALPHA BLENDFACTORALPHA BLENDCURRENTALPHA MODULATEALPHA_ADDCOLOR MODULATEINVALPHA_ADDCOLOR MODULATEINVCOLOR_ADDALPHA OFF SELECTARG1 SELECTARG2 DOTPRODUCT3 </report>
      <report test="not(@USE) and (string-length(normalize-space($mode2)) > 0)     and not($mode2='MODULATE') and not($mode2='REPLACE') and not($mode2='MODULATE2X') and not($mode2='MODULATE4X') and not($mode2='ADD') and not($mode2='ADDSIGNED') and not($mode2='ADDSIGNED2X') and not($mode2='SUBTRACT') and not($mode2='ADDSMOOTH ') and not($mode2='BLENDDIFFUSEALPHA') and not($mode2='BLENDTEXTUREALPHA') and not($mode2='BLENDFACTORALPHA') and not($mode2='BLENDCURRENTALPHA') and not($mode2='MODULATEALPHA_ADDCOLOR') and not($mode2='MODULATEINVALPHA_ADDCOLOR') and not($mode2='MODULATEINVCOLOR_ADDALPHA') and not($mode2='OFF') and not($mode2='SELECTARG1') and not($mode2='SELECTARG2') and not($mode2='DOTPRODUCT3')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' mode='<value-of select='@mode'/>'/&gt; secondary mode attribute &quot;<value-of select='@mode2'/>&quot; has illegal enumeration value, must be one of MODULATE REPLACE MODULATE2X MODULATE4X ADD ADDSIGNED ADDSIGNED2X SUBTRACT ADDSMOOTH  BLENDDIFFUSEALPHA BLENDTEXTUREALPHA BLENDFACTORALPHA BLENDCURRENTALPHA MODULATEALPHA_ADDCOLOR MODULATEINVALPHA_ADDCOLOR MODULATEINVCOLOR_ADDALPHA OFF SELECTARG1 SELECTARG2 DOTPRODUCT3 </report>
      <!-- source -->
      <!-- TODO bug in X3D specification? purpose of source is for second argument, but type is specified as MFString.  source is treated here as SFString. -->
      <report test="not(@USE) and (string-length(normalize-space(@source)) > 0)    and not(@source='DIFFUSE') and not(@source='SPECULAR') and not(@source='FACTOR')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' mode='<value-of select='@mode'/>' source='<value-of select='@source'/>'/&gt; source attribute has illegal enumeration value, source must be empty, DIFFUSE, SPECULAR or FACTOR</report>
      <!-- function -->
      <report test="$trace" role="trace">  $function1=<value-of select='$function1'/>, $function2=<value-of select='$function2'/>, $functionQuoteCount=<value-of select='$functionQuoteCount'/> </report>
      <assert test="(@USE) or not(@function) or ($functionQuoteCount = 2) or ($functionQuoteCount = 4)"    role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' function='<value-of select='@function'/>'/&gt; function attribute has illegal number of quotation marks </assert>
      <report test="not(@USE) and (string-length(normalize-space($function1)) > 0) and not($function1='COMPLEMENT') and not($function1='ALPHAREPLICATE')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' mode='<value-of select='@mode'/> function='<value-of select='@function'/>'/&gt; initial function attribute &quot;<value-of select='@function1'/>&quot; has illegal enumeration value, must be empty, COMPLEMENT or ALPHAREPLICATE</report>
      <report test="not(@USE) and (string-length(normalize-space($function2)) > 0) and not($function2='COMPLEMENT') and not($function2='ALPHAREPLICATE')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' mode='<value-of select='@mode'/> function='<value-of select='@function'/>'/&gt; secondary function attribute &quot;<value-of select='@function2'/>&quot; has illegal enumeration value, must be empty, COMPLEMENT or ALPHAREPLICATE</report>
      <!-- extraneous-quote tests for SFString enumeration fields
      <report test="contains(@function, '&quot;')" role="error">&NodeDEFname; function='<value-of select='@function'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="contains(@mode, '&quot;')" role="error">&NodeDEFname; mode='<value-of select='@mode'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="contains(@source, '&quot;')" role="error">&NodeDEFname; source='<value-of select='@source'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
       -->
    </rule>

    <!-- ========= TextureProperties ========== -->
    <rule context="TextureProperties">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@boundaryModeS, '&quot;')" role="error">&NodeDEFname; boundaryModeS='<value-of select='@boundaryModeS'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="contains(@boundaryModeT, '&quot;')" role="error">&NodeDEFname; boundaryModeT='<value-of select='@boundaryModeT'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="contains(@boundaryModeR, '&quot;')" role="error">&NodeDEFname; boundaryModeR='<value-of select='@boundaryModeR'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="contains(@magnificationFilter, '&quot;')" role="error">&NodeDEFname; magnificationFilter='<value-of select='@magnificationFilter'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="contains(@minificationFilter, '&quot;')" role="error">&NodeDEFname; minificationFilter='<value-of select='@minificationFilter'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="contains(@textureCompression, '&quot;')" role="error">&NodeDEFname; textureCompression='<value-of select='@textureCompression'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
    </rule>

    <!-- ========= MultiTextureCoordinate ========== -->
    <rule context="MultiTextureCoordinate">
      <extends rule="DEFtests"/>
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../Coordinate) and not(../CoordinateDouble) and not(local-name(..)='ElevationGrid')"  role="warning">&NodeDEFname; has no accompanying Coordinate (or CoordinateDouble) node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../Coordinate) and not(../CoordinateDouble) and not(local-name(..)='ElevationGrid')"  role="warning">&lt;<name/> USE='<value-of select='@USE'/>' has no accompanying Coordinate (or CoordinateDouble) node </report>
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and    (../TextureCoordinate)"  role="warning">&NodeDEFname; has sibling TextureCoordinate node, only one is allowed as immediate child of geometry node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and    (../TextureCoordinate)"  role="warning">&lt;<name/> USE='<value-of select='@USE'/>' has sibling TextureCoordinate node, only one is allowed as immediate child of geometry node </report>
    </rule>

    <!-- ========= MultiTextureTransform ========== -->
    <rule context="MultiTextureTransform">
      <extends rule="DEFtests"/>
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../ImageTexture) and not(../MovieTexture) and not(../PixelTexture) and not(../MultiTexture)"  role="warning">&NodeDEFname; has no accompanying ImageTexture, MovieTexture, PixelTexture or MultiTexture node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and not(../ImageTexture) and not(../MovieTexture) and not(../PixelTexture) and not(../MultiTexture)"  role="warning">&lt;<name/> USE='<value-of select='@USE'/>' has no accompanying ImageTexture, MovieTexture, PixelTexture or MultiTexture node </report>
      <report test="not(@USE)                 and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and    (../TextureTransform)"  role="warning">&NodeDEFname; has sibling TextureTransform node, only one is allowed as immediate child of Appearance node </report>
      <report test="(string-length(@USE) > 0) and not(local-name(..)='field') and not(local-name(..)='fieldValue') and not(local-name(..)='ProtoBody') and    (../TextureTransform)"  role="warning">&lt;<name/> USE='<value-of select='@USE'/>' has sibling TextureTransform node, only one is allowed as immediate child of Appearance node </report>
    </rule>

    <!-- ========= Geometry nodes ========== -->

    <!-- ========= abstract: geometryNode ========== -->
    <rule id="geometryNode" abstract="true">
      <extends rule="DEFtests"/>
      <!-- Ensure that orphan geometry nodes have a parent Shape or other legal construct -->
      <assert test="parent::Collision or parent::Shape or parent::ProtoBody or parent::field or parent::fieldValue" role="error">&NodeDEFname; geometry node must have Shape node as parent </assert>
      <!-- Collision proxy must be X3DChildNode, cannot be a geometryNode -->
      <report test="parent::Collision" role="warning">&NodeDEFname; containerField='<value-of select='@containerField'/>' cannot be proxy for parent &lt;Collision DEF='<value-of select='../@DEF'/>'&gt; node, insert intermediate parent node &lt;Shape containerField=&apos;proxy&apos;&gt; between them </report>
      <report test="(@ccw='TRUE' )"             role="error">&NodeDEFname; ccw='TRUE' is incorrect, define ccw='true' instead</report>
      <report test="(@ccw='FALSE')"             role="error">&NodeDEFname; ccw='FALSE' is incorrect, define ccw='false' instead</report>
      <report test="(@convex='TRUE' )"          role="error">&NodeDEFname; convex='TRUE' is incorrect, define convex='true' instead</report>
      <report test="(@convex='FALSE')"          role="error">&NodeDEFname; convex='FALSE' is incorrect, define convex='false' instead</report>
      <report test="(@solid='TRUE' )"           role="error">&NodeDEFname; solid='TRUE' is incorrect, define solid='true' instead</report>
      <report test="(@solid='FALSE')"           role="error">&NodeDEFname; solid='FALSE' is incorrect, define solid='false' instead</report>
      <report test="(@colorPerVertex='TRUE' )"  role="error">&NodeDEFname; colorPerVertex='TRUE' is incorrect, define colorPerVertex='true' instead</report>
      <report test="(@colorPerVertex='FALSE')"  role="error">&NodeDEFname; colorPerVertex='FALSE' is incorrect, define colorPerVertex='false' instead</report>
      <report test="(@normalPerVertex='TRUE' )" role="error">&NodeDEFname; normalPerVertex='TRUE' is incorrect, define normalPerVertex='true' instead</report>
      <report test="(@normalPerVertex='FALSE')" role="error">&NodeDEFname; normalPerVertex='FALSE' is incorrect, define normalPerVertex='false' instead</report>
    </rule>

    <!-- ========= fogCoord_attribTests:  attributes introduced in v3.1 on nodes defined in v3.0 ========== -->
    <!-- ElevationGrid | IndexedFaceSet | IndexedLineSet | IndexedQuadSet | IndexedTriangleFanSet | IndexedTriangleSet | IndexedTriangleStripSet | LineSet | PointSet | QuadSet | TriangleFanSet | TriangleSet | TriangleStripSet -->
    <rule id="fogCoord_attribTests" abstract="true">
      <report test="(@fogCoord) and (/X3D[@version='3.0'])" role="warning">&NodeDEFname; fogCoord='<value-of select='@fogCoord'/>' requires &lt;X3D version=&apos;3.1&apos;&gt; or higher, but found version='<value-of select='/X3D/@version'/>' </report>
      <report test="(@attrib)   and (/X3D[@version='3.0'])" role="warning">&NodeDEFname; attrib='<value-of select='@attrib'/>' requires &lt;X3D version=&apos;3.1&apos;&gt; or higher, but found version='<value-of select='/X3D/@version'/>' </report>
    </rule>

    <rule id="ChildDataCounts" abstract="true">
      <!-- compute values but let parent rule for each node determine whether values are correct -->
      <!-- note that count values = 1 if no nodes or values present, must also test for existence -->
      <let name="coordIndex"                     value="normalize-space(translate(@coordIndex, ',',' '))"/>
      <let name="coordIndexCount"                value="string-length($coordIndex)              - string-length(translate($coordIndex,  ' ','')) + 1"/>
      <let name="colorIndex"                     value="normalize-space(translate(@colorIndex, ',',' '))"/>
      <let name="colorIndexCount"                value="string-length($colorIndex)              - string-length(translate($colorIndex,  ' ','')) + 1"/>
      <let name="normalIndex"                    value="normalize-space(translate(@normalIndex, ',',' '))"/>
      <let name="normalIndexCount"               value="string-length($normalIndex)             - string-length(translate($normalIndex,  ' ','')) + 1"/>
      <let name="texCoordIndex"                  value="normalize-space(translate(@texCoordIndex, ',',' '))"/>
      <let name="texCoordIndexCount"             value="string-length($texCoordIndex)           - string-length(translate($texCoordIndex,  ' ','')) + 1"/>
      <let name="CoordinatePoint"                value="normalize-space(translate(Coordinate/@point, ',',' '))"/>
      <let name="CoordinatePointCount"           value="string-length($CoordinatePoint)         - string-length(translate($CoordinatePoint,  ' ','')) + 1"/>
      <let name="CoordinateDoublePoint"          value="normalize-space(translate(CoordinateDouble/@point, ',',' '))"/>
      <let name="CoordinateDoublePointCount"     value="string-length($CoordinateDoublePoint)   - string-length(translate($CoordinateDoublePoint,  ' ','')) + 1"/>
      <let name="ColorColor"                     value="normalize-space(translate(Color/@color, ',',' '))"/>
      <let name="ColorColorCount"                value="string-length($ColorColor)              - string-length(translate($ColorColor,  ' ','')) + 1"/>
      <let name="ColorRGBAColor"                 value="normalize-space(translate(ColorRGBA/@color, ',',' '))"/>
      <let name="ColorRGBAColorCount"            value="string-length($ColorRGBAColor)          - string-length(translate($ColorRGBAColor,  ' ','')) + 1"/>
      <let name="NormalVector"                   value="normalize-space(translate(Normal/@vector, ',',' '))"/>
      <let name="NormalVectorCount"              value="string-length($NormalVector)            - string-length(translate($NormalVector,  ' ','')) + 1"/>
      <let name="TextureCoordinatePoint"         value="normalize-space(translate(TextureCoordinate/@point, ',',' '))"/>
      <let name="TextureCoordinatePointCount"    value="string-length($TextureCoordinatePoint)  - string-length(translate($TextureCoordinatePoint,  ' ','')) + 1"/>
      <let name="ElevationGridHeight"            value="normalize-space(translate(@height, ',',' '))"/>
      <let name="ElevationGridHeightCount"       value="string-length($ElevationGridHeight)  - string-length(translate($ElevationGridHeight,  ' ','')) + 1"/>
      <!-- set value="true()" to enable, value="false()" to disable -->
      <let name="trace" value="false()"/>
      <!-- duplicate child node tests -->
      <report test="Coordinate and CoordinateDouble" role="error">&NodeDEFname; contains both Coordinate and CoordinateDouble nodes, no more than one is allowed </report>
      <report test="Color and ColorRGBA" role="error">&NodeDEFname; contains both Color and ColorRGBA nodes, no more than one is allowed </report>
      <report test="TextureCoordinate and TextureCoordinateGenerator" role="error">&NodeDEFname; contains both TextureCoordinate and TextureCoordinateGenerator nodes, no more than one is allowed </report>
      <!-- unsuccessful test:  XPath function calls
      <let name="coordIndex"                     value="@coordIndex"/>
      <let name="coordIndexCount"                value="count($coordIndex)"/>
      <let name="coordIndexMin"                  value="  min($coordIndex)"/>
      <let name="coordIndexMax"                  value="  max($coordIndex)"/>
      -->
      <report test="$trace" role="trace">ChildDataCounts: </report>
      <report test="$trace" role="trace">  $coordIndexCount=<value-of select='$coordIndexCount'/>, $colorIndexCount=<value-of select='$colorIndexCount'/>, $normalIndexCount=<value-of select='$normalIndexCount'/>, $texCoordIndexCount=<value-of select='$texCoordIndexCount'/> </report>
      <report test="$trace" role="trace">  $CoordinatePointCount=<value-of select='$CoordinatePointCount'/>, $CoordinateDoublePointCount=<value-of select='$CoordinateDoublePointCount'/> </report>
      <report test="$trace" role="trace">  $ColorColorCount=<value-of select='$ColorColorCount'/>, $ColorRGBAColorCount=<value-of select='$ColorRGBAColorCount'/> </report>
      <report test="$trace" role="trace">  $NormalVectorCount=<value-of select='$NormalVectorCount'/>, $TextureCoordinatePointCount=<value-of select='$TextureCoordinatePointCount'/> </report>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@mode, '&quot;')" role="error">&NodeDEFname; mode='<value-of select='@mode'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <!-- common tests -->
    </rule>

    <!-- ========= Box | Cone | Cylinder | Sphere ========== -->
    <rule context="Box | Cone | Cylinder | Sphere">
      <let name="height"       value="normalize-space(@height)"/>
      <let name="radius"       value="normalize-space(@radius)"/>
      <let name="bottomRadius" value="normalize-space(@bottomRadius)"/>
      <extends rule="geometryNode"/>
      <!-- only Box needs sizeTests -->
      <extends rule="sizeTests"/>
      <!-- check for 0 values in any of the dimension fields -->
      <report test="($height='0')       or ($height='.0')       or ($height='0.0')       or ($height='0.00')"       role="error">&NodeDEFname; height='<value-of select='@height'/>' is incorrect, must be greater than zero </report>
      <report test="($radius='0')       or ($radius='.0')       or ($radius='0.0')       or ($radius='0.00')"       role="error">&NodeDEFname; radius='<value-of select='@radius'/>' is incorrect, must be greater than zero </report>
      <report test="($bottomRadius='0') or ($bottomRadius='.0') or ($bottomRadius='0.0') or ($bottomRadius='0.00')" role="error">&NodeDEFname; bottomRadius='<value-of select='@bottomRadius'/>' is incorrect, must be greater than zero </report>
      <report test="contains(@height,'-')       and not(contains(@height,'E-')       or contains(@height,'e-'))"       role="error">&NodeDEFname; height='<value-of select='@height'/>' is incorrect, must be greater than zero </report>
      <report test="contains(@radius,'-')       and not(contains(@radius,'E-')       or contains(@radius,'e-'))"       role="error">&NodeDEFname; radius='<value-of select='@radius'/>' is incorrect, must be greater than zero </report>
      <report test="contains(@bottomRadius,'-') and not(contains(@bottomRadius,'E-') or contains(@bottomRadius,'e-'))" role="error">&NodeDEFname; bottomRadius='<value-of select='@bottomRadius'/>' is incorrect, must be greater than zero </report>
      <!-- check parts -->
      <report test="(@bottom='TRUE' )" role="error">&NodeDEFname; bottom='TRUE' is incorrect, define bottom='true' instead</report>
      <report test="(@bottom='FALSE')" role="error">&NodeDEFname; bottom='FALSE' is incorrect, define bottom='false' instead</report>
      <report test="(@side='TRUE' )"   role="error">&NodeDEFname; side='TRUE' is incorrect, define side='true' instead</report>
      <report test="(@side='FALSE')"   role="error">&NodeDEFname; side='FALSE' is incorrect, define side='false' instead</report>
      <report test="(@top='TRUE' )"    role="error">&NodeDEFname; top='TRUE' is incorrect, define top='true' instead</report>
      <report test="(@top='FALSE')"    role="error">&NodeDEFname; top='FALSE' is incorrect, define top='false' instead</report>
    </rule>

    <rule id="ElevationGridAttributeChecks" abstract="true">
      <let name="heightValuesNeeded" value="(@xDimension * @zDimension)"/>
      <extends rule="ChildDataCounts"/>
      <report test="(string-length(normalize-space(translate(@xDimension,'0123456789',''))) > 0)"    role="error">&NodeDEFname; erroneous value xDimension='<value-of select='@xDimension'/>', must be non-negative integer </report>
      <report test="(string-length(normalize-space(translate(@zDimension,'0123456789',''))) > 0)"    role="error">&NodeDEFname; erroneous value zDimension='<value-of select='@zDimension'/>', must be non-negative integer </report>
      <report test="starts-with(normalize-space(@xSpacing),'-')"    role="error">&NodeDEFname; erroneous negative value xSpacing='<value-of select='@xSpacing'/>', must be positive </report>
      <report test="starts-with(normalize-space(@zSpacing),'-')"    role="error">&NodeDEFname; erroneous negative value zSpacing='<value-of select='@zSpacing'/>', must be positive </report>
      <report test="(@xSpacing = 0)"    role="error">&NodeDEFname; erroneous zero value xSpacing='<value-of select='@zSpacing'/>', must be positive </report>
      <report test="(@zSpacing = 0)"    role="error">&NodeDEFname; erroneous zero value zSpacing='<value-of select='@zSpacing'/>', must be positive </report>
      <assert test="($ElevationGridHeightCount = $heightValuesNeeded)">&NodeDEFname; height array has <value-of select='$ElevationGridHeightCount'/> values when (xDimension * zDimension = <value-of select='@xDimension'/> * <value-of select='@zDimension'/> = <value-of select='$heightValuesNeeded'/>) values are required </assert>
    </rule>

    <!-- ========= ElevationGrid ========== -->
    <rule context="ElevationGrid">
      <extends rule="geometryNode"/>
      <extends rule="creaseAngle"/>
      <extends rule="ElevationGridAttributeChecks"/>
      <extends rule="fogCoord_attribTests"/>
    </rule>

    <!-- ========= IndexedFaceSet | IndexedLineSet ========== -->
    <rule context="IndexedFaceSet | IndexedLineSet">
      <extends rule="geometryNode"/>
      <extends rule="creaseAngle"/> <!-- for IndexedFaceSet only -->
      <extends rule="ChildDataCounts"/>
      <extends rule="fogCoord_attribTests"/>
      <!-- test index counts -->
      <report test="Coordinate/@point        and ($CoordinatePointCount &gt; 0)        and (string-length($coordIndex)=0)"                                       role="warning">&NodeDEFname; contains Coordinate data but has no coordIndex values </report>
      <report test="CoordinateDouble/@point  and ($CoordinateDoublePointCount &gt; 0)  and (string-length($coordIndex)=0)"                                       role="warning">&NodeDEFname; contains CoordinateDouble data but has no coordIndex values </report>
      <report test="Color/@color             and ($ColorColorCount &gt; 0)             and (string-length($colorIndex)=0)    and (string-length($coordIndex)=0)" role="warning">&NodeDEFname; contains Color data but has no colorIndex or coordIndex values </report>
      <report test="ColorRGBA/@color         and ($ColorRGBAColorCount &gt; 0)         and (string-length($colorIndex)=0)    and (string-length($coordIndex)=0)" role="warning">&NodeDEFname; contains ColorRGBA data but has no colorIndex or coordIndex values </report>
      <report test="Normal/@vector           and ($NormalVectorCount &gt; 0)           and (string-length($normalIndex)=0)   and (string-length($coordIndex)=0)" role="warning">&NodeDEFname; contains Normal data but has no normalIndex or coordIndex values </report>
      <report test="TextureCoordinate/@point and ($TextureCoordinatePointCount &gt; 0) and (string-length($texCoordIndex)=0) and (string-length($coordIndex)=0)" role="warning">&NodeDEFname; contains TextureCoordinate data but has no texCoordIndex or coordIndex values </report>
      <!-- partial test, should only report a problem if contained Coordinate* is USE; these rules do not include test for whether the contained USE node matches the preceding IFS/ILS corresponding contained DEF ndoe -->
      <report test="not(@USE) and ($coordIndex) and (local-name() = 'IndexedFaceSet')  and (string-length($coordIndex) > 10) and preceding::IndexedFaceSet[normalize-space(translate(@coordIndex, ',',' '))=$coordIndex] and not //ROUTE[@toField=$DEF] and not(ancestor::ProtoDeclare) and not(parent::field or parent::fieldValue) and (Coordinate[string-length(@USE) > 0] or CoordinateDouble[string-length(@USE) > 0])"  role="warning">&NodeDEFname; has identical coordIndex array matching a preceding IndexedFaceSet node, consider DEF/USE to avoid duplication if all attributes and child nodes are identical (coordIndex='<value-of select='substring(@coordIndex,0,40)'/>') </report>
      <report test="not(@USE) and ($coordIndex) and (local-name() = 'IndexedLineSet')  and (string-length($coordIndex) > 10) and preceding::IndexedLineSet[normalize-space(translate(@coordIndex, ',',' '))=$coordIndex] and not //ROUTE[@toField=$DEF] and not(ancestor::ProtoDeclare) and not(parent::field or parent::fieldValue) and (Coordinate[string-length(@USE) > 0] or CoordinateDouble[string-length(@USE) > 0])"  role="warning">&NodeDEFname; has identical coordIndex array matching a preceding IndexedLineSet node, consider DEF/USE to avoid duplication if all attributes and child nodes are identical (coordIndex='<value-of select='substring(@coordIndex,0,40)'/>') </report>
    </rule>

    <!-- ========= LineSet | PointSet ========== -->
    <rule context="LineSet | PointSet">
      <extends rule="geometryNode"/>
      <extends rule="ChildDataCounts"/>
      <extends rule="fogCoord_attribTests"/>
    </rule>

    <!-- ========= TriangleSet | TriangleFanSet | TriangleStripSet ========== -->
    <rule context="TriangleSet | TriangleFanSet | TriangleStripSet">
      <extends rule="geometryNode"/>
      <extends rule="ChildDataCounts"/>
      <extends rule="fogCoord_attribTests"/>
    </rule>

    <rule id="indexedPolyTests" abstract="true">
      <let name="missingIndex"         value="(string-length(normalize-space(translate(@index, ', ', ''))) &lt;= 1)"/>
      <report test="$missingIndex and (Coordinate/@point)" role="error">&NodeDEFname; missing index array for contained Coordinate node </report>
      <report test="$missingIndex and (CoordinateDouble/@point)" role="error">&NodeDEFname; missing index array for contained (CoordinateDouble) node </report>
      <report test="$missingIndex and (Color/@color)" role="error">&NodeDEFname; missing index array for contained Color node </report>
      <report test="$missingIndex and (ColorRGBA/@color)" role="error">&NodeDEFname; missing index array for contained ColorRGBA node </report>
      <report test="$missingIndex and (Normal/@vector)" role="error">&NodeDEFname; missing index array for contained Normal node </report>
      <report test="$missingIndex and (TextureCoordinate/@point)" role="error">&NodeDEFname; missing index array for contained TextureCoordinate node </report>
    </rule>

    <!-- ========= IndexedTriangleSet ========== -->
    <rule context="IndexedTriangleSet">
      <extends rule="geometryNode"/>
      <extends rule="ChildDataCounts"/>
      <extends rule="fogCoord_attribTests"/>
      <extends rule="indexedPolyTests"/>
      <report test="contains(@index,'-1')" role="error">&NodeDEFname; index='<value-of select='@index'/>' must not contain -1 sentinel values </report>
    </rule>

    <!-- ========= IndexedTriangleFanSet | IndexedTriangleStripSet ========== -->
    <rule context="IndexedTriangleFanSet | IndexedTriangleStripSet">
      <extends rule="geometryNode"/>
      <extends rule="ChildDataCounts"/>
      <extends rule="fogCoord_attribTests"/>
      <extends rule="indexedPolyTests"/>
    </rule>
    
    <!-- Geometry2D prerequisites met by Immersive, Interactive, Interchange or CADInterchange -->

    <!-- ========= Polyline2D | Polypoint2D | Rectangle2D | TriangleSet2D ========== -->
    <rule context="Polyline2D | Polypoint2D | Rectangle2D | TriangleSet2D">
      <extends rule="geometryNode"/>
      <assert test="(/X3D[(@profile='Immersive') or (@profile='Full')] or /X3D/head/component[@name='Geometry2D'][number(@level) ge 1] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;X3D profile='Immersive'&gt; or &lt;component name='Geometry2D' level='1'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>

    <!-- ========= Arc2D | ArcClose2D | Circle2D | Disk2D ========== -->
    <rule context="Arc2D | ArcClose2D | Circle2D | Disk2D">
      <extends rule="geometryNode"/>
      <assert test="(/X3D[(@profile='Full')]                           or /X3D/head/component[@name='Geometry2D'][number(@level) ge 2] or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='Geometry2D' level='2'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
     <!-- Arc2D, ArcClose2D beginAngle, endAngle [-2pi..2pi] -->
      <report test="(@beginAngle >     3.141592653)" role="error">&NodeDEFname; beginAngle='<value-of select='@beginAngle'/>' is greater than 3.141592653 (Pi radians = 360 degrees), use a smaller value. must not exceed legal range of values or tools may throw errors. </report>
      <report test="(@endAngle   >     3.141592653)" role="error">&NodeDEFname; endAngle='<value-of select='@endAngle'/>' is greater than 3.141592653 (Pi radians = 360 degrees), use a smaller value. must not exceed legal range of values or tools may throw errors. </report>
      <report test="(@beginAngle &lt; -3.141592653)" role="error">&NodeDEFname; beginAngle='<value-of select='@beginAngle'/>' is less than -3.141592653 (-Pi radians = -360 degrees), use a larger value. must not exceed legal range of values or tools may throw errors. </report>
      <report test="(@endAngle   &lt; -3.141592653)" role="error">&NodeDEFname; endAngle='<value-of select='@endAngle'/>' is less than -3.141592653 (-Pi radians = -360 degrees), use a larger value. must not exceed legal range of values or tools may throw errors. </report>
     </rule>

    <!-- ========= Lighting nodes ========== -->

    <rule id="LightingTests" abstract="true">
      <report test="(@global='true') and (/X3D[@version='3.0'])" role="error">&NodeDEFname; global='<value-of select='@global'/>' requires &lt;X3D version=&apos;3.1&apos;&gt; or higher, but found version='<value-of select='/X3D/@version'/>' </report>
      <!-- TODO color tests, SpotLight angle and radius tests -->
      <report test="(@global='TRUE' )" role="error">&NodeDEFname; global='TRUE' is incorrect, define global='true' instead</report>
      <report test="(@global='FALSE')" role="error">&NodeDEFname; global='FALSE' is incorrect, define global='false' instead</report>
      <report test="(@on='TRUE' )"     role="error">&NodeDEFname; on='TRUE' is incorrect, define on='true' instead</report>
      <report test="(@on='FALSE')"     role="error">&NodeDEFname; on='FALSE' is incorrect, define on='false' instead</report>
    </rule>

    <!-- ========= DirectionalLight | PointLight | SpotLight ========== -->
    <rule context="DirectionalLight | PointLight | SpotLight">
      <extends rule="colorField"/>
      <extends rule="LightingTests"/>
      <report test=  "(@beamWidth > 1.570796)" role="error">&NodeDEFname; beamWidth='<value-of select='@beamWidth'/>' is greater than 1.570796 (Pi/2 radians = 90 degrees), use a smaller value. must not exceed legal range of values or tools may throw errors. </report>
      <report test="(@cutoffAngle > 1.570796)" role="error">&NodeDEFname; cutoffAngle='<value-of select='@cutoffAngle'/>' is greater than 1.570796 (Pi/2 radians = 90 degrees), use a smaller value. must not exceed legal range of values or tools may throw errors. </report>
      <report test=  "(@beamWidth &lt;= 0)" role="error">&NodeDEFname; beamWidth='<value-of select='@beamWidth'/>' is less than or equal to 0, use a positive value up to 1.570796 (Pi/2 radians = 90 degrees). must not exceed legal range of values or tools may throw errors. </report>
      <report test="(@cutoffAngle &lt;= 0)" role="error">&NodeDEFname; cutoffAngle='<value-of select='@cutoffAngle'/>' is less than or equal to 0, use a positive value up to 1.570796 (Pi/2 radians = 90 degrees). must not exceed legal range of values or tools may throw errors. </report>
      <report test="(string-length(normalize-space($color)) > 0) and ($colorCount != 3)"    role="warning">&NodeDEFname; color='<value-of select='@color'/>' has <value-of select='($colorCount)'/> values instead of 3 </report>
    </rule>

    <!-- ========= DIS nodes ========== -->

    <rule id="DisComponentLevel1" abstract="true">
      <assert test="((/X3D[@profile='Immersive'] and (/X3D/head/component[@name='DIS'][number(@level) ge 1])) or (/X3D[@profile='Full']) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;X3D profile='Immersive'/&gt; &lt;component name='DIS' level='1'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>

    <rule id="DisComponentLevel2" abstract="true">
      <assert test="((/X3D[@profile='Immersive'] and (/X3D/head/component[@name='DIS'][number(@level) ge 2])) or (/X3D[@profile='Full']) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;X3D profile='Immersive'/&gt; &lt;component name='DIS' level='2'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>

    <!-- ========= EspduTransform ========== -->
    <rule context="EspduTransform">
      <extends rule="DEFtests"/>
      <extends rule="DisComponentLevel1"/>
      <extends rule="NeedsChildNode"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@networkMode, '&quot;')" role="error">&NodeDEFname; networkMode='<value-of select='@networkMode'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <assert test="not(@networkMode) or (@networkMode='') or (@networkMode='standAlone') or (@networkMode='networkReader') or (@networkMode='networkWriter')" role="error">&NodeDEFname; networkMode='<value-of select='@networkMode'/>' is erroneous, must use a legal value ( standAlone | networkReader | networkWriter ) </assert>
      <!-- TODO more tests -->
    </rule>

    <!-- ========= ReceiverPdu ========== -->
    <rule context="ReceiverPdu">
      <extends rule="DEFtests"/>
      <extends rule="DisComponentLevel1"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@networkMode, '&quot;')" role="error">&NodeDEFname; networkMode='<value-of select='@networkMode'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <assert test="not(@networkMode) or (@networkMode='') or (@networkMode='standAlone') or (@networkMode='networkReader') or (@networkMode='networkWriter')" role="error">&NodeDEFname; networkMode='<value-of select='@networkMode'/>' is erroneous, must use a legal value ( standAlone | networkReader | networkWriter ) </assert>
      <!-- TODO more tests -->
    </rule>

    <!-- ========= SignalPdu ========== -->
    <rule context="SignalPdu">
      <extends rule="DEFtests"/>
      <extends rule="DisComponentLevel1"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@networkMode, '&quot;')" role="error">&NodeDEFname; networkMode='<value-of select='@networkMode'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <assert test="not(@networkMode) or (@networkMode='') or (@networkMode='standAlone') or (@networkMode='networkReader') or (@networkMode='networkWriter')" role="error">&NodeDEFname; networkMode='<value-of select='@networkMode'/>' is erroneous, must use a legal value ( standAlone | networkReader | networkWriter ) </assert>
      <!-- TODO more tests -->
    </rule>

    <!-- ========= TransmitterPdu ========== -->
    <rule context="TransmitterPdu">
      <extends rule="DEFtests"/>
      <extends rule="DisComponentLevel1"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@networkMode, '&quot;')" role="error">&NodeDEFname; networkMode='<value-of select='@networkMode'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <assert test="not(@networkMode) or (@networkMode='') or (@networkMode='standAlone') or (@networkMode='networkReader') or (@networkMode='networkWriter')" role="error">&NodeDEFname; networkMode='<value-of select='@networkMode'/>' is erroneous, must use a legal value ( standAlone | networkReader | networkWriter ) </assert>
      <!-- TODO more tests -->
    </rule>

    <!-- ========= DISEntityManager ========== -->
    <rule context="DISEntityManager">
      <extends rule="DEFtests"/>
      <extends rule="DisComponentLevel2"/>
      <!-- TODO more tests -->
    </rule>

    <!-- ========= DISEntityTypeMapping ========== -->
    <rule context="DISEntityTypeMapping">
      <extends rule="DEFtests"/>
      <extends rule="DisComponentLevel2"/>
      <!-- TODO more tests -->
      <report test="parent::DISEntityManager and not(@containerField='mapping')" role="error">&NodeDEFname; containerField='<value-of select='@containerField'/>'incorrect, must be containerField=&apos;mapping&apos;&gt; to match parent DISEntityManager' </report>
    </rule>

    <!-- ========= Geospatial nodes ========== -->

    <rule id="GeospatialComponentLevel1" abstract="true">
      <assert test="((/X3D[@profile='Immersive'] and (/X3D/head/component[@name='Geospatial'][number(@level) ge 1])) or (/X3D[@profile='Full']) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;X3D profile='Immersive'/&gt; &lt;component name='Geospatial' level='1'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>

    <rule id="GeospatialComponentLevel2" abstract="true">
      <assert test="((/X3D[@profile='Immersive'] and (/X3D/head/component[@name='Geospatial'][number(@level) ge 2])) or (/X3D[@profile='Full']) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;X3D profile='Immersive'/&gt; &lt;component name='Geospatial' level='2'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
    </rule>

    <rule id="NoGeospatialAncestor" abstract="true">
      <report test="ancestor::GeoLocation" role="error">&NodeDEFname; must not have any parent or ancestor GeoLocation nodes </report>
      <report test="ancestor::GeoLOD" role="error">&NodeDEFname; must not have any parent or ancestor GeoLOD nodes </report>
      <report test="ancestor::GeoTransform" role="error">&NodeDEFname; must not have any parent or ancestor GeoTransform nodes </report>
      <!-- other Geo nodes should be caught by XML schema/DTD validation rules -->
    </rule>

    <rule id="geoSystemTests" abstract="true">
      <let name="geoSystem1" value="translate(normalize-space(substring-before(substring-after(@geoSystem,'&quot;'),'&quot;')),' ','')"/>
      <let name="geoSystem2" value="translate(normalize-space(substring-after(@geoSystem,$geoSystem1)),'&quot; ','')"/>
      <!-- 25.2.3 Specifying a spatial reference frame -->
      <report test="contains(@geoSystem,'GDC')" role="warning">&NodeDEFname; has deprecated geoSystem='<value-of select='@geoSystem'/>' value GDC, use GD instead </report>
      <report test="contains(@geoSystem,'GCC')" role="warning">&NodeDEFname; has deprecated geoSystem='<value-of select='@geoSystem'/>' value GCC, use GC instead </report>
      <!-- <report test="true()" role="diagnostic">geoSystem1='<value-of select='$geoSystem1'/>' geoSystem2='<value-of select='$geoSystem2'/>'</report> -->
      <assert test="($geoSystem1='') or ($geoSystem1='GD') or ($geoSystem1='UTM') or ($geoSystem1='GC')" role="error">&NodeDEFname; geoSystem='<value-of select='@geoSystem'/>' has illegal value (allowed values are GD, UTM, GC) </assert>
      <!-- Table 25.3, Supported earth ellipsoids -->
      <report test="($geoSystem1='GD') and ($geoSystem2='')" role="warning">&NodeDEFname; geoSystem='<value-of select='@geoSystem'/>' missing second value, assuming &quot;GD&quot; &quot;WE&quot; </report>
      <report test="($geoSystem1='GD') and
          not(($geoSystem2='') or ($geoSystem2='WGS84') or ($geoSystem2='AA') or ($geoSystem2='AM') or ($geoSystem2='AN') or ($geoSystem2='BN') or ($geoSystem2='BR') or
              ($geoSystem2='CC') or ($geoSystem2='CD') or ($geoSystem2='EA') or ($geoSystem2='EB') or ($geoSystem2='EC') or ($geoSystem2='ED') or
              ($geoSystem2='EE') or ($geoSystem2='EF') or ($geoSystem2='FA') or ($geoSystem2='HE') or ($geoSystem2='HO') or ($geoSystem2='ID') or
              ($geoSystem2='IN') or ($geoSystem2='KA') or ($geoSystem2='RF') or ($geoSystem2='SA') or ($geoSystem2='WD') or ($geoSystem2='WE'))" role="error">&NodeDEFname; geoSystem='<value-of select='@geoSystem'/>' spatial reference frame &quot;<value-of select='$geoSystem1'/>&quot; has illegal parameter &quot;<value-of select='$geoSystem2'/>&quot; (see X3D Specification Table 25.3, Supported earth ellipsoids) </report>
      <report test="($geoSystem1='UTM') and not(starts-with($geoSystem2,'Z'))" role="warning">&NodeDEFname; geoSystem='<value-of select='@geoSystem'/>' has invalid second value, must be Z## (where ## is zone number) </report>
      <report test="($geoSystem1='GC') and not($geoSystem2='')" role="warning">&NodeDEFname; geoSystem='<value-of select='@geoSystem'/>' has invalid second value, assuming simply &quot;GC&quot; </report>
      <!-- Check child GeoOrigin nodes -->
      <report test="count(GeoOrigin) > 1" role="warning">&NodeDEFname; can only contain single GeoOrigin node, not <value-of select="count(GeoOrigin)"/> nodes </report>
      <report test="@geoSystem and (string-length(@geoSystem) > 0) and not(contains(@geoSystem,'&quot;'))" role="error">&NodeDEFname; geoSystem='<value-of select='@geoSystem'/>' should have quoted values, for example  geoSystem='&quot;GD&quot; &quot;WE&quot;' </report>
    </rule>

    <!-- ========= GeoCoordinate ========== -->
    <rule context="GeoCoordinate">
        <!-- TODO parent checks -->
      <extends rule="DEFtests"/>
      <extends rule="GeospatialComponentLevel1"/>
      <extends rule="geoSystemTests"/>
      <report test="ancestor::GeoLocation" role="error">&NodeDEFname; must not have any parent or ancestor GeoLocation nodes, use GeoTransform instead </report>
      <report test="ancestor::GeoLOD" role="error">&NodeDEFname; must not have any parent or ancestor GeoLOD nodes, use GeoTransform instead </report>
      <!-- can have IndexedLineSet without GeoTransform, thus ancestor GeoTransform node is optional -->
    </rule>

    <!-- ========= GeoElevationGrid ========== -->
    <rule context="GeoElevationGrid">
      <extends rule="geometryNode"/>
      <extends rule="creaseAngle"/>
      <extends rule="GeospatialComponentLevel1"/>
      <extends rule="NoGeospatialAncestor"/>
      <extends rule="geoSystemTests"/>
      <extends rule="ElevationGridAttributeChecks"/>
      <report test="starts-with(normalize-space(@yScale),'-')"    role="error">&NodeDEFname; erroneous negative value yScale='<value-of select='@yScale'/>', must be positive or zero </report>
      <report test="((@geoGridOrigin='0 0 0') or (@geoGridOrigin='0.0 0.0 0.0')) and not(@USE)" role="warning">&NodeDEFname; geoGridOrigin='<value-of select='@geoGridOrigin'/>', instead needs actual location value </report>
    </rule>

    <!-- ========= GeoLocation ========== -->
    <rule context="GeoLocation">
      <extends rule="DEFtests"/>
      <extends rule="GeospatialComponentLevel1"/>
      <extends rule="NoGeospatialAncestor"/>
      <extends rule="geoSystemTests"/>
      <report test="((@geoCoords='0 0 0') or (@geoCoords='0.0 0.0 0.0')) and not(@USE)" role="warning">&NodeDEFname; geoCoords='<value-of select='@geoCoords'/>', instead needs actual location value </report>
      <report test="//*[starts-with('Geo',local-name()) and not(local-name()='GeoOrigin')]" role="warning">&NodeDEFname; contains geospatial node other than GeoOrigin </report>
    </rule>

    <!-- ========= GeoLOD ========== -->
    <rule context="GeoLOD">
      <extends rule="DEFtests"/>
      <extends rule="GeospatialComponentLevel1"/>
      <extends rule="NoGeospatialAncestor"/>
      <extends rule="geoSystemTests"/>
      <extends rule="NeedsChildNode"/>
      <report test="((@center='0 0 0') or (@center='0.0 0.0 0.0')) and not(@USE)" role="warning">&NodeDEFname; center='<value-of select='@center'/>', instead needs actual location value </report>
      <report test="((string-length(@rootUrl)=0) and not(*)) and not(@USE)" role="warning">&NodeDEFname; has no rootUrl and no contained children, thus will not render </report>
      <report test="((string-length(@rootUrl) &gt; 0) and *) and not(@USE)" role="warning">&NodeDEFname; cannot include both rootUrl and contained children </report>
      <report test="(string-length(@child1Url)=0) and not(@USE)" role="warning">&NodeDEFname; has no child1Url </report>
      <report test="(string-length(@child2Url)=0) and not(@USE)" role="warning">&NodeDEFname; has no child2Url </report>
      <report test="(string-length(@child3Url)=0) and not(@USE)" role="warning">&NodeDEFname; has no child3Url </report>
      <report test="(string-length(@child4Url)=0) and not(@USE)" role="warning">&NodeDEFname; has no child4Url </report>
      <!-- TODO hasUrl rules for child1Url, child2Url, child3Url, child4Url -->
    </rule>

    <!-- ========= GeoMetadata ========== -->
    <rule context="GeoMetadata">
      <extends rule="DEFtests"/>
      <extends rule="GeospatialComponentLevel1"/>
      <!-- TODO metadata value rules -->
      <assert test="starts-with(local-name(..),'Geo') or starts-with(local-name(..),'field')" role="error">&NodeDEFname; parent <value-of select="local-name(..)"/> is not a geospatial node </assert>
      <assert test="*[(@containerField='metadata') or (@containerField='data')]" role="error">&NodeDEFname; contains node &lt;<value-of select="local-name(*[(@containerField!='metadata') and (@containerField!='data')][1])"/> DEF='<value-of select="*[(@containerField!='metadata') and (@containerField!='data')][1]/@DEF"/>'/&gt; with incorrect containerField (allowed values are 'metadata' and 'data') </assert>
    </rule>

    <!-- ========= GeoOrigin ========== -->
    <rule context="GeoOrigin">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.3Deprecated"/>
      <extends rule="GeospatialComponentLevel1"/>
      <extends rule="geoSystemTests"/>
      <extends rule="NotX3dChildNode"/>
      <report test="count(preceding::GeoOrigin) = 0" role="warning">&NodeDEFname; note that use of GeoOrigin node is deprecated by X3D v3.3 Specification (<value-of select='count(//GeoOrigin)'/> occurrences found) </report>
      <report test="count(preceding-sibling::*) > 0" role="warning">&NodeDEFname; note that use of GeoOrigin node (if used) must be first child of parent <value-of select="local-name(..)"/> to pass X3D schema validation </report>
      <report test="((@geoCoords='0 0 0') or (@geoCoords='0.0 0.0 0.0')) and not(@USE)" role="warning">&NodeDEFname; geoCoords='<value-of select='@geoCoords'/>', instead needs actual location value </report>
      <report test="(@rotateYUp='TRUE' )" role="error">&NodeDEFname; rotateYUp='TRUE' is incorrect, define rotateYUp='true' instead</report>
      <report test="(@rotateYUp='FALSE')" role="error">&NodeDEFname; rotateYUp='FALSE' is incorrect, define rotateYUp='false' instead</report>
    </rule>

    <!-- ========= GeoPositionInterpolator ========== -->
    <rule context="GeoPositionInterpolator">
      <extends rule="InterpolatorNode"/>
      <extends rule="GeospatialComponentLevel1"/>
      <!-- TODO needed? <extends rule="NoGeospatialAncestor"/> -->
      <extends rule="geoSystemTests"/>
      <assert test="(not($key) and not($keyValue)) or (3 * $keyCount)=$keyValueCount" role="error">&NodeDEFname; key array (size=<value-of select="$keyCount"/>) must match keyValue array (size=<value-of select="$keyValueCount div 3"/>) </assert>
    </rule>

    <!-- ========= GeoProximitySensor ========== -->
    <rule context="GeoProximitySensor">
      <extends rule="DEFtests"/>
      <extends rule="enabledTests"/>
      <extends rule="sizeTests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="GeospatialComponentLevel2"/>
      <extends rule="NoGeospatialAncestor"/>
      <extends rule="geoSystemTests"/>
      <extends rule="NeedsOutputROUTE"/>
      <report test="((@geoCenter='0 0 0') or (@geoCenter='0.0 0.0 0.0')) and not(@USE)" role="warning">&NodeDEFname; geoCenter='<value-of select='@geoCenter'/>', instead needs actual location value </report>
    </rule>

    <!-- ========= GeoTouchSensor ========== -->
    <rule context="GeoTouchSensor">
      <extends rule="DEFtests"/>
      <extends rule="enabledTests"/>
      <extends rule="GeospatialComponentLevel1"/>
      <!-- TODO needed? <extends rule="NoGeospatialAncestor"/> -->
      <extends rule="geoSystemTests"/>
      <extends rule="NeedsOutputROUTE"/>
      <extends rule="descriptionTests"/>
    </rule>

    <!-- ========= GeoTransform ========== -->
    <rule context="GeoTransform">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
      <extends rule="GeospatialComponentLevel2"/>
      <extends rule="NoGeospatialAncestor"/>
      <extends rule="geoSystemTests"/>
      <extends rule="NeedsChildNode"/>
      <report test="((@geoCenter='0 0 0') or (@geoCenter='0.0 0.0 0.0')) and not(@USE)" role="warning">&NodeDEFname; geoCenter='<value-of select='@geoCenter'/>', instead needs actual location value </report>
      <report test="//*[starts-with('Geo',local-name()) and not(local-name()='GeoCoordinate') and not(local-name()='GeoOrigin')]" role="warning">&NodeDEFname; contains geospatial node other than GeoCoordinate or GeoOrigin </report>
      <report test="contains(normalize-space(@rotation),'0 0 0 ') or contains(normalize-space(@rotation),'0.0 0.0 0.0 ')" role="error">&NodeDEFname; rotation='<value-of select='@rotation'/>' has illegal zero-magnitude axis values</report>
      <report test="contains(normalize-space(@scaleOrientation),'0 0 0 ') or contains(normalize-space(@scaleOrientation),'0.0 0.0 0.0 ')" role="error">&NodeDEFname; scaleOrientation='<value-of select='@scaleOrientation'/>' has illegal zero-magnitude axis values</report>
      <report test="descendant::*[(local-name()='GeoElevationGrid') or (local-name()='GeoLocation') or (local-name()='GeoLOD') or (local-name()='GeoPositionInterpolator') or (local-name()='GeoProximitySensor') or (local-name()='GeoTouchSensor') or (local-name()='GeoTransform') or (local-name()='GeoViewpoint')]" role="error">&NodeDEFname; must not contain other geospatial nodes other than GeoCoordinate </report>
    </rule>

    <!-- ========= GeoViewpoint ========== -->
    <rule context="GeoViewpoint">
      <let name="stringResidueApos" value="translate(@navType,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="stringResidue" value='translate($stringResidueApos,"&apos;","")'/>
      <let name="quoteCount" value="string-length($stringResidue)"/>
      <let name="normalizedString" value="normalize-space(@navType)"/>
      <let name="lastCharacter" value="substring($normalizedString,string-length($normalizedString))"/>
      <!-- TODO also handle internationalization I18N characters -->
      <let name="infoStringResidueApos" value="translate(@info,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="infoStringResidue" value='translate($infoStringResidueApos,"&apos;","")'/>
      <let name="infoQuoteCount" value="string-length($infoStringResidue)"/>
      <let name="infoNormalizedString" value="normalize-space(@info)"/>
      <let name="infoLastCharacter" value="substring($infoNormalizedString,string-length($infoNormalizedString))"/>
      <extends rule="DEFtests"/>
      <extends rule="GeospatialComponentLevel1"/>
      <extends rule="NoGeospatialAncestor"/>
      <extends rule="geoSystemTests"/>
      <report test="((@position='0 0 0') or (@position='0.0 0.0 0.0')) and not(@USE)" role="warning">&NodeDEFname; position='<value-of select='@geoCenter'/>', instead needs actual location value </report>
      <report test="contains(normalize-space(@orientation),'0 0 0 ') or contains(normalize-space(@orientation),'0.0 0.0 0.0 ')" role="error">&NodeDEFname; orientation='<value-of select='@orientation'/>' has illegal zero-magnitude axis values</report>
      <!-- navType MFString array checks -->
      <report test="false()" role="trace">$quoteCount=<value-of select='$quoteCount'/>, $stringResidue=<value-of select='$stringResidue'/>, $stringResidueApos=<value-of select='$stringResidueApos'/> , $lastCharacter=<value-of select='$lastCharacter'/> </report>
      <report test="not(@USE) and contains($normalizedString,'&quot;&quot;') and not(contains($normalizedString,'\&quot;&quot;') or contains($normalizedString,'&quot;\&quot;') or contains($normalizedString,'&quot;&quot; &quot;') or contains($normalizedString,'&quot; &quot;&quot;'))"  role="error">&NodeDEFname; array navType='<value-of select='@navType'/>' has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@navType) and not(contains(@navType,'&quot;'))"    role="error">&NodeDEFname; array navType='<value-of select='@navType'/>' needs to begin and end with &quot;quote&quot; &quot;marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' navType=&apos;&quot;<value-of select='(@navType)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@navType) and    (contains(@navType,'&quot;')) and (($quoteCount div 2)!=round($quoteCount div 2)) and not(contains(@navType,'\&quot;'))"    role="error">&NodeDEFname; array navType='<value-of select='@navType'/>' has <value-of select='($quoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@navType) and (contains(@navType,'\&quot;'))"    role="warning">&NodeDEFname; array navType='<value-of select='@navType'/>' has <value-of select='($quoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;') and (contains(@navType,'&quot;'))"    role="error">&NodeDEFname; array navType='<value-of select='@navType'/>' needs to begin and end with &quot;quote&quot; &quot;marks&quot; </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and    ($lastCharacter='&quot;')"                                     role="error">&NodeDEFname; array navType='<value-of select='@navType'/>' needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($normalizedString) and    (starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;')"                                     role="error">&NodeDEFname; array navType='<value-of select='@navType'/>' needs to end with quote mark &quot; </report>
      <!-- info MFString array checks -->
      <report test="false()" role="trace">$infoQuoteCount=<value-of select='$infoQuoteCount'/>, $infoStringResidue=<value-of select='$infoStringResidue'/>, $infoStringResidueApos=<value-of select='$infoStringResidueApos'/> , $infoLastCharacter=<value-of select='$infoLastCharacter'/> </report>
      <report test="not(@USE) and contains($infoNormalizedString,'&quot;&quot;') and not(contains($infoNormalizedString,'\&quot;&quot;') or contains($infoNormalizedString,'&quot;\&quot;') or contains($infoNormalizedString,'&quot;&quot; &quot;') or contains($infoNormalizedString,'&quot; &quot;&quot;'))"  role="error">&NodeDEFname; array info='<value-of select='@info'/>' has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@info) and not(contains(@info,'&quot;'))"    role="error">&NodeDEFname; array info='<value-of select='@info'/>' needs to begin and end with &quot;quote&quot; &quot;marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' info=&apos;&quot;<value-of select='(@info)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@info) and    (contains(@info,'&quot;')) and (($infoQuoteCount div 2)!=round($infoQuoteCount div 2)) and not(contains(@info,'\&quot;'))"    role="error">&NodeDEFname; array info='<value-of select='@info'/>' has <value-of select='($infoQuoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@info) and (contains(@info,'\&quot;'))"    role="warning">&NodeDEFname; array info='<value-of select='@info'/>' has <value-of select='($infoQuoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($infoNormalizedString) and not(starts-with($infoNormalizedString,'&quot;')) and not($infoLastCharacter='&quot;') and (contains(@info,'&quot;'))"    role="error">&NodeDEFname; array info='<value-of select='@info'/>' needs to begin and end with &quot;quote&quot; &quot;marks&quot; </report>
      <report test="not(@USE) and ($infoNormalizedString) and not(starts-with($infoNormalizedString,'&quot;')) and    ($infoLastCharacter='&quot;')"                                     role="error">&NodeDEFname; array info='<value-of select='@info'/>' needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($infoNormalizedString) and    (starts-with($infoNormalizedString,'&quot;')) and not($infoLastCharacter='&quot;')"                                     role="error">&NodeDEFname; array info='<value-of select='@info'/>' needs to end with quote mark &quot; </report>
      <!-- additional checks -->
      <report test="not(@USE) and (@info) and not(contains(@info,'EXAMINE')) and not(contains(@info,'ANY')) and not(contains(@info,'WALK')) and not(contains(@type,'FLY')) and not(contains(@info,'LOOKAT')) and not(contains(@info,'NONE'))"    role="warning">&NodeDEFname; array info='<value-of select='@info'/>' does not contain any of the guaranteed-support values (&quot;EXAMINE&quot; &quot;ANY&quot; or &quot;WALK&quot; &quot;FLY&quot; &quot;LOOKAT&quot; &quot;NONE&quot;) </report>
      <report test="(@jump='TRUE' )" role="error">&NodeDEFname; jump='TRUE' is incorrect, define jump='true' instead</report>
      <report test="(@jump='FALSE')" role="error">&NodeDEFname; jump='FALSE' is incorrect, define jump='false' instead</report>
      <report test="(@retainUserOffsets='TRUE' )" role="error">&NodeDEFname; retainUserOffsets='TRUE' is incorrect, define retainUserOffsets='true' instead</report>
      <report test="(@retainUserOffsets='FALSE')" role="error">&NodeDEFname; retainUserOffsets='FALSE' is incorrect, define retainUserOffsets='false' instead</report>
    </rule>

    <!-- ========= H-Anim nodes ========== -->

    <!-- ========= abstract: hanimProfile ========== -->
    <rule id="hanimProfile" abstract="true">
      <!-- when used by a node rule, this rule must be preceded by hanimDEFtests rule -->
      <!-- Debug statement: set test="true()" to enable, test="false()" to disable -->
      <report test="false()" role="diagnostic">HAnim checks for <name/> </report>
      <!-- TODO why are duplicates still reported?? -->
      <assert test="((/X3D[@profile='Immersive'] and (/X3D/head/component[@name='H-Anim'][number(@level) ge 1])) or (/X3D[@profile='Full']) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;X3D profile='Immersive'/&gt; &lt;component name='HAnim' level='1'/&gt; or &lt;X3D profile='Full'/&gt; </assert>
      <!--  (diagnostic: $NodeName=<value-of select='$NodeName'/>, count=<value-of select='count(preceding::*[local-name()=$NodeName])'/>) -->
    </rule>

    <!-- ========= abstract: hanimDEFtests ========== -->
    <rule id="hanimDEFtests" abstract="true">
      <extends rule="DEFtests"/>
      <extends rule="requiredName"/>
      <!-- http://www.web3d.org/documents/specifications/19774/V1.0/HAnim/VRMLInterface.html#Humanoid -->
      <report test="(string-length(@DEF) > 0) and (string-length(@name) > 0) and not(contains(@DEF,concat('_',@name)))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; DEF value does not contain correctly modified version of name value (for example, DEF='myPrefix_nameValue' e.g. DEF='myPrefix_<value-of select='@name'/>') - see H-Anim section C.2 Humanoid, VRML Binding </report>
      <report test="(string-length(@USE) > 0) and not((local-name(..)='HAnimHumanoid') or (local-name(..)='field') or (local-name(..)='fieldValue'))" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; can only appear as immediate child of HAnimHumanoid </report>
      <report test="(string-length(@USE) > 0) and (ancestor::HAnimHumanoid/@name != ancestor::Scene//HAnimHumanoid[//*[@DEF=$USE]]/@name)" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; was not defined as part of local &lt;HAnimHumanoid DEF='<value-of select='ancestor::HAnimHumanoid/@DEF'/>' name='<value-of select='ancestor::HAnimHumanoid/@name'/>'/&gt; and instead is illegally referring to another HAnimHumanoid node </report>
    </rule>
    
    <rule context="HAnimHumanoid">
      <let name="stringResidueApos" value="translate(@value,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="stringResidue" value='translate($stringResidueApos,"&apos;","")'/>
      <let name="quoteCount" value="string-length($stringResidue)"/>
      <let name="normalizedString" value="normalize-space(@value)"/>
      <let name="lastCharacter" value="substring($normalizedString,string-length($normalizedString))"/>
      <let name="childrenNodes" value="*[@containerField = 'children']"/>
      <extends rule="hanimDEFtests"/>
      <extends rule="hanimProfile"/>
      <extends rule="boundingBoxTests"/>
      <extends rule="uniqueName"/>
      <extends rule="NeedsChildNode"/>
      <!--<report test="true()" role="diagnostic">$childrenNodes=<value-of select='$childrenNodes'/> </report>-->
      <report test="HAnimJoint[(string-length(@DEF) > 0) and (@containerField != 'skeleton')]" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; contains &lt;HAnimJoint DEF=&quot;<value-of select="HAnimJoint[(string-length(@DEF) > 0)]/@DEF"/>&quot; name=&quot;<value-of select="HAnimJoint[(string-length(@DEF) > 0)]/@name"/>&quot; containerField=&quot;<value-of select="HAnimJoint[(string-length(@DEF) > 0)]/@containerField"/>&quot;/&gt; should be containerField='skeleton' </report>
      <report test="descendant::*[local-name()='HAnimHumanoid']" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot contain another &lt;HAnimHumanoid DEF=&quot;<value-of select="descendant::*[local-name()='HAnimHumanoid']/@DEF"/>&quot; name=&quot;<value-of select="descendant::*[local-name()='HAnimHumanoid']/@name"/>&quot;/&gt; </report>
      <!-- HAnimHumanoid has no children nodes (thanks for checking, H3DViewer) -->
      <report test="$childrenNodes" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot contain any containerField='children' nodes:  &lt;<value-of select="local-name($childrenNodes[1])"/> DEF=&quot;<value-of select="$childrenNodes[1]/@DEF"/>&quot; name=&quot;<value-of select="$childrenNodes[1]/@name"/>&quot; containerField=&quot;<value-of select="$childrenNodes[1]/@containerField"/>&quot;/&gt; </report>
      <!-- TODO check info fields for correct metadata names -->
      <!-- TODO suggest peer Viewpoint centerOfRotation="0 0.9149 0.0016" matches sacroliac -->
      <!-- right side is -x, left side is +x -->
      <report test="not(@version = '2.0') and not(string-length(@USE) > 0)" role="warning">&NodeDEFname; version='<value-of select='@version'/>' might not validate correctly, X3D validation support is tuned for ISO 19774 HAnimHumanoid version='2.0' </report>
      <!-- http://www.web3d.org/documents/specifications/19774/V1.0/HAnim/Guidelines.html#MultipleHumanoidsPerFile -->
      <report test="(count(preceding-sibling::HAnimHumanoid) = 0) and (count(following-sibling::HAnimHumanoid) > 0)" role="warning">&NodeDEFname; H-Anim specification section E.4 recommends a common parent &lt;Group DEF='HumanoidGroup'/&gt; when multiple HAnimHumanoid models are present in a single scene </report>
      <!-- TODO test if only one HAnimHumanoid is present, then prefix is hanim_ (see c.3) -->
      <!-- info field MFString array checks, TODO add checks for specific values -->
      <report test="false()" role="trace">$quoteCount=<value-of select='$quoteCount'/>, $stringResidue=<value-of select='$stringResidue'/>, $stringResidueApos=<value-of select='$stringResidueApos'/> , $lastCharacter=<value-of select='$lastCharacter'/> </report>
      <report test="not(@USE) and contains($normalizedString,'&quot;&quot;') and not(contains($normalizedString,'\&quot;&quot;') or contains($normalizedString,'&quot;\&quot;') or contains($normalizedString,'&quot;&quot; &quot;') or contains($normalizedString,'&quot; &quot;&quot;'))" role="error">&NamedNodeDEFname; array value='<value-of select='@info'/>' has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@info) and not(contains(@info,'&quot;'))"   role="error">&NamedNodeDEFname; array value='<value-of select='@info'/>' needs to begin and end with &quot;quote marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' value=&apos;&quot;<value-of select='(@info)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@info) and    (contains(@info,'&quot;')) and (($quoteCount div 2)!=round($quoteCount div 2)) and not(contains(@info,'\&quot;'))"   role="error">&NamedNodeDEFname; array value='<value-of select='@info'/>' has <value-of select='($quoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@info) and (contains(@info,'\&quot;'))"    role="warning">&NamedNodeDEFname; array value='<value-of select='@info'/>' has <value-of select='($quoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;') and (contains(@info,'&quot;'))" role="error">&NamedNodeDEFname; array value='<value-of select='@info'/>' needs to begin and end with &quot;quote marks&quot; </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and    ($lastCharacter='&quot;')"                                 role="error">&NamedNodeDEFname; array value='<value-of select='@info'/>' needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($normalizedString) and    (starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;')"                                 role="error">&NamedNodeDEFname; array value='<value-of select='@info'/>' needs to end with quote mark &quot; </report>
    </rule>

    <rule context="HAnimDisplacer">
      <extends rule="hanimDEFtests"/>
      <extends rule="hanimProfile"/>
      <!-- TODO table rules for allowed names for each node -->
      <!-- TODO LOA rules -->
      <!-- TODO check for positiveX/negativeX for left/right based on presence of l_ and r_ in name -->
      <!-- TODO check for duplicates -->
      <!-- HAnimDisplacer can be contained by HAnimJoint or HAnimSegment -->
      <report test="((parent::HAnimJoint) or (parent::HAnimSegment))   and not(@containerField='displacers')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>' USE='<value-of select='@USE'/>'/&gt; with parent <value-of select="local-name(..)"/> needs containerField='displacers' </report>
      <!-- only test immediate children to help localize extraneous HAnimHumanoid and avoid numerous false positives; might miss deeper descendants-->
      <report test="HAnimHumanoid" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot contain another &lt;HAnimHumanoid DEF=&quot;<value-of select="HAnimHumanoid/@DEF"/>&quot; name=&quot;<value-of select="HAnimHumanoid/@name"/>&quot;/&gt; </report>
      <!-- more parent/child checks -->
      <report test="not((local-name(..)='HAnimJoint') or (local-name(..)='HAnimSegment') or (local-name(..)='ProtoBody') or (local-name(..)='field') or (local-name(..)='fieldValue'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/> containerField='<value-of select='@containerField'/>'/&gt; has unexpected parent node <value-of select='local-name(..)'/>, expected parent HAnimJoint or HAnimSegment </report>
      <report test="   ((local-name(..)='HAnimJoint') or (local-name(..)='HAnimSegment')) and not(@containerField='displacers')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/> containerField='<value-of select='@containerField'/>'/&gt; has unexpected value, expected containerField='displacers' </report>
    </rule>

    <rule context="HAnimJoint">
      <let name="childrenNodes" value="*[(@containerField = 'children') and not((local-name()='HAnimJoint') or (local-name()='HAnimSegment') or (local-name()='HAnimSite'))]"/>
      <let name="r_name" value="concat('r_',substring-after(normalize-space(@name),'_'))"/>
      <let name="r_name_center" value="normalize-space(ancestor::HAnimHumanoid//HAnimJoint[@name=$r_name]/@center)"/>
      <extends rule="hanimDEFtests"/>
      <extends rule="hanimProfile"/>
      <extends rule="boundingBoxTests"/>
      <!-- TODO table rules for allowed names for each node -->
      <!-- TODO LOA rules -->
      <!-- TODO check for positiveX/negativeX for left/right based on presence of l_ and r_ in name -->
      <!-- TODO check for duplicates -->
      <!-- TODO avoid reporting mismatch if opposite side not present -->
      <!-- cannot contain nodes with containerField='children' -->
      <report test="$childrenNodes" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot contain any containerField='children' nodes:  &lt;<value-of select="local-name($childrenNodes[1])"/> DEF=&quot;<value-of select="$childrenNodes[1]/@DEF"/>&quot; name=&quot;<value-of select="$childrenNodes[1]/@name"/>&quot; containerField=&quot;<value-of select="$childrenNodes[1]/@containerField"/>&quot;/&gt; </report>
      <!-- symmetry warning, left-side coordinates start with a positive-x value and right-side coordinates start with a negative-x value -->
      <report test="starts-with(normalize-space(@name),'l_') and (string-length(normalize-space(@center)) > 0) and (concat('-',normalize-space(@center)) != $r_name_center)" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>' center='<value-of select='@center'/>'/&gt; has asymmetric center value that does not match corresponding &lt;<name/> DEF='<value-of select='ancestor::HAnimHumanoid//HAnimJoint[@name=$r_name]/@DEF'/>' name='<value-of select='$r_name'/>' center='<value-of select='$r_name_center'/>'/&gt; </report>
      <!-- if any top-level USE fields are included in ancestor HAnimHumanoid, report if missing a corresponding USE copy of this DEF node -->
      <report test="not(@USE) and not(string-length(@USE) > 0) and (ancestor::HAnimHumanoid/HAnimJoint[(string-length(@USE) > 0)]) and not(ancestor::HAnimHumanoid/HAnimJoint[(string-length(@USE) > 0)][@USE=$DEF])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has ancestor HAnimHumanoid that does not include a corresponding &lt;<name/> USE='<value-of select='@DEF'/>' containerField='joints'/&gt; to match this node </report>
      <report test="(string-length(@USE) > 0) and (preceding-sibling::HAnimSegment[(@USE = $USE) and (@name = $name)])" role="error">&lt;<name/> USE='<value-of select='@USE'/>' name='<value-of select='@name'/>' containerField='<value-of select='@containerField'/>'/&gt; matches a duplicate preceding USE node </report>
      <!-- HAnimJoint needs to contain a child HAnimSegment to complete the connection made by this joint -->
      <report test="not(@USE) and not(HAnimSegment)" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; is missing child HAnimSegment to complete the connection made by this joint </report>
      <!-- HAnimJoint can be contained by HAnimHumanoid or another HAnimJoint -->
      <report test="not(ancestor::HAnimJoint) and not(ancestor::HAnimHumanoid)" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; is missing an ancestor HAnimHumanoid or HAnimJoint </report>
      <report test="(parent::HAnimHumanoid) and (not(@USE) or not(string-length(@USE) > 0)) and not(@containerField='skeleton')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; with parent HAnimHumanoid needs containerField='skeleton' </report>
      <report test="(parent::HAnimHumanoid) and (@USE)                                      and not(@containerField='joints')"  role="error">&lt;<name/> USE='<value-of select='@USE'/>'/>'/&gt; with parent HAnimHumanoid needs containerField='joints' </report>
      <report test="(parent::HAnimJoint)    and not(@containerField='children')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>' USE='<value-of select='@USE'/>'/&gt; with parent HAnimJoint needs containerField='children' </report>
      <!-- HAnimJoint can only contain HAnimJoint, HAnimSegment, HAnimSite, HAnimDisplacer -->
      <report test="*[not((local-name()='HAnimJoint') or (local-name()='HAnimSegment') or (local-name()='HAnimSite') or (local-name()='HAnimDisplacer') or (local-name()='ProtoInstance'))]" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; HAnimJoint can only contain HAnimJoint, HAnimSegment, HAnimSite, HAnimDisplacer </report>
      <!-- HAnimJoint uses center field, not translation (except for HAnimJoint with name='HumanoidRoot') -->
      <report test="not(@USE) and not(string-length(@USE) > 0) and (not(@center) or (@center='0 0 0') or (@center='0.0 0.0 0.0'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has a missing (or default value 0 0 0) center='<value-of select="@center"/>' field, leaving HAnimJoint location on ground plane </report>
      <report test="not(@USE) and not(string-length(@USE) > 0) and ((string-length(@translation) > 0) and not(@translation='0 0 0') and not(@translation='0.0 0.0 0.0')) and not(@name='HumanoidRoot')" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; includes an unexpected value for translation field (ordinarily translation is empty or has default value 0 0 0) </report>
      <report test="//ROUTE[(@toNode=$DEF)][(@toField='translation') or (@toField='set_translation')] and not(@name='HumanoidRoot')" role="warning">&NodeDEFname; has incoming &lt;ROUTE toNode='<value-of select="@DEF"/>' toField='translation'/&gt; to modify the translation field, which ordinarily is not modified (instead the center field controls HAnimJoint position) </report>
      <report test="@translation and (string-length(@translation) > 0) and not((@translation='0 0 0') or (@translation='0.0 0.0 0.0')) and not(@name='HumanoidRoot')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has non-zero translation='<value-of select="@translation"/>', ordinarily HAnimJoint location is defined by the field center='<value-of select="@center"/>' </report>
      <!-- Joint center cannot have -y value since that is underground.  Once scene is corrected, the corresponding HAnimSegment/Transform/@translation mismatch rule will detect if that field still has negative-y value -->
      <report test="@center and (string-length(@center) > 0) and starts-with(substring-after(@center,' '),'-')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has negative-y vertical value in center='<value-of select="@center"/>', which is illegal since HAnimJoint cannot be underground </report>
      <!-- only test immediate children to help localize extraneous HAnimHumanoid and avoid numerous false positives; might miss deeper descendants-->
      <report test="HAnimHumanoid" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot contain another &lt;HAnimHumanoid DEF=&quot;<value-of select="HAnimHumanoid/@DEF"/>&quot; name=&quot;<value-of select="HAnimHumanoid/@name"/>&quot;/&gt; </report>
      <!-- HAnimJoint/HAnimSegment hierarchy naming tests -->
      <report test="(@name='HumanoidRoot') and (HAnimSegment[not(@name='sacrum')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='sacrum' </report>
      <report test="(@name='sacroiliac') and (HAnimSegment[not(@name='pelvis')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='pelvis' </report>
      <report test="(@name='l_hip') and (HAnimSegment[not(@name='l_thigh')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_thigh' </report>
      <report test="(@name='l_knee') and (HAnimSegment[not(@name='l_calf')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_calf' </report>
      <report test="(@name='l_ankle') and (HAnimSegment[not(@name='l_hindfoot')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_hindfoot' </report>
      <report test="(@name='l_subtalar') and (HAnimSegment[not(@name='l_midproximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_midproximal' </report>
      <report test="(@name='l_midtarsal') and (HAnimSegment[not(@name='l_middistal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_middistal' </report>
      <report test="(@name='l_metatarsal') and (HAnimSegment[not(@name='l_forefoot')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_forefoot' </report>
      <report test="(@name='r_hip') and (HAnimSegment[not(@name='r_thigh')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_thigh' </report>
      <report test="(@name='r_knee') and (HAnimSegment[not(@name='r_calf')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_calf' </report>
      <report test="(@name='r_ankle') and (HAnimSegment[not(@name='r_hindfoot')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_hindfoot' </report>
      <report test="(@name='r_subtalar') and (HAnimSegment[not(@name='r_midproximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_midproximal' </report>
      <report test="(@name='r_midtarsal') and (HAnimSegment[not(@name='r_middistal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_middistal' </report>
      <report test="(@name='r_metatarsal') and (HAnimSegment[not(@name='r_forefoot')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_forefoot' </report>
      <report test="(@name='vl5') and (HAnimSegment[not(@name='l5')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l5' </report>
      <report test="(@name='vl4') and (HAnimSegment[not(@name='l4')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l4' </report>
      <report test="(@name='vl3') and (HAnimSegment[not(@name='l3')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l3' </report>
      <report test="(@name='vl2') and (HAnimSegment[not(@name='l2')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l2' </report>
      <report test="(@name='vl1') and (HAnimSegment[not(@name='l1')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l1' </report>
      <report test="(@name='vt12') and (HAnimSegment[not(@name='t12')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t12' </report>
      <report test="(@name='vt11') and (HAnimSegment[not(@name='t11')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t11' </report>
      <report test="(@name='vt10') and (HAnimSegment[not(@name='t10')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t10' </report>
      <report test="(@name='vt9') and (HAnimSegment[not(@name='t9')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t9' </report>
      <report test="(@name='vt8') and (HAnimSegment[not(@name='t8')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t8' </report>
      <report test="(@name='vt7') and (HAnimSegment[not(@name='t7')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t7' </report>
      <report test="(@name='vt6') and (HAnimSegment[not(@name='t6')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t6' </report>
      <report test="(@name='vt5') and (HAnimSegment[not(@name='t5')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t5' </report>
      <report test="(@name='vt4') and (HAnimSegment[not(@name='t4')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t4' </report>
      <report test="(@name='vt3') and (HAnimSegment[not(@name='t3')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t3' </report>
      <report test="(@name='vt2') and (HAnimSegment[not(@name='t2')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t2' </report>
      <report test="(@name='vt1') and (HAnimSegment[not(@name='t1')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='t1' </report>
      <report test="(@name='vc7') and (HAnimSegment[not(@name='c7')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='c7' </report>
      <report test="(@name='vc6') and (HAnimSegment[not(@name='c6')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='c6' </report>
      <report test="(@name='vc5') and (HAnimSegment[not(@name='c5')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='c5' </report>
      <report test="(@name='vc4') and (HAnimSegment[not(@name='c4')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='c4' </report>
      <report test="(@name='vc3') and (HAnimSegment[not(@name='c3')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='c3' </report>
      <report test="(@name='vc2') and (HAnimSegment[not(@name='c2')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='c2' </report>
      <report test="(@name='vc1') and (HAnimSegment[not(@name='c1')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='c1' </report>
      <report test="(@name='skullbase') and (HAnimSegment[not(@name='skull')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='skull' </report>
      <report test="(@name='l_eyelid_joint') and (HAnimSegment[not(@name='l_eyelid')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_eyelid' </report>
      <report test="(@name='r_eyelid_joint') and (HAnimSegment[not(@name='r_eyelid')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_eyelid' </report>
      <report test="(@name='l_eyeball_joint') and (HAnimSegment[not(@name='l_eyeball')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_eyeball' </report>
      <report test="(@name='r_eyeball_joint') and (HAnimSegment[not(@name='r_eyeball')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_eyeball' </report>
      <report test="(@name='l_eyebrow_joint') and (HAnimSegment[not(@name='l_eyebrow')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_eyebrow' </report>
      <report test="(@name='r_eyebrow_joint') and (HAnimSegment[not(@name='r_eyebrow')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_eyebrow' </report>
      <report test="(@name='temporomandibular') and (HAnimSegment[not(@name='jaw')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='jaw' </report>
      <report test="(@name='l_sternoclavicular') and (HAnimSegment[not(@name='l_clavicle')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_clavicle' </report>
      <report test="(@name='l_acromioclavicular') and (HAnimSegment[not(@name='l_scapula')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_scapula' </report>
      <report test="(@name='l_shoulder') and (HAnimSegment[not(@name='l_upperarm')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_upperarm' </report>
      <report test="(@name='l_elbow') and (HAnimSegment[not(@name='l_forearm')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_forearm' </report>
      <report test="(@name='l_wrist') and (HAnimSegment[not(@name='l_hand')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_hand' </report>
      <report test="(@name='l_thumb1') and (HAnimSegment[not(@name='l_thumb_metacarpal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_thumb_metacarpal' </report>
      <report test="(@name='l_thumb2') and (HAnimSegment[not(@name='l_thumb_proximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_thumb_proximal' </report>
      <report test="(@name='l_thumb3') and (HAnimSegment[not(@name='l_thumb_distal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_thumb_distal' </report>
      <report test="(@name='l_index0') and (HAnimSegment[not(@name='l_index_metacarpal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_index_metacarpal' </report>
      <report test="(@name='l_index1') and (HAnimSegment[not(@name='l_index_proximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_index_proximal' </report>
      <report test="(@name='l_index2') and (HAnimSegment[not(@name='l_index_middle')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_index_middle' </report>
      <report test="(@name='l_index3') and (HAnimSegment[not(@name='l_index_distal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_index_distal' </report>
      <report test="(@name='l_middle0') and (HAnimSegment[not(@name='l_middle_metacarpal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_middle_metacarpal' </report>
      <report test="(@name='l_middle1') and (HAnimSegment[not(@name='l_middle_proximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_middle_proximal' </report>
      <report test="(@name='l_middle2') and (HAnimSegment[not(@name='l_middle_middle')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_middle_middle' </report>
      <report test="(@name='l_middle3') and (HAnimSegment[not(@name='l_middle_distal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_middle_distal' </report>
      <report test="(@name='l_ring0') and (HAnimSegment[not(@name='l_ring_metacarpal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_ring_metacarpal' </report>
      <report test="(@name='l_ring1') and (HAnimSegment[not(@name='l_ring_proximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_ring_proximal' </report>
      <report test="(@name='l_ring2') and (HAnimSegment[not(@name='l_ring_middle')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_ring_middle' </report>
      <report test="(@name='l_ring3') and (HAnimSegment[not(@name='l_ring_distal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_ring_distal' </report>
      <report test="(@name='l_pinky0') and (HAnimSegment[not(@name='l_pinky_metacarpal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_pinky_metacarpal' </report>
      <report test="(@name='l_pinky1') and (HAnimSegment[not(@name='l_pinky_proximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_pinky_proximal' </report>
      <report test="(@name='l_pinky2') and (HAnimSegment[not(@name='l_pinky_middle')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_pinky_middle' </report>
      <report test="(@name='l_pinky3') and (HAnimSegment[not(@name='l_pinky_distal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='l_pinky_distal' </report>
      <report test="(@name='r_sternoclavicular') and (HAnimSegment[not(@name='r_clavicle')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_clavicle' </report>
      <report test="(@name='r_acromioclavicular') and (HAnimSegment[not(@name='r_scapula')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_scapula' </report>
      <report test="(@name='r_shoulder') and (HAnimSegment[not(@name='r_upperarm')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_upperarm' </report>
      <report test="(@name='r_elbow') and (HAnimSegment[not(@name='r_forearm')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_forearm' </report>
      <report test="(@name='r_wrist') and (HAnimSegment[not(@name='r_hand')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_hand' </report>
      <report test="(@name='r_thumb1') and (HAnimSegment[not(@name='r_thumb_metacarpal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_thumb_metacarpal' </report>
      <report test="(@name='r_thumb2') and (HAnimSegment[not(@name='r_thumb_proximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_thumb_proximal' </report>
      <report test="(@name='r_thumb3') and (HAnimSegment[not(@name='r_thumb_distal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_thumb_distal' </report>
      <report test="(@name='r_index0') and (HAnimSegment[not(@name='r_index_metacarpal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_index_metacarpal' </report>
      <report test="(@name='r_index1') and (HAnimSegment[not(@name='r_index_proximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_index_proximal' </report>
      <report test="(@name='r_index2') and (HAnimSegment[not(@name='r_index_middle')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_index_middle' </report>
      <report test="(@name='r_index3') and (HAnimSegment[not(@name='r_index_distal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_index_distal' </report>
      <report test="(@name='r_middle0') and (HAnimSegment[not(@name='r_middle_metacarpal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_middle_metacarpal' </report>
      <report test="(@name='r_middle1') and (HAnimSegment[not(@name='r_middle_proximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_middle_proximal' </report>
      <report test="(@name='r_middle2') and (HAnimSegment[not(@name='r_middle_middle')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_middle_middle' </report>
      <report test="(@name='r_middle3') and (HAnimSegment[not(@name='r_middle_distal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_middle_distal' </report>
      <report test="(@name='r_ring0') and (HAnimSegment[not(@name='r_ring_metacarpal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_ring_metacarpal' </report>
      <report test="(@name='r_ring1') and (HAnimSegment[not(@name='r_ring_proximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_ring_proximal' </report>
      <report test="(@name='r_ring2') and (HAnimSegment[not(@name='r_ring_middle')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_ring_middle' </report>
      <report test="(@name='r_ring3') and (HAnimSegment[not(@name='r_ring_distal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_ring_distal' </report>
      <report test="(@name='r_pinky0') and (HAnimSegment[not(@name='r_pinky_metacarpal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_pinky_metacarpal' </report>
      <report test="(@name='r_pinky1') and (HAnimSegment[not(@name='r_pinky_proximal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_pinky_proximal' </report>
      <report test="(@name='r_pinky2') and (HAnimSegment[not(@name='r_pinky_middle')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_pinky_middle' </report>
      <report test="(@name='r_pinky3') and (HAnimSegment[not(@name='r_pinky_distal')])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has child &lt;HAnimSegment name='<value-of select="HAnimSegment/@name"/>'/&gt; that instead should have name='r_pinky_distal' </report>
      <!-- Ensure left l_ site x translations are positive,  right r_ site x translations are negative -->
      <report test="contains(@name,'_l_') and     starts-with(normalize-space(@center),'-')"  role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; translation needs positive x when on left side </report>
      <report test="contains(@name,'_r_') and not(starts-with(normalize-space(@center),'-'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; translation needs negative x when on left side </report>
      <report test="contains(@name,'_HumanoidRoot') and not(starts-with(normalize-space(@center),'0'))" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; ought to be centered on x axis </report>
      <!-- TODO deserves closer look -->
      <report test="(@name='l_temporomandibular') or (@name='r_temporomandibular')" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; instead should have name='temporomandibular' since single jaw bone is controlled by left and right joints</report>
    </rule>

    <rule context="HAnimSegment">
      <extends rule="hanimDEFtests"/>
      <extends rule="hanimProfile"/>
      <extends rule="boundingBoxTests"/>
      <!-- TODO table rules for allowed names for each node -->
      <!-- TODO LOA rules -->
      <!-- TODO check for positiveX/negativeX for left/right based on presence of l_ and r_ in name -->
      <!-- TODO check for duplicates -->
      <!-- HAnimSegment only provides naming, mass, moment -->
      <!-- if any top-level USE fields are included in ancestor HAnimHumanoid, report if missing a corresponding USE copy of this DEF node -->
      <report test="not(@USE) and not(string-length(@USE) > 0) and (ancestor::HAnimHumanoid/HAnimSegment[(string-length(@USE) > 0)]) and not(ancestor::HAnimHumanoid/HAnimSegment[(string-length(@USE) > 0)][@USE=$DEF])" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has ancestor HAnimHumanoid that does not include a corresponding &lt;<name/> USE='<value-of select='@DEF'/>' containerField='segments'/&gt; to match this node </report>
      <report test="(string-length(@USE) > 0) and (preceding-sibling::HAnimSegment[(@USE = $USE) and (@name = $name)])" role="error">&lt;<name/> USE='<value-of select='@USE'/>' name='<value-of select='@name'/>' containerField='<value-of select='@containerField'/>'/&gt; matches a duplicate preceding USE node </report>
      <!-- HAnimSegment nodes are contained by HAnimJoint or HAnimHumanoid -->
      <report test="not(local-name(..)='HAnimJoint') and not(parent::HAnimHumanoid)"  role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; must be child of HAnimJoint, not <value-of select='local-name(..)'/> </report>
      <report test="(parent::HAnimHumanoid) and (not(@USE) or not(string-length(@USE) > 0))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; with parent HAnimHumanoid needs to be a USE reference to original DEF node under skeleton tree </report>
      <report test="(parent::HAnimHumanoid) and not(@containerField='segments')" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; with parent HAnimHumanoid needs containerField='segments' </report>
      <report test="(parent::HAnimJoint)    and not(@containerField='children')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>' USE='<value-of select='@USE'/>'/&gt; with parent HAnimJoint needs containerField='children' </report>
      <!-- check that child Transform translation for geometry matches parent HAnimJoint-->
      <report test="(parent::HAnimJoint)    and (Transform/Shape) and not(Transform/@translation = ../@center)" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/>'/&gt; has contained Transform/Shape, but child Transform/translation='<value-of select="Transform/@translation"/>' does not match parent HAnimJoint/center='<value-of select="../@center"/>' and may not be in the right location (possibly parent HAnimJoint/center value was changed but contained visualization geometry did not)</report>
      <report test="(parent::HAnimJoint)    and (Shape) and not(Transform/Shape)" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>' USE='<value-of select='@USE'/>'/&gt; has contained Shape geometry, but needs an intermediate Transform with translation value matching parent HAnimJoint/translation='<value-of select="../@center"/>' in order to be in the right location </report>
      <!-- HAnimSegment can only contain HAnimDisplacer or HAnimSite and no other HAnim nodes -->
      <report test="*[(local-name()='HAnimJoint')]"   role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; HAnimSegment cannot contain an HAnimJoint node </report>
      <report test="*[(local-name()='HAnimSegment')]" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; HAnimSegment cannot contain another HAnimSegment node </report>
      <!-- only test immediate children to help localize extraneous HAnimHumanoid and avoid numerous false positives; might miss deeper descendants-->
      <report test="HAnimHumanoid" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot contain another &lt;HAnimHumanoid DEF=&quot;<value-of select="HAnimHumanoid/@DEF"/>&quot; name=&quot;<value-of select="HAnimHumanoid/@name"/>&quot;/&gt; </report>
      <report test="Coordinate      [not(@containerField='coord')]" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; contains &lt;Coordinate containerField='<value-of select="Coordinate[not(@containerField='coord')]/@containerField"/>'/&gt; that instead must have containerField='coord' </report>
      <report test="CoordinateDouble[not(@containerField='coord')]" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; contains &lt;CoordinateDouble containerField='<value-of select="CoordinateDouble[not(@containerField='coord')]/@containerField"/>'/&gt; that instead must have containerField='coord' </report>
      <report test="count(Coordinate|CoordinateDouble) > 1" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; can only contain one Coordinate/CoordinateDouble node (instead of <value-of select="count(Coordinate|CoordinateDouble)"/>)</report>
      <!-- 4.8.2 Modelling of humanoids: HAnimSegment should not be contained by Transform, rather 'built in place' for best performance -->
      <report test="parent::*[local-name()='Transform']" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has parent &lt;Transform DEF='<value-of select="parent::*/@DEF"/>'/&gt; that can be avoided by building body segments in place </report>
      <!-- TODO check that Site and Displacer nodes have further naming rules. Consider use of <extends rule="NeedsChildNode"/> -->
    </rule>

    <rule context="HAnimSite">
      <extends rule="hanimDEFtests"/>
      <extends rule="hanimProfile"/>
      <extends rule="boundingBoxTests"/>
      <!-- TODO table rules for allowed names for each node -->
      <!-- TODO LOA rules -->
      <!-- TODO check for positiveX/negativeX for left/right based on presence of l_ and r_ in name -->
      <!-- TODO check for duplicates -->
      <!-- Debug statement: set test="true()" to enable, test="false()" to disable -->
      <report test="false()" role="diagnostic">HAnim checks for <name/> </report>
      <!-- HAnimSegment only provides naming, mass, moment -->
      <!-- HAnimSite translation cannot have -y value since that is underground. -->
      <report test="@translation and (string-length(@translation) > 0) and starts-with(substring-after(@translation,' '),'-')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has negative-y vertical value in translation='<value-of select="@translation"/>', which is illegal since HAnimSite cannot be underground </report>
      <!-- if any top-level USE fields are included in ancestor HAnimHumanoid, report if missing a corresponding USE copy of this DEF node -->
      <report test="not(@USE) and not(string-length(@USE) > 0) and (ancestor::HAnimHumanoid/HAnimSite[(string-length(@USE) > 0)]) and not(ancestor::HAnimHumanoid/HAnimSite[(string-length(@USE) > 0)][@USE=$DEF]) and not(Viewpoint and (@containerField='viewpoints'))" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; has ancestor HAnimHumanoid that does not include a corresponding &lt;<name/> USE='<value-of select='@DEF'/>' containerField='sites'/&gt; (or containerField='viewpoints') to match this node </report>
      <report test="(string-length(@USE) > 0) and (preceding-sibling::HAnimSite[(@USE = $USE) and (@name = $name)])" role="error">&lt;<name/> USE='<value-of select='@USE'/>' name='<value-of select='@name'/>' containerField='<value-of select='@containerField'/>'/&gt; matches a duplicate preceding USE node </report>
      <!-- HAnimSite nodes are contained by HAnimJoint or HAnimHumanoid -->
      <report test="not(ancestor::HAnimSegment) and not(ancestor::HAnimHumanoid)" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; is missing an ancestor HAnimSegment or HAnimHumanoid</report>
      <report test="(parent::HAnimHumanoid) and (not(@USE) or not(string-length(@USE) > 0)) and not(@containerField='skeleton') and not(Viewpoint and (@containerField='viewpoints'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; with parent HAnimHumanoid needs to be a USE reference to original DEF node under skeleton tree, or else have containerField='viewpoints' and contain a Viewpoint node </report>
      <report test="(parent::HAnimHumanoid) and (@USE)  and not(@containerField='sites') and not(@containerField='viewpoints')" role="error">&lt;<name/> USE='<value-of select='@USE'/>'/&gt; with parent HAnimHumanoid needs containerField='sites' or containerField='viewpoints' </report>
      <report test="(parent::HAnimJoint)    and not(@containerField='children')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>' USE='<value-of select='@USE'/>'/&gt; with parent HAnimJoint needs containerField='children' </report>
      <!-- only test immediate children to help localize extraneous HAnimHumanoid and avoid numerous false positives; might miss deeper descendants-->
      <report test="HAnimHumanoid" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; cannot contain another &lt;HAnimHumanoid DEF=&quot;<value-of select="HAnimHumanoid/@DEF"/>&quot; name=&quot;<value-of select="HAnimHumanoid/@name"/>&quot;/&gt; </report>
      <!-- Ensure left l_ site x translations are positive,  right r_ site x translations are negative -->
      <report test="contains(@name,'_l_') and     starts-with(normalize-space(@translation),'-')"  role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; translation needs positive x when on left side </report>
      <report test="contains(@name,'_r_') and not(starts-with(normalize-space(@translation),'-'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; translation needs negative x when on left side </report>
      <!-- TODO check that Site and Displacer nodes have further naming rules. Consider use of <extends rule="NeedsChildNode"/> -->
      <assert test="(string-length(normalize-space(@USE)) > 0) or (ends-with(normalize-space(@name),'_tip') or ends-with(normalize-space(@name),'_view') or ends-with(normalize-space(@name),'_pt') or (string-length(normalize-space(@name)) = 0) or
        (@name='cervicale') or (@name='crotch') or (@name='l_acromion') or (@name='l_asis') or (@name='l_axilla_ant') or (@name='l_axilla_post') or 
        (@name='l_calcaneous_post') or (@name='l_clavicale') or (@name='l_dactylion') or (@name='l_digit2') or (@name='l_femoral_lateral_epicn') or 
        (@name='l_femoral_medial_epicn') or (@name='l_forefoot_tip') or (@name='l_gonion') or (@name='l_hand_tip') or (@name='l_humeral_lateral_epicn') or 
        (@name='l_humeral_medial_epicn') or (@name='l_iliocristale') or (@name='l_index_distal_tip') or (@name='l_infraorbitale') or (@name='l_knee_crease') or 
        (@name='l_lateral_malleolus') or (@name='l_medial_malleolus') or (@name='l_metacarpal_pha2') or (@name='l_metacarpal_pha5') or (@name='l_metatarsal_pha1') or 
        (@name='l_metatarsal_pha5') or (@name='l_middle_distal_tip') or (@name='l_neck_base') or (@name='l_olecranon') or (@name='l_pinky_distal_tip') or 
        (@name='l_psis') or (@name='l_radial_styloid') or (@name='l_radiale') or (@name='l_rib10') or (@name='l_ring_distal_tip') or (@name='l_sphyrion') or 
        (@name='l_thelion') or (@name='l_thumb_distal_tip') or (@name='l_tragion') or (@name='l_trochanterion') or (@name='l_ulnar_styloid') or (@name='navel') or 
        (@name='nuchale') or (@name='r_acromion') or (@name='r_asis') or (@name='r_axilla_ant') or (@name='r_axilla_post') or (@name='r_calcaneous_post') or 
        (@name='r_clavicale') or (@name='r_dactylion') or (@name='r_digit2') or (@name='r_femoral_lateral_epicn') or (@name='r_femoral_medial_epicn') or 
        (@name='r_forefoot_tip') or (@name='r_gonion') or (@name='r_hand_tip') or (@name='r_humeral_lateral_epicn') or (@name='r_humeral_medial_epicn') or 
        (@name='r_iliocristale') or (@name='r_index_distal_tip') or (@name='r_infraorbitale') or (@name='r_knee_crease') or (@name='r_lateral_malleolus') or 
        (@name='r_medial_malleolus') or (@name='r_metacarpal_pha2') or (@name='r_metacarpal_pha5') or (@name='r_metatarsal_pha1') or (@name='r_metatarsal_pha5') or 
        (@name='r_middle_distal_tip') or (@name='r_neck_base') or (@name='r_olecranon') or (@name='r_pinky_distal_tip') or (@name='r_psis') or (@name='r_radial_styloid') or 
        (@name='r_radiale') or (@name='r_rib10') or (@name='r_ring_distal_tip') or (@name='r_sphyrion') or (@name='r_thelion') or (@name='r_thumb_distal_tip') or 
        (@name='r_tragion') or (@name='r_trochanterion') or (@name='r_ulnar_styloid') or (@name='rib10_midspine') or (@name='sellion') or (@name='skull_tip') or 
        (@name='substernale') or (@name='supramenton') or (@name='suprasternale') or (@name='waist_preferred_post'))" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; is not a recognized name for HAnimSite </assert>
        <report test="not(@USE) and ends-with(normalize-space(@name),'_tip') and not(@name=concat(../@name,'_tip'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' name='<value-of select='@name'/>'/&gt; needs to match name of parent &lt;HAnimSegment name='<value-of select='../@name'/>' (meaning name='<value-of select='../@name'/>_tip') </report>
        <!-- TODO HAnimHumanoid naming prefix rules -->
   </rule>

    <!-- ========= Metadata nodes ========== -->

    <rule context="MetadataBoolean">
      <let name="valueResidue" value="translate(normalize-space(@value),' truefalse,','')"/>
      <extends rule="Metadata"/>
      <extends rule="X3Dversion3.3"/>
      <!-- check for weird mixed-space -->
      <report test="not(@USE) and (string-length($valueResidue) != 0)" role="error">&NamedNodeDEFname; array value='<value-of select='@value'/>' has illegal characters, only (true, false) values are allowed </report>
      <!-- TODO is it possible to add similar rules for simple boolean fields, without leading to false positives for string fields? -->
      <report test="contains(value,'TRUE' )"   role="error">&NamedNodeDEFname; value array 'TRUE' values are incorrect, use 'true' instead</report>
      <report test="contains(value,'True' )"   role="error">&NamedNodeDEFname; value array 'True' values are incorrect, use 'true' instead</report>
      <report test="contains(value,'FALSE')"   role="error">&NamedNodeDEFname; value array 'FALSE' values are incorrect, use 'false' instead</report>
      <report test="contains(value,'False')"   role="error">&NamedNodeDEFname; value array 'False' values are incorrect, use 'false' instead</report>
    </rule>
    
    <rule context="MetadataInteger">
      <let name="valueResidue" value="translate(normalize-space(@value),' +-0123456789Ee,','')"/>
      <extends rule="Metadata"/>
      <report test="not(@USE) and (string-length($valueResidue) != 0)" role="error">&NamedNodeDEFname; array value='<value-of select='@value'/>' has illegal characters, only integer numbers are allowed </report>
    </rule>
    
    <rule context="MetadataFloat | MetadataDouble">
      <let name="valueResidue" value="translate(normalize-space(@value),' +-0123456789Ee,.','')"/>
      <extends rule="Metadata"/>
      <report test="not(@USE) and (string-length(normalize-space($valueResidue)) != 0)" role="error">&NamedNodeDEFname; array value='<value-of select='@value'/>' has illegal characters, only floating-point numbers are allowed </report>
    </rule>
    
    <rule context="MetadataSet">
      <extends rule="Metadata"/>
      <extends rule="NeedsChildNode"/>
      <!-- no other special tests since XML validation handles children -->
    </rule>

    <rule context="MetadataString">
      <let name="stringResidueApos" value="translate(@value,' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^*()-_=+;:[]{}?,./\|&#928;&gt;&lt;&amp;','')"/>
      <let name="stringResidue" value='translate($stringResidueApos,"&apos;","")'/>
      <let name="quoteCount" value="string-length($stringResidue)"/>
      <let name="normalizedString" value="normalize-space(@value)"/>
      <let name="lastCharacter" value="substring($normalizedString,string-length($normalizedString))"/>
      <extends rule="Metadata"/>
      <!-- value field MFString array checks -->
      <report test="false()" role="trace">$quoteCount=<value-of select='$quoteCount'/>, $stringResidue=<value-of select='$stringResidue'/>, $stringResidueApos=<value-of select='$stringResidueApos'/> , $lastCharacter=<value-of select='$lastCharacter'/> </report>
      <report test="not(@USE) and contains($normalizedString,'&quot;&quot;') and not(contains($normalizedString,'\&quot;&quot;') or contains($normalizedString,'&quot;\&quot;') or contains($normalizedString,'&quot;&quot; &quot;') or contains($normalizedString,'&quot; &quot;&quot;'))" role="error">&NamedNodeDEFname; array value='<value-of select='@value'/>' has questionable line-break &quot;&quot; quote marks </report>
      <report test="not(@USE) and (@value) and not(contains(@value,'&quot;'))"   role="error">&NamedNodeDEFname; array value='<value-of select='@value'/>' needs to begin and end with &quot;quote marks&quot;.  Corrected example: &lt;<name/> DEF='<value-of select='$DEF'/>' value=&apos;&quot;<value-of select='(@value)'/>&quot;&apos;/&gt; </report>
      <report test="not(@USE) and (@value) and    (contains(@value,'&quot;')) and (($quoteCount div 2)!=round($quoteCount div 2)) and not(contains(@value,'\&quot;'))"   role="error">&NamedNodeDEFname; array value='<value-of select='@value'/>' has <value-of select='($quoteCount)'/> unescaped &quot;quote marks&quot; but instead needs to have an even number (matched pairs) </report>
      <report test="not(@USE) and (@value) and (contains(@value,'\&quot;'))"    role="warning">&NamedNodeDEFname; array value='<value-of select='@value'/>' has <value-of select='($quoteCount)'/> quote marks with at least one escaped quote mark \&quot; so double-check to ensure paired &quot;quote marks&quot; for each line are matched </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;') and (contains(@value,'&quot;'))" role="error">&NamedNodeDEFname; array value='<value-of select='@value'/>' needs to begin and end with &quot;quote marks&quot; </report>
      <report test="not(@USE) and ($normalizedString) and not(starts-with($normalizedString,'&quot;')) and    ($lastCharacter='&quot;')"                                 role="error">&NamedNodeDEFname; array value='<value-of select='@value'/>' needs to begin with quote mark &quot; </report>
      <report test="not(@USE) and ($normalizedString) and    (starts-with($normalizedString,'&quot;')) and not($lastCharacter='&quot;')"                                 role="error">&NamedNodeDEFname; array value='<value-of select='@value'/>' needs to end with quote mark &quot; </report>
    </rule>

    <!-- ========= Shader nodes ========== -->
    <rule id="ShaderLanguage" abstract="true">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.1"/>
      <assert test="(@language='CG') or (@language='GLSL') or (@language='HLSL')" role="warning">&lt;<name/> DEF='<value-of select='@DEF'/>' value='<value-of select='@value'/>'/&gt; but supported shader language values are GLSL HLSL or Cg </assert>
    </rule>

    <rule id="embeddedWhiteSpaceCount" abstract="true">
      <let name="embeddedWhiteSpaceCount" value="string-length(normalize-space(translate(@value,',',' '))) - string-length(translate(normalize-space(translate(@value,',',' ')),' ',''))"/>
      <extends rule="DEFtests"/>
    </rule>

    <rule context="ComposedShader | ProgramShader">
      <extends rule="ShaderLanguage"/>
      <!-- contained field definition checks are also applied automatically for ComposedShader -->
    </rule>

    <rule context="PackagedShader">
      <extends rule="ShaderLanguage"/>
      <extends rule="hasUrl"/>
      <!-- contained field definition checks are also applied automatically -->
    </rule>

    <rule context="ShaderPart | ShaderProgram">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.1"/>
      <extends rule="hasUrl"/>
      <!-- could test type VERTEX/FRAGMENT but that is caught by DTD/Schema -->
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@type, '&quot;')" role="error">&NodeDEFname; type='<value-of select='@type'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <!-- contained field definition checks are also applied automatically for ShaderProgram -->
      <report test="(local-name(.)='ShaderPart') and (local-name(..)!='ComposedShader')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' value='<value-of select='@value'/>'/&gt; needs to be contained by a &lt;ComposedShader&gt; node rather than a &lt;<value-of select='@numComponents'/>&gt; node</report>
    </rule>

    <rule context="Matrix3VertexAttribute">
      <extends rule="embeddedWhiteSpaceCount"/>
      <extends rule="X3Dversion3.1"/>
      <extends rule="optionalName"/>
      <report test="((($embeddedWhiteSpaceCount + 1) mod  9) != 0)" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 9)'/>) for 9-tuple Matrix3VertexAttribute array </report>
    </rule>

    <rule context="Matrix4VertexAttribute">
      <extends rule="embeddedWhiteSpaceCount"/>
      <extends rule="X3Dversion3.1"/>
      <extends rule="optionalName"/>
      <report test="((($embeddedWhiteSpaceCount + 1) mod 16) != 0)" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div 16)'/>'/>) for 16-tuple Matrix4VertexAttribute array </report>
    </rule>

    <rule context="Matrix4VertexAttribute">
      <extends rule="embeddedWhiteSpaceCount"/>
      <extends rule="X3Dversion3.1"/>
      <extends rule="optionalName"/>
      <report test="((($embeddedWhiteSpaceCount + 1) mod @numComponents) != 0)" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>' value='<value-of select='@value'/>'/&gt; has illegal number of values (<value-of select='(($embeddedWhiteSpaceCount + 1) div @numComponents)'/>'/>) for @numComponents=<value-of select='@numComponents'/> FloatVertexAttribute array </report>
      <report test="(@numComponents &lt; 1) or (@numComponents &gt; 4) " role="error">&lt;<value-of select='local-name(..)'/> name='<value-of select='../@name'/>' DEF='<value-of select='../@DEF'/>'&gt; &lt;<name/> name='<value-of select='@name'/>' numComponents='<value-of select='@numComponents'/>'/&gt; has illegal numComponents value, must be in range [1..4] inclusive </report>
    </rule>
    
    <!-- ========= Cube map environmental texturing nodes ========== -->

    <rule context="ComposedCubeMapTexture ">
      <!-- attribute value validation performed by X3D Schema -->
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.1"/>
    </rule>
    
    <rule context="GeneratedCubeMapTexture">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.1"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@update, '&quot;')" role="error">&NodeDEFname; update='<value-of select='@update'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <!-- TODO more rules -->
    </rule>

    <rule context="ImageCubeMapTexture">
      <!-- attribute value validation performed by X3D Schema -->
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.1"/>
      <extends rule="hasUrl"/>
      <!-- TODO file format check -->
    </rule>

    <!-- ========= Followers: Chasers and Dampers ========== -->

    <rule id="Chaser" abstract="true">
      <!-- attribute value validation performed by X3D Schema -->
      <extends rule="DEFtests"/>
      <report test="starts-with(normalize-space(@duration),'-')" role="info">&NodeDEFname; duration='<value-of select='@duration'/>' cannot be negative </report>
    </rule>

    <rule context="OrientationChaser | PositionChaser | PositionChaser2D | ScalarChaser">
      <extends rule="Chaser"/>
      <extends rule="X3Dversion3.2"/>
    </rule>

    <rule context="ColorChaser | CoordinateChaser | TexCoordChaser2D">
      <extends rule="Chaser"/>
      <extends rule="X3Dversion3.3"/>
    </rule>

    <rule id="Damper" abstract="true">
      <!-- attribute value validation performed by X3D Schema -->
      <extends rule="DEFtests"/>
      <report test="starts-with(normalize-space(@tau),'-')" role="info">&NodeDEFname; tau='<value-of select='@tau'/>' time constant cannot be negative </report>
      <report test="starts-with(normalize-space(@tolerance),'-') and (normalize-space(@tolerance) != -1)" role="info">&NodeDEFname; tolerance='<value-of select='@tau'/>' is an absolute value that can only be positive, zero or -1 (for browser choice) </report>
    </rule>

    <rule context="ColorDamper | CoordinateDamper | OrientationDamper | PositionDamper | PositionDamper2D | TexCoordDamper2D">
      <extends rule="Damper"/>
      <extends rule="X3Dversion3.2"/>
    </rule>

    <rule context="ScalarDamper">
      <extends rule="Damper"/>
      <extends rule="X3Dversion3.3"/>
    </rule>
    
    <!-- ========= NURBS nodes ========== -->

    <rule id="NurbsSurfaceGeometryNode" abstract="true">
      <!-- attribute value validation performed by X3D Schema -->
      <let name="embeddedWhiteSpaceCount" value="string-length(normalize-space(translate(*[(local-name='Coordinate') or (local-name='CoordinateDouble')]/@point,',',' '))) - string-length(translate(normalize-space(translate(*[(local-name='Coordinate') or (local-name='CoordinateDouble')]/@point,',',' ')),' ',''))"/>
      <extends rule="DEFtests"/>
      <report test="starts-with(normalize-space(@uDimension),'-')" role="info">&NodeDEFname; uDimension='<value-of select='@duration'/>' cannot be negative </report>
      <report test="starts-with(normalize-space(@vDimension),'-')" role="info">&NodeDEFname; vDimension='<value-of select='@duration'/>' cannot be negative </report>
      <assert test="@USE or ($embeddedWhiteSpaceCount = 0) or not(($embeddedWhiteSpaceCount+1) = (@uDimension * @vDimension))" role="warning">&lt;<name/>/&gt; controlPoint array size (<value-of select='($embeddedWhiteSpaceCount+1)'/>) must equal (@uDimension='<value-of select='@uDimension'/>') * (@vDimension='<value-of select='@vDimension'/>') </assert>
      <report test="(@uClosed='TRUE' )" role="error">&NodeDEFname; uClosed='TRUE' is incorrect, define uClosed='true' instead</report>
      <report test="(@uClosed='FALSE')" role="error">&NodeDEFname; uClosed='FALSE' is incorrect, define uClosed='false' instead</report>
      <report test="(@vClosed='TRUE' )" role="error">&NodeDEFname; vClosed='TRUE' is incorrect, define vClosed='true' instead</report>
      <report test="(@vClosed='FALSE')" role="error">&NodeDEFname; vClosed='FALSE' is incorrect, define vClosed='false' instead</report>
    </rule>

    <rule context="NurbsPatchSurface">
      <extends rule="NurbsSurfaceGeometryNode"/>
      <!-- TODO other rules? -->
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='NURBS'][number(@level) ge 1]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='NURBS' level='1'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>

    <rule context="NurbsTrimmedSurface">
      <extends rule="NurbsSurfaceGeometryNode"/>
      <!-- TODO other rules? -->
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='NURBS'][number(@level) ge 4]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='NURBS' level='4'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>

    <rule context="Contour2D">
      <let name="embeddedWhiteSpaceCount" value="string-length(normalize-space(translate(@controlPoint,',',' '))) - string-length(translate(normalize-space(translate(@controlPoint,',',' ')),' ',''))"/>
      <extends rule="DEFtests"/>
      <!-- TODO -->
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='NURBS'][number(@level) ge 4]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='NURBS' level='4'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>

    <rule context="ContourPolyline2D">
      <let name="embeddedWhiteSpaceCount" value="string-length(normalize-space(translate(@controlPoint,',',' '))) - string-length(translate(normalize-space(translate(@controlPoint,',',' ')),' ',''))"/>
      <extends rule="DEFtests"/>
      <report test="(parent::Contour2D)         and not((@containerField='children') or not(@containerField) or (string-length(@containerField) = 0))" role="error">&NodeDEFname; containerField='<value-of select='@containerField'/>' but must be containerField='children' (default value) when parent node is Contour2D </report>
      <report test="(parent::NurbsSweptSurface) and not((@containerField='crossSectionCurve') or (@containerField='trajectoryCurve'))"                 role="error">&NodeDEFname; containerField='<value-of select='@containerField'/>' but must be containerField='crossSectionCurve' or 'trajectoryCurve' when parent node is NurbsSweptSurface </report>
      <report test="(parent::NurbsSwungSurface) and not((@containerField='profileCurve')      or (@containerField='trajectoryCurve'))"                 role="error">&NodeDEFname; containerField='<value-of select='@containerField'/>' but must be containerField='profileCurve' or 'trajectoryCurve' when parent node is NurbsSwungSurface </report>
      <assert test="@USE or ($embeddedWhiteSpaceCount = 0) or (($embeddedWhiteSpaceCount div 2)!=round($embeddedWhiteSpaceCount div 2))" role="error">&lt;&NodeDEFname; controlPoint='<value-of select='@controlPoint'/>' array size (<value-of select='($embeddedWhiteSpaceCount+1)'/>) must be an even number for type MFVec2d </assert>
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='NURBS'][number(@level) ge 3]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='NURBS' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>

    <rule context="NurbsCurve">
      <let name="embeddedWhiteSpaceCount" value="string-length(normalize-space(translate(@controlPoint,',',' '))) - string-length(translate(normalize-space(translate(@controlPoint,',',' ')),' ',''))"/>
      <extends rule="DEFtests"/>
      <report test="(parent::Shape)         and not((@containerField='geometry') or not(@containerField) or (string-length(@containerField) = 0))" role="error">&NodeDEFname; containerField='<value-of select='@containerField'/>' but must be containerField='geometry' (default value) when parent node is Shape </report>
      <report test="(parent::NurbsSweptSurface) and not(@containerField='trajectoryCurve')"                                                        role="error">&NodeDEFname; containerField='<value-of select='@containerField'/>' but must be containerField='trajectoryCurve' when parent node is NurbsSweptSurface </report>
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='NURBS'][number(@level) ge 1]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='NURBS' level='1'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>

    <rule context="NurbsCurve2D">
      <let name="embeddedWhiteSpaceCount" value="string-length(normalize-space(translate(@controlPoint,',',' '))) - string-length(translate(normalize-space(translate(@controlPoint,',',' ')),' ',''))"/>
      <extends rule="DEFtests"/>
      <!-- TODO -->
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='NURBS'][number(@level) ge 3]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='NURBS' level='3'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>

    <rule context="NurbsPositionInterpolator">
      <extends rule="DEFtests"/>
      <!-- TODO -->
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='NURBS'][number(@level) ge 1]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='NURBS' level='1'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>

    <rule context="NurbsOrientationInterpolator">
      <extends rule="DEFtests"/>
      <!-- TODO -->
      <report test="not((/X3D[@profile='Full']) or (/X3D/head/component[@name='NURBS'][number(@level) ge 1]) or (count(preceding::*[local-name()=$NodeName]) > 0))" role="error">&NodeDEFname; requires at least &lt;component name='NURBS' level='1'/&gt; or &lt;X3D profile='Full'/&gt; </report>
    </rule>

    <!-- TODO
    default weight field: all 1 values, one for each point; point array length / 3
    
    If the length of the weight vector is 0, the default weight 1.0 is assumed for each control point, thus defining a non-Rational curve. If the number of weight values is less than the number of control points, all weight values shall be ignored and a value of 1.0 shall be used.
    
    27.2.3 last paragraph on knots
    knots defines the knot vector. The number of knots shall be equal to the number of control points plus the order of the curve. The order shall be non-decreasing. Within the knot vector there may not be more than order−1 consecutive knots of equal value. If the length of a knot vector is 0 or not the exact number required (numcontrolPoint + order), a default uniform knot vector is computed.
    Nurbs Book p.66 bottom definition of uniform knot: uniformly spaced values
    
    default knots: default range [0..1] ? add normalize button, largest range 0..1, other scaled appropriately
    p. 85, 89: different uniformly spaced knots for different degrees of polynomials
    
    27.4.1 Contour2D
    27.4.3 CoordinateDouble
    27.4.5 NurbsCurve2D
    27.4.6 NurbsOrientationInterpolator
    27.4.8 NurbsPositionInterpolator
    27.4.9 NurbsSet
    27.4.10 NurbsSurfaceInterpolator
    27.4.11 NurbsSweptSurface
    27.4.12 NurbsSwungSurface
    27.4.13 NurbsTextureCoordinate

    -->

    <!-- ========= Particle System nodes ========== -->

    <rule context="ParticleSystem">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.2"/>
       <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@geometryType, '&quot;')" role="error">&NodeDEFname; geometryType='<value-of select='@geometryType'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <!-- TODO more rules -->
    </rule>

    <!-- TODO rule for (BoundedPhysicsModel | ForcePhysicsModel | WindPhysicsModel) must have parent ParticleSystem -->

    <!-- ========= Volume Rendering nodes ========== -->

    <!-- ========= abstract: VolumeDataNode ========== -->
    <rule id="VolumeDataNode" abstract="true">
      <let name="embeddedWhiteSpaceCount" value="string-length(normalize-space(translate(@dimensions,',',' '))) - string-length(translate(normalize-space(translate(@dimensions,',',' ')),' ',''))"/>
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.3"/>
      <assert test="@USE or not(@dimensions) or ($embeddedWhiteSpaceCount = 2)" role="warning">&NodeDEFname; dimensions='<value-of select='@dimensions'/>' must have 3 values </assert>
      <report test="starts-with(normalize-space(@dimensions),'-') or contains(normalize-space(@dimensions),' -')" role="info">&NodeDEFname; dimensions='<value-of select='@dimensions'/>' cannot include a negative value </report>
    </rule>

    <rule context="BlendedVolumeStyle">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.3"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@weightFunction1, '&quot;')" role="error">&NodeDEFname; weightFunction1='<value-of select='@weightFunction1'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="contains(@weightFunction2, '&quot;')" role="error">&NodeDEFname; weightFunction2='<value-of select='@weightFunction2'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <!-- TODO more rules -->
    </rule>

    <rule context="ProjectionVolumeStyle">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.3"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@type, '&quot;')" role="error">&NodeDEFname; type='<value-of select='@type'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <!-- TODO more rules -->
    </rule>

    <rule context="ShadedVolumeStyle">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.3"/>
      <!-- extraneous-quote tests for SFString enumeration fields -->
      <report test="contains(@phaseFunction, '&quot;')" role="error">&NodeDEFname; phaseFunction='<value-of select='@phaseFunction'/>' is erroneous since the contained enumeration value must not include quotation marks </report>
      <report test="Appearance/Material" role="error">&NodeDEFname; contains Appearance/Material children, instead can only contain Material with no Appearance </report>
      <!-- TODO more rules -->
    </rule>

    <rule context="ISOSurfaceVolumeData">
      <report test="true()" role="error">&NodeDEFname; has incorrect capitalization, change to IsoSurfaceVolumeData </report>
    </rule>

    <rule context="IsoSurfaceVolumeData">
      <extends rule="VolumeDataNode"/>
      <report test="count(ComposedTexture3D | ImageTexture3D | PixelTexture3D) > 1" role="error">&NodeDEFname; can only contain one (ComposedTexture3D | ImageTexture3D | PixelTexture3D) node (for voxels) </report>
    </rule>

    <rule context="SegmentedVolumeData">
      <extends rule="VolumeDataNode"/>
      <report test="count(ComposedTexture3D | ImageTexture3D | PixelTexture3D) > 2" role="error">&NodeDEFname; cannot contain more than 2 (ComposedTexture3D | ImageTexture3D | PixelTexture3D) nodes (one for containerField = 'gradients' and one for containerField = 'voxels') </report>
    </rule>

    <rule context="VolumeData">
      <extends rule="VolumeDataNode"/>
      <report test="count(ComposedTexture3D | ImageTexture3D | PixelTexture3D) > 2" role="error">&NodeDEFname; cannot contain more than 2 (ComposedTexture3D | ImageTexture3D | PixelTexture3D) nodes (one for containerField = 'segmentIdentifiers' and one for containerField = 'voxels') </report>
    </rule>

    <rule context="BoundaryEnhancementVolumeStyle | CartoonVolumeStyle | ComposedVolumeStyle | EdgeEnhancementVolumeStyle |
                   OpacityMapVolumeStyle | SilhouetteEnhancementVolumeStyle | ToneMappedVolumeStyle">
      <!-- attribute value validation performed by X3D Schema -->
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.3"/>
    </rule>

    <!-- 3D texture nodes TODO finish -->

    <!-- ========= abstract: X3DTexture3DNode ========== -->
    <rule id="X3DTexture3DNode" abstract="true">
      <extends rule="DEFtests"/>
      <extends rule="X3Dversion3.1"/>
      <!-- TODO additional containerField rules -->
      <report test="(parent::IsoSurfaceVolumeData) and not(@containerField = 'voxels') and not(@containerField = 'gradients')" role="error">&NodeDEFname; illegal containerField='<value-of select='@containerField'/>' with parent IsoSurfaceVolumeData, allowed values are containerField='voxels' and containerField='gradients' </report>
      <report test="(parent::SegmentedVolumeData) and not(@containerField = 'voxels') and not(@containerField = 'segmentIdentifiers')" role="error">&NodeDEFname; illegal containerField='<value-of select='@containerField'/>' with parent SegmentedVolumeData, allowed values are containerField='voxels' and containerField='segmentIdentifiers' </report>
      <report test="parent::VolumeData and not(@containerField = 'voxels')" role="error">&NodeDEFname; illegal containerField='<value-of select='@containerField'/>' with parent VolumeData, allowed value is containerField='voxels' </report>
    </rule>
    
    <rule context="ComposedTexture3D">
      <extends rule="X3DTexture3DNode"/>
    </rule>
    
    <rule context="ImageTexture3D">
      <extends rule="X3DTexture3DNode"/>
    </rule>
    
    <rule context="PixelTexture3D">
      <extends rule="X3DTexture3DNode"/>
    </rule>
        
    <!-- TODO integrate using regular patterns -->
    <!-- ========= X3Dversion3.1 nodes ========== -->
    <rule context="//ComposedCubeMapTexture | //ComposedShader | //ComposedTexture3D | //FloatVertexAttribute | //FogCoordinate | //GeneratedCubeMapTexture |
                   //ImageCubeMapTexture | //ImageTexture3D | //Matrix3VertexAttribute | //Matrix4VertexAttribute | //PackagedShader | //PixelTexture3D |
                   //ProgramShader | //ShaderPart | //ShaderProgram |
                   //TextureCoordinate3D | //TextureCoordinate4D | //TextureTransform3D | //TextureTransformMatrix3D">
      <extends rule="DEFtests"/>
      <assert test="(/X3D/@version='3.1') or (/X3D/@version='3.2') or (/X3D/@version='3.3') or (/X3D/@version='3.4')" role="error">contained node requires X3D version 3.1 or higher, but found version='<value-of select='/X3D/@version'/>' </assert>
      <report test="(@repeatS='TRUE' )" role="error">&NodeDEFname; repeatS='TRUE' is incorrect, define repeatS='true' instead</report>
      <report test="(@repeatS='FALSE')" role="error">&NodeDEFname; repeatS='FALSE' is incorrect, define repeatS='false' instead</report>
      <report test="(@repeatT='TRUE' )" role="error">&NodeDEFname; repeatT='TRUE' is incorrect, define repeatT='true' instead</report>
      <report test="(@repeatT='FALSE')" role="error">&NodeDEFname; repeatT='FALSE' is incorrect, define repeatT='false' instead</report>
      <report test="(@repeatR='TRUE' )" role="error">&NodeDEFname; repeatR='TRUE' is incorrect, define repeatR='true' instead</report>
      <report test="(@repeatR='FALSE')" role="error">&NodeDEFname; repeatR='FALSE' is incorrect, define repeatR='false' instead</report>
   </rule>

<!-- TODO avoid crash problem, rewrite these composite rules on a node-by-node basis
    ========== X3Dversion3.2 nodes ==========
    <rule context="//BoundedPhysicsModel | //ClipPlane | 
                   //ColorDamper | //ConeEmitter | //CoordinateDamper | //DISEntityManager | //DISEntityTypeMapping |
                   //EaseInEaseOut | //ExplosionEmitter | //ForcePhysicsModel | //GeoProximitySensor | //GeoTransform">
      <extends rule="DEFtests"/>
      <assert test="/X3D/@version='3.2'" role="error">contained node requires X3D version 3.2, but found version='<value-of select='/X3D/@version'/>' </assert>
    </rule>
    <rule context="//Layer | //LayerSet | //Layout | //LayoutGroup | //LayoutLayer | //LinePickSensor | //LocalFog | //OrientationChaser | //OrientationDamper |
                   //ParticleSystem | //PickableGroup | //PointEmitter | //PointPickSensor | //PolylineEmitter | //PositionChaser | //PositionChaser2D |
                   //PositionDamper | //PositionDamper2D | //PrimitivePickSensor">
      <extends rule="DEFtests"/>
      <assert test="/X3D/@version='3.2'" role="error">contained node requires X3D version 3.2, but found version='<value-of select='/X3D/@version'/>' </assert>
    </rule>
    <rule context="//ScalarChaser | //ScreenFontStyle | //ScreenGroup | //SplinePositionInterpolator | //SplinePositionInterpolator2D |
                   ">
      <extends rule="DEFtests"/>
      <assert test="/X3D/@version='3.2'" role="error">contained node requires X3D version 3.2, but found version='<value-of select='/X3D/@version'/>' </assert>
    </rule>
    <rule context="//SplineScalarInterpolator | //SquadOrientationInterpolator | //SurfaceEmitter | //TexCoordDamper | //TextureProperties | //TransformSensor |
                   //ViewpointGroup | //Viewport | //VolumeEmitter | //VolumePickSensor | //WindPhysicsModel">
      <extends rule="DEFtests"/>
      <assert test="/X3D/@version='3.2'" role="error">contained node requires X3D version 3.2, but found version='<value-of select='/X3D/@version'/>' </assert>
    </rule>
    
  TODO
  Warning: only one LayerSet node is allowed in a scene, and it shall be a root node at the top of the scene graph.
  
  Check appliedParamaterValues in MFString appliedParameters field for CollisionCollection and Contact.
 -->

    <!-- ========= abstract: profileTests ========== -->
    <rule id="profileTests" abstract="true">
      <!-- compute needed profile -->
      <let name="fullProfile" value="
                   (//Arc2D                         and not(/X3D/head/component[@name='Geometry2D']   [number(@level) ge 2]))
		or (//ArcClose2D                    and not(/X3D/head/component[@name='Geometry2D']   [number(@level) ge 2]))
		or (//Circle2D                      and not(/X3D/head/component[@name='Geometry2D']   [number(@level) ge 2]))
		or (//ClipPlane                     and not(/X3D/head/component[@name='Rendering']    [number(@level) ge 5]))
		or (//Contour2D                     and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 4]))
		or (//ContourPolyline2D             and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 3]))
		or (//CoordinateDouble              and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 1]))
		or (//CoordinateInterpolator2D      and not(/X3D/head/component[@name='Interpolation'][number(@level) ge 3]))
                or (//DISEntityManager              and not(/X3D/head/component[@name='DIS']          [number(@level) ge 2]))
                or (//DISEntityTypeMapping          and not(/X3D/head/component[@name='DIS']          [number(@level) ge 2]))
		or (//Disk2D                        and not(/X3D/head/component[@name='Geometry2D']   [number(@level) ge 2]))
		or (//EspduTransform                and not(/X3D/head/component[@name='DIS']          [number(@level) ge 1]))
		or (//FillProperties                and not(/X3D/head/component[@name='Shape']        [number(@level) ge 3]))
		or (//FogCoordinate                 and not(/X3D/head/component[@name='EnvironmentalEffects'][number(@level) ge 3]))
		or (//GeoCoordinate                 and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 1]))
		or (//GeoElevationGrid              and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 1]))
		or (//GeoLocation                   and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 1]))
		or (//GeoLOD                        and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 1]))
		or (//GeoMetadata                   and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 1]))
		or (//GeoOrigin                     and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 1]))
		or (//GeoPositionInterpolator       and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 1]))
		or (//GeoProximitySensor            and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 2]))
		or (//GeoTouchSensor                and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 1]))
		or (//GeoTransform                  and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 2]))
		or (//GeoViewpoint                  and not(/X3D/head/component[@name='Geospatial']   [number(@level) ge 1]))
		or (//HAnimDisplacer                and not(/X3D/head/component[@name='H-Anim']       [number(@level) ge 1]))
		or (//HAnimHumanoid                 and not(/X3D/head/component[@name='H-Anim']       [number(@level) ge 1]))
		or (//HAnimJoint                    and not(/X3D/head/component[@name='H-Anim']       [number(@level) ge 1]))
		or (//HAnimSegment                  and not(/X3D/head/component[@name='H-Anim']       [number(@level) ge 1]))
		or (//HAnimSite                     and not(/X3D/head/component[@name='H-Anim']       [number(@level) ge 1]))
		or (//NurbsCurve                    and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 1]))
		or (//NurbsCurve2D                  and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 3]))
		or (//NurbsOrientationInterpolator  and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 1]))
		or (//NurbsPatchSurface             and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 1]))
		or (//NurbsPositionInterpolator     and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 1]))
		or (//NurbsSet                      and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 2]))
		or (//NurbsSurfaceInterpolator      and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 1]))
		or (//NurbsSweptSurface             and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 3]))
		or (//NurbsSwungSurface             and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 3]))
		or (//NurbsTextureCoordinate        and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 1]))
		or (//NurbsTrimmedSurface           and not(/X3D/head/component[@name='NURBS']        [number(@level) ge 4]))
		or (//PositionInterpolator2D        and not(/X3D/head/component[@name='Interpolation'][number(@level) ge 3]))
		or (//ReceiverPdu                   and not(/X3D/head/component[@name='DIS']          [number(@level) ge 1]))
		or (//SignalPdu                     and not(/X3D/head/component[@name='DIS']          [number(@level) ge 1]))
		or (//StaticGroup                   and not(/X3D/head/component[@name='Grouping']     [number(@level) ge 3]))
		or (//TextureBackground             and not(/X3D/head/component[@name='EnvironmentalEffects'][number(@level) ge 3]))
		or (//TransformSensor               and not(/X3D/head/component[@name='EnvironmentalSensor'] [number(@level) ge 3]))
		or (//LocalFog                      and not(/X3D/head/component[@name='EnvironmentalEffects'][number(@level) ge 3]))
		or (//FogCoordinate                 and not(/X3D/head/component[@name='EnvironmentalEffects'][number(@level) ge 3]))
		or (//TransmitterPdu                and not(/X3D/head/component[@name='DIS']          [number(@level) ge 1]))"/>
      
      <let name="immersiveProfile" value="not($fullProfile) and 
       (           (//ExternProtoDeclare            and not(/X3D/head/component[@name='Core']         [number(@level) ge 2]))
		or (//field                         and not(/X3D/head/component[@name='Scripting']    [number(@level) ge 1] or
                                                            /X3D/head/component[@name='Core']         [number(@level) ge 2]))
		or (//fieldValue                    and not(/X3D/head/component[@name='Core']         [number(@level) ge 2]))
		or (//IS                            and not(/X3D/head/component[@name='Core']         [number(@level) ge 2]))
		or (//connect                       and not(/X3D/head/component[@name='Core']         [number(@level) ge 2]))
		or (//ProtoDeclare                  and not(/X3D/head/component[@name='Core']         [number(@level) ge 2]))
		or (//ProtoInterface                and not(/X3D/head/component[@name='Core']         [number(@level) ge 2]))
		or (//ProtoBody                     and not(/X3D/head/component[@name='Core']         [number(@level) ge 2]))
		or (//ProtoInstance                 and not(/X3D/head/component[@name='Core']         [number(@level) ge 2]))
		or (//AudioClip                     and not(/X3D/head/component[@name='Sound']        [number(@level) ge 1]))
		or (//Billboard                     and not(/X3D/head/component[@name='Navigation']   [number(@level) ge 2]))
		or (//Collision                     and not(/X3D/head/component[@name='Navigation']   [number(@level) ge 2]))
		or (//Extrusion                     and not(/X3D/head/component[@name='Geometry3D']   [number(@level) ge 4]))
		or (//Fog                           and not(/X3D/head/component[@name='EnvironmentalEffects'][number(@level) ge 2]))
		or (//FontStyle                     and not(/X3D/head/component[@name='Text']         [number(@level) ge 1]))
		or (//LineProperties                and not(/X3D/head/component[@name='Shape']        [number(@level) ge 2]))
		or (//IMPORT                        and not(/X3D/head/component[@name='Networking']   [number(@level) ge 3]))
		or (//EXPORT                        and not(/X3D/head/component[@name='Networking']   [number(@level) ge 3]))
		or (//LoadSensor                    and not(/X3D/head/component[@name='Networking']   [number(@level) ge 3]))
		or (//LOD                           and not(/X3D/head/component[@name='Navigation']   [number(@level) ge 2]))
		or (//MovieTexture                  and not(/X3D/head/component[@name='Texturing']    [number(@level) ge 3]))
		or (//Polyline2D                    and not(/X3D/head/component[@name='Geometry2D']   [number(@level) ge 1]))
		or (//Polypoint2D                   and not(/X3D/head/component[@name='Geometry2D']   [number(@level) ge 1]))
		or (//Rectangle2D                   and not(/X3D/head/component[@name='Geometry2D']   [number(@level) ge 1]))
		or (//Script                        and not(/X3D/head/component[@name='Scripting']    [number(@level) ge 1]))
		or (//Sound                         and not(/X3D/head/component[@name='Sound']        [number(@level) ge 1]))
		or (//Switch                        and not(/X3D/head/component[@name='Grouping']     [number(@level) ge 2]))
		or (//Text                          and not(/X3D/head/component[@name='Text']         [number(@level) ge 1]))
		or (//TriangleSet2D                 and not(/X3D/head/component[@name='Geometry2D']   [number(@level) ge 1]))
		or (//VisibilitySensor              and not(/X3D/head/component[@name='EnvironmentalSensor'][number(@level) ge 2])))"/>
      
      <let name="interactiveProfile"    value="not($fullProfile) and not($immersiveProfile) and 
       (           (//Anchor                        and not(/X3D/head/component[@name='Networking']   [number(@level) ge 1]))
		or //BooleanFilter
		or //BooleanSequencer
		or //BooleanToggle
		or //BooleanTrigger
		or //CylinderSensor
		or //ElevationGrid
		or (//Inline                        and not(/X3D/head/component[@name='Networking']   [number(@level) ge 2]))
		or //IntegerSequencer
		or //IntegerTrigger
		or //KeySensor
		or //PlaneSensor
		or //PointLight
		or (//ProximitySensor               and not(/X3D/head/component[@name='EnvironmentalSensor'][number(@level) ge 1]))
		or //SphereSensor
		or //SpotLight
		or //StringSensor
		or //Switch
		or //TimeTrigger
		or //TouchSensor)"/>
      <!-- note that CADInterchange profile is quite a bit different from Interchange profile, with no subset/superset relationship -->
      <let name="cadComponentNodes" value="
       (           //CADAssembly
		or //CADFace
		or //CADLayer
		or //CADPart
		or //IndexedQuadSet
		or //QuadSet)"/>
      <let name="interchangeProfile"    value="not($fullProfile) and not($immersiveProfile) and not($interactiveProfile) and not($cadComponentNodes) and
       (           //Appearance
		or //Background
		or //Box
		or //Color
		or //ColorInterpolator
		or //ColorRGBA
		or //Cone
		or //Coordinate
		or //CoordinateInterpolator
		or //Cylinder
		or //DirectionalLight
		or //Group
		or //ImageTexture
		or //IndexedFaceSet
		or //IndexedLineSet
		or //IndexedTriangleFanSet
		or //IndexedTriangleSet
		or //IndexedTriangleStripSet
		or //LineSet
		or //Material
		or //MultiTexture
		or //MultiTextureCoordinate
		or //MultiTextureTransform
		or //NavigationInfo
		or //Normal
		or //NormalInterpolator
		or //OrientationInterpolator
		or //PixelTexture
		or //PointSet
		or //PositionInterpolator
		or //ScalarInterpolator
		or //Shape
		or //Sphere
		or //TextureCoordinate
		or //TextureCoordinateGenerator
		or //TextureTransform
		or //TimeSensor
		or //Transform
		or //TriangleFanSet
		or //TriangleSet
		or //TriangleStripSet
		or //Viewpoint
		or //WorldInfo)"/>
      <let name="cadInterchangeProfile" value="not($fullProfile) and not($immersiveProfile) and not($interactiveProfile) and not($interchangeProfile) and
       (   $cadComponentNodes
                or //Appearance
		or //Billboard
		or //Collision
		or //Color
		or //ColorRGBA
		or //Coordinate
		or //DirectionalLight
                or //FragmentShader
		or //Group
		or //ImageTexture
		or //IndexedLineSet
		or //IndexedTriangleFanSet
		or //IndexedTriangleSet
		or //IndexedTriangleStripSet
		or //LineProperties
		or //LineSet
		or //LOD
		or //Material
		or //MetadataDouble
		or //MetadataFloat
		or //MetadataInteger
		or //MetadataSet
		or //MetadataString
		or //MultiShader
		or //MultiTexture
		or //MultiTextureCoordinate
		or //MultiTextureTransform
		or //NavigationInfo
		or //Normal
		or //PixelTexture
		or //PointSet
		or //Shader
		or //ShaderAppearance
		or //Shape
		or //TextureCoordinate
		or //TextureCoordinateGenerator
		or //TextureTransform
		or //Transform
		or //TriangleFanSet
		or //TriangleSet
		or //TriangleStripSet
		or //VertexShader
		or //Viewpoint
		or //WorldInfo)"/>
      <let name="coreProfile"           value="not($fullProfile) and not($immersiveProfile) and not($interactiveProfile) and not($cadComponentNodes) and not($interchangeProfile) and
       (   //component
		or //head
		or //meta
		or //MetadataDouble
		or //MetadataFloat
		or //MetadataInteger
		or //MetadataSet
		or //MetadataString
		or //ROUTE
		or //X3D)"/>
      <let name="profileLegal"  value="(@profile='Full') or (@profile='Immersive') or (@profile='Interactive') or (@profile='CADInterchange') or (@profile='Interchange') or (@profile='Core')"/>
      <let name="profileMatch"  value="(@profile='Full'           and $fullProfile) or
                                       (@profile='Immersive'      and $immersiveProfile) or
                                       (@profile='Interactive'    and $interactiveProfile) or
                                       (@profile='CADInterchange' and $cadInterchangeProfile) or
                                       (@profile='Interchange'    and $interchangeProfile) or
                                       (@profile='Core'           and $coreProfile)"/>
<!--  diagnostics:
      <report test="not($profileMatch)" role="info"> Diagnostic: $fullProfile=<value-of select='$fullProfile'/>, $immersiveProfile=<value-of select='$immersiveProfile'/>,  $interactiveProfile=<value-of select='$interactiveProfile'/>, $cadInterchangeProfile=<value-of select='$cadInterchangeProfile'/>, $interchangeProfile=<value-of select='$interchangeProfile'/>, $coreProfile=<value-of select='$coreProfile'/> </report>
-->
      <!--  individual profile mismatch reports (unless a component statement is present) -->
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $fullProfile"           role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='Full', ensure component statements are sufficient to provide coverage </report>
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $immersiveProfile"      role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='Immersive', ensure component statements are sufficient to provide coverage </report>
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $interactiveProfile"    role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='Interactive', ensure component statements are sufficient to provide coverage </report>
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $cadInterchangeProfile" role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='CADInterchange', ensure component statements are sufficient to provide coverage </report>
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $interchangeProfile"    role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='Interactive', ensure component statements are sufficient to provide coverage </report>
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $coreProfile"           role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='Core', ensure component statements are sufficient to provide coverage </report>
      
      <!-- compare declared profile to measured profile -->
      <assert test="
           (@profile='Full')  or
          ((@profile='Immersive')                     and ($coreProfile or $interchangeProfile or $interactiveProfile or $immersiveProfile)) or
          ((@profile='Interactive')                   and ($coreProfile or $interchangeProfile or $interactiveProfile)) or
          ((@profile='Immersive') and
           (/X3D/head/component[@name='CADGeometry']) and ($coreProfile or $cadInterchangeProfile)) or
          ((@profile='CADInterchange')                and ($coreProfile or $cadInterchangeProfile)) or
          ((@profile='Interchange')                   and ($coreProfile or $interchangeProfile)) or
          ((@profile='Core')                          and ($coreProfile)) or
           ($profileLegal and /X3D/head/component)"
        role="error">&lt;X3D profile='<value-of select="@profile"/>'&gt; doesn't match contained nodes, increase profile or add needed &lt;component/&gt; definition(s) </assert>
      <!-- note parent scene profile must be equal or greater than Inline child scene profile, so those possibilities are allowed without report -->
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $fullProfile"           role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='Full' </report>
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $immersiveProfile"      role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='Immersive' </report>
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $interactiveProfile"    role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='Interactive' </report>
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $cadInterchangeProfile" role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='CADInterchange' </report>
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $interchangeProfile"    role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='Interchange' </report>
      <report test="$profileLegal and not($profileMatch) and not(/X3D/head/component) and $coreProfile"           role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined, but nodes in scene have actual profile='Core' </report>
      <report test="$profileLegal and (//Inline) and not($fullProfile)" role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; is defined satisfactorily for this scene, but ensure that child Inline scenes do not exceed this profile/component combination since a parent scene must have an equal or higher profile/component combination </report>
      <report test="not($profileLegal) and $fullProfile"           role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; has illegal value, actual profile='Full' </report>
      <report test="not($profileLegal) and $immersiveProfile"      role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; has illegal value, actual profile='Immersive' </report>
      <report test="not($profileLegal) and $interactiveProfile"    role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; has illegal value, actual profile='Interactive' </report>
      <report test="not($profileLegal) and $cadInterchangeProfile" role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; has illegal value, actual profile='CADInterchange' </report>
      <report test="not($profileLegal) and $interchangeProfile"    role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; has illegal value, actual profile='Interchange' </report>
      <report test="not($profileLegal) and $coreProfile"           role="info">&lt;X3D profile='<value-of select='@profile'/>'&gt; has illegal value, actual profile='Core' </report>
    </rule>
    
    <!-- ========= Wildcard (default) node tests: common miscapitalization and spelling errors ==========
    Important: this rule must appear last, in order to ensure that all other rules (for correctly named X3D nodes) fire first!
    -->
    <rule id="wildcardName" context="*">
      <extends rule="DEFtests"/>
      <extends rule="elementNameUnrecognized"/>
      <!-- Debug statement: set test="true()" to enable, test="false()" to disable -->
      <report test="false()" role="diagnostic">wildcardName checks for <name/> complete (no other rule found) </report>
    </rule>
   
    <rule id="elementNameUnrecognized" abstract="true">
      <!-- Any valid node must have a separate rule to trap it, otherwise this "unrecognized" rule will fire. -->
      <!-- Always include this initial report in case no other spell-check rule fires. -->
      <report test="true()" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; not handled correctly by X3D schematron rule, or else node name has unrecognized spelling and may fail X3D DTD/Schema validation... </report>
      <!-- can test using lower-case for generality since properly spelled node names should have been caught already by preceding rules -->
      <report test="(contains(local-name(),'2d'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be 2D (rather than 2d) for <name/> </report>
      <report test="(contains(local-name(),'3d'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be 3D (rather than 3d) for <name/> </report>
      <report test="(contains(local-name(),'4d'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be 4D (rather than 4d) for <name/> </report>
      <report test="(contains(lower-case(local-name()),'cad'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should start with CAD (rather than Cad) for <name/> </report>
      <report test="(contains(lower-case(local-name()),'polyLine'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be Polyline (rather than <name/>) </report>
      <report test="(starts-with(lower-case(local-name()),'arcclose'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be ArcClose2D (rather than <name/>) </report>
      <report test="(starts-with(lower-case(local-name()),'disentity'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should start with <emph>DISEntity</emph> (rather than <name/>) </report>
      <report test="(starts-with(lower-case(local-name()),'geo'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should start with <emph>Geo</emph> (rather than <name/>) </report>
      <report test="(starts-with(lower-case(local-name()),'hanim') or starts-with(lower-case(local-name()),'h-anim'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should start with <emph>HAnim</emph> (rather than <name/>) </report>
      <report test="(starts-with(lower-case(local-name()),'metadata'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should start with <emph>Metadata</emph> (rather than <name/>) </report>
      <report test="(starts-with(lower-case(local-name()),'nurbs'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should start with <emph>Nurbs</emph> (rather than <name/>) </report>
      <report test="(starts-with(lower-case(local-name()),'polyline'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be <emph>Polyline</emph> (rather than <name/>) </report>
      <report test="(starts-with(lower-case(local-name()),'polypoint'))" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be <emph>Polypoint2D</emph> (rather than <name/>) </report>
      <report test="not(local-name()='ClipPlane') and ((lower-case(local-name())='clipplane') or (lower-case(local-name())='clippingplane') or (lower-case(local-name())='cliplane'))" role="error">&lt;<name/> node name spelling is incorrect, should be <emph>ClipPlane</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='connect')" role="error">&lt;<name/>statement name capitalization is incorrect, should be <emph>connect</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='export')" role="error">&lt;<name/>statement name capitalization is incorrect, should be<emph>EXPORT</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='import')" role="error">&lt;<name/>statement name capitalization is incorrect, should be <emph>IMPORT</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='is')" role="error">&lt;<name/>statement name capitalization is incorrect, should be <emph>IS</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='geolod')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be <emph>GeoLOD</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='lod')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be <emph>LOD</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='navigationinfo') or (lower-case(local-name())='navinfo')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name spelling is incorrect, should be <emph>NavigationInfo</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='orthoviewpoint')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be <emph>OrthoViewpoint</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='viewpoint')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be <emph>Viewpoint</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='worldinfo')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name capitalization is incorrect, should be <emph>WorldInfo</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='matrix3dvertexattribute')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name spelling is incorrect, should be <emph>Matrix3VertexAttribute</emph> (rather than <name/>) </report>
      <report test="(lower-case(local-name())='matrix4dvertexattribute')" role="error">&lt;<name/> DEF='<value-of select='@DEF'/>'/&gt; node name spelling is incorrect, should be <emph>Matrix4VertexAttribute</emph> (rather than <name/>) </report>
    </rule>

    <!-- =========  ========== -->
  </pattern>

  <!-- not used
  <diagnostics>
    <diagnostic id="measuredProfile">diagnostic:  $fullProfile=<value-of select='$fullProfile'/>, $immersiveProfile=<value-of select='$immersiveProfile'/>, $interactiveProfile=<value-of select='$interactiveProfile'/>, $cadInterchangeProfile=<value-of select='$cadInterchangeProfile'/>, $interchangeProfile=<value-of select='$interchangeProfile'/>, $coreProfile=<value-of select='$coreProfile'/></diagnostic>
   
    error, results in empty string:
    <diagnostic id="DEFdiagnostic">&NodeDEFname;</diagnostic>

  </diagnostics>
  -->

</schema>
