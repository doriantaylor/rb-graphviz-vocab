require "graphviz/vocab/version"

require 'rest-client'
require 'stringio'
require 'tidy_ffi'
require 'nokogiri'
require 'uri'
require 'xml-mixup'

module GraphViz
  class Vocab

    private

    # the following stylesheet will further beautify the tidied
    # documentation fragments.
    XSLT = Nokogiri::XSLT.parse(<<-XSLT)
<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:html="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="html">

<xsl:output method="xml" indent="yes"/>

<xsl:template match="html:body">
<body><xsl:text>
</xsl:text>
<xsl:apply-templates select="html:p|html:table" mode="root-block"/>
<xsl:if test="not(html:p|html:table)">
<p><xsl:apply-templates/></p>
</xsl:if>
<xsl:text>
</xsl:text>
</body>
</xsl:template>

<xsl:template match="html:*" mode="root-block">
<xsl:variable name="prev-block" select="(preceding-sibling::html:p|preceding-sibling::html:table)[last()]"/>
<xsl:variable name="prev-inline" select="(preceding-sibling::node()[not(self::html:p|self::html:table)][not(following-sibling::*[generate-id() = generate-id($prev-block)])])"/>
<xsl:if test="count($prev-inline[self::*]) + string-length(normalize-space($prev-inline))">
<p>
<xsl:apply-templates select="$prev-inline"/>
</p><xsl:text>
</xsl:text>
</xsl:if>
<xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="html:table">
<table>
<xsl:apply-templates select="@*"/>
<xsl:choose>
  <xsl:when test="not(*[not(self::html:tr)])">
    <xsl:text>
</xsl:text>
    <tbody>
      <xsl:apply-templates/>
    </tbody><xsl:text>
</xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xsl:apply-templates/>
  </xsl:otherwise>
</xsl:choose>
</table><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="html:b">
<strong>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</strong>
</xsl:template>

<xsl:template match="html:i">
<em>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</em>
</xsl:template>

<xsl:template match="html:tt">
<code>
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</code>
</xsl:template>

<xsl:template match="text()[normalize-space() != '']">
<xsl:value-of select="translate(., '&#x9;&#xa;&#xd;', '   ')"/>
</xsl:template>

<xsl:template match="@*">
<xsl:attribute name="{name()}"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="html:*">
<xsl:element name="{local-name()}">
<xsl:apply-templates select="@*"/>
<xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
    XSLT

    # see the beginning of the infosrc/attrs file for this specification
    ATTR = /^\s*:\s*(?<name>.*?)
    \s*:\s*(?<uses>.*?)
    \s*:\s*(?<kind>.*?)
    (?:\s*:\s*(?<dflt>(?<=\s):|[^:]*?))?
    (?:\s*:\s*(?<minv>.*?))?
    (?:\s*;\s*(?<notes>.*?))?\s*$/x

    def read_graphviz_src io
      io = StringIO.new(io) if io.is_a? String
      out = {}
      k = nil
      while line = io.gets
        next if /^\s*#/.match line
        if m = ATTR.match(line)
          v = m.named_captures.transform_keys &:to_sym
          k = v.delete :name
          k, co = k.split(/\s+/, 2) # comments
          k, *al = k.split(/\/+/) # aliases
          v[:comment] = co if co
          v[:alias] = al unless al.empty?
          v[:uses]  = v[:uses].split('').map(&:to_sym).sort.uniq
          v[:body]  = ''
          out[k] = v
        elsif m = /^\s*:(.*?)\s*$/.match(line)
          out[k = m[1]] = { body: '' }
        elsif k
          out[k][:body] << line
        end
      end

      out.each do |_, v|
        # clean up and transform the documentation
        v[:body] = TidyFFI::Tidy.new(v[:body],
          numeric_entities: true, tidy_mark: false, output_xhtml: true).clean
        v[:body] = XSLT.transform(Nokogiri.XML v[:body])
      end

      out
    end

    def get_content uri
      uri = URI(uri) unless uri.is_a? URI
      cwd = URI("file://#{Pathname.getwd.to_s}/")
      uri = (cwd.merge uri).normalize
      if uri.scheme == 'file'
        return Pathname(uri.path).open
      elsif uri.scheme.start_with? 'http'
        resp = RestClient.get uri.to_s
        return StringIO.new resp.body if resp.code == 200
        # blow up if the response fails
        raise RestClient::RequestFailed.new resp
      else
        raise ArgumentError.new "Don't know how to handle #{uri}"
      end
    end

    public

    # @param attrs
    # @param types
    # @param vocab
    # @param target

    def initialize attrs: nil, types: nil, vocab: nil, target: nil
      attrs  = get_content attrs
      @attrs = read_graphviz_src attrs

      types  = get_content types
      @types = read_graphviz_src types

      vocab  = get_content vocab
      @vocab = Nokogiri.XML vocab
    end

    def run
      #warn @attrs
      #@types.each { |k, v| print v[:body].to_xml }
      print @vocab.to_xml
    end
  end
end
