require 'csv'
baseDir = ARGV[0]
includeEverything=ARGV[1]
deployDir = ARGV[2]
File.open("#{deployDir}/package.xml",'w') do |file|
  package =  <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
EOF
file.puts package

if(includeEverything)
  package = <<EOF
  <types>
      <members>*</members>
      <name>ApexClass</name>
  </types>
  <types>
      <members>*</members>
      <name>ApexComponent</name>
  </types>
  <types>
      <members>*</members>
      <name>ApexPage</name>
  </types>
  <types>
      <members>*</members>
      <name>ApexTrigger</name>
  </types>
  <types>
      <members>*</members>
      <name>CustomApplication</name>
  </types>
  <types>
      <members>*</members>
      <name>CustomLabel</name>
  </types>
  <types>
      <members>*</members>
      <name>CustomLabels</name>
  </types>
  <types>
      <members>*</members>
      <members>Account</members>
      <members>AccountContactRole</members>
      <members>Activity</members>
      <members>Asset</members>
      <members>Campaign</members>
      <members>CampaignMember</members>
      <members>Case</members>
      <members>CaseContactRole</members>
      <members>Contact</members>
      <members>ContentVersion</members>
      <members>Contract</members>
      <members>ContractContactRole</members>
      <members>Event</members>
      <members>Idea</members>
      <members>Lead</members>
      <members>Opportunity</members>
      <members>OpportunityContactRole</members>
      <members>OpportunityLineItem</members>
      <members>PartnerRole</members>
      <members>Product2</members>
      <members>Quote</members>
      <members>QuoteLineItem</members>
      <members>Site</members>
      <members>Solution</members>
      <members>Task</members>
      <members>User</members>
      <name>CustomObject</name>
  </types>
  <types>
      <members>*</members>
      <name>CustomPageWebLink</name>
  </types>
  <types>
      <members>*</members>
      <name>CustomSite</name>
  </types>
  <types>
      <members>*</members>
      <name>CustomTab</name>
  </types>
  <types>
      <members>*</members>
      <name>Flow</name>
  </types>
  <types>
      <members>*</members>
      <name>HomePageComponent</name>
  </types>
  <types>
      <members>*</members>
      <name>HomePageLayout</name>
  </types>
  <types>
      <members>*</members>
      <name>Layout</name>
  </types>
  <types>
      <members>*</members>
      <name>Letterhead</name>
  </types>

  <types>
      <members>*</members>
      <name>ReportType</name>
  </types>
  <types>
      <members>*</members>
      <name>StaticResource</name>
  </types>
  <types>
      <members>*</members>
      <name>Workflow</name>
  </types>
  <types>
EOF
  file.puts package
end
  CSV.foreach("#{baseDir}/profiles/config/Profiles.csv", :headers => true) do |row|
    file.puts "  <members>#{row[0]}</members>"
  end

  package = <<EOF
    <name>Profile</name>
  </types>
  <version>29.0</version>
</Package>
EOF
  file.puts package
end

