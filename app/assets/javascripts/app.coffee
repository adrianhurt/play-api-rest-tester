define ['jquery', 'bootstrap', 'requests', 'jsonview'], ($, bootstrap, requests, jsonview) ->
	
	makeRequest = ->
		withApiUrl (apiUrl) ->
			request = $('#request').val().replace(/^\//, '')
			if isEmpty(request)
				alert 'The Request is required'
			else			
				$('.response-empty, .response').addClass('hidden')
				$('.response-loading').removeClass('hidden')
				
				method = getMethod()
				
				data = {
					url: apiUrl + '/' + request
					method: method
					headers: getHeaders()
					body: if bodyIsRequired(method) then $('#request-body').val() else ''
				}

				console.log '\n-----------------------------\nRequest:   '+data.method + ' - ' + data.url
				console.log '\t' + (k+': '+v for k, v of data.headers).join('\n\t')
				if data.body.length > 0
					try
						console.log JSON.parse(data.body)
					catch e
						console.log e						
								
				crossDomain data,
					(jqXHR) -> showResponse(jqXHR, request),
					(jqXHR) -> showResponse(jqXHR, request)


	showResponse = (jqXHR, request) ->
		data = jqXHR.responseJSON
		body = if (Object.prototype.toString.call(data.body) == '[object String]') then '"' + data.body + '"' else data.body
		
		console.log "\nResponse: #{data.status} #{data.statusText}"
		console.log '\t' + data.headers.join('\n\t')
		console.log body
		console.log '-----------------------------\n\n\n'
		
		$('#response-status').removeClass('success error').addClass(if data.status < 400 then 'success' else 'error')
		$('#response-status-code').text(data.status)
		$('#response-status-text').text(data.statusText)
		$('#response-headers').html(data.headers.join('<br>'))
		if body != undefined
			showJsonView $('#response-body'), body
		else
			$('#response-body').html('')		
		$('.response-empty, .response-loading').addClass('hidden')
		$('.response').removeClass('hidden')
		
		switch request
			when 'signin' then storeToken(body.token)
			when 'signout' then removeToken()
	
	
	setPreparedRequest = (reqName) ->
		{secured, method, uri, body} = requests.prepared(reqName)
		selectMethod(method)
		$('#request').val(if $('#enveloped').prop('checked') then envelope(uri) else uri)
		$('#checkbox-token').prop('checked', secured)
		$('#request-body').val(JSON.stringify(body, null, 2))
	
	
	signIn = ->
		withApiUrl (apiUrl) ->
			$('#signin').button('loading')
			crossDomain {
					url: apiUrl + '/signin'
					method: 'POST'
					headers: getDefaultHeaders()
					body: JSON.stringify({ email: 'user1@mail.com', password: '123456' })
				},
				(jqXHR) -> storeToken(jqXHR.responseJSON.body.token),
				(jqXHR) -> console.log jqXHR ; alert('Error while trying to sign in'),
				(jqXHR) -> $('#signin').button('reset')
	
	signOut = ->
		withApiUrl (apiUrl) ->
			headers = getDefaultHeaders(true)
			tokenHeader = headers['X-Auth-Token']
			if tokenHeader != undefined and tokenHeader.length > 0
				$('#signout').button('loading')
				crossDomain {
						url: apiUrl + '/signout'
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
	
	getMethod = ->
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
	
	getHeaders = ->
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
			contentType: 'application/json'
			data: JSON.stringify(data)
		}
		.done (data, textStatus, jqXHR) -> doneFunc(jqXHR) ; alwaysFunc(jqXHR)
		.fail (jqXHR, textStatus, err) -> failFunc(jqXHR) ; alwaysFunc(jqXHR)
	
	storeToken = (token) ->
		if token? and token.length > 0
			$('#checkbox-token').prop('checked', true)
			$('#token').val(token).attr('value', token)
	removeToken = ->
		$('#checkbox-token').prop('checked', false)
		$('#token').removeAttr('value')
	
	
	showJsonView = ($el, js) ->
		$el.JSONView(js, {collapsed: !Array.isArray(js)})
	

#######################################################
# Document ready

	$ ->
		
		$('#method-selector label[method]').click -> selectMethod($(this).attr('method'))
		$('#test-button').click -> makeRequest()
		$('#request').keyup (e) -> if(e.which == 13) then makeRequest()
		$('#test-list a[req]').click -> setPreparedRequest($(this).attr('req'))		
		$('#signin').click -> signIn()
		$('#signout').click -> signOut()
		$('#enveloped').change -> envelopeRequest($(this).prop('checked'))
		
		$('[data-toggle="tooltip"]').tooltip()