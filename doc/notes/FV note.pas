*TView.Show
    SetState(sfVisible, True);                       { Show the view }  
	
*TView.Hide
	SetState(sfVisible, False);                      { Hide the view }
	
* Procedure TView.SetState
		case AState of
		sfVisible:
			begin
			  if Owner^.State and sfExposed <> 0 then
				SetState(sfExposed, Enable);
			  if Enable then
				DrawShow(nil)
			  else
				DrawHide(nil);
			  if Options and ofSelectable <> 0 then
				Owner^.ResetCurrent;
			end;
		if ((OState xor State) and (sfCursorVis+sfCursorIns+sfFocused))<>0 then
		CursorChanged;
		
	* procedure TView.DrawShow(LastView: PView);
	begin
	  DrawView;
	  if State and sfShadow <> 0 then
	   DrawUnderView(True, LastView);
	end;
	
	* procedure TView.DrawHide(LastView: PView);
	begin
	  TView.DrawCursor;
	  DrawUnderView(State and sfShadow <> 0, LastView);
	end; 
	
* procedure TView.DrawUnderView(DoShadow: Boolean; LastView: PView);
  // it shall invalidate the screen because it is final call on Show/Hide
  // I can't believe : why this method is called after 'DrawView' on DrawShow ?
	var
	  R: TRect;
	begin
	  GetBounds(R);
	  if DoShadow then
	   begin
		 inc(R.B.X,ShadowSize.X);
		 inc(R.B.Y,ShadowSize.Y);
	   end;
	  DrawUnderRect(R, LastView);
	end; 	
	# it's called by:
		- TView.DrawHide
				DrawUnderView(State and sfShadow <> 0, LastView); 				
		- TView.DrawShow
				if State and sfShadow <> 0 then
					DrawUnderView(True, LastView)					
		- TView.SetState 
			sfShadow:
				DrawUnderView(True, nil);   
	
	
	

* procedure TView.DrawUnderRect(var R: TRect; LastView: PView);
  // it shall invalidate the screen because it is final call on Show/Hide
begin
  Owner^.Clip.Intersect(R);
  Owner^.DrawSubViews(NextView, LastView); //it seem as later calls DrawView also. So, DoShow call double DrawView. I guessing.
  Owner^.GetExtent(Owner^.Clip); //reset to bounds
end;

	* procedure TGroup.DrawSubViews(P, Bottom: PView);
		begin
		  if P <> nil then
		   while P <> Bottom do
			begin
			  P^.DrawView;
			  P := P^.NextView;
			end;
		end;
		# it is called by:
			- TView.DrawUnderRec
			- TGroup.Draw;
			- TGroup.Redraw
			


======================================================== HERE CENTRAL OF UPDATE SCREEN =====================================================		
* procedure TView.DrawView;	
  // Primarily, it is called by 'Show' and is NOT called by 'Hide'
  //it's only here. no things such TGroup.DrawView 
begin
  if Exposed then
   begin
     LockScreenUpdate; { don't update the screen yet }
     Draw;
     UnLockScreenUpdate;
     DrawScreenBuf(false); <------------------------------------ CALL VIDEO TO UPDATE ????
     TView.DrawCursor;
   end;
end;
# is called by various, in not less than 56 places
======================================================== HERE CENTRAL OF UPDATE SCREEN =====================================================



			procedure DrawScreenBuf(force:boolean); //views.pas
			begin
			  if (GetLockScreenCount=0) then
			   begin	
				 UpdateScreen(force); //call os-dependent: currentVideo.UpdateScreen
			   end;
			end; 
			
			procedure TGroup.Redraw;
			begin
			  {Lock to prevent screen update.}
			  lockscreenupdate;
			  DrawSubViews(First, nil);
			  unlockscreenupdate;
			  {Draw all views at once, forced update.}
			  drawscreenbuf(true);  <------------------------------------ CALL VIDEO TO UPDATE !!!!
			end; 
			#.Redraws called by:
				- TProgram.GetEvent
						If (Event.What = evKeyDown) then
						Begin
						 if Event.keyCode = kbAltF12 then
						   ReDraw;
						End;
				- TApplication.DosShell; 
				- TGroup.ChangeBounds

			
			
			
	CONST
		MaxViewWidth = 255;                                { Max view width } 
	TYPE
	   TDrawBuffer = Array [0..MaxViewWidth - 1] Of Word; { Draw buffer record }
	   PDrawBuffer = ^TDrawBuffer;                        { Ptr to draw buffer }  
   
	* PROCEDURE TView.Draw;
	VAR B : TDrawBuffer;
	BEGIN
	  MoveChar(B, ' ', GetColor(1), Size.X);
	  WriteLine(0, 0, Size.X, Size.Y, B);
	END; 
	
	* PROCEDURE TGroup.Draw;
	BEGIN
	   If Buffer=Nil then
		 DrawSubViews(First, nil)
	   else
		 WriteBuf(0,0,Size.X,Size.Y,Buffer);
	END;
	
		* procedure TGroup.DrawSubViews(P, Bottom: PView);
		begin
		  if P <> nil then
		   while P <> Bottom do
			begin
			  P^.DrawView;
			  P := P^.NextView;
			end;
		end;
		
		
	* procedure TView.WriteLine(X, Y, W, H: Sw_Integer; var Buf);
	var
	  i:Sw_integer;
	begin
	  if h>0 then
	   for i:=0 to h-1 do
		do_writeView(x,x+w,y+i,buf);
	  DrawScreenBuf(false);
	end; 
	--------------------------------------------
	
	* procedure TView.WriteBuf(X, Y, W, H: Sw_Integer; var Buf);
	var
	  i : Sw_integer;
	begin
	  if h>0 then
	   for i:= 0 to h-1 do
		do_writeView(X,X+W,Y+i,TVideoBuf(Buf)[W*i]);
	end;
	
		* procedure TView.do_WriteView(x1,x2,y:Sw_integer; var Buf);
		begin
		  if (y>=0) and (y<Size.Y) then
		   begin
			 if x1<0 then
			  x1:=0;
			 if x2>Size.X then
			  x2:=Size.X;
			 if x1<x2 then
			  begin
				staticVar2.offset:=x1;
				staticVar2.y:=y;
				staticVar1:=@Buf;
				do_writeViewRec2( x1, x2, @Self, 0 );
			  end;
		   end;
		end; 
		
		* procedure TView.do_writeViewRec2(x1,x2:Sw_integer; p:PView; shadowCounter:Sw_integer);
		var
		  savedStatics : TstatVar2;
		  dx : Sw_integer;
		  G  : PGroup;
		begin
		  G:=P^.Owner;
		  if ((p^.State and sfVisible) <> 0) and (G<>Nil) then
		   begin
			 savedStatics:=staticVar2;
			 inc(staticVar2.y,p^.Origin.Y);
			 dx:=p^.Origin.X;
			 inc(x1,dx);
			 inc(x2,dx);
			 inc(staticVar2.offset,dx);
			 staticVar2.target:=p;
			 if (staticVar2.y >= G^.clip.a.y) and (staticVar2.y < G^.clip.b.y) then
			  begin
				if (x1<g^.clip.a.x) then
				 x1 := g^.clip.a.x;
				if (x2>g^.clip.b.x) then
				 x2 := g^.clip.b.x;
				if x1<x2 then
				 do_writeViewRec1(x1,x2,G^.Last,shadowCounter);
			  end;
			 staticVar2 := savedStatics;
		   end;
		end;       
		
		* procedure TView.do_writeViewRec1(x1,x2:Sw_integer; p:PView; shadowCounter:Sw_integer);
			var
			  G      : PGroup;
			  c      : Word;
			  BufPos,
			  SrcPos,
			  l,dx : Sw_integer;
			begin
			  repeat
				p:=p^.Next;
				if (p=staticVar2.target) then
				 begin
				   G:=p^.Owner;
				   if (G^.buffer<>Nil) then
					begin
					  BufPos:=G^.size.x * staticVar2.y + x1;
					  SrcPos:=x1 - staticVar2.offset;
					  l:=x2-x1;
					  if (shadowCounter=0) then
					   move(staticVar1^[SrcPos],PVideoBuf(G^.buffer)^[BufPos],l shl 1)
					  else
					   begin { paint with shadowAttr }
						 while (l>0) do
						  begin
							c:=staticVar1^[SrcPos];
							WordRec(c).hi:=shadowAttr;
							PVideoBuf(G^.buffer)^[BufPos]:=c;
							inc(BufPos);
							inc(SrcPos);
							dec(l);
						  end;
					   end;
					end;
				   if G^.lockFlag=0 then
					 do_writeViewRec2(x1,x2,G,shadowCounter);
				   exit;
				 end; { p=staticVar2.target }

				if ((p^.state and sfVisible)<>0) and (staticVar2.y>=p^.Origin.Y) then
				 begin
				   if staticVar2.y<p^.Origin.Y+p^.size.Y then
					begin
					  if x1<p^.origin.x then
					   begin
						 if x2<=p^.origin.x then
						  continue;
						 do_writeViewRec1(x1,p^.origin.x,p,shadowCounter);
						 x1:=p^.origin.x;
					   end;
					  dx:=p^.origin.x+p^.size.x;
					  if (x2<=dx) then
					   exit;
					  if (x1<dx) then
					   x1:=dx;
					  inc(dx,shadowSize.x);
					  if ((p^.state and sfShadow)<>0) and (staticVar2.y>=p^.origin.y+shadowSize.y) then
					   if (x1>dx) then
						continue
					   else
						begin
						  inc(shadowCounter);
						  if (x2<=dx) then
						   continue
						  else
						   begin
							 do_writeViewRec1(x1,dx,p,shadowCounter);
							 x1:=dx;
							 dec(shadowCounter);
							 continue;
						   end;
						end
					   else
						continue;
					end;

				   if ((p^.state and sfShadow)<>0) and (staticVar2.y<p^.origin.y+p^.size.y+shadowSize.y) then
					begin
					  dx:=p^.origin.x+shadowSize.x;
					  if x1<dx then
					   begin
						 if x2<=dx then
						  continue;
						 do_writeViewRec1(x1,dx,p,shadowCounter);
						 x1:=dx;
					   end;
					  inc(dx,p^.size.x);
					  if x1>=dx then
					   continue;
					  inc(shadowCounter);
					  if x2<=dx then
					   continue
					  else
					   begin
						 do_writeViewRec1(x1,dx,p,shadowCounter);
						 x1:=dx;
						 dec(shadowCounter);
					   end;
					end;
				 end;
			  until false;
			end;                 
------------------------------------------


* PROCEDURE TView.GetExtent (Var Extent: TRect);
BEGIN
   Extent.A.X := 0;                                   { Zero x field }
   Extent.A.Y := 0;                                   { Zero y field }
   Extent.B.X := Size.X;                              { Return x size }
   Extent.B.Y := Size.Y;                              { Return y size }
END;

CONSTRUCTOR TGroup.Load (Var S: TStream);
VAR I: Sw_Word;
    Count: Word;
    P, Q: ^Pointer; V: PView; OwnerSave: PGroup;
    FixupSave: PFixupList;
BEGIN
   Inherited Load(S);                                 { Call ancestor }
   GetExtent(Clip);                                   { Get view extents }
   OwnerSave := OwnerGroup;                           { Save current group }
   OwnerGroup := @Self;                               { We are current group }
   FixupSave := FixupList;                            { Save current list }
   Count := 0;                                        { Zero count value }
   S.Read(Count, SizeOf(Count));                      { Read entry count }
   If (MaxAvail >= Count*SizeOf(Pointer)) Then Begin  { Memory available }
     GetMem(FixupList, Count*SizeOf(Pointer));        { List size needed }
     FillChar(FixUpList^, Count*SizeOf(Pointer), #0); { Zero all entries }
     For I := 1 To Count Do Begin
       V := PView(S.Get);                             { Get view off stream }
       If (V <> Nil) Then InsertView(V, Nil);         { Insert valid views }
     End;
     V := Last;                                       { Start on last view }
     For I := 1 To Count Do Begin
       V := V^.Next;                                  { Fetch next view }
       P := FixupList^[I];                            { Transfer pointer }
       While (P <> Nil) Do Begin                      { If valid view }
         Q := P;                                      { Copy pointer }
         P := P^;                                     { Fetch pointer }
         Q^ := V;                                     { Transfer view ptr }
       End;
     End;
     FreeMem(FixupList, Count*SizeOf(Pointer));       { Release fixup list }
   End;
   OwnerGroup := OwnerSave;                           { Reload current group }
   FixupList := FixupSave;                            { Reload current list }
   GetSubViewPtr(S, V);                               { Load any subviews }
   SetCurrent(V, NormalSelect);                       { Select current view }
   If (OwnerGroup = Nil) Then Awaken;                 { If topview activate }
END; 
------------------------------
* procedure TView.SetBounds(var Bounds: TRect);
begin
  Origin := Bounds.A;                                { Get first corner }
  Size := Bounds.B;                                 { Get second corner }
  Dec(Size.X,Origin.X);
  Dec(Size.Y,Origin.Y);
end;

* PROCEDURE TView.GetClipRect (Var Clip: TRect);
BEGIN
   GetBounds(Clip);                                   { Get current bounds }
   If (Owner <> Nil) Then Clip.Intersect(Owner^.Clip);{ Intersect with owner }
   Clip.Move(-Origin.X, -Origin.Y);                   { Sub owner origin }
END; 

===================== B U F F E R ==========================
	buffer changed only 3 times:
	
* TGroup = OBJECT (TView)
	 Buffer  : PVideoBuf;                         { Speed up buffer }  
	 
PROCEDURE TProgram.InitScreen;
	{Initscreen is passive only, i.e. it detects the video size and capabilities
	 after initalization. Active video initalization is the task of Tapplication.}
	BEGIN
	  { the orginal code can't be used here because of the limited
		video unit capabilities, the mono modus can't be handled
	  }
	  Drivers.DetectVideo;
	  if (ScreenMode.Col div ScreenMode.Row<2) then
		ShadowSize.X := 1
	  else
		ShadowSize.X := 2;

	  ShadowSize.Y := 1;
	  ShowMarkers := False;
	  if ScreenMode.color then
		AppPalette := apColor
	  else
		AppPalette := apBlackWhite;
	  Buffer := Views.PVideoBuf(VideoBuf); <---------------------------- INIT
	END;	 
	
PROCEDURE TProgram.SetScreenMode (Mode: Word);
	var
	  R: TRect;
	begin
	  HideMouse;
	{  DoneMemory;}
	{  InitMemory;}
	  InitScreen;
	  Buffer := Views.PVideoBuf(VideoBuf); <--------------- RESET
	  R.Assign(0, 0, ScreenWidth, ScreenHeight);
	  ChangeBounds(R);
	  ShowMouse;
	end; 	

procedure TProgram.SetScreenVideoMode(const Mode: TVideoMode);
	var
	  R: TRect;
	begin
	  hidemouse;
	{  DoneMouse;
	  DoneMemory;}
	  ScreenMode:=Mode;
	{  InitMouse;
	  InitMemory;}
	{  InitScreen;
	   Warning: InitScreen calls DetectVideo which
		resets ScreenMode to old value, call it after
		video mode was changed instead of before }
	  Video.SetVideoMode(Mode);

	  { Update ScreenMode to new value }
	  InitScreen;
	  ScreenWidth:=Video.ScreenWidth;
	  ScreenHeight:=Video.ScreenHeight;
	  Buffer := Views.PVideoBuf(VideoBuf); <-------------------- RESET
	  R.Assign(0, 0, ScreenWidth, ScreenHeight);
	  ChangeBounds(R);
	  ShowMouse;
	end;  	
	
	
====================== A P P L I C A T I O N ========================
TYPE
   TProgram = OBJECT (TGroup)    
   TApplication = OBJECT (TProgram)
   TDeskTop = OBJECT (TGroup) 
   
* CONSTRUCTOR TProgram.Init;
	VAR R: TRect;
	BEGIN
	   R.Assign(0, 0, ScreenWidth, ScreenHeight);         { Full screen area }
	   Inherited Init(R);                                 { Call ancestor }
	   Application := PApplication(@Self);                { Set application ptr } <----------------- INIT GLOBAL VAR
	   InitScreen;                                        { Initialize screen }
	   State := sfVisible + sfSelected + sfFocused +
		  sfModal + sfExposed;                            { Deafult states }
	   Options := 0;                                      { No options set }
	   Size.X := ScreenWidth;                             { Set x size value }
	   Size.Y := ScreenHeight;                            { Set y size value }
	   InitStatusLine;                                    { Create status line }
	   InitMenuBar;                                       { Create a bar menu }
	   InitDesktop;                                       { Create desktop }
	   If (Desktop <> Nil) Then Insert(Desktop);          { Insert desktop }
	   If (StatusLine <> Nil) Then Insert(StatusLine);    { Insert status line }
	   If (MenuBar <> Nil) Then Insert(MenuBar);          { Insert menu bar }
	END; 	
	
	* PROCEDURE TGroup.Insert (P: PView);
	BEGIN
	  BeforeInsert(P);
	  InsertBefore(P, First);
	  AfterInsert(P);
	END;  
	
		* TGroup = OBJECT (TView)
			 Phase   : (phFocused, phPreProcess, phPostProcess);
			 EndState: Word;                              { Modal result }
			 Current : PView;                             { Selected subview }
			 Last    : PView;                             { 1st view inserted }
			 Buffer  : PVideoBuf;                         { Speed up buffer }    
			 
		* FUNCTION TGroup.First: PView;
			BEGIN
			   If (Last = Nil) Then First := Nil                  { No first view }
				 Else First := Last^.Next;                        { Return first view }
			END; 
			
		* PROCEDURE TGroup.InsertBefore (P, Target: PView);
		VAR SaveState : Word;
		BEGIN
		   If (P <> Nil) AND (P^.Owner = Nil) AND             { View valid }
		   ((Target = Nil) OR (Target^.Owner = @Self))        { Target valid }
		   Then Begin
			 If (P^.Options AND ofCenterX <> 0) Then     { Centre on x axis }
			   P^.Origin.X := (Size.X - P^.Size.X) div 2;
			 If (P^.Options AND ofCenterY <> 0) Then     { Centre on y axis }
			   P^.Origin.Y := (Size.Y - P^.Size.Y) div 2;
			 SaveState := P^.State;                           { Save view state }
			 P^.Hide;                                         { Make sure hidden }
			 InsertView(P, Target);                           { Insert into list }
			 If (SaveState AND sfVisible <> 0) Then P^.Show;  { Show the view }
			 If (State AND sfActive <> 0) Then                { Was active before }
			   P^.SetState(sfActive , True);                  { Make active again }
		   End;
		END; 
		
		* PROCEDURE TGroup.InsertView (P, Target: PView);
		BEGIN
		   If (P <> Nil) Then Begin                           { Check view is valid }
			 P^.Owner := @Self;                               { Views owner is us }
			 If (Target <> Nil) Then Begin                    { Valid target }
			   Target := Target^.Prev;                        { 1st part of chain }
			   P^.Next := Target^.Next;                       { 2nd part of chain }
			   Target^.Next := P;                             { Chain completed }
			 End Else Begin
			   If (Last <> Nil) Then Begin                    { Not first view }
				 P^.Next := Last^.Next;                       { 1st part of chain }
				 Last^.Next := P;                             { Completed chain }
			   End Else P^.Next := P;                         { 1st chain to self }
			   Last := P;                                     { P is now last }
			 End;
		   End;
		END;    