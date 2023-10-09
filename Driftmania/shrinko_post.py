def postprocess_main(cart, **_):
	cart.code = cart.code.replace('".."','')
