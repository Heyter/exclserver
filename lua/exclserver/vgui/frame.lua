local PANEL = {}
surface.CreateFont( "ESFrameText", { 
font = "Roboto", 
size = 20,
weight=500 } 
)
surface.CreateFont( "ESFrameTextShadow", { 
font = "Roboto", 
size = 20,
weight=500,
blursize=2 } 
)

local tex = Material("exclserver/gradient.png")
function PANEL:Init()
	self.PaintHook = false;
	self.Title = "Hey fuck face, give me a name."
	self.showCloseBut = true;

	if self.ShowCloseButton then
		self:ShowCloseButton(false);
	end
	if self.btnClose then
		self.btnClose:Remove();
		self.btnMaxim:Remove();
		self.btnMinim:Remove();
	end
	
	if self.SetTitle then
		self:SetTitle( "" )
	end
	function self:SetTitle(title)
		self.Title = title;
	end
	self.PerformLayout = function() end
	
end
function PANEL:EnableCloseButton(b)
	self.showCloseBut = b;
	self.OnClose = function() end
end
function PANEL:OnMouseReleased()
	if not self.showCloseBut then return end

    local x, y = gui.MousePos();	
	local xPanel,yPanel = self:GetPos();
	if x > xPanel+self:GetWide()-24 and x < xPanel+self:GetWide()-1 and y > yPanel and y < yPanel+30 then
		if self and self:IsValid() then
			if self.OnClose then
				self.OnClose();
			end	
			self:Remove();
		end
	end
end
--local matShading = Material("exclserver/scanlines.png");
local mat_close = Material("exclserver/close.png")
function PANEL:Paint(w,h)
	local a,b,c = ES.GetColorScheme();

	draw.RoundedBoxEx(4,0,0,w,h,ES.Color["#000000AA"],true,true) 
	draw.RoundedBoxEx(4,1,1,w-2,30,a,true,true) 
	--draw.RoundedBoxEx(4,2,2,w-4,29/2,Color(255,255,255,5),true,true) 

	--[[surface.SetDrawColor(Color(0,0,0,255));
	surface.DrawRect(0,0,w,1);
	surface.DrawRect(0,30-1,w,1);
	surface.DrawRect(0,1,1,30-2);
	surface.DrawRect(w-1,1,1,30-2)]]

	draw.RoundedBoxEx(4,1,30,w-2,h-31,ES.Color["#1E1E1E"],false,false,true,true);
	--surface.SetDrawColor(Color(255,255,255,4));
	--surface.DrawRect(1,31,w-2,h-32) 

	--draw.SimpleText(self.Title,"ESFrameTextBlur",10,4,COLOR_BLACK,0,0);
	draw.SimpleText(string.upper(self.Title),"ESFrameTextShadow",11,30/2+1,ES.Color["#00000022"],0,1);
	draw.SimpleText(string.upper(self.Title),"ESFrameText",10,30/2,COLOR_WHITE,0,1);

	if self.showCloseBut then
		--[[draw.RoundedBoxEx(2,self:GetWide()-45,1,30, 20, Color(255,61,61,255),false,false,true,true)	
		draw.RoundedBoxEx(2,self:GetWide()-44,1,28, 19, Color(255,255,255,40),false,false,true,true)

		local x, y = gui.MousePos();	
		local xPanel,yPanel = self:GetPos();
		if x > xPanel+self:GetWide()-45 and x < xPanel+self:GetWide()-15 and y > yPanel and y < yPanel+20 then
			draw.RoundedBoxEx(2,self:GetWide()-43,2,26, 17, Color(200,150,150,50),false,false,true,false)	
		else
			draw.RoundedBoxEx(2,self:GetWide()-43,2,26, 17, Color(100,50,50,50),false,false,true,false)
		end
]
		draw.SimpleText("x","ESDefaultBold",self:GetWide()-30,2,COLOR_WHITE,1,0);]]

		surface.SetMaterial(mat_close);
		surface.SetDrawColor(ES.Color.White);
		surface.DrawTexturedRect(self:GetWide()-24,15-8,16,16);
	end


	--[[draw.RoundedBox(6,0,0,self:GetWide(), self:GetTall(), Color(10,10,10,200))	
	draw.RoundedBoxEx(6,1,1,self:GetWide()-2, 29, Color(200,200,200,255),true,true,false,false)	
	draw.RoundedBoxEx(6,2,2,self:GetWide()-4, 27, Color(255,255,255,100),true,true,false,false)	
	surface.SetMaterial(tex)
	surface.SetDrawColor(0,0,0,255) //Makes sure the image draws correctly
	surface.DrawTexturedRectRotated(self:GetWide()/2,30,self:GetWide(),60,180)

	draw.RoundedBoxEx(6,1,31,self:GetWide()-2, self:GetTall()-32, Color(230,230,230,255),false,false,true,true)	

	-- Close button
	if self.showCloseBut then
		draw.RoundedBoxEx(4,self:GetWide()-45,1,30, 20, Color(255,61,61,255),false,false,true,true)	
		draw.RoundedBoxEx(4,self:GetWide()-44,1,28, 19, Color(255,255,255,40),false,false,true,true)

		local x, y = gui.MousePos();	
		local xPanel,yPanel = self:GetPos();
		if x > xPanel+self:GetWide()-45 and x < xPanel+self:GetWide()-15 and y > yPanel and y < yPanel+20 then
			draw.RoundedBoxEx(4,self:GetWide()-43,2,26, 17, Color(200,150,150,50),false,false,true,false)	
		else
			draw.RoundedBoxEx(4,self:GetWide()-43,2,26, 17, Color(100,50,50,50),false,false,true,false)
		end

		draw.SimpleText("x","ESDefaultBold",self:GetWide()-30,2,Color(0,0,0,255),1,0);
	end
	-- Text

	draw.SimpleText(self.Title,"ESFrameText",11,4,Color(60,60,60,255),0,0);
	draw.SimpleText(self.Title,"ESFrameText",12,5,Color(0,0,0,80),0,0);
	--draw.SimpleText(self.Discr,"default",15,17,Color(0,0,0,255),0,2);]]
	if self.PaintHook then
		self.PaintHook()
	end
end
vgui.Register( "esFrame", PANEL, "EditablePanel" );