CC=gcc
CFLAGS=-I.

libfastcluster.so: fastcluster.o
	$(CC) -shared -fPIC -o libfastcluster.so fastcluster.o -lstdc++

fastcluster.o: fastcluster.cpp
	$(CC) -c fastcluster.cpp -o fastcluster.o
