package transport

import (
	"context"
	"fmt"
	"net"
	"time"
)

func sendDNSQuery(data []byte, target string) (responses []string, err error) {
	// Custom resolver
	resolver := net.Resolver{
		PreferGo: true,
		Dial: func(ctx context.Context, network, address string) (net.Conn, error) {
			d := net.Dialer{
				Timeout: time.Millisecond * time.Duration(10000),
			}
			return d.DialContext(ctx, network, "8.8.8.8:53")
		},
	}

	// We use TXT requests to tunnel data. Feel free to implement your own method.
	responses, err = resolver.LookupTXT(context.Background(), fmt.Sprintf("%s.%s", data, target))
	return
}
