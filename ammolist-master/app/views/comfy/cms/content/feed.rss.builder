xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom",
  "xmlns:content" => "http://purl.org/rss/1.0/modules/content/",
  "xmlns:wfw" => "http://wellformedweb.org/CommentAPI/",
  "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
  "xmlns:atom" => "http://www.w3.org/2005/Atom",
  "xmlns:sy" => "http://purl.org/rss/1.0/modules/syndication/",
  "xmlns:slash" => "http://purl.org/rss/1.0/modules/slash/",
  "xmlns:media" => "http://search.yahoo.com/mrss/" do
  xml.channel do
    xml.title @cms_site.label
    xml.description @cms_site.label    
    xml.link "http:"+@cms_site.url
    xml.language 'en'
    xml.tag! 'atom:link', :rel => 'self', :type => 'application/rss+xml', :href => request.original_url
    
    for page in @pages
      xml.item do
        xml.title page.label
        xml.link "http:"+page.url

        doc = Nokogiri::HTML(page.block_content)
        img_srcs = doc.css('img').map{ |i| i['src'] }
        img_url = "http:"+@cms_site.url+img_srcs[0]
        xml.enclosure :url => img_url, :length => 4829, :type => 'image/jpg'
        xml.media :content, :url => img_url, :type => "image/jpg", :medium => "image", :height => "225", :width => "150"

        xml.pubDate page.updated_at.to_s(:rfc822)
        xml.description {xml.cdata!(truncate(sanitize(page.block_content, :tags=>[]), :length => 150, separator: ' '))}
      end
    end
  end
end