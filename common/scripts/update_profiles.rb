require 'nokogiri'
require 'csv'
baseDir = ARGV[0]

def process_section(baseDir, fileName, metadataType, nameElement, otherFields)
	fullFileName="#{baseDir}/profiles/config/#{fileName}"
	if (File.exists?(fullFileName))
		CSV.foreach(fullFileName, :headers => true) do |row|
		  name = row[0]
		  delete = row.header?('Delete') ?  row["Delete"] : "FALSE"
		  delete="FALSE" if delete.nil?
		 # puts "#{metadataType} - #{name} - #{delete}"
		  xpath = "//xmlns:#{metadataType}[./xmlns:#{nameElement} = \'#{name}\']"
		  if (@doc.at_xpath(xpath))
		  		node = @doc.xpath(xpath)
		  		if delete == "TRUE"
		  			#puts "Deleting #{name}"
		  			node.remove
		  		else
			  		otherFields.each do |field|
			  			value = row[field[:csvColumn]]
			  			node.xpath("xmlns:#{field[:elementName]}").first.content=value
			  		end
			  	end
		  	else
		  		if delete == "FALSE"
			  		node = Nokogiri::XML::Node.new metadataType, @doc
			  		nameNode = Nokogiri::XML::Node.new nameElement, @doc
			  		nameNode.content = name
			  		node.add_child (nameNode)

			  		otherFields.each do |field|
			  			value = row[field[:csvColumn]]
			  		#	value = 'true' if value
			  		#	value = 'false' if value==false

			  			otherNode = Nokogiri::XML::Node.new field[:elementName], @doc
			  			otherNode.content = value
			  			node.add_child (otherNode)
			  		end
			  		if (@doc.at_xpath("//xmlns:#{metadataType}"))
			  			@doc.at_xpath("//xmlns:#{metadataType}").add_previous_sibling(node)
			  		else
			  			@doc.xpath("//xmlns:tabVisibilities").last.add_next_sibling(node)
			  		end
			  	end
		  end

		  if (delete = "TRUE" && metadataType == "objectPermissions")
		  		@doc.xpath("//xmlns:fieldPermissions[starts-with(xmlns:field, \'#{name}\')]").each{|node| node.remove}
		  		@doc.xpath("//xmlns:tabVisibilities[starts-with(xmlns:tab, \'#{name}\')]").each{|node| node.remove}
		  		@doc.xpath("//xmlns:layoutAssignments[starts-with(xmlns:layout, \'#{name}\')]").each{|node| node.remove}
		  end
		end
	end
end



CSV.foreach("#{baseDir}/profiles/config/Profiles.csv", :headers => true) do |row|
	f = File.open("#{baseDir}/profiles/src/profiles/#{row['Profile']}.profile")
	@doc = Nokogiri::XML(f) do |config|
	  config.default_xml.noblanks
	end

	process_section baseDir, "Fields.csv", "fieldPermissions", "field", [{:csvColumn =>"#{row["Type"]}-Editable", :elementName =>"editable"},{:csvColumn =>"#{row["Type"]}-Visible", :elementName =>"readable"}]
	process_section baseDir, "Pages.csv", "pageAccesses", "apexPage", [{:csvColumn =>row["Type"], :elementName =>"enabled"}]
	process_section baseDir, "Layout.csv", "layoutAssignments", "recordType", [{:csvColumn =>row["Type"], :elementName =>"layout"}]
	process_section baseDir, "RecordType.csv", "recordTypeVisibilities", "recordType", [{:csvColumn =>"#{row["Type"]}-Visible", :elementName =>"visible"},{:csvColumn =>"#{row["Type"]}-Default", :elementName =>"default"}]
	process_section baseDir, "Tabs.csv", "tabVisibilities", "tab", [{:csvColumn =>row["Type"], :elementName =>"visibility"}]
	process_section baseDir, "UserPermissions.csv", "userPermissions", "name", [{:csvColumn =>row["Type"], :elementName =>"enabled"}]
	process_section baseDir, "Objects.csv", "objectPermissions", "object", [{:csvColumn =>"#{row["Type"]}-Create", :elementName =>"allowCreate"},{:csvColumn =>"#{row["Type"]}-Delete", :elementName =>"allowDelete"},{:csvColumn =>"#{row["Type"]}-Read", :elementName =>"allowRead"},{:csvColumn =>"#{row["Type"]}-Edit", :elementName =>"allowEdit"},{:csvColumn =>"#{row["Type"]}-ModifyAll", :elementName =>"modifyAllRecords"},{:csvColumn =>"#{row["Type"]}-ViewAll", :elementName =>"viewAllRecords"}]
	process_section baseDir, "Apex.csv", "classAccesses", "apexClass", [{:csvColumn =>row["Type"], :elementName =>"enabled"}]


	File.open("#{baseDir}/profiles/updates/profiles/#{row['Profile']}.profile",'w') {|f| f.write @doc.to_xml(:indent => 2)}
	f.close
end
