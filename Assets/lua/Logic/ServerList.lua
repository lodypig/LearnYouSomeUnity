ServerListCtrl = {};

ServerListCtrl.serverList = {
    {name = "龙神创世",  ip = "120.27.139.129"},
    {name = "龙虎争霸",  ip = "139.129.160.8" },
	{name = "内网",  ip = "WAE01020131.woobest.com"},
    {name = "本地服",  ip = "127.0.0.1"},
    {name = "旋律猪",  ip = "WAE01020214.woobest.com"},
    {name = "洪志鹏",  ip = "10.2.30.58"},
    {name = "林淮",  ip = "WAE01020227.woobest.com"},
    {name = "曾燕斌",  ip = "10.2.30.73"},
    {name = "程辉",  ip = "WAE01020107.woobest.com"},
    {name = "汤瑞鑫",  ip = "WAE01020171.woobest.com"},
    {name = "王湛",  ip = "WAE01020185.woobest.com"},
    {name = "林霖",  ip = "WAE01020162.woobest.com"},
    {name = "张旭",  ip = "WAE01020187.woobest.com"},
    {name = "小帅",  ip = "WAE01020218.woobest.com"},
    {name = "吴冠杰",  ip = "WAE01020208.woobest.com"},
    {name = "李文华",  ip = "WAE01020108.woobest.com"},
    {name = "冯成立", ip = "WAE01020199.woobest.com"},
    {name = "刘柱", ip = "WAE01020175.woobest.com"},
    {name = "宋琦", ip = "WAE01020182.woobest.com"},
    {name = "陈凯", ip = "WAE01020194.woobest.com"},
    {name = "程天生", ip = "WAE01020221.woobest.com"},
    {name = "谢根煌", ip = "WAE01020326.woobest.com"},
    {name = "裘文飞", ip = "10.2.18.20"},
    {name = "刘沛然", ip = "10.2.18.28"},
}

ServerListCtrl.SetNetServerInfo = function(index)
	if index < 1 and index > #ServerListCtrl.serverList then 
		return
	end
	local info = ServerListCtrl.serverList[index]
	if info ~= nil then
		Net.serverName = info.name
		Net.serverIP = info.ip
	end
end