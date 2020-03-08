disabled-pkgs := \
	all-pkgs native-texlive-build shared largefile \
    synctex mflua mfluajit pmp upmp \
    ptex eptex uptex euptex aleph xetex pdftex luatex luajittex

enabled-pkgs := tex mf mp web2c

system-pkgs := \
	mpfr gmp harfbuzz cairo libpng ptexenc kpathsea xpdf freetype2 \
	gd teckit t1lib icu graphite2 zziplib poppler

without := x mf-x-toolkit

configure-opts := \
	--prefix=$(or $(PREFIX),/opt/texlive) \
	$(addprefix --disable-,$(disabled-pkgs)) \
	$(addprefix --enable-,$(enabled-pkgs)) \
	$(addprefix --with-system-,$(system-pkgs)) \
	$(addprefix --without-,$(without))

all: build

build: configure
	$(MAKE) -C target

source: .git/modules/source/info/sparse-checkout
	( cd source && ./reautoconf )

clean:
	rm -fr target

configure: source/configure
	( mkdir -p ./target && cd ./target && ../source/configure $(configure-opts) )

.PHONY: all source clean configure build

# Git module hackery
source/.git .git/modules/source:
	git config --replace-all submodule.source.update '!true'
	git submodule update --init -- source
	git config --unset-all submodule.source.update

.git/modules/source/info/sparse-checkout: sparse-checkout.list | .git/modules/source
	cp $< $@
	( cd source && git sparse-checkout init )
