# This should be a makefile
# Get latest gnuchess
# Get latest xboard
# Get gnuchess books
# build gnuchess
# use gnuchess to convert books to .bin
XBOARD_URL = ftp://ftp.gnu.org/gnu/xboard/
GNUCHESS_URL = ftp://ftp.gnu.org/gnu/chess/
GNUCHESS_LATEST := $(shell curl ftp://ftp.gnu.org/gnu/chess/ | grep -o 'gnuchess-.*.gz' | sort -n | tail -1)
XBOARD_LATEST := $(shell curl ftp://ftp.gnu.org/gnu/xboard/ | grep -o 'xboard-.*.gz' | sort -n | tail -1)

snap: gnuchess.tar.gz xboard.tar.gz book.bin 
	snapcraft snap

gnuchess.tar.gz: $(GNUCHESS_LATEST)
	ln -fs $< gnuchess.tar.gz

xboard.tar.gz: $(XBOARD_LATEST)
	ln -fs $< xboard.tar.gz

$(GNUCHESS_LATEST):
	curl -O $(GNUCHESS_URL)/$(GNUCHESS_LATEST)
	curl -O $(GNUCHESS_URL)/$(GNUCHESS_LATEST).sig
	gpg --keyserver pgp.mit.edu --recv-keys 766D3CA0FFB903333D2AE492A8AB893AE40251D9
	gpg --verify $(GNUCHESS_LATEST).sig

$(XBOARD_LATEST):
	curl -O $(XBOARD_URL)/$(XBOARD_LATEST)
	curl -O $(XBOARD_URL)/$(XBOARD_LATEST).sig
	gpg --keyserver pgp.mit.edu --recv-keys 446E23EE
	gpg --verify $(XBOARD_LATEST).sig

%.pgn.gz:
	curl -O http://ftp.gnu.org/gnu/chess/$@

gnuchess/src/gnuchess: $(GNUCHESS_LATEST)
	mkdir -p gnuchess
	tar  --strip-components=1 -zxvf $(GNUCHESS_LATEST) -C gnuchess
	(cd gnuchess && ./configure && make)

book.bin: gnuchess/src/gnuchess book_1.00.pgn.gz  book_1.01.pgn.gz book_1.02.pgn.gz
	gunzip -f -k book_*.pgn.gz

	echo "quit" | GNUCHESS_PKGDATADIR=./ gnuchess/src/gnuchess --addbook book_1.0*.pgn

clean:
	rm -f gnuchess-*.tar.gz*
	rm -f gnuchess.tar.gz
	rm -f xboard-*.tar.gz*
	rm -f xboard.tar.gz
	rm -f book_*.pgn.gz
	rm -f book_*.pgn
	rm -f book.bin
	rm -rf gnuchess
	snapcraft clean

.PHONY: clean snap
