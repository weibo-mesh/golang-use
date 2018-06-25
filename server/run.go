package main

import (
	"fmt"
	motan "github.com/weibocom/motan-go"
)

func main() {
	mscontext := motan.GetMotanServerContext("")
	mscontext.RegisterService(&HelloWorldService{}, "")
	mscontext.Start(nil)
	mscontext.ServicesAvailable() //注册服务后，默认并不提供服务，调用此方法后才会正式提供服务。需要根据实际使用场景决定提供服务的时机。作用与java版本中的服务端心跳开关一致。
	for {
	}
}

type HelloWorldService struct{}

func (m *HelloWorldService) Hello(name string) string {
	fmt.Printf("HelloWorldService hello:%s\n", name)
	return "hello " + name
}
