-- the new main
local mm;
hook.Add("HUDShouldDraw","ES.MM.SupressHUD",function()
	if IsValid(mm) then return false end
end);
--[[local view = {};
hook.Add("CalcView","ES.MMCalcView",function(ply,pos,angles,fov)
	if IsValid(mm) then
		local bone=ply:LookupBone("ValveBiped.Bip01_Head1");

		if bone then
		
			pos,angles=ply:GetBonePosition(bone);

			if pos and angles then

				angles:RotateAroundAxis(angles:Up(),110);
				angles:RotateAroundAxis(angles:Forward(),90);
				angles:RotateAroundAxis(angles:Up(),180);

				view.origin=LerpVector(FrameTime()*10,view.origin,pos);
				view.angles=LerpAngle(FrameTime()*10,view.angles,angles);

				view.fov = fov;
				
				return view

			end
		end
	else
		view.origin=pos;
		view.angles=angles;
	end
end);]]
local fx = {
	["$pp_colour_addr"] = 0, 
	["$pp_colour_addg"] = 0, 
	["$pp_colour_addb"] = 0, 
	["$pp_colour_brightness"] = -.1, 
	["$pp_colour_contrast"] = 1.1, 
	["$pp_colour_colour"] = 0, 
	["$pp_colour_mulr"] = 0, 
	["$pp_colour_mulg"] = 0, 
	["$pp_colour_mulb"] = 0
}
hook.Add("RenderScreenspaceEffects","ES.MMBlackWhite",function()
	if IsValid(mm) then
		fx["$pp_colour_colour"]=Lerp(FrameTime()*8,fx["$pp_colour_colour"],.1);
		DrawColorModify(fx);
	else
		fx["$pp_colour_colour"]=1;
	end
end);
hook.Add("ShouldDrawLocalPlayer","ES.MMDrawLocal",function()
	if IsValid(mm) then
		return true;
	end
end);
local view = {};
local rot=0;
hook.Add("CalcView","ES.MMCalcView",function(ply,pos,angles,fov)
	if not view.origin or not view.angles or not IsValid(mm) then
		view.origin=pos;
		view.angles=angles;
	elseif IsValid(mm) then
		local bone=ply:LookupBone("ValveBiped.Bip01_Spine");

		if bone then
		
			pos,angles=ply:GetBonePosition(bone);

			if pos and angles then

				rot=(rot + (FrameTime() * 6)) % 360;

				angles=ply:GetAngles();
				angles:RotateAroundAxis(angles:Up(),rot);

				local tr=util.TraceLine( {
					start=pos,
					endpos=pos-(angles:Forward()*70),
					filter=ply
				} );

				view.origin = LerpVector(FrameTime(),view.origin,tr.HitPos + angles:Forward()*10);
				view.angles = LerpAngle(FrameTime(),view.angles,angles);
				view.fov = fov;
				
				return view

			end
		end
	end
end);

local helpText = [[ExclServer is an all-in-one server system that handles items, forums, administration and has a plugin framework.
The global currency used to buy items is Bananas. You can earn these bananas simply by playing, or you can purchase then
on the forum.

Bananas can be spent in the shop menu (accessable from this screen).
If you are not familar with ExclServer the best way to get to know it is to simply explore these menus, we would suggest you
to click the 'My account' tab and make a forum account or link your existing account. Doing so will give you 500 bananas.
Bananas are shared across all our servers (including the forums). This means that bananas earned on one server are 
automatically transferred
to all other servers.


ExclServer is created and constructed by Excl.]]

surface.CreateFont("ES.MainMenu.HeadingText",{
	font = "Calibri",
	size = 28,
})
local needvip;
function openNeedVIP(tier)
	if needvip and IsValid(needvip) then needvip:Remove() end
	needvip= vgui.Create("esFrame");
	needvip:SetTitle("VIP Exclusive");
	local l = Label("You need "..tier.." VIP.\nClick on VIP to check out the available VIP tiers.",needvip)
	l:SetPos(15,45);
	l:SizeToContents();
	l:SetColor(COLOR_WHITE);
	needvip:SetSize(15+l:GetWide()+15,45+l:GetTall()+15);
	needvip:Center();
	needvip:MakePopup();
end

local function addCheckbox(help,txt,convar,x,y,oncheck)

	local togOwn = vgui.Create("esToggleButton",help);
	togOwn:SetPos(x,y);
	togOwn:SetSize(help:GetWide()-30,30);
	togOwn.Text = txt
	togOwn.DoClick = function(self)
		if self:GetChecked() then
			LocalPlayer():ConCommand(convar.." 1")
			oncheck(togOwn);
		else
			LocalPlayer():ConCommand(convar.." 0")
			oncheck(togOwn);
		end
	end

	togOwn:SetChecked(GetConVarNumber(convar) == 1);
end

function ES.CreateMainMenu()
	if IsValid(mm) then mm:Remove(); return end
	
	mm = vgui.Create("ESMainMenu");
	mm:SetPos(0,0);
	mm:SetSize(ScrW(),ScrH());
	mm:MakePopup();

	--### main items
	mm:AddButton("Main",Material("icon16/car.png"),function() 
		mm:OpenChoisePanel({
			{icon = Material("exclserver/menuicons/generic.png"), name = "Help",func = function()
				local p = mm:OpenFrame(640)
				p:SetTitle("Help");
				local l = Label(helpText,p);
				l:SetColor(Color(255,255,255,200));
				l:SetPos(15,15);
				l:SizeToContents();
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Settings",func = function()
				local p = mm:OpenFrame(300)
				p:SetTitle("Settings");

				addCheckbox(p,"Disable trails","es_trails_disable",15,15,function()
					timer.Simple(.5,function()
						RunConsoleCommand( "excl_trails_reload")
					end);
				end);
				addCheckbox(p,"Bind ExclServer to F6","es_bind_to_f6",15,15+22+5+22+5,function() end);
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Colors",func = function()
				local p = mm:OpenFrame(300)
				p:SetTitle("Colors");

				local l = Label("Color scheme",p)
				l:SetFont("ES.MainMenu.HeadingText");
				l:SetPos(15,15);
				l:SizeToContents();
				l:SetColor(COLOR_WHITE);

				local f,s,t = ES.GetColorScheme();

				local firstCube = p:Add("DColorMixer");
				local secondCube = p:Add("DColorMixer");
				local thirdCube = p:Add("DColorMixer");

				firstCube:SetPos(15,l.y+l:GetTall()+10);
				firstCube:SetSize(256,200);
				firstCube:SetLabel("Primary Color")
				firstCube:SetColor(f);
				function firstCube:ValueChanged()
					ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())
				end

				
				secondCube:SetPos(15,firstCube.y+firstCube:GetTall()+10);
				secondCube:SetSize(256,200);
				secondCube:SetLabel("Secondary Color")
				secondCube:SetColor(s);
				function secondCube:ValueChanged()
					ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())
				end

				thirdCube:SetPos(15,secondCube.y+firstCube:GetTall()+10);
				thirdCube:SetSize(256,200);
				thirdCube:SetLabel("Third Color")
				thirdCube:SetColor(t);
				function thirdCube:ValueChanged()
					ES.PushColorScheme(firstCube:GetColor(),secondCube:GetColor(),thirdCube:GetColor())
				end

				local b = vgui.Create("esButton",p);
				b:SetSize(100,30);
				b:SetPos(p:GetWide()-100-20,15)
				b:SetText("Reset")
				b.DoClick = function()
					ES.PushColorScheme();
					f,s,t = ES.GetColorScheme();
					firstCube:SetColor(f);
					secondCube:SetColor(s);
					thirdCube:SetColor(t);

					ES.SaveColorScheme();
				end

			end},
		})
	end)
	--mm:AddWhitespace();
	mm:AddButton("Shop",Material("icon16/basket.png"),function() 
		mm:OpenChoisePanel({
			{icon = Material("exclserver/menuicons/generic.png"), name = "Items",func = function()
				ES._MMGenerateShop(mm,"Prop",ES.ITEM_PROP)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Trails",func = function()
				ES._MMGenerateShop(mm,"Trail",ES.ITEM_TRAIL)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Melee",func = function()
				ES._MMGenerateShop(mm,"Melee",ES.ITEM_MELEE)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Models",func = function()
				ES._MMGenerateShop(mm,"Model",ES.ITEM_MODEL)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Auras",func = function()
				ES._MMGenerateShop(mm,"Aura",ES.ITEM_AURA)
			end}
		})
	end)
	mm:AddButton("Inventory",Material("icon16/plugin.png"),function() 
		mm:OpenChoisePanel({
			{icon = Material("exclserver/menuicons/generic.png"), name = "Effects",func = function()
				ES._MMGenerateInventoryEffects(mm)
			end},
			{icon = Material("exclserver/menuicons/generic.png"), name = "Outfit",func = function()

				ES._MMGenerateInventoryOutfit(mm);
				
			end},
		})
	end)

	--mm:AddButton("Crafting",Material("icon16/paintbrush.png"),function() mm:CloseChoisePanel(); openWorkingOnIt() end)
	--mm:AddWhitespace();
	mm:AddButton("VIP",Material("icon16/star.png"),function() 
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(600);
		p:SetTitle("VIP");
		local lblVIPHelp = Label("VIPs are special",p)
		lblVIPHelp:SetFont("ES.MainMenu.HeadingText");
		lblVIPHelp:SetColor(Color(255,255,255,255));
		lblVIPHelp:SetPos(15,15);
		lblVIPHelp:SizeToContents();
		local lblVIPInfo = Label("",p);
		
		local txt = [[VIP is a special status given to special members. You can buy yourself VIP status for 5000 bananas 
per tier.There are 4 VIP tiers: Bronze, Silver, Gold and Carebear.
Being a VIP gives you special benefits in ExclServer that non-VIPs do not have. 
The gamemode ran by the server may also have implemented VIP benefits.

Not enough bananas? If you donate we will give you a reward in the form of bananas.
Go here to donate: www.CasualBananas.com/forums/donate.php, click anywhere on this 
text to copy this URL to your clipboard (in your browser, press CTRL+V in the URL 
field to paste)
Every $1 you donate will get you 1000 bananas.]];
		
		lblVIPInfo:SetFont("ESDefaultBold");
		lblVIPInfo:SetText(txt)
		lblVIPInfo:SizeToContents();
		lblVIPInfo:SetPos(15,lblVIPHelp.y + lblVIPHelp:GetTall() + 25);
		lblVIPInfo:SetColor(Color(255,255,255,200))
		function lblVIPInfo:OnMouseReleased()
			SetClipboardText("www.CasualBananas.com/forums/donate.php")
		end

		local curtier = LocalPlayer():ESGetVIPTier();	
		local tbl = vgui.Create("esTable",p);
		tbl:SetPos(15, lblVIPInfo.y + lblVIPInfo:GetTall() + 50)
		tbl:SetSize(p:GetWide()-30,280);
		tbl:SetRows(5,8);
		tbl.headColors[2] = Color(152,101,0);
		tbl.headColors[3] = Color(180,180,180);
		tbl.headColors[4] = Color(245,184,0);
		tbl.headColors[5] = Color(201,53,71);
		tbl.itemPrice[2] = (1 - curtier) * 5000;

		if tbl.itemPrice[2] < 0 then tbl.itemPrice[2] = 0; end
		tbl.itemPrice[3] = (2 - curtier) * 5000;
		if tbl.itemPrice[3] < 0 then tbl.itemPrice[3] = 0; end
		tbl.itemPrice[4] = (3 - curtier) * 5000;
		if tbl.itemPrice[4] < 0 then tbl.itemPrice[4] = 0; end
		tbl.itemPrice[5] = (4 - curtier) * 5000;
		if tbl.itemPrice[5] < 0 then tbl.itemPrice[5] = 0; end

		tbl.rows[2][1] = "Bronze"
		tbl.rows[3][1] = "Silver"
		tbl.rows[4][1] = "Gold"
		tbl.rows[5][1] = "Carebear"

		tbl.rows[1][2] = "Joke access";
		tbl.rows[2][2] = true;
		tbl.rows[3][2] = true;
		tbl.rows[4][2] = true;
		tbl.rows[5][2] = true;
		tbl.rows[1][3] = "VIP items";
		tbl.rows[2][3] = true;
		tbl.rows[3][3] = true;
		tbl.rows[4][3] = true;
		tbl.rows[5][3] = true;
		tbl.rows[1][4] = "Long trail";
		tbl.rows[3][4] = true;
		tbl.rows[4][4] = true;
		tbl.rows[5][4] = true;
		tbl.rows[1][5] = "Thirdperson";
		tbl.rows[4][5] = true;
		tbl.rows[5][5] = true;
		tbl.rows[1][6] = "Player models";
		tbl.rows[4][6] = true;
		tbl.rows[5][6] = true;
		tbl.rows[1][7] = "Hat particles";
		tbl.rows[5][7] = true;
		tbl.rows[1][8] = "Large trail";
		tbl.rows[2][8] = false;
		tbl.rows[3][8] = false;
		tbl.rows[4][8] = false;
		tbl.rows[5][8] = true;

		tbl.buttons[2]:SetDoClick(function()
			if LocalPlayer():ESGetVIPTier() >= 1 then return end
			RunConsoleCommand("excl","buyvip","1")
			p:GetParent():Remove();
		end)
		tbl.buttons[3]:SetDoClick(function()
			if LocalPlayer():ESGetVIPTier() >= 2 then return end
			RunConsoleCommand("excl","buyvip","2")
			p:GetParent():Remove();
		end)
		tbl.buttons[4]:SetDoClick(function()
			if LocalPlayer():ESGetVIPTier() >= 3 then return end
			RunConsoleCommand("excl","buyvip","3")
			p:GetParent():Remove();
		end)
		tbl.buttons[5]:SetDoClick(function()
			if LocalPlayer():ESGetVIPTier() >= 4 then return end
			RunConsoleCommand("excl","buyvip","4")
			p:GetParent():Remove();
		end)
	end)
	--mm:AddWhitespace();
	mm:AddButton("Achievements",Material("icon16/rosette.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(640)
		p:SetTitle("Achievements");

		local stat = p:Add("esMMPanel");
		stat:SetSize(p:GetWide()-30,60);
		stat:SetPos(15,15);
		stat:SetColor(ES.GetColorScheme(3))

		local cnt = 0;
		for k,v in pairs(ES.Achievements)do
			if LocalPlayer():ESHasCompletedAchievement(k) then
				cnt = cnt+1;
			end
		end
		local lbl = Label(cnt.." / "..table.Count(ES.Achievements).." Unlocked",stat);
		lbl:SetFont("ES.MainMenu.MainElementInfoBnns")
		lbl:SizeToContents();
		lbl:SetPos(12,12);
		lbl:SetColor(COLOR_WHITE);

		local context = p:Add("Panel");
		context:SetSize(p:GetWide()-30,p:GetTall() - (stat:GetTall() + 15 + stat.y + 15));
		context:SetPos(15,stat:GetTall() + 15 + stat.y);
		local y = 0;
		for k,v in pairs(ES.Achievements)do
			local ach = context:Add("esMMPanel");
			ach:SetPos(0,y);
			ach:SetSize(context:GetWide()-15-2,110);

			local ic = ach:Add("DImage");
			ic:SetMaterial(v.icon);
			ic:SetSize(64,64);
			ic:SetPos(8,8);

			local lb2 = Label(v.name,ach);
			lb2:SetFont("ESAchievementFontBig");
			lb2:SetPos(72+6,10);
			lb2:SizeToContents();
			lb2:SetColor(COLOR_WHITE);

			local lbl = Label(v.hidden and !LocalPlayer():ESHasCompletedAchievement(k) and "<secret>" or ES.FormatLine(v.descr,"ESDefault",ach:GetWide() - 80 - 4 - 4) or "Unknown",ach);
			lbl:SetFont("ESDefault");
			lbl:SizeToContents();
			lbl:SetPos(lb2.x+2,lb2.y + lb2:GetTall()+3);
			lbl:SetColor(COLOR_WHITE);

			local dr = vgui.Create("Panel",ach);
			dr:SetPos(5,ach:GetTall()-25);
			dr:SetSize(ach:GetWide() - 10,20);
			local a = ES.GetColorScheme();
			dr.Paint = function(self,w,h)
				draw.RoundedBox(2,0,0,w,h,COLOR_BLACK);

				if (LocalPlayer().excl.achievements and LocalPlayer().excl.achievements[v.id] or 0) > 0 then
					draw.RoundedBox(2,1,1,(w-2)*((LocalPlayer().excl.achievements and LocalPlayer().excl.achievements[v.id] or 0)/ES.Achievements[v.id].progressNeeded),h-2,a);
				end
				draw.SimpleText((LocalPlayer().excl.achievements and LocalPlayer().excl.achievements[v.id] or 0).." / "..ES.Achievements[v.id].progressNeeded,"ESDefaultBoldBlur",w/2,h/2,COLOR_BLACK,1,1);
				--draw.SimpleText(p.excl.achievements[id].." / "..ES.Achievements[id].progressNeeded,"ESDefaultBold",w/2 +1,h/2 +1,COLOR_BLACK,1,1);
				draw.SimpleText((LocalPlayer().excl.achievements and LocalPlayer().excl.achievements[v.id] or 0).." / "..ES.Achievements[v.id].progressNeeded,"ESDefaultBold",w/2,h/2,COLOR_WHITE,1,1);
			end

			y = y + ach:GetTall() + 1;
		end

		local scr = context:Add("esScrollbar");
		scr:SetPos(context:GetWide()-15,0);
		scr:SetSize(15,context:GetTall());
		scr:SetUp()
	end);
	--mm:AddWhitespace();
	mm:AddButton("Server list",Material("icon16/server.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(640)
		p:SetTitle("Servers");
		local page = 1;
		local cbcservers = {};
		local perPage = 4
		local pnls = {};
		local function buildServers()
			for k,v in pairs(pnls)do if v and IsValid(v) then v:Remove() end end
			local c = 0;
			for k,v in pairs(cbcservers)do
				if k > (page-1)*perPage and k <= page*perPage then
					
					local row = vgui.Create("esMMServerRow",p);
					row:SetSize(p:GetWide()-30,130);
					row:SetPos(15,15 + c*(130+10));
					row.name = v.name;
					row.ip = v.ip;
					row.mapname = v.mapname;
					row.password = v.password;
					row.players = v.players
					row.maxplayers = v.maxplayers;
					row.mapicon = v.mapicon;

					c=c+1;
					table.insert(pnls,1,row);
				end
			end
		end

		local lblPage = Label("Page 1/1",p);
		http.Fetch("http://casualbananas.com/forums/inc/servers/cache/servers.gmod.json.php",
			function(rtrn)
				if !IsValid(p) then return end

				cbcservers = util.JSONToTable(rtrn);
				perPage = 0;
				local tall = 15+15+34+15+128;
				while tall < p:GetTall() do
					perPage = perPage+1;
					tall = tall + 138;
				end

				buildServers();

				lblPage:SetText(page.."/"..math.ceil(#cbcservers/perPage))				
			end,
			function()end
		);
		
		lblPage:SetColor(COLOR_WHITE);
		lblPage:SetFont("ESDefaultBold");
		lblPage:SizeToContents();
		lblPage:SetPos(15+32+10+32+15,p:GetTall()-15-25);
		local butPrev = vgui.Create("esIconButton",p)
				butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
				butPrev:SetSize(32,32);
				butPrev:SetPos(15,p:GetTall()-15-32);
				butPrev.DoClick = function(self)
					page = page - 1;
					if page < 0 then page = 1 return end;

					buildServers();

					
					lblPage:SetText(page.."/"..math.ceil(#cbcservers/perPage))
				end
				butPrev.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					if page-1 < 0 then
						surface.SetDrawColor(Color(150,150,150));
					else
						surface.SetDrawColor(COLOR_WHITE);
					end
					
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);

				end
			local butNext = vgui.Create("esIconButton",p)
				butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
				butNext:SetSize(32,32);
				butNext:SetPos(butPrev.x+32+10,butPrev.y);
				butNext.DoClick = function(self)
					page = page + 1;
					if page > math.ceil(#cbcservers/perPage) then 
						page = math.ceil(#cbcservers/perPage) 
						return;
					end

					buildServers();

					lblPage:SetText(page.."/"..math.ceil(#cbcservers/perPage))
				end
				butNext.Paint = function(self,w,h)
					if not self.Mat then return end
					
					surface.SetMaterial(self.Mat)
					--if !models[page+1] then
					--	surface.SetDrawColor(Color(150,150,150));
					--else
						surface.SetDrawColor(COLOR_WHITE);
					--end
					surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);

				end
	end)
	mm:AddButton("Player list",Material("icon16/user.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame(320+320+5+15+15);
		p:SetTitle("Players");

		local context = p:Add("EditablePanel");
		context:SetSize(p:GetWide()-30,p:GetTall()-60);
		context:SetPos(15,15);

		local max = math.floor(context:GetTall()/57);
		local page = 0;
		local tickskip = 0;
		local oldAll;
		function context:Think()
			if not self.rows then 
				self.rows = {} 
			end
			
				for k,v in pairs(player.GetAll())do
					if not v.esMMPlayerRow or not IsValid(v.esMMPlayerRow) then
						v.esMMPlayerRow = vgui.Create("esMMPlayerRow",self);
						v.esMMPlayerRow:Setup(v);
						v.esMMPlayerRow:PerformLayout();
						v.esMMPlayerRow:SetSize(320,52);
						v.esMMPlayerRow:SetPos(0,0);
						table.insert(self.rows,v.esMMPlayerRow);
					end
				end
				local colomn = 0;
				local row = 0;
				local skip = 0;

				for k,v in pairs(self.rows)do
					if not v or not k or not IsValid(v) then continue end

					if IsValid(v) and IsValid(v.Player) and colomn <= 1 and skip >= (page * max * 2) then
						v:SetVisible(true);
						v:SetPos(5 + 325*colomn,(row)*(57))
						row = row + 1;
						if row >= max then
							row = 0;
							colomn = colomn + 1;
						end
					elseif IsValid(v) and not IsValid(v.Player) then
						v:Remove();
					elseif IsValid(v) then
						v:SetVisible(false);
						skip = skip + 1;
					end
				end

		end
		local butPrev = vgui.Create("esIconButton",p)
		butPrev:SetIcon(Material("exclserver/mmarrowicon.png"));
		butPrev:SetSize(32,32);
		butPrev:SetPos(20,p:GetTall()-32-15);
		butPrev.DoClick = function(self)
			page = page - 1;
			if page < 0 then page = 0 end
		end
		butPrev.Paint = function(self,w,h)
			if not self.Mat then return end
						
			surface.SetMaterial(self.Mat)
			surface.SetDrawColor(COLOR_WHITE);
			surface.DrawTexturedRectRotated(w/2,w/2,w,w,180);
		end

		local butNext = vgui.Create("esIconButton",p)
		butNext:SetIcon(Material("exclserver/mmarrowicon.png"));
		butNext:SetSize(32,32);
		butNext:SetPos(butPrev.x + butPrev:GetWide() + 32/2,butPrev.y);
		butNext.DoClick = function(self)
			page = (page + 1)
			if page+1 >  math.ceil( #player.GetAll() / (max*2) ) then
				page =  math.ceil( #player.GetAll() / (max*2) )-1;
			end
		end
		butNext.Paint = function(self,w,h)
			if not self.Mat then return end
						
			surface.SetMaterial(self.Mat)
			surface.SetDrawColor(COLOR_WHITE);
			surface.DrawTexturedRectRotated(w/2,w/2,w,w,0);
		end

		local lblPg = Label("Page 1/1",p);
		lblPg:SetFont("ESDefaultBold");
		lblPg:SetPos(butNext.x + butNext:GetWide() +32/2, butNext.y+1);
		lblPg:SetColor(COLOR_WHITE);
		lblPg:SizeToContents();
		lblPg.Think = function(self)
			self:SetText("Page "..tostring(page+1).."/".. math.ceil( #player.GetAll() / (max*2) ) )
			self:SizeToContents();
		end
	

		local lblPl = Label("0 active players",p);
		lblPl:SetFont("ESDefaultBold");
		lblPl:SetPos(lblPg.x, lblPg.y + lblPg:GetTall() + 1);
		lblPl:SetColor(COLOR_WHITE);
		lblPl:SizeToContents();
		lblPl.Think = function(self)
			self:SetText(#player.GetAll().." active players")
			self:SizeToContents();
		end

		--[[local muteall = p:Add("esButton");
		muteall:SetText("Mute all");
		muteall:SetSize(90,20);
		muteall:SetPos(p:GetWide()-15-90,p:GetTall()-15-20);
		muteall.DoClick = function()
			for k,v in pairs(player.GetAll())do
				if IsValid(v) then
					v:SetMuted(true);
				end
			end
		end
		local unmuteall = p:Add("esButton");
		unmuteall:SetText("Unmute all");
		unmuteall:SetSize(90,20);
		unmuteall:SetPos(muteall.x-15-90,p:GetTall()-15-20);
		unmuteall.DoClick = function()
			for k,v in pairs(player.GetAll())do
				if IsValid(v) then
					v:SetMuted(false);
				end
			end
		end]]
	end)
--mm:AddWhitespace();
mm:AddButton("Website",Material("icon16/world.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame();
		p:SetTitle("Community Website");

		local lbl = Label("Loading...",p);
		lbl:SetFont("ESDefaultBold");
		lbl:SizeToContents();
		lbl:Center();
		lbl:SetColor(COLOR_WHITE);

		local web = vgui.Create("HTML",p);
		web:SetSize(p:GetWide()-2,p:GetTall()-1);
		web:SetPos(1,0);
		web:OpenURL("http://casualbananas.com/")
	end)
	----mm:AddWhitespace();
	--[[mm:AddButton("Music",Material("icon16/sound.png"),function()
		mm:CloseChoisePanel()
		local p = mm:OpenFrame();
		p:SetTitle("Music Player");

		local ply = p:Add("esMMMusicPlayer");
		ply:SetPos(15,15);
		ply:SetSize(p:GetWide()-30,100);
	end)]]

end

net.Receive("ESToggleMenu",function() ES.CreateMainMenu() end);

local was_pressed = false;
hook.Add("Think","exclMMOpenWithF5",function()
	if input.IsKeyDown(KEY_F5) and not was_pressed then
		was_pressed = true;
		ES.CreateMainMenu()
	elseif not input.IsKeyDown(KEY_F5) then
		was_pressed = false;
	end
end)

hook.Add("PlayerBindPress","exclMMSupressJPeg",function(ply, bind, pressed)
	if string.find(bind,"jpeg",0,false) and input.IsKeyDown(KEY_F5) then
		return true;
	end
end);