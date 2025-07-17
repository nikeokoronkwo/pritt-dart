package goa

import "fmt"

func (f Footballer) GetName() string {
	return fmt.Sprintf("%s %s", f.FirstName, f.LastName)
}

// Get a list of footballers 
func GetFootballers() []Footballer {
	return []Footballer{}
}

func (f Footballer) GetPostsByFootballers() {

}