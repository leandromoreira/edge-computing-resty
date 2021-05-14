# Edge computing resty

During our hackday, we created a simple edge computing platform using nginx, lua and rails. The ideas is to inject lua code into a running nginx through a CMS.

## Quick start

```bash

# running all the systems
make run
# open another tab - simulating a live colorbar live hls signal
make broadcast_tvshow

# you can check the streaming manifest content
http http://localhost:8080/hls/colorbar.m3u8
````

Go to http://localhost:3000/ and create a simple lua code to ensure a super secret token scheme:

```lua
local token = ngx.var.arg_token or ngx.var.cookie_superstition

if token ~= 'token' then
  return ngx.exit(ngx.HTTP_FORBIDDEN)
else
  ngx.header['Set-Cookie'] = {'superstition=token'}
end
```

![A CMS print screen](/cms.jpg "A CMS print screen")

```bash
# if you try to fetch the token again, the server will reply with a 403
http http://localhost:8080/hls/colorbar.m3u8

# but if you pass the super token, then it's going to work fine :)
http http://localhost:8080/hls/colorbar.m3u8?token=token
```
