require.config
	paths:
		jquery: '../lib/jquery/jquery'
		bootstrap: '../lib/bootstrap/js/bootstrap'
		jsonview: '../lib/jquery-jsonview/jquery.jsonview'
	
	shim:
		jquery:
			exports: '$'
		bootstrap:
			deps: ['jquery']
		jsonview:
			deps: ['jquery']


require ['app']