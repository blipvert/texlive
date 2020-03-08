all:

source/.git .git/modules/source:
	git config --replace-all submodule.source.update '!true'
	git submodule update --init -- source
	git config --unset-all submodule.source.update

.git/modules/source/info/sparse-checkout: sparse-checkout.list | .git/modules/source
	cp $< $@
	( cd source && git sparse-checkout init )

sparse: .git/modules/source/info/sparse-checkout
	cp sparse-checkout.list .git/modules/source/info/sparse-checkout
	( cd source && git sparse-checkout init )

.PHONY: all sparse
