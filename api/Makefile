docker:
	docker build -t lambdatest .
	docker run -p 9000:8080 lambdatest
build: 
	GOOS=linux go build -o main main.go