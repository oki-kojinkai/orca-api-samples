#!/usr/bin/ruby
#-*-coding: utf-8-*-

#------ 患者番号一覧取得

require 'pp'
require 'uri'
require 'net/http'
require 'crack'
require 'crack/xml'


Net::HTTP.version_1_2

HOST = "192.168.4.123"
PORT = "8000"
USER = "ormaster"
PASSWD = "ormaster123"
CONTENT_TYPE = "application/xml"


req = Net::HTTP::Post.new("/api01rv2/patientlst1v2?class=01")
# class :01 新規・更新対象
# class :02 新規対象
#
#

#編集
  puts "===================="
  patient_start = ARGV[0]
  puts "開始日:#{patient_start}"
  patient_end = ARGV[1]
  puts "終了日:#{patient_end}"
#編集終わり

BODY = <<EOF
<data>
	<patientlst1req type="record">
		<Base_StartDate type="string">#{patient_start}</Base_StartDate>
		<Base_EndDate type="string">#{patient_end}</Base_EndDate>
		<Contain_TestPatient_Flag type="string">1</Contain_TestPatient_Flag>
	</patientlst1req>
</data>
EOF

def list_patient(body)
	root = Crack::XML.parse(body)
	#pp root
	result = root["xmlio2"]["patientlst1res"]["Api_Result"]
	unless result == "00"
		puts "error:#{result}"
		exit 1
	end

	pinfo = root["xmlio2"]["patientlst1res"]["Patient_Information"]
	
	
	pinfo.each do |patient|
		puts "===================="
		puts "#{patient["Patient_ID"]} #{patient["WholeName"]} #{patient["WholeName_inKana"]} #{patient["BirthDate"]} #{patient["Sex"]}"
	end

end

req.content_length = BODY.size
req.content_type = CONTENT_TYPE
req.body = BODY
req.basic_auth(USER, PASSWD)

Net::HTTP.start(HOST, PORT) {|http|
	res = http.request(req)
	#puts res.code
	list_patient(res.body)
}

