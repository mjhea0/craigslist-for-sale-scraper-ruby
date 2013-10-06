require 'nokogiri' 
require 'open-uri'
require 'csv'

@url = ARGV[0]

if @url.nil? || @url == ''
  puts "Usage: ruby scraper.rb http://sfbay.craigslist.org/moa/"
  exit 0
end

# Override the default to_s function
# so that it outputs the content of the
# node instead of the html
class Nokogiri::XML::Node
  def to_s
    self && self.content.to_s
  end
end

# parse the city from the url
city = @url.scan(/\/([\w]+)\.c/).last.first

# open url
doc = Nokogiri::HTML(open(@url))

# open csv
CSV.open('results.csv', 'a+') do |csv|
  doc.css('.row').each do |row|
    csv << [
      row.attr('data-pid'),                             # pid
      city,                                             # city
      row.at_css('.price').to_s.tr('$', ''),            # price
      row.at_css('.pl a'),                              # title
      row.at_css('a.gc').attr('data-cat'),              # category key
      row.at_css('a.gc'),                               # category name
      row.at_css('.pnr small').to_s.tr('()', '').strip  # location - we remove ( ) and surrounding spaces
    ]
  end
end
