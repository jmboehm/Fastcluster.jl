CC=gcc
CFLAGS=-I.
LDFLAGS = -lm

libfastcluster.so: fastcluster.o
	$(CC) -shared -fPIC -o libfastcluster.so fastcluster.o -lstdc++ $(LDFLAGS)

fastcluster.o: src/fastcluster.cpp
	$(CC) -fPIC -c src/fastcluster.cpp -o fastcluster.o

.PHONY: install
install:
	mkdir -p bin
	mv libfastcluster.so bin/libfastcluster.so

.PHONY: clean
clean:
	rm -f fastcluster.o