define [], () ->
	
	# Given a request name (identifier), returns a JSON object with the information of the corresponding prepared request:
	#  secured: true if the request is secured by a token.
	#  method: GET, POST, PUT, DELETE, ...
	#  uri: the request uri
	#  body: the optional body as a JSON object
	
	prepared: (requestName) ->
		
		# Auxiliar functions
		req = (method, uri, body = undefined) -> { secured: false, method: method, uri: uri, body: body }
		securedReq = (method, uri, body = undefined) -> { secured: true, method: method, uri: uri, body: body }
		
		switch requestName
			when 'test' then req 'GET', 'test'
			when 'usernames' then req 'GET', 'usernames'
			when 'signin' then req 'POST', 'signin', { email: "user1@mail.com", password: "123456" }
			when 'signout' then securedReq 'POST', 'signout'
			when 'signup' then req 'POST', 'signup', { email: "user4@mail.com", password: "123456", user: { name: "User 4" } }
			
			when 'account' then securedReq 'GET', 'account'
			when 'account-update' then securedReq 'PUT', 'account', { name: "New name" }
			when 'account-update-password' then securedReq 'PUT', 'account/password', { old: "123456", new: "654321" }
			when 'account-delete' then securedReq 'DELETE', 'account'
			
			when 'folders' then securedReq 'GET', 'folders?sort=order&page=1&size=2'
			when 'folder-new' then securedReq 'POST', 'folders', { name: "New folder" }
			when 'folder' then securedReq 'GET', 'folders/1'
			when 'folder-update' then securedReq 'PUT', 'folders/1', { name: "New name" }
			when 'folder-update-order' then securedReq 'PUT', 'folders/1/order/2'
			when 'folder-delete' then securedReq 'DELETE', 'folders/1'

			when 'tasks-filtering-sorting' then securedReq 'GET', 'folders/1/tasks?done=false&sort=-deadline,-date,order&page=1'
			when 'tasks-searching' then securedReq 'GET', 'folders/1/tasks?q=barcelona&page=1'
			when 'task-new' then securedReq 'POST', 'folders/1/tasks', { text: "New task", deadline: "24-11-2015 18:00:00" }
			when 'task' then securedReq 'GET', 'tasks/1'
			when 'task-update' then securedReq 'PUT', 'tasks/1', { text: "New text" }
			when 'task-update-order' then securedReq 'PUT', 'tasks/1/order/2'
			when 'task-update-folder' then securedReq 'PUT', 'tasks/1/folder/2'
			when 'task-update-done' then securedReq 'PUT', 'tasks/1/done'
			when 'task-update-undone' then securedReq 'DELETE', 'tasks/1/done'
			when 'task-delete' then securedReq 'DELETE', 'tasks/1'
	
