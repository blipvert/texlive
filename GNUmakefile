all:

sparse:
	cp sparse-checkout.list .git/modules/source/info/sparse-checkout
	( cd source && git sparse-checkout init )

.PHONY: all sparse
