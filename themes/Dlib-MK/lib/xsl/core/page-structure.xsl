<!--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

-->
<!--
    Main structure of the page, determines where
    header, footer, body, navigation are structurally rendered.
    Rendering of the header, footer, trail and alerts

    Author: art.lowel at atmire.com
    Author: lieven.droogmans at atmire.com
    Author: ben at atmire.com
    Author: Alexey Maslov

-->
<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
    xmlns:dri="http://di.tamu.edu/DRI/1.0/"
    xmlns:mets="http://www.loc.gov/METS/"
    xmlns:xlink="http://www.w3.org/TR/xlink/"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:confman="org.dspace.core.ConfigurationManager"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="i18n dri mets xlink xsl dim xhtml mods dc confman">
    <xsl:output indent="yes"/>
    <!--
        Requested Page URI. Some functions may alter behavior of processing depending if URI matches a pattern.
        Specifically, adding a static page will need to override the DRI, to directly add content.
    -->
    <xsl:variable name="request-uri" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']"/>
    <!--
        The starting point of any XSL processing is matching the root element. In DRI the root element is document,
        which contains a version attribute and three top level elements: body, options, meta (in that order).

        This template creates the html document, giving it a head and body. A title and the CSS style reference
        are placed in the html head, while the body is further split into several divs. The top-level div
        directly under html body is called "ds-main". It is further subdivided into:
            "ds-header"  - the header div containing title, subtitle, trail and other front matter
            "ds-body"    - the div containing all the content of the page; built from the contents of dri:body
            "ds-options" - the div with all the navigation and actions; built from the contents of dri:options
            "ds-footer"  - optional footer div, containing misc information

        The order in which the top level divisions appear may have some impact on the design of CSS and the
        final appearance of the DSpace page. While the layout of the DRI schema does favor the above div
        arrangement, nothing is preventing the designer from changing them around or adding new ones by
        overriding the dri:document template.
    -->
    <xsl:template match="dri:document">
        <html class="no-js">
            <!-- First of all, build the HTML head element -->
            <xsl:call-template name="buildHead"/>
            <!-- Then proceed to the body -->
            <!--paulirish.com/2008/conditional-stylesheets-vs-css-hacks-answer-neither/-->
            <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 7 ]&gt; &lt;body class="ie6"&gt; &lt;![endif]--&gt;
                &lt;!--[if IE 7 ]&gt;    &lt;body class="ie7"&gt; &lt;![endif]--&gt;
                &lt;!--[if IE 8 ]&gt;    &lt;body class="ie8"&gt; &lt;![endif]--&gt;
                &lt;!--[if IE 9 ]&gt;    &lt;body class="ie9"&gt; &lt;![endif]--&gt;
                &lt;!--[if (gt IE 9)|!(IE)]&gt;&lt;!--&gt;&lt;body&gt;&lt;!--&lt;![endif]--&gt;</xsl:text>
            <xsl:choose>
              <xsl:when test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='framing'][@qualifier='popup']">
                <xsl:apply-templates select="dri:body/*"/>
              </xsl:when>
                  <xsl:otherwise>
                    <div id="ds-main">
                        <!--The header div, complete with title, subtitle and other junk-->
                        <xsl:call-template name="buildHeader"/>
                        <!--The trail is built by applying a template over pageMeta's trail children. -->
                        <xsl:call-template name="buildTrail"/>
                        <!--javascript-disabled warning, will be invisible if javascript is enabled-->
                        <div id="no-js-warning-wrapper" class="hidden">
                            <div id="no-js-warning">
                                <div class="notice failure">
                                    <xsl:text>JavaScript is disabled for your browser. Some features of this site may not work without it.</xsl:text>
                                </div>
                            </div>
                        </div>
                        <!--ds-content is a groups ds-body and the navigation together and used to put the clearfix on, center, etc.
                            ds-content-wrapper is necessary for IE6 to allow it to center the page content-->
                        <div id="ds-content-wrapper">
                            <div id="ds-content" class="clearfix">
                                <!--
                               Goes over the document tag's children elements: body, options, meta. The body template
                               generates the ds-body div that contains all the content. The options template generates
                               the ds-options div that contains the navigation and action options available to the
                               user. The meta element is ignored since its contents are not processed directly, but
                               instead referenced from the different points in the document. -->
                                <xsl:apply-templates/>
                            </div>
                        </div>
                        <div id="otkrij-wrapper">
                            <xsl:call-template name="buildOtkrij"/>
                        </div>
                        <!--
                            The footer div, dropping whatever extra information is needed on the page. It will
                            most likely be something similar in structure to the currently given example. -->
                        <xsl:call-template name="buildFooter"/>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
                <!-- Javascript at the bottom for fast page loading -->
              <xsl:call-template name="addJavascript"/>
            <xsl:text disable-output-escaping="yes">&lt;/body&gt;</xsl:text>
        </html>
    </xsl:template>
        <!-- The HTML head element contains references to CSS as well as embedded JavaScript code. Most of this
        information is either user-provided bits of post-processing (as in the case of the JavaScript), or
        references to stylesheets pulled directly from the pageMeta element. -->
    <!-- Hide Homepage Search box -->
    <xsl:template name="disable_front-page-search" match="dri:div[@id='aspect.discovery.SiteViewer.div.front-page-search']">
    </xsl:template>
    <!-- Hide Homepage Community list -->
    <xsl:template name="hide_homepage_community-list" match="dri:div[@id='aspect.artifactbrowser.CommunityBrowser.div.comunity-browser']">
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI']/text()">
            <xsl:apply-templates />
        </xsl:if>
    </xsl:template>
    <xsl:template name="buildHead">
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
            <!-- Always force latest IE rendering engine (even in intranet) & Chrome Frame -->
            <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
            <!--  Mobile Viewport Fix
                  j.mp/mobileviewport & davidbcalhoun.com/2010/viewport-metatag
            device-width : Occupy full width of the screen in its current orientation
            initial-scale = 1.0 retains dimensions instead of zooming out if page height > device height
            maximum-scale = 1.0 retains dimensions instead of zooming in if page width < device width
            -->
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
            <link rel="shortcut icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                    <xsl:text>/images/favicon.ico</xsl:text>
                </xsl:attribute>
            </link>
            <link rel="apple-touch-icon">
                <xsl:attribute name="href">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                    <xsl:text>/images/apple-touch-icon.png</xsl:text>
                </xsl:attribute>
            </link>
            <meta name="Generator">
              <xsl:attribute name="content">
                <xsl:text>DSpace</xsl:text>
                <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='dspace'][@qualifier='version']"/>
                </xsl:if>
              </xsl:attribute>
            </meta>
            <!-- Add stylesheets -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='stylesheet']">
                <link rel="stylesheet" type="text/css">
                    <xsl:attribute name="media">
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/themes/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>
            <link href='http://fonts.googleapis.com/css?family=Ubuntu:400,500&amp;subset=latin,cyrillic-ext' rel='stylesheet' type='text/css'/>
            <!-- Add syndication feeds -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='feed']">
                <link rel="alternate" type="application">
                    <xsl:attribute name="type">
                        <xsl:text>application/</xsl:text>
                        <xsl:value-of select="@qualifier"/>
                    </xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                </link>
            </xsl:for-each>
            <!--  Add OpenSearch auto-discovery link -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']">
                <link rel="search" type="application/opensearchdescription+xml">
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='scheme']"/>
                        <xsl:text>://</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverName']"/>
                        <xsl:text>:</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='serverPort']"/>
                        <xsl:value-of select="$context-path"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='autolink']"/>
                    </xsl:attribute>
                    <xsl:attribute name="title" >
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='opensearch'][@qualifier='shortName']"/>
                    </xsl:attribute>
                </link>
            </xsl:if>
            <xsl:text disable-output-escaping="yes">&lt;!--[if lte IE 9 ]&gt; 
                &lt;https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js&gt; &lt;/script&gt;
                &lt;https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js&gt; &lt;/script&gt;&lt;![endif]--&gt;</xsl:text>
            <script type="text/javascript">
                //Clear default text of empty text areas on focus
                function tFocus(element)
                {
                    if (element.value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){element.value='';}
                }
                //Clear default text of empty text areas on submit
                function tSubmit(form)
                {
                    var defaultedElements = document.getElementsByTagName("textarea");
                        for (var i=0; i != defaultedElements.length; i++){
                        if (defaultedElements[i].value == '<i18n:text>xmlui.dri2xhtml.default.textarea.value</i18n:text>'){
                            defaultedElements[i].value='';}}
                }
                //Disable pressing 'enter' key to submit a form (otherwise pressing 'enter' causes a submission to start over)
                function disableEnterKey(e)
                {
                    var key;
                    if(window.event)
                        key = window.event.keyCode;     //Internet Explorer
                        else
                        key = e.which;     //Firefox and Netscape
                        if(key == 13)  //if "Enter" pressed, then disable!
                            return false;
                        else
                            return true;
                }
                function FnArray()
                {
                    this.funcs = new Array;
                }
                FnArray.prototype.add = function(f)
                {
                    if( typeof f!= "function" )
                        {
                            f = new Function(f);
                        }
                            this.funcs[this.funcs.length] = f;
                };
                FnArray.prototype.execute = function()
                    {
                        for( var i=0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> this.funcs.length; i++ )
                    {
                        this.funcs[i]();
                    }
                };
                var runAfterJSImports = new FnArray();
            </script>
            <!-- Add the title in -->
            <xsl:variable name="page_title" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']" />
            <title>
                <xsl:choose>
                        <xsl:when test="starts-with($request-uri, 'page/about')">
                                <xsl:text>About This Repository</xsl:text>
                        </xsl:when>
                        <xsl:when test="starts-with($request-uri, 'page/faq')">
                                <xsl:text>DSpace Help</xsl:text>
                        </xsl:when>
                        <xsl:when test="not($page_title)">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:when>
                        <xsl:when test="$page_title = ''">
                            <i18n:text>xmlui.dri2xhtml.METS-1.0.no-title</i18n:text>
                        </xsl:when>
                        <xsl:otherwise>
                                <xsl:copy-of select="$page_title/node()" />
                        </xsl:otherwise>
                </xsl:choose>
            </title>
            <!-- Head metadata in item pages -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='xhtml_head_item']"
                              disable-output-escaping="yes"/>
            </xsl:if>

            <!-- Add all Google Scholar Metadata values -->
            <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[substring(@element, 1, 9) = 'citation_']">
                <meta name="{@element}" content="{.}"></meta>
            </xsl:for-each>
        </head>
    </xsl:template>
    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various
        placeholders for header images -->
    <xsl:template name="buildHeader">
        <div id="ds-header-wrapper">
            <div id="ds-header" class="clearfix">
                <div id="mobile-header">
                    <a id="l-menu" href="#l-menu"><span class="icon icon-reorder">&#160;</span></a>
                </div>
                <a id="ds-header-logo-link">
                    <xsl:attribute name="href">
                        <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/</xsl:text>
                    </xsl:attribute>
                    <span id="ds-header-logo">&#160;</span>
                    <span id="ds-header-logo-text">
                       <i18n:text>xmlui.dri2xhtml.structural.head-subtitle</i18n:text>
                    </span>
                </a>
                <div id="mobile-header">
                    <a id="r-menu" href="#r-menu"><span class="icon icon-gear">&#160;</span></a>
                </div>
                <h1 class="pagetitle visuallyhidden">
                    <xsl:choose>
                        <!-- protection against an empty page title -->
                        <xsl:when test="not(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title'])">
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='title']/node()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </h1>
                <div id="ds-user-box">
                    <ul id="nav">
                        <li><a href="/">Home</a></li>
                        <li><a href="/page/about">About Us</a></li>
                        <li><a href="/recent-submissions">Latetst Items</a></li>
                        <li><a href="/page/faq">Help</a></li>
                        <li><a href="/contact">Contact</a></li>
                    </ul>
                </div>                
                <xsl:call-template name="languageSelection" />                
            </div>
        </div>
    </xsl:template>
    <!-- The header (distinct from the HTML head element) contains the title, subtitle, login box and various placeholders for header images -->
    <xsl:template name="buildTrail">
        <div id="ds-trail-wrapper">
            <div id="ds-trail">
                <ul>
                    <xsl:choose>
                        <xsl:when test="starts-with($request-uri, 'page/about')">
                             <xsl:text>About This Repository</xsl:text>
                        </xsl:when>
                        <xsl:when test="starts-with($request-uri, 'page/faq')">
                             <xsl:text>DSpace Help</xsl:text>
                        </xsl:when>
                        <xsl:when test="count(/dri:document/dri:meta/dri:pageMeta/dri:trail) = 0">
                            <li class="ds-trail-link first-link">-</li>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="/dri:document/dri:meta/dri:pageMeta/dri:trail"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </ul>
                <div id="ds-search-option">
                    <form id="ds-search-form" method="post">
                        <xsl:attribute name="action">
                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                        </xsl:attribute>
                        <fieldset>
                            <input id="search-glaven" class="ds-text-field " type="text">
                                <xsl:attribute name="name">
                                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='queryField']"/>
                                </xsl:attribute>
                            </input>
                            <input class="ds-button-field search-icon malo" name="submit" type="submit" i18n:attr="value" value="xmlui.general.go">
                                    <xsl:attribute name="onclick">
                                    <xsl:text>
                                        var radio = document.getElementById(&quot;ds-search-form-scope-container&quot;);
                                           if (radio != undefined &amp;&amp; radio.checked)
                                        {
                                        var form = document.getElementById(&quot;ds-search-form&quot;);
                                        form.action=
                                    </xsl:text>
                                    <xsl:text>&quot;</xsl:text>
                                    <xsl:value-of
                                        select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath']"/>
                                    <xsl:text>/handle/&quot; + radio.value + &quot;</xsl:text>
                                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='search'][@qualifier='simpleURL']"/>
                                    <xsl:text>&quot; ; </xsl:text>
                                    <xsl:text>
                                        }
                                    </xsl:text>
                                    </xsl:attribute>
                            </input>
                        </fieldset>
                    </form>
                </div>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="dri:trail">
        <!--put an arrow between the parts of the trail-->
        <xsl:if test="position()>1">
            <li class="ds-trail-arrow">
                <xsl:text>&#8594;</xsl:text>
            </li>
        </xsl:if>
        <li>
            <xsl:attribute name="class">
                <xsl:text>ds-trail-link </xsl:text>
                <xsl:if test="position()=1">
                    <xsl:text>first-link </xsl:text>
                </xsl:if>
                <xsl:if test="position()=last()">
                    <xsl:text>last-link</xsl:text>
                </xsl:if>
            </xsl:attribute>
            <!-- Determine whether we are dealing with a link or plain text trail link -->
            <xsl:choose>
                <xsl:when test="./@target">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="./@target"/>
                        </xsl:attribute>
                        <xsl:apply-templates />
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>
    <xsl:template name="cc-license">
        <xsl:param name="metadataURL"/>
        <xsl:variable name="externalMetadataURL">
            <xsl:text>cocoon:/</xsl:text>
            <xsl:value-of select="$metadataURL"/>
            <xsl:text>?sections=dmdSec,fileSec&amp;fileGrpTypes=THUMBNAIL</xsl:text>
        </xsl:variable>
        <xsl:variable name="ccLicenseName"
                      select="document($externalMetadataURL)//dim:field[@element='rights']"
                      />
        <xsl:variable name="ccLicenseUri"
                      select="document($externalMetadataURL)//dim:field[@element='rights'][@qualifier='uri']"
                      />
        <xsl:variable name="handleUri">
                    <xsl:for-each select="document($externalMetadataURL)//dim:field[@element='identifier' and @qualifier='uri']">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:copy-of select="./node()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="./node()"/>
                        </a>
                        <xsl:if test="count(following-sibling::dim:field[@element='identifier' and @qualifier='uri']) != 0">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                </xsl:for-each>
        </xsl:variable>
   <xsl:if test="$ccLicenseName and $ccLicenseUri and contains($ccLicenseUri, 'creativecommons')">
        <div about="{$handleUri}" class="clearfix">
            <xsl:attribute name="style">
                <xsl:text>margin:0em 2em 0em 2em; padding-bottom:0em;</xsl:text>
            </xsl:attribute>
            <a rel="license"
                href="{$ccLicenseUri}"
                alt="{$ccLicenseName}"
                title="{$ccLicenseName}"
                >
                <xsl:call-template name="cc-logo">
                    <xsl:with-param name="ccLicenseName" select="$ccLicenseName"/>
                    <xsl:with-param name="ccLicenseUri" select="$ccLicenseUri"/>
                </xsl:call-template>
            </a>
            <span>
                <xsl:attribute name="style">
                    <xsl:text>vertical-align:middle; text-indent:0 !important;</xsl:text>
                </xsl:attribute>
                <i18n:text>xmlui.dri2xhtml.METS-1.0.cc-license-text</i18n:text>
                <xsl:value-of select="$ccLicenseName"/>
            </span>
        </div>
        </xsl:if>
    </xsl:template>
    <xsl:template name="cc-logo">
        <xsl:param name="ccLicenseName"/>
        <xsl:param name="ccLicenseUri"/>
        <xsl:variable name="ccLogo">
             <xsl:choose>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by/')">
                       <xsl:value-of select="'cc-by.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-sa/')">
                       <xsl:value-of select="'cc-by-sa.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nd/')">
                       <xsl:value-of select="'cc-by-nd.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc/')">
                       <xsl:value-of select="'cc-by-nc.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc-sa/')">
                       <xsl:value-of select="'cc-by-nc-sa.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/licenses/by-nc-nd/')">
                       <xsl:value-of select="'cc-by-nc-nd.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/publicdomain/zero/')">
                       <xsl:value-of select="'cc-zero.png'" />
                  </xsl:when>
                  <xsl:when test="starts-with($ccLicenseUri,
                                           'http://creativecommons.org/publicdomain/mark/')">
                       <xsl:value-of select="'cc-mark.png'" />
                  </xsl:when>
                  <xsl:otherwise>
                       <xsl:value-of select="'cc-generic.png'" />
                  </xsl:otherwise>
             </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ccLogoImgSrc">
            <xsl:value-of select="$theme-path"/>
            <xsl:text>/images/creativecommons/</xsl:text>
            <xsl:value-of select="$ccLogo"/>
        </xsl:variable>
        <img>
             <xsl:attribute name="src">
                <xsl:value-of select="$ccLogoImgSrc"/>
             </xsl:attribute>
             <xsl:attribute name="alt">
                 <xsl:value-of select="$ccLicenseName"/>
             </xsl:attribute>
             <xsl:attribute name="style">
                 <xsl:text>float:left; margin:0em 1em 0em 0em; border:none;</xsl:text>
             </xsl:attribute>
        </img>
    </xsl:template>
    <!-- Discovery template -->
    <xsl:template name="buildOtkrij">
        <div id="otkrij" class="clearfix">
            <ul>
                <xsl:apply-templates select="dri:options/dri:list[@id='aspect.discovery.Navigation.list.discovery']" mode="nested"/>
            </ul>
        </div>
    </xsl:template>
    <!-- Like the header, the footer contains various miscellaneous text, links, and image placeholders -->
    <xsl:template name="buildFooter">
        <div id="ds-footer-wrapper">
            <div id="ds-footer">
                <div id="ds-footer-links">
                    <a href="http://www.dspace.org/" target="_blank">DSpace software</a> copyright&#160;&#169;&#160;2002-2013&#160; <a href="http://www.duraspace.org/" target="_blank">Duraspace</a>
                </div>
                <!--Invisible link to HTML sitemap (for search engines) -->
                <a class="hidden">
                    <xsl:attribute name="href">
                        <xsl:value-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                        <xsl:text>/htmlmap</xsl:text>
                    </xsl:attribute>
                    <xsl:text>&#160;</xsl:text>
                </a>
            </div>
        </div>
    </xsl:template>
<!--
        The meta, body, options elements; the three top-level elements in the schema
-->
    <!--
        The template to handle the dri:body element. It simply creates the ds-body div and applies
        templates of the body's child elements (which consists entirely of dri:div tags).
    -->
    <xsl:template match="dri:body">
        <div id="ds-body">
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
                <div id="ds-system-wide-alert">
                    <p>
                        <xsl:copy-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()"/>
                    </p>
                </div>
            </xsl:if>
            <!-- Check for the custom pages -->
            <xsl:choose>
                <xsl:when test="starts-with($request-uri, 'page/about')">
                    <div>
                        <h1>About This Repository</h1>
                        <div class="video-container">
                        <xsl:element name="iframe">
                            <xsl:attribute name="class">cf</xsl:attribute>  
                            <xsl:attribute name="width">798</xsl:attribute>
                            <xsl:attribute name="height">449</xsl:attribute>
                            <xsl:attribute name="src">http://www.youtube.com/embed/SvLlyXrF6kY</xsl:attribute>
                            <xsl:attribute name="frameborder">0</xsl:attribute>
                            <xsl:comment/><!-- avoid empty tag value that breaks the html-->
                        </xsl:element>
                        </div>
                        <p>To add your own content to this page, edit webapps/xmlui/themes/Mirage2/lib/xsl/core/page-structure.xsl and add your own content to the title, trail, and body. If you wish to add additional pages, you will need to create an additional xsl:when block and match the request-uri to whatever page you are adding. Currently, static pages created through altering XSL are only available under the URI prefix of page/.</p>
                    </div>
                </xsl:when>
                <xsl:when test="starts-with($request-uri, 'page/faq')">
                    <h1>DSpace Help</h1>
                    <p>DSpace captures, distributes and preserves digital research products. Here you can find articles, working papers, preprints, technical reports, conference papers and data sets in various digital formats. Content grows daily as new communities and collections are added to DSpace.</p>
                    <p>The DSpace content is organized around Communities which can correspond to administrative entities such as schools, departments, labs and research centers. Within each community there can be an unlimited number subcommunities and an unlimited number of collections. Each collection may contain an unlimited number of items.</p>
                    <div id="accordion">
                        <h2>BROWSE</h2>
                        <div>
                            <p><strong>Browse</strong> allows you to go through a list of items in some specified order:</p>
                            <p><strong>Browse by Community/Collection</strong> takes you through the communities in alphabetical 
                            order and allows you to see the subcommunities and collections within each community.</p>
                            <p><strong>Browse by Title</strong> allows you to move through an alphabetical list of all titles of items in DSpace.</p>
                            <p><strong>Browse by Author</strong> allows you to move through an alphabetical list of all authors of items in DSpace.</p>
                            <p><strong>Browse by Subject </strong>allows you to move through an alphabetical list of subjects assigned to items in DSpace.</p>
                            <p><strong>Browse by Date </strong>allows you to move through a list of all items in DSpace in reverse chronological order.</p>
                            <p><strong>You may sign on to the system if you:</strong> </p>
                            <ul>
                                <li>wish to subscribe to a collection and receive e-mail updates when new items are added</li>
                                <li>wish to go to the "My DSpace" page that tracks your subscriptions and other interactions with DSpace requiring authorization (if you are a submitter for a collection, for instance.)</li>
                              <li>wish to edit your profile</li>
                            </ul>
                            <p><strong>Submit</strong> is the DSpace unction that enables users to add an item to DSpace. The process of submission 
                              includes filling out information about the item on a metadata form and uploading the file(s) comprising the digital item. Each community sets its own submission policy.</p>
                            <p><strong>My DSpace</strong> is a personalpage that is maintained for each member. This page can contain a list of items that are in the submission process for a particular member, or a task list of items that need attention such as editing, reviewing, or checking. In the future this page will also maintain information about personal services offered by DSpace, such as e-mail notification when new items are added to a collection.</p>
                            <p><strong>Edit Profile</strong> allows you to change your password.</p>
                            <p><strong>About</strong> takes you to information about the DSpace project and its development.</p>
                        </div>
                        <h2>SEARCH</h2>
                        <div>
                            <p>To search all of DSpace, use the yellow search box at the top of the navigation bar on the left (or the search box in the middle of the home page)</p>
                            <p style="text-align:center"> <img src="/static/icons/searchtop.gif" alt="Search Box" width="119" height="53" /></p>
                            <p> To limit your search to a specific community or collection, navigate to that community or collection and use the search bar on that page.</p>
                            <p style="text-align:center"> <img src="/static/icons/searchother.gif" alt="Search Box" width="253" height="69" /></p>
                            <p>DSpace uses the<strong> Jakarta Lucene </strong>search engine. Here are some search hints:</p>
                            <h3>What is searched in the general keyword search (yellow box)</h3>
                            <p>The word(s) you enter in the search box will be searched against the title, author, subject abstract, series, sponsor and identifier fields of each item's record.</p>
                            <p>If your site is enabled for full-text searching, the text you entered will also be searched against the full text of all archived documents. For more information on full-text searching please contact your DSpace Administrator.</p>
                            <h3>What is not searched - Stop Words</h3>
                            <p>The search engine ignores certain words that occur frequently in English, but do not add value to the search. These are:</p>
                            <p style="text-align:center"> "a", "and", "are", "as", "at", "be", "but", "by" , "for", "if", "in", "into",</p>
                            <p style="text-align:center">"is", "it", "no", "not", "of", "on", "or", "such", "the", "to", "was"</p>
                            <h3>Truncation</h3>
                            <p>Use an asterisk (*) after a word stem to get all hits having words starting with that root, for example: </p>
                            <p><img src="/static/icons/search1.gif" alt="" width="75" height="27" />  will retrieve selects, selector, selectman, selecting.</p>
                            <h3>Stemming</h3>
                            <p>The search engine automatically expands words with common endings to includeplurals, past tenses ...etc.</p>
                            <h3>Phrase Searching</h3>
                            <p>To search using multiple words as a phrase, put quotation marks (") around the phrase.</p>
                            <p><img src="/static/icons/search8.jpg" alt=""  width="196" height="28" /></p>
                            <h3>Exact word match</h3>
                            <p>Put a plus (+) sign before a word if it MUST appear in the search result. For instance, in the following search the word "training" is optional, but the word "dog" must be in the result.</p>
                            <p><img src="/static/icons/search2.gif" alt=""  width="123" height="27" /></p>
                            <h3>Eliminate items with unwanted words</h3>
                            <p>Put a minus (-) sign before a word if it should not appear in the search results.Alternatively, you can use <strong>NOT</strong>. This can limit your search to eliminate unwanted hits. For instance, in the search</p>
                            <p><img src="/static/icons/search3.jpg" alt="" width="124" height="28" />    <img src="/static/icons/search4.jpg" alt="" width="136" height="28" /></p>
                            <p>you will get items containing the word "training", except those that also contain the word "cat".</p>
                            <h3>Boolean searching</h3>
                            <p>The following Boolean operators can be used to combine terms. Note that they must be CAPITALIZED!</p>
                            <p><strong>AND</strong> - to limit searches to find items containing all words or phrases combined with this operator, e.g.</p>
                            <p><img src="/static/icons/search5.jpg" alt="" width="124" height="28" /> will retrieve all items that contain BOTH the words "cats" and "dogs".</p>
                            <p><strong>OR</strong> - to enlarge searches to find items containing any of the words or phrases surrounding this operator</p>
                            <p><img src="/static/icons/search6.jpg" alt="" width="124" height="28" /> will retrieve all items that contain EITHER the words "cats" or "dogs".</p>
                            <p><strong>NOT - </strong>to exclude items containing the word following this operator, e.g.</p>
                            <p><img src="/static/icons/search4.jpg" alt="" width="136" height="28" />will retrieve all items that contain the word "training" EXCEPT those also containing the word "cat".</p>
                            <p>Parentheses can be used in the search query to group search terms into sets, and operators can then be applied to the whole set, e.g.</p>
                            <p><img src="/static/icons/search7.jpg" alt="" width="340" height="28" /></p>
                        </div>
                        <h2>ADVANCED SEARCH</h2>
                        <div>
                            <p>The advanced search page allows you to specify the fields you wish to search, and to combine these searches with the Boolean "and", "or" or "not".</p>
                            <p>You can restrict your search to a community by clicking on the arrow to the right of the top box. If you want your search to encompass all of DSpace, leave that box in the default position.</p>
                            <p>Then select the field to search in the left hand column and enter the word or phrase you are searching in the right hand column. You can select the Boolean operator to combine searches by clicking on the arrow to the right of the "AND" box.</p>
                        </div>
                        <h2>SUBJECT CATEGORY SEARCH</h2>
                        <div>
                            <p>A controlled vocabulary is a set of terms which form a dictionary of descriptions of particular types of content or subject matter. These are maintained by standards bodies in order to standardise the way that similar materials are categorised in archives.  This aids searching by increasing the likelihood that the relevant materials will be returned by the user's search.</p>
                            <p>Filtering the category list will remove from the list any terms which do not match the filter.  The remaining terms are any category or sub category which contains the filter term anywhere in the heirarchy.  Expanding each category will show you which terms (or sub terms) did match the filter.</p>
                            <p>To search the archive items by the subject category, check as many boxes next to the categories as necessary, before clicking "Search...". The search will return all items that either match the categories selected exactly, or which are categorised underneath a higher level category.  Clicking on the "+" next to the category will expand the tree to show you what refinements are available for your selected category.</p>
                        </div>
                        <h2>COMMUNITIES</h2>
                        <div>
                            <p>The DSpace content is organized around Communities which can correspond to administrative entities such as schools,  departments, labs and research centers. Within each community there can be an unlimited number subcommunities and an unlimited number of collections. Each collection may contain an unlimited number of items. This organization gives DSpace the flexibility to accommodate differing needs of communities by allowing them to</p>
                            <ul>
                                <li>Decide on policies such as:<br /> - - who contributes content<br /> - - whether there will be a review process<br /> - - who will have access</li>
                                <li> Determine workflow - reviewing, editing, metadata</li>
                                <li>Manage collections</li>
                            </ul>
                            <p>Each community has its own entry page displaying information, news and links reflecting the interests of that community, as well as a descriptive list of collections within the community.</p>
                        </div>
                        <h2>COLLECTIONS</h2>
                        <div>
                            <p>Communities can maintain an unlimited number of collections in DSpace. Collections can be organized around a topic, or by type of information (such as working papers or datasets) or by any other sorting method a community finds useful in organizing its digital items. Collections can have different policies and workflows.</p>
                            <p>Each DSpace collection has its own entry page displaying information, news and links reflecting the interests of users of that collection.</p>
                        </div>
                        <h2>SIGN ON TO DSPACE</h2>
                        <div>
                            <p>When you access an area of DSpace that requires authorization, the system will require you to log in. All users can register to become subscribers. Some restricted functions, such as content submission, require authorization from the community.</p>
                            <p>Before you log in for the first time, you will need to click on "register with DSpace" and follow the instructions. After that, you will need to enter your e-mail address and password in the log-in form that appears. Your e-mail address should include your username and domain name. It is not case sensitive.</p>
                            <p style="text-align:center">Example: moniker@mycorp.com</p>
                            <p>Type your password exactly as you entered it originally. It is case sensitive. Be sure to click on the "log in" button to continue.</p>
                        </div>
                        <h2>SUBMIT</h2>
                        <div>
                            <p>Stopping during the Submission Process:</p>
                            <p>At any point in the submission process you can stop and save your work for a later date by clicking on the "cancel/save" button at the bottom of the page. The data you have already entered will be stored until you come back to the submission, and you will be reminded on your "My DSpace" page that you have a submission in process. If somehow you accidentally exit from the submit process, you can always resume from your "My DSpace" page. You can also cancel your submission at any point.</p>
                            <h3>Choose Collection</h3>
                            <p>Progress Bar - Oval Buttons at Top of Page:</p>
                            <p>At the top of the submit pages you will find 7 oval buttons representing each step in the submission process. As you move through the process these ovals will change color. Once you have started you can also use these buttons to move back and forth within the submission process by clicking on them. You will not lose data by moving back and forth.</p>
                            <p><img src="/static/icons/progressbar.gif" alt="Progress Bar" width="698" height="39" /></p>
                            <p>Select Collection:</p>
                            <h3>Click on the arrow at the right of the drop-down box to see a list of Collections. Move your mouse to the collection into which you wish to add your item and click.</h3>
                            <p>(If you are denied permission to submit to the collection you choose, please contact your DSpace Administrator for more information.)</p>
                            <p>You must be authorized by a community to submit items to a collection. If you would like to submit an item to DSpace, but don't see an appropriate community, please contact your DSpace Administrator to find out how you can get your community set up in DSpace.</p>
                            <p>Click on the "next" button to proceed, or "cancel/save" button to stop and save or cancel your submission.</p>
                        </div>
                        <h2>SUBMIT: Describe Your Item - Page 1</h2>
                        <div>
                            <p>If you respond "yes" to any of the questions on this page, you will be presented with a modified input form tailored to capture extra information. Otherwise you will get the "regular" input form.</p>
                            <ul>
                                <li>* More than one title - Sometimes an item has more than one title, perhaps an abbreviation, acronym, or a title in another language. If this is the case, and you want this information captured, click in the "yes" box.</li>
                                <li>* Previously issued - New items that have NOT been previously published or distributed will be assigned an issue date by the system upon DSpace distribution. If you are entering older items that have already been distributed or published, click in the "yes" box. You will receive a form prompting you for several pieces of information relating to publication.</li>
                                <li>* Multiple files - An item can consist of more than one file in DSpace. A common example of this would be an HTML file with references to image files (such as JPG or GIF files). Another example of this would be an article supplemented with a video simulation and a data file. If you are submitting more than one file for this item, click in the "yes" box.</li>
                            </ul>
                            <p>Click on the "next" button to proceed, or "cancel/save" button to stop and save or cancel your submission.</p>
                        </div>
                        <h2>SUBMIT: Describe Your Item - Page 2</h2>
                        <div>
                            <p>The information you fill in on these two screens will form the metadata record that will enable users to retrieve your item using search engines. The richer the metadata, the more "findable" your item will be, so please take the time to fill in as many fields as are applicable to your item.</p>
                            <h3>Author:</h3>
                            <p>This can be a person, organization or service responsible for creating or contributing to the content of the item. By clicking on the "Add More" button you can add as many authors as needed.   Examples:</p>
                            <p style="text-align:center"><img src="/static/icons/author.gif" alt="Author submit" width="584" height="71" /></p>
                            <p style="text-align:center">If the author is an organization, use the last name input box for the organization name:</p>
                            <p style="text-align:center"><img src="/static/icons/corpauthor.gif" alt="author submit" width="575" height="66" /></p>
                            <h3>Title:</h3>
                            <p>Enter the full and proper name by which this item should be known. All DSpace items must have a title!</p>
                            <p style="text-align:center"><img src="/static/icons/finalTitle1.jpg" alt="title submit" width="392" height="62" /></p>
                            <h3>Other Title:</h3>
                            <p>(note - this input box appears only if you indicated on the first page that the item has more than one title.) If your item has a valid alternative title, for instance, a title in another language or an abbreviation, then enter it here. Example:</p>
                            <p style="text-align:center"><img src="/static/icons/othertitle.gif" alt="Other title" width="612" height="62" /></p>
                            <h3>Date of Issue:</h3>
                            <p>(note - this input box appears only if you indicated on the first page that the item has been previously published or distributed. If DSpace is the first means of distribution of this item, a date will be assigned by the system when the item becomes a part of the repository.)</p>
                            <p>If your item was previously published or made public, enter the date of that event here. If you don't know the month, leave the default "no month"; otherwise select a month from the drop-down box. If you don't know the exact day, leave that box empty.</p>
                            <p style="text-align:center"><img src="/static/icons/date.gif" alt="date of issue" width="471" height="53" /></p>
                            <h3>Publisher:</h3>
                            <p>(note - this input box appears only if you indicated on the first page that the item has been previously published or distributed.)</p>
                            <p>Enter the name of the publisher of this item.</p>
                            <p style="text-align:center"><img src="/static/icons/date.gif" alt="date of issue" width="471" height="53" /></p>
                            <h3>Citation:</h3>
                            <p>(note - this input box appears only if you indicated on the first page that the item has been previously published or distributed.)</p>
                            <p>Enter citation information for this item if it was a journal article or part of a larger work, such as a book chapter. For journal articles, include the journal title, volume number, date and paging. For book chapters, include the book title, place of publication, publisher name, date and paging.</p>
                            <h3>Series/Report No.:</h3>
                            <p>Some of the collections in DSpace are numbered series such as technical reports or working papers. If this collection falls into that category, then there should be a default value in the Series Name box which you should not change, but you will have to fill in the assigned number in the Report or Paper No. input box.  Examples:</p>
                            <p style="text-align:center"><img src="/static/icons/Series.gif" alt="Series" width="633" height="67" /></p>
                            <h3>Identifiers:</h3>
                            <p>If you know of a unique number or code that identifies this item in some system, please enter it here. Click on the arrow to the right of the input box, and select from one of the choices in the drop down menu. The choices refer to:
                                <ul>
                                    <li>Govt.doc # - Government Document Number - e.g. NASA SP 8084</li>
                                    <li>ISBN - International Standard Book Number - e.g. 0-1234-5678-9</li>
                                    <li>ISSN - International Standard Serial Number - e.g. 1234-5678</li>
                                    <li>ISMN - International Standard Music Number - e.g. M-53001-001-3</li>
                                    <li>URI - Universal Resource Identifier - e.g.. http://www.dspace.org/help/submit.html</li>
                                    <li>Other - An unique identifier assigned to the item using a system other than the above</li>
                                </ul>
                            </p>
                            <h3>Type:</h3>
                            <p>Select the type of work (or genre) that best fits your item. To select more than one value in the list, you may have to hold down the "ctrl" or "shift" key.</p>
                            <h3>Language:</h3>
                            <p>Select the language of the intellectual content of your item. If the default (English - United States) is not appropriate, click on the arrow on the right of the drop down box to see a list of languages commonly used for publications, e.g.</p>
                            <p style="text-align:center"><img src="/static/icons/finalLanguage1.jpg" alt="language" width="284" height="40" /></p>
                            <p>If your item is not a text document and language is not applicable as description, then select the N/A choice.</p>
                            <p>Click on the "next" button to proceed, or "cancel/save" button to stop and save or cancel your submission.</p>
                        </div>
                        <h2>SUBMIT: Describe Your Item - Page 3</h2>
                        <div>
                            <h3>Subject/Keywords:</h3>
                            <p>Please enter as many subject keywords as are appropriate to describe this item, from the general to the specific. The more words you provide, the more likely it is that users will find this item in their searches. Use one input box for each subject word or phrase. You can get more input boxes by clicking on the "add more" button. Examples:</p>
                            <p style="text-align:center"><img src="/static/icons/keywords.gif" alt="keywords" width="533" height="100" /></p>
                            <p>Your community may suggest the use of a specific vocabulary, taxonomy, or thesaurus. If this is the case, please select your subject words from that list. Future versions of DSpace will provide links to those lists.</p>
                            <h3>Abstract:</h3>
                            <p>You can either cut and paste an abstract into this box, or you can type in the abstract. There is no limit to the length of the abstract. We urge you to include an abstract for the convenience of end-users and to enhance search and retrieval capabilities.</p>
                            <h3>Sponsors:</h3>
                            <p>If your item is the product of sponsored research, you can provide information about the sponsor(s) here. This is a freeform field where you can enter any note you like. Example:</p>
                            <p style="text-align:center"><img src="/static/icons/sponsor.gif" alt="sponsor" width="542" height="110" /></p>
                            <h3>Description:</h3>
                            <p>Here you can enter any other information describing the item you are submitting or comments that may be of interest to users of the item.</p>
                            <p>Click on the "next" button to proceed, or "cancel/save" button to stop and save or cancel your submission.</p>
                        </div>
                        <h2>SUBMIT: Controlled Vocabulary</h2>
                        <div>
                            <p>A controlled vocabulary is a set of terms which form a dictionary of descriptions of particular types of content or subject matter. These are maintained by standards bodies in order to standardise the way that similar materials are categorised in archives.</p>
                            <p>Accurately categorising material using a controlled vocabulary increases the likelihood that relevant results will be returned to users when searching individual or multiple archives.</p>
                            <p>To enter a controlled vocabulary term in the form, select "Subject Categories" from underneath the input field. This will open a window containing the available vocabularies. You may filter the vocabulary lists as described above in order to find the terms most relevant to your submission. Once you have found the term that you wish to enter, simply click on it, and it will be automatically entered into the submission form and the popup window will close. You may add as many subject category terms as you like into the form. Use "Add More" on the right to generate more input boxes.</p>
                            <p>Filtering the category list will remove from the list any terms which do not match the filter. The remaining terms are any category or sub category which contains the filter term anywhere in the heirarchy. Expanding each category will show you which terms (or sub terms) did match the filter.</p>
                        </div>
                        <h2>SUBMIT: Upload a File</h2>
                        <div>
                            <p>There are two methods of entering the name of the file you wish to upload:</p>
                            <ol>
                                <li>Type the full path and file name into the input box and then click on the "next" button in the lower right hand corner of the screen.</li>
                                <li>Click on the "browse" button and a window showing your files will appear. You can navigate through your directories and folders until you find the correct file to upload. Double-click on the file name you wish to upload, and the name will be entered into the input box.</li>
                            </ol>
                            <p>Once the correct file name is in the input box, click on the "next" button to proceed.</p>
                            <h3>File Description</h3>
                            <p>If you specified at the beginning of the submit process that you had more than one file to upload for this item, you will see an input box marked "File Description". The information you provide here will help users to understand what information is in each file, for instance, "main article" or "images" or "computer program" or "data set". Enter file descriptions for each item, and click on the "next" button to proceed.</p>
                        </div>
                        <h2>SUBMIT: File Formats</h2>
                        <div>
                            <p>To properly archive and give access to a file, we need to know what format it is, for example "PDF", "HTML", or "Microsoft Word". If the system does not automatically recognize the format of the file you have uploaded, you will be asked to describe it. If the format of the file appears in the list offered, click on it and then on "Submit". If you can't see the format in the list, click on "format not in list" and describe the format in the text box lower down on the page. Be sure to give the name of the application you used to create the file and the version of that application, for example "Autodesk AutoCAD R20 for UNIX".</p>
                            <h3>Uploaded File</h3>
                            <p>After you have uploaded a file, check the information in the table to make sure it is correct. There are two further ways to verify that your files have been uploaded correctly:
                                <ul>
                                    <li>Click on the filename. This will download the file in a new browser window, so that you can check the contents.</li>
                                    <li>Compare the file checksum displayed here with the checksum you calculate.</li>
                                </ul>
                            </p>
                            <p><strong>If you're only uploading one file</strong>, click on "Next" when you're happy that the file has been uploaded correctly.</p>
                            <p><strong>If you're uploading more than one file</strong>, click on the "Add Another File" button (this will appear if you checked "The item consists of more than one file" on the "Submit: Describe Your Item" page). When you are satisfied that all files for this item have been successfully uploaded, click on the "Next" button.</p>
                            <p><strong>If you're uploading an HTML page with embedded files</strong>, click on the "Add Another File" button, and upload all files or bitstreams referenced in the html page. After all the are uploaded, in the column marked "Primary Bitstream", select the bitstream or file that is the index page or the top page for the web page. This will ensure that all of your embedded files will display properly on the HTML page. Then click on the "Next" button.</p>
                            <h3>Checksums</h3>
                            <p>DSpace generates an MD5 checksum for every file it stores; we use this checksum internally to verify the integrity of files over time (a file's checksum shouldn't change). You can use this checksum to be sure what we've received is indeed the file you've uploaded.</p>
                            <p>If you wish to verify the file using checksums, click "Show checksums" on the "Uploaded File" page. The DSpace-generated MD5 checksum for every file we've received from you will show to the right of the filename. You will then need to use a local program to generate your own checksum for these files, and verify that your results match ours. On most UNIX-like systems (including Mac OS X), use md5sum. For instance, type "md5sum MYFILE" for every file you want to check; the summary should print on your screen. For Windows machines, MD5 tools are freely available: try md5 (from <a href="http://www.fourmilab.ch/md5/" target="_blank">http://www.fourmilab.ch/md5/</a>), or md5sum, available via the textutils package in Cygwin (<a href="http://www.cygwin.com/" target="_blank">http://www.cygwin.com/</a>). All of these utilities will need to be run from a command-line, or terminal, window. The entire digest printed out when you run the md5 tool on your local copy of the file you're uploading should be exactly equal to what DSpace reports.</p>
                        </div>
                        <h2>SUBMIT: Verify Submission</h2>
                        <div>
                            <p>This page lets you review the information you have entered to describe the item. To correct or edit information, click on the corresponding button on the right, or use the oval buttons in the progress bar at the top of the page to move around the submission pages. When you are satisfied that the submission is in order, click on the "Next" button to continue.</p>
                            <p>Click on the "Cancel/Save" button to stop and save your data, or to cancel your submission.</p>
                        </div>
                        <h2>SUBMIT: License</h2>
                        <div>
                            <p>DSpace requires agreement to this non-exclusive distribution license before your item can appear on DSpace. Please read the license carefully. If you have any questions, please contact your DSpace Administrator.</p>
                        </div>
                        <h2>SUBMIT: Submission Complete</h2>
                        <div>
                            <p>Now that your submission has been successfully entered into the DSpace system, it will go through the workflow process designated for the collection to which you are submitting. Some collections require the submission to go through editing or review steps, while others may immediately accept the submission. You will receive e-mail notification as soon as your item has become a part of the collection, or if for some reason there is a problem with your submission. If you have questions about the workflow procedures for a particular collection, please contact the community responsible for the collection directly. You can check on the status of your submission by going to the My DSpace page.</p>
                        </div>
                        <h2>HANDLES</h2>
                        <div>
                            <p>When your item becomes a part of the DSpace repository it is assigned a persistent URL. This means that, unlike most URLs, this identifier will not have to be changed when the system migrates to new hardware, or when changes are made to the system. DSpace is committed to maintaining the integrity of this identifier so that you can safely use it to refer to your item when citing it in publications or other communications. Our persistent urls are registered with the <a href="http://www.handle.net/" target="_blank">Handle System</a>, a comprehensive system for assigning, managing, and resolving persistent identifiers, known as "handles," for digital objects and other resources on the Internet. The Handle System is administered by the <a href="http://www.cnri.reston.va.us/" target="_blank">Corporation for National Research Initiatives (CNRI)</a>, which undertakes, fosters, and promotes research in the public interest.</p>
                        </div>
                        <h2>MY DSPACE</h2>
                        <div>
                            <p>If you are an authorized DSpace submitter or supervisor, or if you are a staff member responsible for DSpace collection or metadata maintenance, you will have a My DSpace page. Here you will find:
                                <ul>
                                    <li>a list of your in-progress submissions - from this list you can resume the submission process where you left off, or you can remove the submission and cancel the item.</li>
                                    <li>a list of the submissions which you are supervising or collaborating on</li>
                                    <li>a list of submissions that are awaiting your action (if you have a collection workflow role).</li>
                                    <li>a link to a list of items that you have submitted and that have already been accepted into DSpace.</li>
                                </ul>
                            </p>
                        </div>
                        <h2>EDIT PROFILE</h2>
                        <div>
                            <p>This page allows you to change the information we have for you. You must be authenticated with your log-in to change any of your personal information.</p>
                        </div>
                        <h2>SUBSCRIBE TO E-MAIL ALERTS</h2>
                        <div>
                            <p>Users can subscribe to receive daily e-mail alerts of new items added to collections. Users may subscribe to as many collections as they wish. To subscribe:
                                <ul>
                                    <li>go to the DSpace registration page by clicking on the sign-on link in the navigation bar on the left of the home page</li>
                                    <li>fill out the registration form</li>
                                    <li>navigate to a collection for which you would like to receive e-mail alerts, and click on the "subscribe" button (repeat for other collections)</li>
                                    <li>navigate to a collection for which you would like to receive e-mail alerts, and click on the "subscribe" button (repeat for other collections)</li>
                                </ul>
                            </p>
                        </div>
                        <h2>FOR FURTHER ASSISTANCE...</h2>
                        <div>
                            <p>For help with using DSpace and questions about your specific site, please contact your DSpace Administrator.</p>
                            <p>For general information and news about DSpace, visit the <a href="http://www.dspace.org/" traget="_blank">DSpace Website</a>.</p>
                        </div>
                    </div>
                </xsl:when>
                <!-- Otherwise use default handling of body -->
                <xsl:otherwise>
                    <xsl:apply-templates />
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <!-- Currently the dri:meta element is not parsed directly. Instead, parts of it are referenced from inside
        other elements (like reference). The blank template below ends the execution of the meta branch -->
    <xsl:template match="dri:meta">
    </xsl:template>
    <!-- Meta's children: userMeta, pageMeta, objectMeta and repositoryMeta may or may not have templates of
        their own. This depends on the meta template implementation, which currently does not go this deep.
    <xsl:template match="dri:userMeta" />
    <xsl:template match="dri:pageMeta" />
    <xsl:template match="dri:objectMeta" />
    <xsl:template match="dri:repositoryMeta" />
    -->
    <xsl:template name="addJavascript">
        <xsl:variable name="jqueryVersion">
            <xsl:text>1.6.2</xsl:text>
        </xsl:variable>
        <xsl:variable name="protocol">
            <xsl:choose>
                <xsl:when test="starts-with(confman:getProperty('dspace.baseUrl'), 'https://')">
                    <xsl:text>https://</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>http://</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <script type="text/javascript" src="{concat($protocol, 'ajax.googleapis.com/ajax/libs/jquery/', $jqueryVersion ,'/jquery.min.js')}">&#160;</script>
        <xsl:variable name="localJQuerySrc">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
            <xsl:text>/static/js/jquery-</xsl:text>
            <xsl:value-of select="$jqueryVersion"/>
            <xsl:text>.min.js</xsl:text>
        </xsl:variable>
        <script type="text/javascript">
            <xsl:text disable-output-escaping="yes">!window.jQuery &amp;&amp; document.write('&lt;script type="text/javascript" src="</xsl:text><xsl:value-of
                select="$localJQuerySrc"/><xsl:text disable-output-escaping="yes">"&gt;&#160;&lt;\/script&gt;')</xsl:text>
        </script>
        <!-- Add theme javascipt  -->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='url']">
            <script type="text/javascript">
                <xsl:attribute name="src">
                    <xsl:value-of select="."/>
                </xsl:attribute>&#160;</script>
        </xsl:for-each>
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][not(@qualifier)]">
            <script type="text/javascript">
                <xsl:attribute name="src">
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                    <xsl:text>/themes/</xsl:text>
                    <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                    <xsl:text>/</xsl:text>
                    <xsl:value-of select="."/>
                </xsl:attribute>&#160;</script>
        </xsl:for-each>
        <script src="/static/js/plugins.js" type="text/javascript">&#160;</script>
        <!-- add "shared" javascript from static, path is relative to webapp root -->
        <xsl:for-each select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='javascript'][@qualifier='static']">
            <!--This is a dirty way of keeping the scriptaculous stuff from choice-support
            out of our theme without modifying the administrative and submission sitemaps.
            This is obviously not ideal, but adding those scripts in those sitemaps is far
            from ideal as well-->
            <xsl:choose>
                <xsl:when test="text() = 'static/js/choice-support.js'">
                    <script type="text/javascript">
                        <xsl:attribute name="src">
                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/themes/</xsl:text>
                            <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                            <xsl:text>/lib/js/choice-support.js</xsl:text>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
                <xsl:when test="not(starts-with(text(), 'static/js/scriptaculous'))">
                    <script type="text/javascript">
                        <xsl:attribute name="src">
                            <xsl:value-of
                                    select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                            <xsl:text>/</xsl:text>
                            <xsl:value-of select="."/>
                        </xsl:attribute>&#160;</script>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
        <!-- add setup JS code if this is a choices lookup page -->
        <xsl:if test="dri:body/dri:div[@n='lookup']">
          <xsl:call-template name="choiceLookupPopUpSetup"/>
        </xsl:if>
        <!--PNG Fix for IE6-->
        <xsl:text disable-output-escaping="yes">&lt;!--[if lt IE 7 ]&gt;</xsl:text>
        <script type="text/javascript">
            <xsl:attribute name="src">
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='contextPath'][not(@qualifier)]"/>
                <xsl:text>/themes/</xsl:text>
                <xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='theme'][@qualifier='path']"/>
                <xsl:text>/lib/js/DD_belatedPNG_0.0.8a.js?v=1</xsl:text>
            </xsl:attribute>&#160;</script>
        <script type="text/javascript">
            <xsl:text>DD_belatedPNG.fix('#ds-header-logo');DD_belatedPNG.fix('#ds-footer-logo');$.each($('img[src$=png]'), function() {DD_belatedPNG.fixPng(this);});</xsl:text>
        </script>
        <xsl:text disable-output-escaping="yes" >&lt;![endif]--&gt;</xsl:text>
        <script type="text/javascript">
            runAfterJSImports.execute();
        </script>
        <!-- Share this -->
        <script type="text/javascript">var switchTo5x=true;</script>
        <script type="text/javascript" src="http://w.sharethis.com/button/buttons.js">&#160;</script>
        <script type="text/javascript">stLight.options({publisher: "enter-your-number-here", onhover: false});</script>
        <!-- Add a google analytics script if the key is present -->
        <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']">
            <script type="text/javascript"><xsl:text>
                   var _gaq = _gaq || [];
                   _gaq.push(['_setAccount', '</xsl:text><xsl:value-of select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='google'][@qualifier='analytics']"/><xsl:text>']);
                   _gaq.push(['_trackPageview']);
                   (function() {
                       var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                       ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                       var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
                   })();
           </xsl:text></script>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
