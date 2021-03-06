-- Edit these variables to configurate MySQL.

local DATABASE_HOST     = "localhost";	-- (String) IPv4 IP of the mysql server.
local DATABASE_PORT     = 3306;					-- (Number) mysql server port.
local DATABASE_SCHEMA   = "exclserver";	-- (String) name of the schema/database
local DATABASE_USERNAME = "root";	-- (String) Username
local DATABASE_PASSWORD = "";		-- (String) Password

-- Do not edit anything under this line, unless you're a competent Lua developer.

require "tmysql4";

ES.ServerID = -1

local conn,err = tmysql.initialize(DATABASE_HOST,DATABASE_USERNAME,DATABASE_PASSWORD,DATABASE_SCHEMA,DATABASE_PORT,nil,CLIENT_MULTI_STATEMENTS)

if err then
	ES.Error("MYSQL_CONNECT_FAILED",err)

	hook.Add("InitPostEntity","exclserver.data.restart",function()
		RunConsoleCommand("changelevel",game.GetMap())
	end)
	return;
end

-- OLD FUNCTIONS, for legacy support
function ES.DBEscape(str)
	return conn:Escape(str);
end

local function cbFailed(...)
	for k,v in ipairs{...}do
		if v then
			ES.DebugPrint("MySQL query failed: ",v)
		end
	end
end
function ES.DBQuery(query,callback,callbackFailed)
	callbackFailed = callbackFailed or cbFailed;

	return conn:Query(query,function(res)
		local retSuccess={}
		local retFail={}

		local failed=false
		for k,v in ipairs(res)do
			if v.error then
				retSuccess[k]={};
				retFail[k]=v.error;
				failed=true
			else
				retSuccess[k]=v.data or {};
				retFail[k]=false;
			end
		end

		if callback then
			callback(unpack(retSuccess))
		end

		if failed then
			callbackFailed(unpack(retFail))
		end
	end);
end

-- Setup tables
conn:Query("CREATE TABLE IF NOT EXISTS `es_restrictions_props` (`id` smallint unsigned not null AUTO_INCREMENT, model varchar(255), serverid smallint unsigned not null default 0, req int(8) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_restrictions_tools` (`id` smallint unsigned not null AUTO_INCREMENT, toolmode varchar(255), serverid smallint unsigned not null default 0, req int(9) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_blockades` (`id` smallint unsigned not null AUTO_INCREMENT, mapname varchar(255), startX int(16), startY int(16), startZ int(16), endX int(16), endY int(16), endZ int(16), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_settings` (`id` smallint unsigned NOT NULL AUTO_INCREMENT, value varchar(255), name varchar(255), serverid tinyint(3) unsigned, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_player_inventory` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), itemtype tinyint unsigned, name varchar(255), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_player_fields` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_player_outfit` (`id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), slot int(8) unsigned NOT NULL, item varchar(255), bone varchar(255), pos varchar(255), ang varchar(255), scale varchar(255), color varchar(255), UNIQUE KEY (`id`, `slot`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_ranks` ( `id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(50), serverid int(10), rank varchar(100), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_bans` (`ban_id` int unsigned NOT NULL AUTO_INCREMENT, steamid varchar(100), steamidAdmin varchar(100), name varchar(100), nameAdmin varchar(100), serverid int(8), unbanned tinyint(1), time int(32), timeStart int(32), reason varchar(255), PRIMARY KEY (`ban_id`), UNIQUE KEY `ban_id` (`ban_id`)) ENGINE=MyISAM DEFAULT CHARSET=utf8;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_ranks_config` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, name varchar(100), prettyname varchar(200), power int(16), PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_logs` (`id` int unsigned NOT NULL AUTO_INCREMENT, text varchar(255), type tinyint unsigned not null, time int unsigned not null, serverid tinyint unsigned not null, PRIMARY KEY (`id`), UNIQUE KEY `id` (`id`)) ENGINE=InnoDB DEFAULT CHARSET=utf8;")
conn:Query("CREATE TABLE IF NOT EXISTS `es_servers` ( `id` tinyint(3) unsigned NOT NULL AUTO_INCREMENT, ip varchar(100), port int(16) unsigned default 27015, dns varchar(100), name varchar(100), game varchar(100), PRIMARY KEY (`id`), UNIQUE KEY (`id`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;")

-- Load the server ID
hook.Add("InitPostEntity","exclrp.db.loadserverid",function()
	local serverIP,serverPort = ES.GetServerIP(),ES.GetServerPort();
	conn:Query("SELECT id FROM es_servers WHERE ip = '"..serverIP.."' AND port = "..serverPort.." AND game = 'garrysmod' LIMIT 1;",function(res)
		if res[1].data and res[1].data[1] then
			ES.ServerID = res[1].data[1].id

			hook.Call("ESDatabaseReady",GM or GAMEMODE,ES.ServerID,serverIP,serverPort)
		else
			conn:Query("INSERT INTO es_servers SET ip = '"..serverIP.."', port = "..serverPort..", game = 'garrysmod';",function(res)
				ES.ServerID = res[1].lastid

				hook.Call("ESDatabaseReady",GM or GAMEMODE,ES.ServerID,serverIP,serverPort)
				timer.Simple(0,function()
					game.ConsoleCommand("changelevel "..game.GetMap()..";")
				end)
			end)
		end
	end)
end)

-- Alter fields tables
hook.Add("Initialize","exclrp.db.alterfields",function()
	for k,v in pairs(ES.NetworkedVariables)do
				if v.save then
					ES.DebugPrint("Checking player field: "..v.name)
					ES.DBQuery("ALTER TABLE `es_player_fields` ADD "..ES.DBEscape(v.name).." "..v.save..";",ES.Void,ES.Void)
				end
			end

end)

-- Ranks configuration
hook.Add("Initialize","exclrp.db.loadranks",function()
	conn:Query("SELECT * FROM es_ranks_config LIMIT 100;",function(res)
		for k,v in ipairs(res[1].data)do
			ES.SetupRank(v.name,v.prettyname,tonumber(v.power))
		end
	end)
end)
