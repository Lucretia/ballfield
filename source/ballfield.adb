--
--  "Ballfield"
--
--  (C) David Olofson <david@olofson.net>, 2002, 2003
--
--  This software is released under the terms of the GPL.
--
--  Contact author for permission if you want to use this
--  software, or work derived from it, under other terms.

with Ada.Text_IO;

with Ada.Numerics.Elementary_Functions;
with Ada.Numerics.Discrete_Random;
with Ada.Real_Time;

with SDL.Video.Windows.Makers;

with SDL.Images.IO;
with SDL.Events.Events;
with SDL.Events.Keyboards;

package body Ballfield is

   use SDL.Video.Surfaces;

   procedure Debug (Text : String);
   --  Print out debug Text to standard output.

--   procedure Clean_Alpha (Work : out Surface;
--                          S    :     Surface);
   --  Bump areas of low and high alpha to 0% or 100%
   --  respectively, just in case the graphics contains
   --  "alpha noise".

   procedure Load_Zoomed (Sprites   : out Surface;
                          File_Name :     String;
                          Alpha     :     Boolean);
   --  Load and convert an antialiazed, zoomed set of sprites.

   procedure Print_Number (Destin : in out Surface;
                           Font   :        Surface;
                           X, Y   :        Integer;
                           Value  :        String);
   --  Render Value to position (X, Y) on Destin surface with Font.
   --  Value elements must be in "0..9.,-" otherwise element is not output.

   type Koord_Type is new Integer;

   procedure Ballfield_Init (Field : out Ballfield_Type);
   procedure Ballfield_Free (Field : in out Ballfield_Type);
   procedure Ballfield_Init_Frames (Field : in out Ballfield_Type);
   procedure Ballfield_Load_Gfx (Field     : in out Ballfield_Type;
                                 File_Name :        String;
                                 Color     :        Color_Type);
   procedure Ballfield_Move (Field      : in out Ballfield_Type;
                             Dx, Dy, Dz :        Koord_Type);
   procedure Ballfield_Render (Field  : in out Ballfield_Type;
                               Screen : in out Surface);

   procedure Tiled_Back (Back   :        Surface;
                         Screen : in out Surface;
                         Xo, Yo :        Integer);
   --  Draw tiled background image with offset.

   --
   --
   --

   procedure Debug (Text : String) is
   begin
      Ada.Text_IO.Put_Line (Text);
   end Debug;

   -----------------
   -- Clean_Alpha --
   -----------------

--     procedure Clean_Alpha (Work : out surface;
--                            S    :     Surface)
--     is
--        use SDL.Video.Pixel_Formats;
--        subtype Unsigned_32 is Interfaces.Unsigned_32;
--        use type SDL.Video.Pixel_Formats.C.int;
--        --    SDL_Surface *work;
--        Pixels : Natural; --    Uint32*
--        Pp     : Integer;
--        X, Y   : Integer;
--        Size : constant SDL.Sizes := S.Size;
--     begin
--        SDL.Video.Surfaces.Makers.Create (Work,
--                                          -- SDL_SWSURFACE,
--                                          (S.Size.Width, S.Size.Height), 32,
--                                          16#FF_00_00_00#, 16#00_FF_00_00#,
--                                          16#00_00_FF_00#, 16#00_00_00_FF#);
--  --      Work := SDL_CreateRGBSurface
--  (SDL_SWSURFACE, S.Size.Width, S.Size.Height, 32,
--  --                                    16#Ff_00_00_00#, 16#00_FF_00_00#,
--  --                                    16#00_00_FF_00#, 16#00_00_00_FF#);

--        --    if(!work)
--  --            return NULL;

--        declare
--           use SDL.Video.Rectangles;
--           R  : Rectangle := (0, 0, S.Size.Width, S.Size.Height);
--           SA : Rectangle := (0,0,0,0);
--        begin
--           Work.Blit (R, S, SA);
--        end;
--  --              if(SDL_BlitSurface(s, &r, work, NULL) < 0)
--  --      {
--  --              SDL_FreeSurface(work);
--  --              return NULL;
--  --      end if;

--        Work.Lock;

--        Pixels := Work.Pixels;
--        Pp := Work.Pitch / (Unsigned_32'Size / 8);

--        for Y in 0 .. Work.Size.Height - 1 loop
--           for X in 0 .. Work.Size.Width - 1 loop

--              declare
--                 Pix : Unsigned_32 := Pixels (Y * pp + X);
--              begin
--                 case Pix mod 16#100# / 2**4 is
--                    when 0      =>  pix := 16#00000000#;
--                    when others =>  null;
--                    when 15     =>  Pix := Pix or 16#FF#;
--                 end case;

--                 Pixels (Y * pp + X) := Pix;
--              end;
--           end loop;
--        end loop;

--        Work.Unlock;

--        --return work;
--     end Clean_Alpha;

   -----------------
   -- Load_Zoomed --
   -----------------

   procedure Load_Zoomed (Sprites   : out Surface;
                          File_Name :     String;
                          Alpha     :     Boolean)
   is
--      Sprites : SDL.Video.Surfaces.Surface;
--      Temp    : SDL.Video.Surfaces.Surface;
   begin
--      SDL.Images.IO.Create (Temp, File_Name);
      SDL.Images.IO.Create (Sprites, File_Name);


--      Sprites := Temp;

      --  SDL.Video.Textures.Set_Alpha (Sprites, 200);  -- SDL_RLEACCEL, 255);
--      Clean_Alpha (Temp, Sprites);

      --      Sprites.Finalize; -- SDL_FreeSurface (Sprites);

--      if(!temp)
--      {
--              fprintf(stderr, "Could not clean alpha!\n");
--              return NULL;
--      }

      if Alpha then
         null;
         --  SDL.Video.Textures.Set_Alpha (Temp, 0);
         --  SDL_SRCALPHA or SDL_RLEACCEL, 0);
         --  Sprites := SDL_DisplayFormatAlpha (Temp);
      else
         null;
         --           SDL.Video.Surfaces.Set_Colour_Key
--             (Temp, -- SDL_SRCCOLORKEY or SDL_RLEACCEL,
--              Now    => SDL.Video.Pixel_Formats.To_Pixel
--  (Temp.Pixel_Format,0,0,0),
--              --SDL_MapRGB (Temp.format, 0, 0, 0),
--              Enable => True);
--           --Sprites := SDL_DisplayFormat (Temp);
      end if;
      --  SDL_FreeSurface(temp);

      --  return Sprites;
   end Load_Zoomed;

   ------------------
   -- Print_Number --
   ------------------

   procedure Print_Number (Destin : in out Surface;
                           Font   :        Surface;
                           X, Y   :        Integer;
                           Value  :        String)
   is
      use SDL.Video.Rectangles, SDL.C;
      Character_Width  : constant int := 7;
      Character_Height : constant int := 10;

      subtype Character_Index is Integer range 0 .. 11;
      Character_Zero   : constant Character_Index := 0;
      Character_Minus  : constant Character_Index := 10;
      Character_Point  : constant Character_Index := 11;
      Char             : Character_Index;
      Good_Character   : Boolean;

      From : Rectangle := (0, 0,
                           Width  => Character_Width,
                           Height => Character_Height);
      To   : Rectangle;
   begin
      for Pos in Value'Range loop

         Good_Character := True;
         case Value (Pos) is
            when '0' .. '9' => Char := (Character_Zero
                                          + Character'Pos (Value (Pos))
                                          - Character'Pos ('0'));
            when '-'        => Char := Character_Minus;
            when '.' | ','  => Char := Character_Point;
            when others     => Good_Character := False;
         end case;

         if Good_Character then

            From.X := int (Char) * Character_Width;

            To.X := int (X) + int (Pos - Value'First) * Character_Width;
            To.Y := int (Y);

            Destin.Blit (Source      => Font,
                         Source_Area => From,
                         Self_Area   => To);
         end if;
      end loop;

   end Print_Number;

   ----------------
   -- Initialize --
   ----------------

   procedure Ballfield_Init (Field : out Ballfield_Type) is

      Ball_Types : constant := Ball_Index'Last - Ball_Index'First + 1;
      package Random_Integers
      is new Ada.Numerics.Discrete_Random (Integer);
      use Random_Integers;

      Gen : Generator;
   begin
      Reset (Gen);

      for I in Ball_Index loop

         Field.Points (I).X := Random (Gen) mod 16#20000#;
         Field.Points (I).Y := Random (Gen) mod 16#20000#;
         Field.Points (I).Z := 16#20000# * Integer (I) / Ball_Types;

         if Random (Gen) mod 100 > 80 then
            Field.Points (I).C := Red;
         else
            Field.Points (I).C := Blue;
         end if;

      end loop;
   end Ballfield_Init;

   ----------
   -- Free --
   ----------

   procedure Ballfield_Free (Field : in out Ballfield_Type)
   is
      pragma Unreferenced (Field);
   begin
      for I in Color_Type loop
         null; --  Bf.Gfx (I).Finalize;
      end loop;
   end Ballfield_Free;

   -----------------------
   -- Initialize_Frames --
   -----------------------

   procedure Ballfield_Init_Frames (Field : in out Ballfield_Type)
   is
      use SDL.C;

      J     : int          := 0;
      Width : constant int := Field.Gfx (Blue).Size.Width;

      subtype Index_Range is Natural
      range 0 .. Natural (Width) - 1;

   begin
      --
      --  Set up source rects for all frames
      --
      Field.Frames := new Rectangle_Array'(Index_Range => <>);

      for I in Index_Range loop

         Field.Frames (I) := (X      => 0,
                           Y      => J,
                           Width  => Width - int (I),
                           Height => Width - int (I));

         J := J + Width - int (I);
      end loop;

   end Ballfield_Init_Frames;

   --------------
   -- Load_Gfx --
   --------------

   procedure Ballfield_Load_Gfx (Field     : in out Ballfield_Type;
                                 File_Name :        String;
                                 Color     :        Color_Type) is
   begin
      Load_Zoomed (Field.Gfx (Color),
                   File_Name => File_Name,
                   Alpha     => Field.Use_Alpha);
   end Ballfield_Load_Gfx;

   ----------
   -- Move --
   ----------

   procedure Ballfield_Move (Field : in out Ballfield_Type;
                             Dx, Dy, Dz : Koord_Type) is
   begin
      for Point of Field.Points loop
         Point := (X => (Point.X + Integer (Dx)) mod 16#20000#,
                   Y => (Point.Y + Integer (Dy)) mod 16#20000#,
                   Z => (Point.Z + Integer (Dz)) mod 16#20000#,
                   C => Point.C);
      end loop;
   end Ballfield_Move;

   ------------
   -- Render --
   ------------

   procedure Ballfield_Render (Field     : in out Ballfield_Type;
                               Screen : in out Surface)
   is

      function Find_Z_Maximum return Ball_Index;
      --  Find the ball with the highest Z.

      function Find_Z_Maximum return Ball_Index is
         J_High : Ball_Index := 0;
         Z_High : Integer    := 0;
      begin
         for Index in Ball_Index loop
            if Field.Points (Index).Z > Z_High then
               J_High := Index;
               Z_High := Field.Points (Index).Z;
            end if;
         end loop;
         return J_High;
      end Find_Z_Maximum;

      J : Ball_Index := Find_Z_Maximum;
   begin

      --  Render all balls in back->front order.
      for I in Ball_Index loop
         declare
            use SDL.C;
            R : SDL.Video.Rectangles.Rectangle;
            F : Integer;
            Z : Integer;
         begin
            Z := Field.Points (J).Z;
            Z := Z + 50;

            F := Integer ((Field.Frames (0).Width / 2**12) + 100000) / Z;
            F := Integer (Field.Frames (0).Width) - F;
            F := Integer'Max (0, F);
            F := Integer'Min (F, Integer (Field.Frames (0).Width) - 1);

            Z := Z / 2**7;
            Z := Z + 1;
            R.X := int (Field.Points (J).X - 16#10000#) / int (Z);
            R.Y := int (Field.Points (J).Y - 16#10000#) / int (Z);
            R.X := R.X + (Screen.Size.Width  - Field.Frames (F).Width) / 2;
            R.Y := R.Y + (Screen.Size.Height - Field.Frames (F).Height) / 2;
            Screen.Blit (Source      => Field.Gfx (Field.Points (J).C),
                         Source_Area => Field.Frames (F),
                         Self_Area   => R);
            J := (if J > 0 then J - 1 else Ball_Index'Last);
         end;
      end loop;
   end Ballfield_Render;

   -------------------------------
   -- Other rendering functions --
   -------------------------------

   ---------------
   -- Tile_Back --
   ---------------

   procedure Tiled_Back (Back   :        Surface;
                         Screen : in out Surface;
                         Xo, Yo :        Integer)
   is
      use SDL.C;
      Width  : constant Natural := Natural (Back.Size.Width);
      Height : constant Natural := Natural (Back.Size.Height);

      Xoc    : constant Natural :=
        (Xo + Width  * ((-Xo) / Width + 1))  mod Width;

      Yoc    : constant Natural :=
        (Yo + Height * ((-Yo) / Height + 1)) mod Height;

      X, Y : Integer;
   begin
      Y  := -Yoc;
      while Y < Integer (Screen.Size.Height) loop
         X := -Xoc;
         while X < Integer (Screen.Size.Width) loop
            declare
               R  : SDL.Video.Rectangles.Rectangle := (int (X), int (Y), 0, 0);
               SA : SDL.Video.Rectangles.Rectangle := (0, 0, 0, 0);
            begin
               Screen.Blit (Source      => Back,
                            Source_Area => SA,
                            Self_Area   => R);
            end;
            X := X + Width;
         end loop;
         Y := Y + Height;
      end loop;

   end Tiled_Back;

   ----------
   -- Main --
   ----------

   procedure Main is

      Balls  : Ballfield_Type;
      Window : SDL.Video.Windows.Window;

      Screen : Surface;
      Back   : Surface;
      Logo   : Surface;
      Font   : Surface;

--      bpp    : Integer := 0;
--      flags  : Integer := SDL_DOUBLEBUF or SDL_SWSURFACE;
      Alpha  : constant Boolean := True;
   begin
      if not SDL.Initialise (SDL.Enable_Screen) then
         raise Program_Error with "Could not initialise SDL";
      end if;

--      for(i = 1; i < argc; ++i)
--      {
--              if(strncmp(argv[i], "-na", 3) == 0)
--                      alpha = 0;
--              else if(strncmp(argv[i], "-nd", 3) == 0)
--                      flags &= ~SDL_DOUBLEBUF;
--              else if(strncmp(argv[i], "-h", 2) == 0)
--              {
--                      flags |= SDL_HWSURFACE;
--                      flags &= ~SDL_SWSURFACE;
--              }
--              else if(strncmp(argv[i], "-f", 2) == 0)
--                      flags |= SDL_FULLSCREEN;
--              else
--                      bpp = atoi(&argv[i][1]);
--      end loop;

      SDL.Video.Windows.Makers.Create (Window,
                                       Title    => "Ballfield",
                                       Position => (100, 100),
                                       Size     => (SCREEN_W, SCREEN_H) -- ,
                                       --  Bpp,
                                       ); -- Flags => False); --Flags);
      Screen := Window.Get_Surface;

--      if(flags & SDL_FULLSCREEN)
--              SDL_ShowCursor(0);

      Ballfield_Init (Balls);

      --  Load and prepare balls...
      Balls.Use_Alpha := Alpha;

      Ballfield_Load_Gfx (Balls, Assets_Path & "blueball.png", Blue);
      Ballfield_Load_Gfx (Balls, Assets_Path & "redball.png",  Red);
      Ballfield_Init_Frames (Balls);

      --  Load background image
      SDL.Images.IO.Create (Back, Assets_Path & "redbluestars.png");
--      Back := SDL_DisplayFormat(temp_image);

      --  Load logo
      SDL.Images.IO.Create (Logo, Assets_Path & "logo.bmp");
--      SDL_SetColorKey (temp_image, SDL_SRCCOLORKEY or SDL_RLEACCEL,
--                      SDL_MapRGB (Temp_Image.format, 255, 0, 255));
--      logo := SDL_DisplayFormat (temp_image);

      --  Load font
      SDL.Images.IO.Create (Font, Assets_Path & "font7x10.bmp");
--      SDL_SetColorKey (Temp_Image, SDL_SRCCOLORKEY or SDL_RLEACCEL,
--                       SDL_MapRGB (Temp_Image.format, 255, 0, 255));
--      font := SDL_DisplayFormat (temp_image);

      Dynamic :
      declare
         package FPS_IO is new Ada.Text_IO.Float_IO (Num => Float);
         Number : String (1 .. 5);

         X_Offs : Integer := 0;
         Y_Offs : Integer := 0;

         Tick      : Ada.Real_Time.Time;
         Last_Tick : Ada.Real_Time.Time := Ada.Real_Time.Clock;

         Time       : Long_Float := 0.000;
         Delta_Time : Duration;

         FPS_Count : Integer := 0;
         FPS_Start : Ada.Real_Time.Time := Ada.Real_Time.Clock;
         FPS       : Float := 0.0;
      begin
         loop

            --  Events
            declare
               use SDL.Events;
               Event : SDL.Events.Events.Events;
            begin
               if Events.Poll (Event) then
                  exit when Event.Common.Event_Type = Quit;
                  exit when Event.Common.Event_Type = Keyboards.Key_Down;
               end if;
            end;

            --  Timing
            declare
               use Ada.Real_Time;
            begin
               Tick       := Ada.Real_Time.Clock;
               Delta_Time := To_Duration (Tick - Last_Tick);
               Last_Tick  := Tick;
            end;

            --  Background image
            Tiled_Back (Back, Screen, X_Offs / 2**11, Y_Offs / 2**11);

            --  Ballfield
            Ballfield_Render (Balls, Screen);

            --  Logo
            declare
               use SDL.Video.Rectangles;
               Destin_Area : Rectangle := (2, 2, 0, 0);
               Source_Area : Rectangle := (0, 0, 0, 0);
            begin
               Screen.Blit (Source      => Logo,
                            Source_Area => Source_Area,
                            Self_Area   => Destin_Area);
            end;

            --  FPS counter
            declare
               use Ada.Real_Time;
            begin
               if Tick > FPS_Start + Milliseconds (500) then
                  FPS       := (Float (FPS_Count)
                                  / Float (To_Duration (Tick - FPS_Start)));
                  FPS_Count := 0;
                  FPS_Start := Tick;
               end if;
               FPS_IO.Put (Number, FPS, Exp => 0, Aft => 1);
               Print_Number (Screen, Font,
                             X     => Integer (Screen.Size.Width) - 37,
                             Y     => Integer (Screen.Size.Height) - 12,
                             Value => Number);

               FPS_Count := FPS_Count + 1;
            end;

            --  Update
            Window.Update_Surface;

            --  Animate
            declare
               use Ada.Numerics.Elementary_Functions;

               FT      : constant Float := Float (Time);
               X_Speed : constant Float := 500.0 * Sin (FT * 0.37);
               Y_Speed : constant Float := 500.0 * Sin (FT * 0.53);
               Z_Speed : constant Float := 400.0 * Sin (FT * 0.21);
            begin
               Ballfield_Move (Balls,
                               Koord_Type (X_Speed),
                               Koord_Type (Y_Speed),
                               Koord_Type (Z_Speed));

               X_Offs := X_Offs - Integer (X_Speed);
               Y_Offs := Y_Offs - Integer (Y_Speed);
            end;

            Time := Time + Long_Float (Delta_Time);
         end loop;
      end Dynamic;

      Ballfield_Free (Balls);

      Back.Finalize;
      Logo.Finalize;
      Font.Finalize;

      SDL.Finalise;
      Debug ("##End of Main");
   end Main;

end Ballfield;
