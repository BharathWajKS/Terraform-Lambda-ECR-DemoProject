package main

import (
	"encoding/json"
	"fmt"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
)

type Books struct {
	Id   int    `json:"id"`
	Name string `json:"name"`
}

func list() (events.APIGatewayProxyResponse, error) {
	books := []Books{
		{Id: 1, Name: "Golang"},
	}
	fmt.Println("aa")

	res, _ := json.Marshal(&books)
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
		Body: string(res),
	}, nil
}

func main() {
	lambda.Start(list)
}
