vsc:
	for lib in $(ls lib/* -d); do \
		cd $(lib)
                ./vramen
