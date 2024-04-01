.PHONY: build run

init:
	mkdir build

build:
	odin build . -o:speed -out:build/app
run:
	./build/app $(file)
clean:
	rm -rf build
