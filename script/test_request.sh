#!/bin/sh


curl http://localhost:3000/twilio -d "Body=request 5 from %2B17079710903 for thing" -d "From=%2B14152544629"
curl http://localhost:3000/twilio -d "Body=ok" -d "From=%2B17079710903"
