require "zip"
require "csv"
require "rexml/document"

template = <<-EOF
<?xml version="1.0" encoding="utf-8"?>
<ComicInfo xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <Series></Series>
    <Title></Title>
    <Volume></Volume>
    <Writer></Writer>
    <ScanInformation></ScanInformation>
    <Pages></Pages>
</ComicInfo>
EOF
doc = REXML::Document.new(template)

=begin
Dir.glob("contents/*.cbz") do |filename|
    Zip::File.open(filename) do |zip_file|
        
    end
end
=end

manga_data = []
CSV.parse(File.read('manga2.csv')) do |data|
    manga_data.push(data)
end

formatter = REXML::Formatters::Pretty.new
formatter.compact = true
    
manga_data.each do |manga|
    id = manga[0]
    title = manga[1]
    writer = manga[2]

    puts "id: #{id}, title: #{title}"

    if title != "unknown" then
        REXML::XPath.each(doc, "/ComicInfo/Title") do |node|
            node.text = title
        end
    end
    if writer != "unknown" then
        REXML::XPath.each(doc, "/ComicInfo/Writer") do |node|
           node.text = writer
        end
    end
    output = StringIO.new
    formatter.write(doc, output)
    
    Zip::File.open("contents/#{id}.cbz", Zip::File::CREATE) do |zip|
        zip.get_output_stream("ComicInfo.xml") { |f| f.print(output.string) }
    end
end