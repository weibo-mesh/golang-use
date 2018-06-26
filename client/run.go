package main

import (
	"fmt"

	motan "github.com/weibocom/motan-go"
	"net/http"
)

func main() {
	http.Handle("/", http.HandlerFunc(hello))
	err := http.ListenAndServe(":9999", nil)
	if err != nil {
		fmt.Printf("start listen manage port fail! port:%d, err:%s\n", 9999, err.Error())
	}
}

func hello(w http.ResponseWriter, r *http.Request) {
	mccontext := motan.GetClientContext("")
	mccontext.Start(nil)
	mclient := mccontext.GetClient("hello-world")

	args := "weibo-motan-gloang"
	var reply string
	err := mclient.Call("Hello", []interface{}{args}, &reply)
	if err != nil {
		w.Write([]byte("motan call fail!" + err.Error()))
	} else {
		w.Write([]byte(fmt.Sprintf("motan call success! reply:%s\n", reply)))
	}
}
