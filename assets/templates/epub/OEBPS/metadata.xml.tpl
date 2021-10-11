<?xml version="1.0"  encoding="UTF-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="calibre_id">
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf" xmlns:Txt2ePub="http://no722.cocolog-nifty.com/blog/metadata">
    <dc:title>{{ title }}</dc:title>
    <dc:creator opf:role="aut" opf:file-as="e-hentai.org">e-hentai.org</dc:creator>
    {# <dc:contributor opf:role="bkp" opf:file-as="ChainLP">ChainLP (0.0.40.17) [http://no722.cocolog-nifty.com/blog/]</dc:contributor> #}
    {# <dc:date>2021-07-30T05:37:00+00:00</dc:date> #}
    <dc:publisher>e-hentai.org</dc:publisher>
    <dc:language>{{ language }}</dc:language>
    {# <dc:identifier opf:scheme="CHAINLP">254ce15d-dfdf-4fa0-bba0-9dbd232c7854</dc:identifier> #}
    <meta content="true" name="fixed-layout"/>
    <meta content="comic" name="book-type"/>
    <meta name="Txt2ePub:series_index" content="1"/>
    <meta name="calibre:title_sort" content="{{ title }}"/>
    <meta name="cover" content="cover"/>
  </metadata>
  <manifest>
    {%- for fileName in fileNameList %}
    <item id="index{{ fileName.withoutExtension }}" href="content/index_{{ fileName.withoutExtension }}.xhtml" media-type="application/xhtml+xml"/>
    {%- endfor %}
    {%- for fileName in fileNameList %}
    <item id="img_{{ fileName.withoutExtension }}" href="content/resources/{{ fileName.name }}" media-type="image/{{ fileName.extension }}"/>
    {%- endfor %}
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    <item id="idcss" href="content/resources/index_0.css" media-type="text/css"/>
    <item id="cover" href="content/resources/{{ coverName }}" media-type="image/{{ coverExtension }}"/>
  </manifest>
  <spine>
    {%- for fileName in fileNameList %}
    <itemref idref="index{{ fileName.withoutExtension }}"/>
    {%- endfor %}
  </spine>
</package>
