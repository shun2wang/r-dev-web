<?xml version="1.0"?>

<!-- Copyright the Omegahat Project for Statistical Computing, 2000 -->
<!-- Author: Duncan Temple Lang -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
                xmlns:bib="http://www.bibliography.org"
                xmlns:c="http://www.bell-labs.com"
                xmlns:rs="http://www.omegahat.org/RS"
                version="1.0">

<xsl:include href="http://www.omegahat.org/XSL/article.xsl" />

<xsl:template match="cstruct">
 <b class="cstruct"><xsl:apply-templates/></b>
</xsl:template>

<xsl:template match="cvariable">
 <i class="cvariable"><xsl:apply-templates/></i>
</xsl:template>

<xsl:template match="ckeyword">
 <b class="ckeyword"><xsl:apply-templates/></b>
</xsl:template>

</xsl:stylesheet>
