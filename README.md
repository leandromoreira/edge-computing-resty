# Edge computing resty

During our hackday, we created a simple edge computing platform using nginx, lua and rails. The ideas is to inject lua code into a running nginx through a CMS.

## Demo

https://user-images.githubusercontent.com/55913/118967200-ce974e00-b940-11eb-89ab-d4366e360dc9.mp4

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

# Future work

* Federated functions
  * maybe using the domain to shard and sum with a global domain *
* Some form of lua sandboxing 
  * since [luajit can't enforce](https://github.com/Kong/kong-lua-sandbox) quota, one might use the admin phase to run the code and mesure the time, check syntax, security?!
* Provide a API hook for authentication
* Publish it as a rock
* Add measurements
