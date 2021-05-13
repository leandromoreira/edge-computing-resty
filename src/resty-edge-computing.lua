local edge_computing = {}
local http = require 'resty.http'
local json = require "cjson"


--- computing unit ---
---    cu = {}
---    cu["id"] = "coding id"
---    cu["phase"] = "phase"
---    cu["code"] = function_code
---    cu["sampling"] = 50
--- computing unit ---

edge_computing.cus = {}
edge_computing.ready = false
edge_computing.interval = 20 -- seconds
edge_computing.workers_max_jitter = 5 -- seconds
edge_computing.phases = {
  "init", "init_worker", "ssl_cert", "ssl_session_fetch", "ssl_session_store", "set",
  "rewrite", "balancer", "access", "content", "header_filter", "body_filter", "log",
  "timer"
}

edge_computing.api_uri = "http://localhost:9090/computing_units.json"
edge_computing.api_timeout = 1

edge_computing.spawn_poller = function()
  -- starting luajit entropy per worker
  math.randomseed(ngx.time() + ngx.worker.pid())

  -- initializating cus
  edge_computing.reset_cus()

  local jitter_seconds = math.random(1, edge_computing.workers_max_jitter)
  local worker_interval_seconds = edge_computing.interval + jitter_seconds

  -- scheduling recurring a polling
  ngx.timer.every(edge_computing.interval, edge_computing.fetch_code)

  -- polling right away (in the next nginx "cicle")
  -- to avoid all the workers to go downstream we add a jitter of 60s
  ngx.timer.at(0 + math.random(0, 60), edge_computing.fetch_code)
end

edge_computing.reset_cus = function()
  edge_computing.cus = {}
  for _, phase in ipairs(edge_computing.phases) do
    edge_computing.cus[phase] = {}
  end
end

edge_computing.fetch_code = function()
  local httpc = http.new()
  httpc:set_timeout(edge_computing.api_timeout * 1000)
  local res_api, err_api = httpc:request_uri(edge_computing.api_uri)

  if err_api ~= nil and type(err_api) == "string" and err_api ~= "" then
    return "error"
  end

  if res_api.status ~= 200 then
    return "error"
  end

  local admin_response, err = json.decode(res_api.body)
  if err ~= nil then
    return "error"
  end

  edge_computing.reset_cus()
  for _, coding_unit in ipairs(admin_response) do
      local function_code, _ = edge_computing.loadstring(coding_unit.code)
      local cu = {}
      cu["id"] = coding_unit.id
      cu["phase"] = coding_unit.phase
      cu["code"] = function_code
      cu["sampling"] = coding_unit.sampling
      table.insert(edge_computing.cus[cu["phase"]], cu)
  end
  edge_computing.log("all code was processed")
end

-- lua phases
-- https://github.com/openresty/lua-nginx-module#ngxget_phase
edge_computing.phase = function()
  return ngx.get_phase()
end

edge_computing.log = function(msg)
  ngx.log(ngx.ERR, " :: edge_computing :: [" .. ngx.worker.id() .. "] "  .. msg)
end

edge_computing.should_skip = function(n)
  return n < math.random(100)
end

-- returns status and computing units runtime errors
-- it can be true and still have some runtime errors
edge_computing.execute = function()
  local phase = edge_computing.phase()
  local runtime_errors = {}

  for _, cu in ipairs(edge_computing.cus[phase]) do
    if cu["sampling"] ~= nil and cu["sampling"] ~= "" then
      local sampling = tonumber(cu["sampling"])
      local should_skip = edge_computing.should_skip(sampling)
      if should_skip then goto continue end
    end

    local status, ret = pcall(cu["code"], {ctx="anything"})

    if not status then
      table.insert(runtime_errors, "execution of cu id=" .. cu["id"] .. ", failed due err=" .. ret)
    end
    ::continue::
  end

  return true, runtime_errors
end

edge_computing.loadstring = function(str_code)
  -- API wrapper
  local api_fun, err = loadstring("return function (ctx) " .. str_code .. " end")
  if api_fun then
    return api_fun()
  else
    return api_fun, err
  end
end

return edge_computing
