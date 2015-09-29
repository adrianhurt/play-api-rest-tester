define ['jquery', 'bootstrap'], ($, bootstrap) ->
	
	makeRequest = () ->
		withApiUrl (apiUrl) ->
			request = $('#request').val().replace(/^\//, '')
			if isEmpty(request)
				alert 'The Request is required'
			else			
				$('.response-empty, .response').addClass('hidden')
				$('.response-loading').removeClass('hidden')
				
				method = getMethod()
				
				data = {
					url: apiUrl + "/" + request
					method: method
					headers: getHeaders()
					body: if bodyIsRequired(method) then $('#request-body').val() else ''
				}

				console.log "\n-----------------------------\nSent Data:"
				console.log data
				console.log "-----------------------------\n"
								
				crossDomain data,
					(jqXHR) -> showResponse(jqXHR, request),
					(jqXHR) -> showResponse(jqXHR, request)


	showResponse = (jqXHR, request) ->
		status = jqXHR.status
		statusText = jqXHR.statusText
		headers = jqXHR.getAllResponseHeaders()
		body = if jqXHR.responseJSON != undefined then JSON.stringify(jqXHR.responseJSON, null, 2) else undefined
		
		withNewLines = (str, newLine) -> str.replace(/[\n\r]+/g, newLine)
		withSpaces = (str) -> str.replace(/\s/g, '&nbsp;')
		
		console.log "\n-----------------------------"
		console.log "Response (jqXHR):"
		console.log jqXHR
		console.log "Status: #{status} #{statusText}"
		console.log "Headers:"
		console.log "\t" + withNewLines(headers, '\n\t')
		console.log "Body:"
		console.log body
		console.log "-----------------------------\n"
		$('#response-status').removeClass('success error').addClass(if status < 400 then 'success' else 'error')
		$('#response-status-code').text(status)
		$('#response-status-text').text(statusText)
		$('#response-headers').html(withNewLines(headers, '<br>'))
		$('#response-body').html(if body != undefined then withSpaces(withNewLines(body, '<br>')) else '')
		$('.response-empty, .response-loading').addClass('hidden')
		$('.response').removeClass('hidden')
		
		switch request
			when 'signin' then storeToken(jqXHR.responseJSON.token)
			when 'signout' then removeToken()
	
	
	setPreparedRequest = (reqName) ->
		setPreparedReq = (method, req, withToken, body) ->
			selectMethod(method)
			$('#request').val(if $('#enveloped').prop('checked') then envelope(req) else req)
			$('#checkbox-token').prop('checked', withToken)
			$('#request-body').val(JSON.stringify(body, null, 2))
		
		set = (method, req, body = undefined) -> setPreparedReq(method, req, false, body)
		setSecured = (method, req, body = undefined) -> setPreparedReq(method, req, true, body)
		
		switch reqName
			when 'test' then set 'GET', 'test'
			when 'usernames' then set 'GET', 'usernames'
			when 'signin' then set 'POST', 'signin', { email: "user1@mail.com", password: "123456" }
			when 'signout' then setSecured 'POST', 'signout'
			when 'signup' then set 'POST', 'signup', { email: "user4@mail.com", password: "123456", user: { name: "User 4" } }
			
			when 'account' then setSecured 'GET', 'account'
			when 'account-update' then setSecured 'PUT', 'account', { name: "New name" }
			when 'account-update-password' then setSecured 'PUT', 'account/password', { old: "123456", new: "654321" }
			when 'account-delete' then setSecured 'DELETE', 'account'
			
			when 'folders' then setSecured 'GET', 'folders?sort=order&page=1&size=2'
			when 'folder-new' then setSecured 'POST', 'folders', { name: "New folder" }
			when 'folder' then setSecured 'GET', 'folders/1'
			when 'folder-update' then setSecured 'PUT', 'folders/1', { name: "New name" }
			when 'folder-update-order' then setSecured 'PUT', 'folders/1/order/2'
			when 'folder-delete' then setSecured 'DELETE', 'folders/1'

			when 'tasks-filtering-sorting' then setSecured 'GET', 'folders/1/tasks?done=false&sort=-deadline,-date,order&page=1'
			when 'tasks-searching' then setSecured 'GET', 'folders/1/tasks?q=barcelona&page=1'
			when 'task-new' then setSecured 'POST', 'folders/1/tasks', { text: "New task", deadline: "24-11-2015 18:00:00" }
			when 'task' then setSecured 'GET', 'tasks/1'
			when 'task-update' then setSecured 'PUT', 'tasks/1', { text: "New text" }
			when 'task-update-order' then setSecured 'PUT', 'tasks/1/order/2'
			when 'task-update-folder' then setSecured 'PUT', 'tasks/1/folder/2'
			when 'task-update-done' then setSecured 'PUT', 'tasks/1/done'
			when 'task-update-undone' then setSecured 'DELETE', 'tasks/1/done'
			when 'task-delete' then setSecured 'DELETE', 'tasks/1'
	
	
	
	signIn = () ->
		withApiUrl (apiUrl) ->
			$('#signin').button('loading')
			crossDomain {
					url: apiUrl + "/signin"
					method: 'POST'
					headers: getDefaultHeaders()
					body: JSON.stringify({ email: "user1@mail.com", password: "123456" })
				},
				(jqXHR) -> storeToken(jqXHR.responseJSON.token),
				(jqXHR) -> console.log jqXHR ; alert('Error while trying to sign in'),
				(jqXHR) -> $('#signin').button('reset')
	
	signOut = () ->
		withApiUrl (apiUrl) ->
			headers = getDefaultHeaders(true)
			tokenHeader = headers['X-Auth-Token']
			if tokenHeader != undefined and tokenHeader.length > 0
				$('#signout').button('loading')
				crossDomain {
						url: apiUrl + "/signout"
						method: 'POST'
						headers: headers
						body: ''
					},
					(jqXHR) -> removeToken(),
					(jqXHR) -> console.log jqXHR ; alert('Error while trying to sign out'),
					(jqXHR) -> $('#signout').button('reset')
			else
				removeToken()

		
#######################################################
# UTILS

	isEmpty = (str) -> not str? or str.length == 0
	
	bodyIsRequired = (method) -> !(method == 'GET' or method == 'DELETE')
	
	selectMethod = (method) ->
		$('#method-selector label[method='+method+']').addClass('active').siblings().removeClass('active')
		if bodyIsRequired(method)
			$('#request-body-section').removeClass('hidden')
		else
			$('#request-body-section').addClass('hidden')
	
	getMethod = () ->
		$('#method-selector label.active').attr('method')
	
	envelopeRequest = (envelopeOrNot) ->
		req = $('#request').val()
		$('#request').val(if envelopeOrNot then envelope(req) else unenvelope(req))
	unenvelope = (req) -> req.replace(/&envelope=[^&]*/ig, '').replace(/[?&]envelope=\w*$/i, '').replace(/\?envelope=\w*&/ig, '?')
	envelope = (req) ->
		unenveloped = unenvelope(req)
		separator = if unenveloped.indexOf('?') == -1 then '?' else '&'
		unenveloped + separator + 'envelope=true'
	
	withApiUrl = (f) ->
		apiUrl = $('#apiurl').val().replace(/\/$/, '')
		if isEmpty(apiUrl)
			alert 'The API URL is required'
		else
			f(apiUrl)
	
	getDefaultHeaders = (withToken = false) ->
		headers = {}
		for tr in $('#request-headers tr')
			[key, value] = [$(tr).find('td.key').text(), $(tr).find('input[type=text]').attr('value')]
			if withToken or key != 'X-Auth-Token'
				headers[key] = value
		headers
	
	getHeaders = () ->
		headers = {}
		for tr in $('#request-headers tr')
			if $(tr).find('input[type=checkbox]').prop('checked')
				[key, value] = [$(tr).find('td.key').text(), $(tr).find('input[type=text]').val()]
				headers[key] = value
		headers
	
	crossDomain = (data, doneFunc, failFunc, alwaysFunc = (x) -> null) ->
		$.ajax {
			url: '/proxy'
			method: 'POST'
			contentType: "application/json"
			data: JSON.stringify(data)
		}
		.done (data, textStatus, jqXHR) -> doneFunc(jqXHR) ; alwaysFunc(jqXHR)
		.fail (jqXHR, textStatus, err) -> failFunc(jqXHR) ; alwaysFunc(jqXHR)
	
	storeToken = (token) ->
		if token? and token.length > 0
			$('#checkbox-token').prop('checked', true)
			$('#token').val(token).attr('value', token)
	removeToken = () ->
		$('#checkbox-token').prop('checked', false)
		$('#token').removeAttr('value')
	

#######################################################
# Document ready

	$ ->
		
		$('#method-selector label[method]').click () -> selectMethod($(this).attr('method'))
		$('#test-button').click () -> makeRequest()
		$('#request').keyup (e) -> if(e.which == 13) then makeRequest()
		$('#test-list a[req]').click () -> setPreparedRequest($(this).attr('req'))		
		$('#signin').click () -> signIn()
		$('#signout').click () -> signOut()
		$('#enveloped').change () -> envelopeRequest($(this).prop('checked'))
		
		$('[data-toggle="tooltip"]').tooltip()