extends HTTPRequest

func _ready():
	# Connect the signal to itself
	self.request_completed.connect(_on_request_completed)

func post_json(data: Dictionary):
	var url = "http://localhost:8080/networktest01/api/chat"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify(data)
	
	# Perform request
	var error = self.request(url, headers, HTTPClient.METHOD_POST, body)
	
	if error != OK:
		print("Error initiating request: ", error)

func _on_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		var response = body.get_string_from_utf8()
		print("Server Response: ", response)
	else:
		print("Server http: ", response_code)
		print("Server header: ", _headers)
		print("Server result: ", _result)
		print("Server body: ", PackedByteArray(body).get_string_from_utf8())
