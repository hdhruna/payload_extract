##### Usage Instructions

```
./payload_extract.sh http://payload.io/
```

The script will take a URL input from user, on the response received script will 

1) report back if any service names are not OK
2) fail if any malformed url is sent as an argument
3) timeout after 10s if url is not responding within time limit
