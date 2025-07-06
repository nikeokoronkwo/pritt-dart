package goa

type Footballer struct {
	FirstName string `json:"first_name"`
	LastName  string `json:"last_name"`
	Age       uint   `json:"age"`
}

type Post struct {
	Title string `json:"title"`
	Owner Footballer `json:"owner"`
}

type Video struct {
	Title string `json:"title"`
	Owner Footballer `json:"owner"`
}