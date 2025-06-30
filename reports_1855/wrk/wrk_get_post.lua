-- wrk_get_post.lua
-- 用于模拟混合请求类型、动态路径、设置自定义请求头

counter = 0

-- 请求前准备，每个线程初始化
function setup(thread)
  thread:set("id", counter)
  counter = counter + 1
end

-- 每次请求前构造请求
function request()
  local path = "/api/test?id=" .. math.random(1, 100)
  local method = (math.random() > 0.5) and "GET" or "POST"

  if method == "POST" then
    wrk.method = "POST"
    wrk.body = '{"msg": "Hello from Lua POST"}'
  else
    wrk.method = "GET"
    wrk.body = nil
    path = path .. "&type=get"
  end

  wrk.headers["Content-Type"] = "application/json"
  wrk.headers["X-Custom-Header"] = "wrk-lua-header"
  wrk.headers["User-Agent"] = "wrk-benchmark"

  return wrk.format(nil, path)
end

