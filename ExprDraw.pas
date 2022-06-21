unit ExprDraw;

 interface

  uses Windows,Classes,SysUtils,Graphics,Math;

   const efLeft=1;
         efRight=2;
         efNegative=4;
         efRoundBrackets=24;
         efBrackets=16;
         efNumber=32;

         esMuchLess=1;
         esMuchGreater=2;
         esApproxLess=3;
         esApproxGreater=4;
         esPlusMinus=5;
         esMinusPlus=6;
         esAlmostEqual=7;
         //esLessOrEqual=8;
         //esGreaterOrEqual=9;
         esParallel=10;
         esPerpendicular=11;
         esAngle=12;

         esPlus=43;
         esMinus=8722;
         esLess=60;
         esEqual=61;
         esGreater=62;
         esNotEqual=8800;
         esMultiply=183;
         esLessOrEqual=8804;
         esGreaterOrEqual=8805;
         esApproxEqual=8776;
         esCrossMultiply=215;
         esDivide=247;
         esTilde=126;
         esEquivalent=8801;
         esArrow=8594;
         esSlash=47;

         esEllipsis=8230;
         esInfinum=8734;
         esPartDiff=8706;

         tcWidth=1 shl 0;
         tcHeight=1 shl 1;
         tcPowerXPos=1 shl 2;
         tcPowerYPos=1 shl 3;
         tcIndexXPos=1 shl 4;
         tcIndexYPos=1 shl 5;
         tcCapDX=1 shl 6;
         tcCapDY=1 shl 7;
         tcMidLineUp=1 shl 8;
         tcMidlineDn=1 shl 9;
         tcCellSize=1 shl 10;
         tcSymbolWidth=1 shl 10;
         tcSymbolHeight=1 shl 11;

    type TExprOrigin=(eoTop,eoBottom);

         TExprHorAlign=(ehLeft,ehCenter,ehRight);
         TExprVertAlign=(evTop,evCenter,evBottom);

         TExprBracket=(ebNone,ebRound,ebSquare,ebFigure,ebModule);

         TExprCapStyle=(ecPoints,ecVector,ecCap,ecTilde,ecLine);

         TExprClass=class
                     private
                      FParent:TExprClass;
                      FNext:TExprClass;
                      FColor:TColor;
                      FFont:TFont;
                      FWidth,FHeight,FMidLineUp,FMidLineDn,FPowerXPos,FPowerYPos,FIndexXPos,FIndexYPos,FCapDY,FCapDXLeft,FCapDXRight:Integer;
                      FCanvas:TCanvas;
                      ToChange:Cardinal;
                      procedure SetNext(Value:TExprClass);
                      function GetColor:TColor;
                      procedure SetLineWidth;
                      procedure SetFont(NewFont:TFont);
                      procedure SetCanvas(Value:TCanvas);
                      procedure SetColor(Value:TColor);
                      procedure FontNotify(Sender:TObject);
                      function GetWidth:Integer;
                      function GetHeight:Integer;
                      function GetMidLineUp:Integer;
                      function GetMidLineDn:Integer;
                      function GetPowerXPos:Integer;
                      function GetPowerYPos:Integer;
                      function GetIndexXPos:Integer;
                      function GetIndexYPos:Integer;
                      function GetCapDXLeft:Integer;
                      function GetCapDXRight:Integer;
                      function GetCapDY:Integer;
                      procedure SetParent(Value:TExprClass);
                     protected
                      WX,WY:Integer;
                      RWX,RWY:Extended;
                      property Parent:TExprClass read FParent write SetParent;
                      procedure DynaSetFont;dynamic;
                      procedure DynaSetCanvas;dynamic;
                      procedure SetCanvasFont;dynamic;
                      procedure SetPenAndBrush;
                      procedure ConvertCoords(var X,Y:Integer;HorAlign:TExprHorAlign;VertAlign:TExprVertAlign);
                      procedure AssignCanvas(Value:TCanvas;EWX,EWY:Integer;ERWX,ERWY:Extended);
                      procedure AssignFont(NewFont:TFont;EWX,EWY:Integer;ERWX,ERWY:Extended);
                      procedure Paint(X,Y:Integer);dynamic;
                      function NeedBrackets:Boolean;dynamic;
                      function ArgNeedBrackets:Boolean;dynamic;
                      function CalcWidth:Integer;dynamic;
                      function CalcHeight:Integer;dynamic;
                      function CalcMidLine(Origin:TExprOrigin):Integer;dynamic;
                      function CalcPowerXPos:Integer;dynamic;
                      function CalcIndexXPos:Integer;dynamic;
                      function CalcPowerYPos:Integer;dynamic;
                      function CalcIndexYPos:Integer;dynamic;
                      function CalcCapDY:Integer;dynamic;
                      procedure CalcCapDX(var DLeft,DRight:Integer);dynamic;
                     public
                      property Next:TExprClass read FNext write SetNext;
                      property Color:TColor read GetColor write SetColor;
                      property Font:TFont read FFont write SetFont;
                      property Canvas:TCanvas read FCanvas write SetCanvas;
                      property Width:Integer read GetWidth;
                      property Height:Integer read GetHeight;
                      property MidLineUp:Integer read GetMidLineUp;
                      property MidLineDn:Integer read GetMidLineDn;
                      property PowerXPos:Integer read GetPowerXPos;
                      property PowerYPos:Integer read GetPowerYPos;
                      property IndexXPos:Integer read GetIndexXPos;
                      property IndexYPos:Integer read GetIndexYPos;
                      property CapDXLeft:Integer read GetCapDXLeft;
                      property CapDXRight:Integer read GetCapDXRight;
                      property CapDY:Integer read GetCapDY;
                      function FTType:Integer;dynamic;
                      constructor Create;
                      destructor Destroy;override;
                      procedure AddNext(Value:TExprClass);
                      function CutOff:TExprClass;
                      procedure Draw(X,Y:Integer;HorAlign:TExprHorAlign;VertAlign:TExprVertAlign);
                    end;

         TExprParent=class(TExprClass)
                      private
                       FSon:TExprClass;
                       procedure SetSon(Value:TExprClass);
                       procedure SetSonFont;dynamic;
                       procedure SetSonCanvas;dynamic;
                      protected
                       procedure DynaSetFont;override;
                       procedure DynaSetCanvas;override;
                      public
                       property Son:TExprClass read FSon write SetSon;
                       constructor Create(ASon:TExprClass);
                       destructor Destroy;override;
                       function CutOffSon:TExprClass;
                     end;

         TExprBigParent=class(TExprParent)
                         private
                          FDaughter:TExprClass;
                          procedure SetDaughter(Value:TExprClass);
                          procedure SetDaughterFont;dynamic;
                          procedure SetDaughterCanvas;dynamic;
                         protected
                          procedure DynaSetCanvas;override;
                          procedure DynaSetFont;override;
                         public
                          property Daughter:TExprClass read FDaughter write SetDaughter;
                          constructor Create(ASon,ADaughter:TExprClass);
                          destructor Destroy;override;
                          function CutOffDaughter:TExprClass;
                        end;

         TExprChain=class(TExprParent)
                     private
                      procedure CalcOverAbove(var Over,Above:Integer);
                     protected
                      procedure Paint(X,Y:Integer);override;
                      function CalcCapDY:Integer;override;
                      procedure CalcCapDX(var DLeft,DRight:Integer);override;
                      function CalcMidLine(Origin:TExprOrigin):Integer;override;
                      function CalcWidth:Integer;override;
                      function CalcHeight:Integer;override;
                     public
                      procedure BuildUpChain(Value:TExprClass);
                      function FTType:Integer;override;
                    end;

         TExprSimple=class(TExprClass)
                      protected
                       S:string;
                       procedure Paint(X,Y:Integer);override;
                       function CalcWidth:Integer;override;
                       function CalcHeight:Integer;override;
                       function CalcCapDY:Integer;override;
                      public
                       constructor Create(Expr:string);
                     end;

         TExprVar=class(TExprSimple)
                   protected
                    procedure SetCanvasFont;override;
                    //function CalcCapDY:Integer;override;
                    procedure CalcCapDX(var DLeft,DRight:Integer);override;
                    function CalcPowerXPos:Integer;override;
                    function CalcIndexXPos:Integer;override;
                  end;

         TExprCustomText=class(TExprSimple)
                          protected
                           FFontStyle:TFontStyles;
                           FFontName:string;
                           procedure SetCanvasFont;override;
                          public
                           constructor Create(Expr:string;FontStyle:TFontStyles=[fsBold];FontName:string='Times New Roman');
                         end;

         TExprNumber=class(TExprClass)
                      private
                       FNumber:Extended;
                       SM,SE:string;
                       ExpVal:Boolean;
                       procedure SetNumber(Value:Extended);
                      protected
                       function NumToStr:string;dynamic;
                       function CalcCapDY:Integer;override;
                       procedure Paint(X,Y:Integer);override;
                       function CalcWidth:Integer;override;
                       function CalcHeight:Integer;override;
                       function CalcMidLine(Origin:TExprOrigin):Integer;override;
                      public
                       property Number:Extended read FNumber write SetNumber;
                       constructor Create(A:Extended;ExpForm:Boolean);
                       function FTType:Integer;override;
                     end;

         TExprExpNumber=class(TExprNumber)
                         private
                          FPrecision,FDigits,FMaxDeg:Integer;
                         protected
                          function NumToStr:string;override;
                         public
                          constructor Create(A:Extended;Precision:Integer=4;Digits:Integer=4;MaxDeg:Integer=2);
                        end;

         TExprRatio=class(TExprBigParent)
                     protected
                      procedure Paint(X,Y:Integer);override;
                      function CalcWidth:Integer;override;
                      function CalcHeight:Integer;override;
                      function CalcMidLine(Origin:TExprOrigin):Integer;override;
                    end;

         TExprRoot=class(TExprBigParent)
                    private
                     procedure SetDaughterFont;override;
                     procedure SetDaughterCanvas;override;
                    protected
                     procedure Paint(X,Y:Integer);override;
                     function CalcWidth:Integer;override;
                     function CalcHeight:Integer;override;
                     function CalcMidLine(Origin:TExprOrigin):Integer;override;
                   end;

         TExprBracketed=class(TExprChain)
                         protected
                          Left,Right:TExprBracket;
                          procedure Paint(X,Y:Integer);override;
                          function IsBracketed:Boolean;dynamic;
                          function CalcCapDY:Integer;override;
                          procedure CalcCapDX(var DLeft,DRight:Integer);override;
                          function CalcWidth:Integer;override;
                          function CalcHeight:Integer;override;
                          function CalcMidLine(Origin:TExprOrigin):Integer;override;
                         public
                          constructor Create(ASon:TExprClass;LeftBracket,RightBracket:TExprBracket);
                          function FTType:Integer;override;
                          procedure RemoveBrackets;
                        end;

         TExprRound=class(TExprBracketed)
                     public
                      constructor Create(ASon:TExprClass);
                      function FTType:Integer;override;
                     end;

         TExprExtSymbol=class(TExprClass)
                          Symbol:WideChar;
                         protected
                          procedure Paint(X,Y:Integer);override;
                          function CalcCapDY:Integer;override;
                          procedure CalcCapDX(var DLeft,DRight:Integer);override;
                          function CalcPowerXPos:Integer;override;
                          function CalcWidth:Integer;override;
                          function CalcHeight:Integer;override;
                         public
                          constructor Create(SymbolCode:Integer);
                        end;

         TExprPlank=class(TExprExtSymbol)
                     protected
                      procedure SetCanvasFont;override;
                      function CalcCapDY:Integer;override;
                      procedure CalcCapDX(var DLeft,DRight:Integer);override;
                     public
                      constructor Create;
                     end;

         TExprSign=class(TExprExtSymbol)
                    protected
                     function NeedBrackets:Boolean;override;
                     procedure Paint(X,Y:Integer);override;
                     function CalcCapDY:Integer;override;
                     function CalcWidth:Integer;override;
                    public
                     function FTType:Integer;override;
                   end;

         TExprTwinParent=class(TExprParent)
                          private
                           Twins:array[1..2] of TExprClass;
                           procedure SetTwins(Index:Integer;Value:TExprClass);
                          protected
                           procedure DynaSetFont;override;
                           procedure DynaSetCanvas;override;
                          public
                           property Twin1:TExprClass index 1 read Twins[1] write SetTwins;
                           property Twin2:TExprClass index 2 read Twins[2] write SetTwins;
                           constructor Create(ASon,FirstTwin,SecondTwin:TExprClass);
                           destructor Destroy;override;
                         end;

         TExprIndex=class(TExprTwinParent)
                     protected
                      function CalcCapDY:Integer;override;
                      procedure Paint(X,Y:Integer);override;
                      function CalcWidth:Integer;override;
                      function CalcHeight:Integer;override;
                      function CalcMidLine(Origin:TExprOrigin):Integer;override;
                     public
                      function ArgNeedBrackets:Boolean;override;
                      function FTType:Integer;override;
                    end;

         TExprArgument=class(TExprBracketed)
                        protected
                         ForcedBrackets:Boolean;
                         function IsBracketed:Boolean;override;
                        public
                         constructor Create(ASon:TExprClass);
                         procedure SetBrackets;
                       end;

         TExprCommonFunc=class(TExprBigParent)
                          protected
                           procedure Paint(X,Y:Integer);override;
                           function CalcWidth:Integer;override;
                           function CalcHeight:Integer;override;
                           function CalcMidLine(Origin:TExprOrigin):Integer;override;
                          public
                           function ArgumentNeedBrackets:Boolean;
                           function FTType:Integer;override;
                         end;

         TExprFuncName=class(TExprSimple)
                        protected
                         function ArgNeedBrackets:Boolean;override;
                       end;

         TExprFunc=class(TExprCommonFunc)
                    public
                     constructor Create(FuncName:string;ADaughter:TExprClass);
                   end;

         TExprBase=class(TExprBracketed)
                    protected
                     function IsBracketed:Boolean;override;
                    public
                     constructor Create(ASon:TExprClass);
                   end;

         TExprComma=class(TExprExtSymbol)
                     protected
                      function NeedBrackets:Boolean;override;
                      function CalcCapDY:Integer;override;
                     public
                      constructor Create;
                    end;

         TExprLim=class(TExprParent)
                   protected
                    procedure SetSonFont;override;
                    procedure SetSonCanvas;override;
                    procedure Paint(X,Y:Integer);override;
                    function ArgNeedBrackets:Boolean;override;
                    function CalcWidth:Integer;override;
                    function CalcHeight:Integer;override;
                    function CalcMidLine(Origin:TExprOrigin):Integer;override;
                  end;

         TExprSpace=class(TExprClass)
                     private
                      N:Integer;
                     protected
                      function CalcWidth:Integer;override;
                     public
                      constructor Create(Space:Integer);
                     end;

         TExprStrokes=class(TExprClass)
                       private
                        N:Integer;
                       protected
                        procedure Paint(X,Y:Integer);override;
                        function CalcWidth:Integer;override;
                        function CalcHeight:Integer;override;
                       public
                        constructor Create(Strokes:Integer);
                      end;

         TExprAtValue=class(TExprBigParent)
                       private
                        procedure SetDaughterFont;override;
                        procedure SetDaughterCanvas;override;
                       protected
                        procedure Paint(X,Y:Integer);override;
                        function CalcWidth:Integer;override;
                        function CalcHeight:Integer;override;
                        function CalcMidLine(Origin:TExprOrigin):Integer;override;
                       public
                        function FTType:Integer;override;
                      end;

         TExprCap=class(TExprParent)
                   private
                    Style:TExprCapStyle;
                    N:Integer;
                   protected
                    function CapWidth:Integer;
                    function CapHeight:Integer;
                    function SelfHeight:Integer;
                    function CalcPowerXPos:Integer;override;
                    function CalcPowerYPos:Integer;override;
                    function CalcIndexXPos:Integer;override;
                    function CalcCapDY:Integer;override;
                    procedure Paint(X,Y:Integer);override;
                    function CalcWidth:Integer;override;
                    function CalcHeight:Integer;override;
                    function CalcMidLine(Origin:TExprOrigin):Integer;override;
                   public
                    constructor Create(ASon:TExprClass;CapStyle:TExprCapStyle;Count:Integer);
                    function FTType:Integer;override;
                  end;

         TExprStand=class(TExprParent)
                     private
                      Alg:TExprHorAlign;
                     protected
                      procedure Paint(X,Y:Integer);override;
                      function CalcWidth:Integer;override;
                      function CalcHeight:Integer;override;
                     public
                      constructor Create(ASon:TExprClass;Align:TExprHorAlign);
                    end;

         TExprMatrix=class(TExprParent)
                      private
                       HS,VS:Integer;
                       FCX,FCY:Integer;
                      protected
                       procedure GetCellSize(var CX,CY:Integer);
                       procedure Paint(X,Y:Integer);override;
                       function CalcWidth:Integer;override;
                       function CalcHeight:Integer;override;
                       function GetCellWidth:Integer;
                       function GetCellHeight:Integer;
                      public
                       constructor Create(ASon:TExprClass;HorSize,VertSize:Integer);
                     end;

         TExprGroupOp=class(TExprTwinParent)
                       private
                        FSymbolHeight,FSymbolWidth:Integer;
                       protected
                        function CalcSymbolHeight:Integer;
                        function CalcSymbolWidth:Integer;dynamic;abstract;
                        procedure DrawSymbol(X,Y:Integer);dynamic;abstract;
                        procedure LRDrawSymbol(X,Y:Integer);dynamic;abstract;
                        procedure Paint(X,Y:Integer);override;
                        function GetSymbolWidth:Integer;
                        function GetSymbolHeight:Integer;
                        function CalcWidth:Integer;override;
                        function CalcHeight:Integer;override;
                        function CalcMidLine(Origin:TExprOrigin):Integer;override;
                       public
                        constructor Create(ASon,FirstTwin,SecondTwin:TExprClass);
                      end;

         TExprSumma=class(TExprGroupOp)
                     protected
                      function CalcSymbolWidth:Integer;override;
                      procedure DrawSymbol(X,Y:Integer);override;
                      procedure LRDrawSymbol(X,Y:Integer);override;
                    end;

         TExprProd=class(TExprGroupOp)
                    protected
                     function CalcSymbolWidth:Integer;override;
                     procedure DrawSymbol(X,Y:Integer);override;
                     procedure LRDrawSymbol(X,Y:Integer);override;
                   end;

         TExprCirc=class(TExprGroupOp)
                    protected
                     function CalcSymbolWidth:Integer;override;
                     procedure DrawSymbol(X,Y:Integer);override;
                     procedure LRDrawSymbol(X,Y:Integer);override;
                   end;

         TExprIntegral=class(TExprGroupOp)
                        private
                         K:Integer;
                        protected
                         function CalcSymbolWidth:Integer;override;
                         procedure DrawSymbol(X,Y:Integer);override;
                         procedure LRDrawSymbol(X,Y:Integer);override;
                         procedure DrawHook(H,X,Y:Integer);
                         procedure LRDrawHook(H,X,Y:Integer);
                        public
                         constructor Create(ASon,FirstTwin,SecondTwin:TExprClass;Mult:Integer);
                       end;

         TExprLambda=class(TExprExtSymbol)
                      protected
                       procedure Paint(X,Y:Integer);override;
                      public
                       constructor Create;
                     end;

         TExprNabla=class(TExprExtSymbol)
                     protected
                      procedure Paint(X,Y:Integer);override;
                     public
                      constructor Create;
                    end;

         TExprAsterix=class(TExprSimple)
                       protected
                        procedure Paint(X,Y:Integer);override;
                       public
                        constructor Create;
                      end;

         TExprCase=class(TExprParent)
                    protected
                     procedure Paint(X,Y:Integer);override;
                     function CalcWidth:Integer;override;
                     function CalcHeight:Integer;override;
                   end;

         TExprEmpty=class(TExprClass)
                     protected
                      function CalcHeight:Integer;override;
                    end;

 implementation

  const ASumma:array[1..49] of TPoint=((X:3695;Y:-2777),
                                       (X:3695;Y:-2777),
                                       (X:3480;Y:-2734),
                                       (X:3480;Y:-2734),
                                       (X:3297;Y:-3475),
                                       (X:3050;Y:-3776),
                                       (X:2642;Y:-3904),
                                       (X:2342;Y:-4001),
                                       (X:2062;Y:-4044),
                                       (X:1815;Y:-4044),
                                       (X:1815;Y:-4044),
                                       (X:-2578;Y:-4044),
                                       (X:-2578;Y:-4044),
                                       (X:-2578;Y:-4044),
                                       (X:795;Y:499),
                                       (X:795;Y:499),
                                       (X:795;Y:499),
                                       (X:-2213;Y:4570),
                                       (X:-2213;Y:4570),
                                       (X:-2213;Y:4570),
                                       (X:1761;Y:4570),
                                       (X:1761;Y:4570),
                                       (X:2546;Y:4570),
                                       (X:2975;Y:4184),
                                       (X:3093;Y:3195),
                                       (X:3093;Y:3195),
                                       (X:3308;Y:3195),
                                       (X:3308;Y:3195),
                                       (X:3308;Y:3195),
                                       (X:3158;Y:5000),
                                       (X:3158;Y:5000),
                                       (X:3158;Y:5000),
                                       (X:-3695;Y:5000),
                                       (X:-3695;Y:5000),
                                       (X:-3695;Y:5000),
                                       (X:-3695;Y:4807),
                                       (X:-3695;Y:4807),
                                       (X:-3695;Y:4807),
                                       (X:-107;Y:38),
                                       (X:-107;Y:38),
                                       (X:-107;Y:38),
                                       (X:-3695;Y:-4796),
                                       (X:-3695;Y:-4796),
                                       (X:-3695;Y:-4796),
                                       (X:-3695;Y:-5000),
                                       (X:-3695;Y:-5000),
                                       (X:-3695;Y:-5000),
                                       (X:3351;Y:-5000),
                                       (X:3351;Y:-5000));

        AProd:array[1..76] of TPoint=((X:2132;Y:-3958),
                                      (X:2132;Y:-4560),
                                      (X:1896;Y:-4796),
                                      (X:1262;Y:-4796),
                                      (X:1262;Y:-4796),
                                      (X:1080;Y:-4796),
                                      (X:1080;Y:-4796),
                                      (X:1080;Y:-4796),
                                      (X:1080;Y:-5000),
                                      (X:1080;Y:-5000),
                                      (X:1080;Y:-5000),
                                      (X:4281;Y:-5000),
                                      (X:4281;Y:-5000),
                                      (X:4281;Y:-5000),
                                      (X:4281;Y:-4796),
                                      (X:4281;Y:-4796),
                                      (X:4281;Y:-4796),
                                      (X:4087;Y:-4796),
                                      (X:4087;Y:-4796),
                                      (X:3464;Y:-4796),
                                      (X:3228;Y:-4560),
                                      (X:3228;Y:-3958),
                                      (X:3228;Y:-3958),
                                      (X:3228;Y:3969),
                                      (X:3228;Y:3969),
                                      (X:3228;Y:4560),
                                      (X:3464;Y:4807),
                                      (X:4087;Y:4807),
                                      (X:4087;Y:4807),
                                      (X:4281;Y:4807),
                                      (X:4281;Y:4807),
                                      (X:4281;Y:4807),
                                      (X:4281;Y:5000),
                                      (X:4281;Y:5000),
                                      (X:4281;Y:5000),
                                      (X:-4280;Y:5000),
                                      (X:-4280;Y:5000),
                                      (X:-4280;Y:5000),
                                      (X:-4280;Y:4807),
                                      (X:-4280;Y:4807),
                                      (X:-4280;Y:4807),
                                      (X:-4097;Y:4807),
                                      (X:-4097;Y:4807),
                                      (X:-3453;Y:4807),
                                      (X:-3217;Y:4560),
                                      (X:-3217;Y:3969),
                                      (X:-3217;Y:3969),
                                      (X:-3217;Y:-3958),
                                      (X:-3217;Y:-3958),
                                      (X:-3217;Y:-4560),
                                      (X:-3464;Y:-4796),
                                      (X:-4097;Y:-4796),
                                      (X:-4097;Y:-4796),
                                      (X:-4280;Y:-4796),
                                      (X:-4280;Y:-4796),
                                      (X:-4280;Y:-4796),
                                      (X:-4280;Y:-5000),
                                      (X:-4280;Y:-5000),
                                      (X:-4280;Y:-5000),
                                      (X:-1068;Y:-5000),
                                      (X:-1068;Y:-5000),
                                      (X:-1068;Y:-5000),
                                      (X:-1068;Y:-4796),
                                      (X:-1068;Y:-4796),
                                      (X:-1068;Y:-4796),
                                      (X:-1262;Y:-4796),
                                      (X:-1262;Y:-4796),
                                      (X:-1895;Y:-4796),
                                      (X:-2143;Y:-4560),
                                      (X:-2143;Y:-3958),
                                      (X:-2143;Y:-3958),
                                      (X:-2143;Y:4581),
                                      (X:-2143;Y:4581),
                                      (X:-2143;Y:4581),
                                      (X:2132;Y:4581),
                                      (X:2132;Y:4581));

        AIntegral:array[1..52] of TPoint=((X:960;Y:355),
                                          (X:960;Y:-259),
                                          (X:979;Y:-969),
                                          (X:1017;Y:-1756),
                                          (X:1065;Y:-2630),
                                          (X:1190;Y:-3311),
                                          (X:1190;Y:-3964),
                                          (X:1190;Y:-4175),
                                          (X:1113;Y:-4251),
                                          (X:998;Y:-4251),
                                          (X:835;Y:-4251),
                                          (X:653;Y:-3944),
                                          (X:441;Y:-3944),
                                          (X:192;Y:-3944),
                                          (X:0;Y:-4136),
                                          (X:0;Y:-4424),
                                          (X:0;Y:-4760),
                                          (X:240;Y:-5000),
                                          (X:576;Y:-5000),
                                          (X:825;Y:-5000),
                                          (X:1036;Y:-4894),
                                          (X:1209;Y:-4674),
                                          (X:1478;Y:-4347),
                                          (X:1622;Y:-3704),
                                          (X:1651;Y:-2764),
                                          (X:1699;Y:-1104),
                                          (X:1727;Y:-154),
                                          (X:1727;Y:67),
                                          (X:1727;Y:873),
                                          (X:1660;Y:1929),
                                          (X:1545;Y:3253),
                                          (X:1516;Y:3580),
                                          (X:1497;Y:3810),
                                          (X:1497;Y:3944),
                                          (X:1497;Y:4165),
                                          (X:1583;Y:4251),
                                          (X:1689;Y:4251),
                                          (X:1843;Y:4251),
                                          (X:2092;Y:3983),
                                          (X:2246;Y:3983),
                                          (X:2495;Y:3983),
                                          (X:2687;Y:4184),
                                          (X:2687;Y:4482),
                                          (X:2687;Y:4741),
                                          (X:2409;Y:5000),
                                          (X:2092;Y:5000),
                                          (X:1795;Y:5000),
                                          (X:1459;Y:4789),
                                          (X:1286;Y:4367),
                                          (X:1152;Y:4040),
                                          (X:1075;Y:3628),
                                          (X:1056;Y:3138));

        ABigRing:array[1..13] of TPoint=((X:1343;Y:1343),
                                         (X:604;Y:1343),
                                         (X:0;Y:739),
                                         (X:0;Y:0),
                                         (X:0;Y:-739),
                                         (X:604;Y:-1343),
                                         (X:1343;Y:-1343),
                                         (X:2082;Y:-1343),
                                         (X:2686;Y:-739),
                                         (X:2686;Y:0),
                                         (X:2686;Y:739),
                                         (X:2082;Y:1343),
                                         (X:1343;Y:1343));

        ASmallRing:array[1..13] of TPoint=((X:1343;Y:1037),
                                           (X:757;Y:1037),
                                           (X:306;Y:568),
                                           (X:306;Y:0),
                                           (X:306;Y:-568),
                                           (X:757;Y:-1037),
                                           (X:1343;Y:-1037),
                                           (X:1928;Y:-1037),
                                           (X:2380;Y:-568),
                                           (X:2380;Y:0),
                                           (X:2380;Y:568),
                                           (X:1928;Y:1037),
                                           (X:1343;Y:1037));

   {TExprClass}

   constructor TExprClass.Create;
    begin
     inherited Create;
     FNext:=nil;
     Parent:=nil;
     FColor:=clNone;
     FFont:=TFont.Create;
     FFont.Name:='Times New Roman';
     FFont.Charset:=Russian_Charset;
     FFont.OnChange:=FontNotify;
     FWidth:=0;
     FHeight:=0;
     FMidLineUp:=0;
     FMidLineDn:=0;
     FPowerXPos:=0;
     FPowerYPos:=0;
     FIndexXPos:=0;
     FIndexYPos:=0;
     FCapDXLeft:=0;
     FCapDXRight:=0;
     FCapDY:=0;
     WX:=0;
     WY:=0;
     RWX:=0;
     RWY:=0;
     ToChange:=0;
     FCanvas:=nil
    end;

   destructor TExprClass.Destroy;
    begin
     FNext.Free;
     FFont.Free;
     inherited Destroy
    end;

   procedure TExprClass.SetNext;
    begin
     if Assigned(FNext) then
      FNext.Free;
     FNext:=Value;
     if Assigned(FNext) then
      FNext.Parent:=Parent;
    end;

   procedure TExprClass.SetParent;
    begin
     if FParent<>Value then
      begin
       FParent:=Value;
       if Assigned(FNext) then
        FNext.Parent:=Parent
      end
    end;

   function TExprClass.GetColor;
    begin
     if FColor<>clNone then
      Result:=FColor
     else
      if Assigned(Parent) then
       Result:=Parent.Color
      else
       Result:=clBlack
    end;

   procedure TExprClass.SetColor;
    begin
     if Value<>FColor then
      begin
       FColor:=Value;
       if Assigned(FNext) then
        FNext.Color:=Value
      end
    end;

   procedure TExprClass.SetCanvas;
    begin
     if FCanvas<>Value then
      begin
       FCanvas:=Value;
       if Assigned(Canvas) then
        begin
         ToChange:=$FFFFFFFF;
         SetLineWidth
        end
       else
        ToChange:=0;
       DynaSetCanvas
      end
    end;

   procedure TExprClass.AssignCanvas;
    begin
     if FCanvas<>Value then
      begin
       FCanvas:=Value;
       if Assigned(Canvas) then
        ToChange:=$FFFFFFFF
       else
        ToChange:=0;
       WX:=EWX;
       WY:=EWY;
       RWX:=ERWX;
       RWY:=ERWY;
       DynaSetCanvas
      end
    end;

   procedure TExprClass.SetLineWidth;
    var H:Extended;
        M2:TMat2;
        GM:TGlyphMetrics;
     begin
      SetCanvasFont;
      H:=Canvas.TextHeight('+');
      RWX:=H/27.6;
      RWY:=RWX*GetDeviceCaps(Canvas.Handle,LogPixelSY)/GetDeviceCaps(Canvas.Handle,LogPixelSX);
      ZeroMemory(@M2,SizeOf(M2));
      M2.eM11.value:=1;
      M2.eM22.value:=1;
      GetGlyphOutline(Canvas.Handle,Cardinal('_'),GGO_Metrics,GM,0,nil,M2);
      WY:=GM.gmBlackBoxY;
      WX:=Round(WY*GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY))
     end;

   procedure TExprClass.SetFont;
    begin
     FFont.Assign(NewFont);
     if Assigned(Canvas) then
      SetLineWidth;
     DynaSetFont
    end;

   procedure TExprClass.AssignFont;
    begin
     FFont.Assign(NewFont);
     WX:=EWX;
     WY:=EWY;
     RWX:=ERWX;
     RWY:=ERWY;
     DynaSetFont
    end;

   procedure TExprClass.FontNotify;
    begin
     if Assigned(Canvas) then
      SetLineWidth;
     DynaSetFont
    end;

   procedure TExprClass.DynaSetCanvas;
    begin
     if Assigned(Next) then
      Next.AssignCanvas(Canvas,WX,WY,RWX,RWY)
    end;

   procedure TExprClass.DynaSetFont;
    begin
     ToChange:=$FFFFFFFF;
     if Assigned(Next) then
      Next.AssignFont(Font,WX,WY,RWX,RWY)
    end;

   procedure TExprClass.AddNext;
    var P:TExprClass;
     begin
      P:=Self;
      while Assigned(P.Next) do
       P:=P.Next;
      P.FNext:=Value;
      P.FNext.Font:=Font;
      P.FNext.Canvas:=Canvas
     end;

   function TExprClass.CutOff;
    begin
     Result:=FNext;
     FNext:=nil
    end;

   function TExprClass.NeedBrackets;
    begin
     Result:=False
    end;

   function TExprClass.ArgNeedBrackets;
    begin
     Result:=True
    end;

   function TExprClass.FTType;
    begin
     Result:=efLeft or efRight
    end;

   function TExprClass.CalcPowerXPos;
    begin
     Result:=Width
    end;

   function TExprClass.CalcIndexXPos;
    begin
     Result:=Width
    end;

   function TExprClass.CalcPowerYPos;
    begin
     SetCanvasFont;
     Result:=Canvas.TextHeight('A') div 2
    end;

   function TExprClass.CalcIndexYPos;
    begin
     SetCanvasFont;
     Result:=Height-Canvas.TextHeight('A') div 2-2
    end;

   function TExprClass.CalcCapDY;
    begin
     Result:=0
    end;

   procedure TExprClass.CalcCapDX;
    begin
     DLeft:=0;
     DRight:=0
    end;

   function TExprClass.CalcMidLine;
    begin
     if Origin=eoTop then
      Result:=Height div 2
     else
      Result:=-((Height-1) div 2)
    end;

   procedure TExprClass.SetCanvasFont;
    begin
     Canvas.Font:=Font;
     Canvas.Font.Color:=Color
    end;

   procedure TExprClass.SetPenAndBrush;
    begin
     Canvas.Pen.Style:=psSolid;
     Canvas.Pen.Width:=1;
     Canvas.Pen.Color:=Color;
     Canvas.Brush.Style:=bsSolid;
     Canvas.Brush.Color:=Color
    end;

   procedure TExprClass.ConvertCoords;
    begin
     case HorAlign of
      ehCenter:Dec(X,Width div 2);
      ehRight:Dec(X,Width-1)
     end;
     case VertAlign of
      evCenter:Dec(Y,MidLineUp);
      evBottom:Dec(Y,Height-1)
     end
    end;

   function TExprClass.CalcWidth;
    begin
     Result:=0
    end;

   function TExprClass.CalcHeight;
    begin
     Result:=0
    end;

   procedure TExprClass.Paint;
    begin
    end;

   procedure TExprClass.Draw;
    begin
     ConvertCoords(X,Y,HorAlign,VertAlign);
     {if Self is TExprClass then
      begin
       Canvas.Pen.Color:=clRed;
       Canvas.Brush.Style:=bsClear;
       Canvas.Rectangle(X,Y,X+Width,Y+Height)
      end;}
     SetBkMode(Canvas.Handle,Transparent);
     SetTextAlign(Canvas.Handle,TA_Top or TA_Left);
     SetCanvasFont;
     Paint(X,Y);
    end;

   function TExprClass.GetWidth;
    begin
     if ToChange and tcWidth<>0 then
      begin
       FWidth:=CalcWidth;
       ToChange:=ToChange and not tcWidth
      end;
     Result:=FWidth
    end;

   function TExprClass.GetHeight;
    begin
     if ToChange and tcHeight<>0 then
      begin
       FHeight:=CalcHeight;
       ToChange:=ToChange and not tcHeight
      end;
     Result:=FHeight
    end;

   function TExprClass.GetMidLineUp;
    begin
     if ToChange and tcMidLineUp<>0 then
      begin
       FMidLineUp:=CalcMidLine(eoTop);
       ToChange:=ToChange and not tcMidLineUp
      end;
     Result:=FMidLineUp
    end;

   function TExprClass.GetMidLineDn;
    begin
     if ToChange and tcMidLineDn<>0 then
      begin
       FMidLineDn:=CalcMidLine(eoBottom);
       ToChange:=ToChange and not tcMidLineDn
      end;
     Result:=FMidLineDn
    end;

   function TExprClass.GetPowerXPos;
    begin
     if ToChange and tcPowerXPos<>0 then
      begin
       FPowerXPos:=CalcPowerXPos;
       ToChange:=ToChange and not tcPowerXPos
      end;
     Result:=FPowerXPos
    end;

   function TExprClass.GetPowerYPos;
    begin
     if ToChange and tcPowerYPos<>0 then
      begin
       FPowerYPos:=CalcPowerYPos;
       ToChange:=ToChange and not tcPowerYPos
      end;
     Result:=FPowerYPos
    end;

   function TExprClass.GetIndexXPos;
    begin
     if ToChange and tcIndexXPos<>0 then
      begin
       FIndexXPos:=CalcIndexXPos;
       ToChange:=ToChange and not tcIndexXPos
      end;
     Result:=FIndexXPos
    end;

   function TExprClass.GetIndexYPos;
    begin
     if ToChange and tcIndexYPos<>0 then
      begin
       FIndexYPos:=CalcIndexYPos;
       ToChange:=ToChange and not tcIndexYPos
      end;
     Result:=FIndexYPos
    end;

   function TExprClass.GetCapDXLeft;
    begin
     if ToChange and tcCapDX<>0 then
      begin
       CalcCapDX(FCapDXLeft,FCapDXRight);
       ToChange:=ToChange and not tcCapDX
      end;
     Result:=FCapDXLeft
    end;

   function TExprClass.GetCapDXRight;
    begin
     if ToChange and tcCapDX<>0 then
      begin
       CalcCapDX(FCapDXLeft,FCapDXRight);
       ToChange:=ToChange and not tcCapDX
      end;
     Result:=FCapDXRight
    end;

   function TExprClass.GetCapDY;
    begin
     if ToChange and tcCapDY<>0 then
      begin
       FCapDY:=CalcCapDY;
       ToChange:=ToChange and not tcCapDY
      end;
     Result:=FCapDY
    end;

   {TExprParent}

   constructor TExprParent.Create;
    begin
     inherited Create;
     Son:=ASon
    end;

   destructor TExprParent.Destroy;
    begin
     FSon.Free;
     inherited Destroy
    end;

   procedure TExprParent.SetSon;
    begin
     FSon.Free;
     FSon:=Value;
     if Assigned(FSon) then
      begin
       FSon.Parent:=Self;
       SetSonFont;
       SetSonCanvas
      end;
     ToChange:=$FFFFFFFF
    end;

   procedure TExprParent.DynaSetFont;
    begin
     inherited DynaSetFont;
     SetSonFont
    end;

   procedure TExprParent.DynaSetCanvas;
    begin
     inherited DynaSetCanvas;
     SetSonCanvas
    end;

   procedure TExprParent.SetSonFont;
    begin
     if Assigned(FSon) then
      FSon.AssignFont(Font,WX,WY,RWX,RWY)
    end;

   procedure TExprParent.SetSonCanvas;
    begin
     if Assigned(FSon) then
      Son.AssignCanvas(Canvas,WX,WY,RWX,RWY)
    end;

   function TExprParent.CutOffSon;
    begin
     Result:=FSon;
     FSon:=nil;
     ToChange:=$FFFFFFFF
    end;

   {TExprBigParent}

   constructor TExprBigParent.Create;
    begin
     inherited Create(ASon);
     Daughter:=ADaughter
    end;

   destructor TExprBigParent.Destroy;
    begin
     FDaughter.Free;
     inherited Destroy
    end;

   procedure TExprBigParent.SetDaughter;
    begin
     FDaughter.Free;
     FDaughter:=Value;
     if Assigned(FDaughter) then
      begin
       FDaughter.Parent:=Self;
       SetDaughterFont;
       SetDaughterCanvas
      end;
     ToChange:=$FFFFFFFF
    end;

   procedure TExprBigParent.DynaSetFont;
    begin
     inherited DynaSetFont;
     SetDaughterFont
    end;

   procedure TExprBigParent.DynaSetCanvas;
    begin
     inherited DynaSetCanvas;
     SetDaughterCanvas
    end;

   procedure TExprBigParent.SetDaughterFont;
    begin
     if Assigned(FDaughter) then
      FDaughter.AssignFont(Font,WX,WY,RWX,RWY)
    end;

   procedure TExprBigParent.SetDaughterCanvas;
    begin
     if Assigned(FDaughter) then
      FDaughter.AssignCanvas(Canvas,WX,WY,RWX,RWY)
    end;

   function TExprBigParent.CutOffDaughter;
    begin
     Result:=FDaughter;
     FDaughter:=nil;
     ToChange:=$FFFFFFFF
    end;

   {TExprChain}

   procedure TExprChain.CalcOverAbove;
    var P:TExprClass;
     begin
      Over:=0;
      Above:=0;
      P:=Son;
      while Assigned(P) do
       with P do
        begin
         Over:=MaxIntValue([Over,MidLineUp+1]);
         Above:=MaxIntValue([Above,Height-MidLineUp-1]);
         P:=Next
        end
     end;

   procedure TExprChain.BuildUpChain;
    var P:TExprClass;
     begin
      if Assigned(Son) then
       begin
        P:=Son;
        while Assigned(P.Next) do
         P:=P.Next;
        P.Next:=Value;
        Value.Parent:=Self
       end
      else
       Son:=Value;
      ToChange:=$FFFFFFFF
     end;

   function TExprChain.CalcWidth;
    var P:TExprClass;
     begin
      Result:=0;
      P:=Son;
      while Assigned(P) do
       begin
        Inc(Result,P.Width);
        P:=P.Next
       end
     end;

   function TExprChain.CalcHeight;
    var Over,Above:Integer;
     begin
      CalcOverAbove(Over,Above);
      Result:=Over+Above
     end;

   function TExprChain.CalcMidLine;
    var Over,Above:Integer;
     begin
      CalcOverAbove(Over,Above);
      if Origin=eoTop then
       Result:=Over-1
      else
       Result:=-Above
     end;

   function TExprChain.FTType;
    var P:TExprClass;
     begin
      P:=Son;
      while Assigned(P.Next) do
       P:=P.Next;
      Result:=Son.FTType and efLeft or P.FTType and efRight or Son.FTType and efNegative
     end;

   procedure TExprChain.Paint;
    var P:TExprClass;
     begin
      Inc(Y,MidLineUp);
      P:=Son;
      while Assigned(P) do
       with P do
        begin
         Draw(X,Y,ehLeft,evCenter);
         Inc(X,Width);
         P:=Next
        end
     end;

   function TExprChain.CalcCapDY;
    var P:TExprClass;
        DY:Integer;
     begin
      Result:=MaxInt;
      P:=Son;
      while Assigned(P) do
       begin
        DY:=P.CapDY;
        if DY<Result then
         Result:=DY;
        P:=P.Next
       end
     end;

   procedure TExprChain.CalcCapDX;
    var P:TExprClass;
     begin
      DLeft:=Son.CapDXLeft;
      P:=Son;
      while Assigned(P.Next) do
       P:=P.Next;
      DRight:=P.CapDXRight
     end;

   {TExprSimple}

   constructor TExprSimple.Create;
    begin
     inherited Create;
     S:=Expr
    end;

   function TExprSimple.CalcWidth;
    var ABC:TABC;
     begin
      SetCanvasFont;
      Result:=Canvas.TextWidth(S);
      if GetCharABCWidths(Canvas.Handle,Integer(S[1]),Integer(S[1]),ABC) and (ABC.abcA<0) then
       Dec(Result,ABC.abcA);
      if GetCharABCWidths(Canvas.Handle,Integer(S[Length(S)]),Integer(S[Length(S)]),ABC) and (ABC.abcC<0) then
       Dec(Result,ABC.abcC)
     end;

   function TExprSimple.CalcHeight;
    begin
     SetCanvasFont;
     Result:=Canvas.TextHeight(S)
    end;

   procedure TExprSimple.Paint;
    var ABC:TABC;
     begin
      SetCanvasFont;
      if GetCharABCWidths(Canvas.Handle,Integer(S[1]),Integer(S[1]),ABC) and (ABC.abcA<0) then
       Canvas.TextOut(X-ABC.abcA,Y,S)
      else
       Canvas.TextOut(X,Y,S)
     end;

   function TExprSimple.CalcCapDY;
    var DY:Extended;
     begin
      case S[1] of
       'A'..'Z','À'..'È','Ê'..'ß':DY:=4;
       'a','c','e','g','m'..'s','u'..'z','à'..'è','ê'..'ÿ':DY:=9.5;
       'b','d','f','h','k','l':DY:=4;
       'i','j','t','é','¸':DY:=7;
       '¨','É':DY:=2.5
      else
       DY:=0
      end;
      Result:=Round(DY*RWY)
     end;

   {TExprVar}

   procedure TExprVar.SetCanvasFont;
    begin
     Canvas.Font:=Font;
     Canvas.Font.Style:=Canvas.Font.Style+[fsItalic];
     Canvas.Font.Color:=Color
    end;

   {function TExprVar.CalcCapDY;
    var DY:Extended;
     begin
      case S[1] of
       'A'..'Z':DY:=4;
       'a','c','e','g','m'..'s','u'..'z':DY:=9.5;
       'b','d','f','h','k','l':DY:=4;
       'i','j','t':DY:=7
      else
       DY:=0
      end;
      Result:=Round(DY*RWY)
     end;}

   procedure TExprVar.CalcCapDX;
    var DX:Extended;
     begin
      case S[1] of
       'A','f':DX:=5;
       'B','D'..'F','L','P','R'..'T','Y','Z','a'..'e','g'..'o','q'..'t','y'..'z':DX:=1;
       'C','G'..'K','M'..'O','Q','X','p':DX:=2;
       'U'..'W':DX:=1.5;
       'u','v','w':DX:=-0.5
      else
       DX:=0
      end;
      DLeft:=Round(DX*RWX);
      case S[Length(S)] of
       'A','f':DX:=5.5;
       'B','D'..'F','I','P','R','X':DX:=4;
       'C','G','H','J'..'L','O','Q','S','U'..'W','Y','Z','p':DX:=2;
       'M','N':DX:=1.5;
       'T':DX:=2.4;
       'a'..'e','g','h','k','m'..'o','q'..'s','u'..'z':DX:=1;
       'i','j','l','t':DX:=3
      else
       DX:=0
      end;
      DRight:=Round(DX*RWX)
     end;

   function TExprVar.CalcIndexXPos;
    var DX:Extended;
     begin
      case S[Length(S)] of
       'R':DX:=1.5;
       'W':DX:=6;
       'x':DX:=1;
      else
       DX:=3
      end;
      Result:=inherited CalcIndexXPos-Round(DX*RWX)
     end;

   function TExprVar.CalcPowerXPos;
    var DX:Integer;
     begin
      DX:=0;
      case S[Length(S)] of
       'f','d':DX:=2;
       'r':DX:=1
      end;
      Result:=inherited CalcPowerXPos+Round(DX*RWX)
     end;

   {TExprCustomText}

   constructor TExprCustomText.Create;
    begin
     inherited Create(Expr);
     FFontStyle:=FontStyle;
     FFontName:=FontName
    end;

   procedure TExprCustomText.SetCanvasFont;
    begin
     Canvas.Font:=Font;
     Canvas.Font.Name:=FFontName;
     Canvas.Font.Style:=FFontStyle;
     Canvas.Font.Color:=Color
    end;

   {TExprNumber}

   constructor TExprNumber.Create;
    begin
     inherited Create;
     ExpVal:=ExpForm;
     if A=0 then
      FNumber:=1
     else
      FNumber:=0;
     Number:=A
    end;

   function TExprNumber.NumToStr;
    begin
     if ExpVal then
      Result:=FloatToStrF(Number,ffExponent,14,0)
     else
      Result:=FloatToStr(Number)
    end;

   procedure TExprNumber.SetNumber;
    var S:string;
        P:Integer;
     begin
      if Value<>FNumber then
       begin
        FNumber:=Value;
        S:=NumToStr;
        P:=Pos('E',S);
        if P=0 then
         begin
          SM:=FloatToStr(StrToFloat(S));
          SE:=''
         end
        else
         begin
          SM:=Copy(S,1,P-1);
          SE:=Copy(S,P+1,MaxInt);
          SM:=FloatToStr(StrToFloat(SM));
          if SE[1]='+' then
           Delete(SE,1,1);
          while (SE[1]='0') and (Length(SE)>1) do
           Delete(SE,1,1);
          P:=Pos('.',SM);
          if P>0 then
           begin
            while SM[Length(SM)]='0' do
             Delete(SM,Length(SM),1);
            if SM[Length(SM)]='.' then
             Delete(SM,Length(SM),1)
           end
         end;
        ToChange:=ToChange or tcWidth or tcHeight or tcCapDY
       end
     end;

   function TExprNumber.CalcWidth;
    begin
     SetCanvasFont;
     if SE<>'' then
      begin
       if SM='1' then
        Result:=Canvas.TextWidth('10')
       else
        Result:=Canvas.TextWidth(SM+'·10');
       Canvas.Font.Height:=Round(0.7*Canvas.Font.Height);
       Inc(Result,Canvas.TextWidth(SE))
      end
     else
      Result:=Canvas.TextWidth(SM);
    end;

   function TExprNumber.CalcHeight;
    begin
     SetCanvasFont;
     Result:=Canvas.TextHeight(SM);
     if SE<>'' then
      Result:=Round(1.2*Result)
    end;

   function TExprNumber.CalcCapDY;
    begin
     if SE='' then
      Result:=Round(8*RWY)
     else
      Result:=Round(3*RWY)
    end;

   function TExprNumber.CalcMidLine;
    var H:Integer;
     begin
      if (SE='') then
       Result:=inherited CalcMidLine(Origin)
      else
       begin
        SetCanvasFont;
        H:=Canvas.TextHeight(SM);
        if Origin=eoTop then
         Result:=H div 2+Round(H*0.2)
        else
         Result:=-((H-1) div 2)
       end
     end;

   function TExprNumber.FTType;
    begin
     Result:=efRight or efNegative*Integer(Number<0)
    end;

   procedure TExprNumber.Paint;
    var H,W:Integer;
     begin
      SetCanvasFont;
      if SE='' then
       Canvas.TextOut(X,Y,SM)
      else
       with Canvas do
        begin
         H:=Round(0.2*TextHeight(SM));
         if SM='1' then
          begin
           TextOut(X,Y+H,'10');
           W:=TextWidth('10')
          end
         else
          begin
           TextOut(X,Y+H,SM+'·10');
           W:=TextWidth(SM+'·10')
          end;
         Font.Height:=Round(0.7*Canvas.Font.Height);
         TextOut(X+W,Y,SE)
        end
     end;

   {TExprExpNumber}

   constructor TExprExpNumber.Create;
    begin
     FPrecision:=Precision;
     FDigits:=Digits;
     FMaxDeg:=MaxDeg;
     inherited Create(A,False);
    end;

   function TExprExpNumber.NumToStr;
    begin
     if (FNumber<>0) and (Log10(Abs(FNumber))<=-FMaxDeg) then
      Result:=FloatToStrF(FNumber,ffExponent,FPrecision,1)
     else
      Result:=FloatToStrF(FNumber,ffFixed,FPrecision,FDigits)
    end;

   {TExprRatio}

   function TExprRatio.CalcWidth;
    begin
     Result:=8*WX+MaxIntValue([Son.Width,Daughter.Width])
    end;

   function TExprRatio.CalcHeight;
    begin
     Result:=3*WY+Son.Height+Daughter.Height
    end;

   function TExprRatio.CalcMidLine;
    begin
     if Origin=eoTop then
      Result:=Son.Height+WY+WY div 2
     else
      Result:=-Daughter.Height-WY-WY div 2
    end;

   procedure TExprRatio.Paint;
    var XC,YC:Integer;
     begin
      YC:=MidLineUp;
      XC:=Width div 2;
      Son.Draw(X+XC,Y+YC-WY-WY div 2,ehCenter,evBottom);
      Daughter.Draw(X+XC,Y+YC+WY+WY div 2,ehCenter,evTop);
      with Canvas do
       begin
        SetPenAndBrush;
        Rectangle(X+3*WX,Y+YC-WY div 2,X+Width-3*WX+1,Y+YC+WY div 2+WY and 1)
       end
     end;

   {TExprRoot}

   function TExprRoot.CalcWidth;
    begin
     Result:=Son.Width+8*WX+Round((Son.Height+WY)/2);
     if Assigned(Daughter) then
      Inc(Result,MaxIntValue([0,Daughter.Width-5*WX]))
    end;

   function TExprRoot.CalcHeight;
    begin
     Result:=3*WY+Son.Height;
     if Assigned(Daughter) then
      Inc(Result,MaxIntValue([0,Daughter.Height-4*WY]))
    end;

   function TExprRoot.CalcMidLine;
    begin
     if Origin=eoBottom then
      Result:=Son.MidLineDn
     else
      if Assigned(Daughter) and (Daughter.Height>4*WY) then
       Result:=Son.MidLineUp-WY+Daughter.Height
      else
       Result:=Son.MidLineUp+3*WY
    end;

   procedure TExprRoot.SetDaughterFont;
    var TmpFont:TFont;
     begin
      if Assigned(Daughter) then
       begin
        TmpFont:=TFont.Create;
        TmpFont.Assign(Font);
        TmpFont.Height:=Round(0.7*Font.Height);
        Daughter.Font:=TmpFont;
        TmpFont.Free
       end
     end;

   procedure TExprRoot.SetDaughterCanvas;
    begin
     if Assigned(Daughter) then
      Daughter.Canvas:=Canvas
    end;

   procedure TExprRoot.Paint;
    var DX,DY,I,W,H:Integer;
        Pt:array[1..12] of TPoint;
     begin
      H:=3*WY+Son.Height;
      W:=Son.Width+8*WX+Round((Son.Height+WY)/2);
      Pt[1]:=Point(X+WX,Y+6*WY);
      Pt[2]:=Point(X+6*WX-1,Y+6*WY);
      Pt[3]:=Point(X+6*WX-1,Y+Round(H-3*Sqrt(3)*WY));
      Pt[4]:=Point(X+W-3*WX-Son.Width-WX div 2-1,Y+WY);
      Pt[5]:=Point(X+W-WX-1,Y+WY);
      Pt[6]:=Point(X+W-WX-1,Y+4*WY-1);
      Pt[7]:=Point(X+W-2*WX,Y+4*WY-1);
      Pt[8]:=Point(X+W-2*WX,Y+2*WY-1);
      Pt[9]:=Point(X+W-3*WX-Son.Width-1,Y+2*WY-1);
      Pt[10]:=Point(X+4*WX,Y+H);
      Pt[11]:=Point(X+4*WX,Y+7*WY-1);
      Pt[12]:=Point(X+WX,Y+7*WY-1);
      if Assigned(Daughter) then
       begin
        DX:=MaxIntValue([0,Daughter.Width-5*WX]);
        DY:=MaxIntValue([0,Daughter.Height-4*WY]);
        for I:=1 to 12 do
         begin
          Inc(Pt[I].X,DX);
          Inc(Pt[I].Y,DY)
         end;
        Daughter.Draw(Pt[2].X,Pt[2].Y-WY,ehRight,evBottom)
       end;
      Son.Draw(Pt[9].X,Pt[9].Y+WY,ehLeft,evTop);
      SetPenAndBrush;
      Canvas.Polygon(Pt)
     end;

   {TExprBracketed}

   constructor TExprBracketed.Create;
    begin
     inherited Create(ASon);
     Left:=LeftBracket;
     Right:=RightBracket
    end;

   function TExprBracketed.IsBracketed;
    begin
     Result:=True
    end;

   function TExprBracketed.FTType;
    begin
     if IsBracketed and (Left<>ebNone) and (Right<>ebNone) then
      begin
       Result:=efLeft or efRight or efBrackets;
       if (Left=ebRound) and (Right=ebRound) then
        Result:=Result or efRoundBrackets
      end
     else
      Result:=inherited FTType
    end;

   function TExprBracketed.CalcWidth;
    begin
     Result:=inherited CalcWidth;
     if IsBracketed then
      begin
       case Left of
        ebRound:Inc(Result,Round(Height*0.191192)+2*WX);
        ebSquare:Inc(Result,5*WX);
        ebFigure:Inc(Result,7*WX);
        ebModule:Inc(Result,3*WX)
       end;
       case Right of
        ebRound:Inc(Result,Round(Height*0.191192)+2*WX);
        ebSquare:Inc(Result,5*WX);
        ebFigure:Inc(Result,7*WX);
        ebModule:Inc(Result,3*WX)
       end
      end
    end;

   function TExprBracketed.CalcHeight;
    begin
     Result:=inherited CalcHeight;
     Inc(Result,2*WY);
     if IsBracketed and ((Left=ebFigure) or (Right=ebFigure)) then
      if Odd(Result-WY) then
       Inc(Result)
    end;

   function TExprBracketed.CalcMidLine;
    begin
     if (Origin=eoTop) then
      Result:=inherited CalcMidLine(eoTop)+WY
     else
      begin
       Result:=inherited CalcMidLine(eoBottom)-WY;
       if IsBracketed and ((Left=ebFigure) or (Right=ebFigure)) then
        if Odd(Result-WY) then
         Dec(Result)
      end
    end;

   procedure TExprBracketed.Paint;
    var W,H,KH,DX,N:Integer;
        Pt:array[1..46] of TPoint;
     begin
      if not IsBracketed or ((Left=ebNone) and (Right=ebNone)) then
       inherited Paint(X,Y)
      else
       begin
        W:=inherited CalcWidth;
        H:=Height;
        case Left of
         ebNone:DX:=0;
         ebRound:begin
                  DX:=Round(H*0.191192);
                  Pt[1].X:=X+DX;
                  Pt[1].Y:=Y+WY;
                  Pt[2].X:=X+DX-Round(H*0.156491);
                  Pt[2].Y:=Y+WY+Round(H*0.294316);
                  Pt[3].X:=Pt[2].X;
                  Pt[3].Y:=Y-WY+H-Round(H*0.294316)-1;
                  Pt[4].X:=Pt[1].X;
                  Pt[4].Y:=Y-WY+H-1;
                  Pt[5].X:=X;
                  Pt[5].Y:=Y-WY+H-Round(H*0.273051)-1;
                  Pt[6].X:=X;
                  Pt[6].Y:=Y+WY+Round(H*0.273051);
                  Pt[7].X:=X+DX;
                  Pt[7].Y:=Y+WY;
                  N:=7;
                  Inc(DX,2*WX)
                 end;
         ebSquare:begin
                   DX:=5*WX;
                   Pt[1].X:=X+WX;
                   Pt[1].Y:=Y+WY;
                   Pt[2]:=Pt[1];
                   Pt[3].X:=X+5*WX-1;
                   Pt[3].Y:=Y+WY;
                   Pt[4]:=Pt[3];
                   Pt[5]:=Pt[4];
                   Pt[6].X:=X+5*WX-1;
                   Pt[6].Y:=Y+2*WY-1;
                   Pt[7]:=Pt[6];
                   Pt[8].X:=X+3*WX+2;
                   Pt[8].Y:=Y+2*WY-1;
                   Pt[9].X:=X+3*WX-1;
                   Pt[9].Y:=Y+2*WY-2;
                   Pt[10].X:=X+3*WX-1;
                   Pt[10].Y:=Y+3*WY-1;
                   Pt[11]:=Pt[10];
                   for N:=12 to 22 do
                    begin
                     Pt[N].X:=Pt[23-N].X;
                     Pt[N].Y:=2*Y+H-1-Pt[23-N].Y
                    end;
                   N:=22
                  end;
         ebFigure:begin
                   DX:=7*WX;
                   KH:=(H-11*WY) div 2+1;
                   Pt[1].X:=X+WX;
                   Pt[1].Y:=Y+KH+5*WY-1;
                   Pt[2].X:=X+2*WX-1;
                   Pt[2].Y:=Y+KH+5*WY-1;
                   Pt[3].X:=X+3*WX;
                   Pt[3].Y:=Y+KH+4*WY-2;
                   Pt[4].X:=Pt[3].X;
                   Pt[4].Y:=Y+KH+3*WY-1;
                   Pt[5]:=Pt[4];
                   Pt[6].X:=Pt[5].X;
                   Pt[6].Y:=Y+3*WY-1;
                   Pt[7]:=Pt[6];
                   Pt[8].X:=Pt[7].X;
                   Pt[8].Y:=Y+WY;
                   Pt[9].X:=Pt[7].X+WX;
                   Pt[9].Y:=Y+WY;
                   Pt[10].X:=X+7*WX-1;
                   Pt[10].Y:=Y+WY;
                   Pt[11]:=Pt[10];
                   Pt[12].X:=Pt[10].X;
                   Pt[12].Y:=Y+2*WY-1;
                   Pt[13]:=Pt[12];
                   Pt[14].X:=X+5*WX-1;
                   Pt[14].Y:=Y+2*WY-1;
                   Pt[15]:=Pt[14];
                   Pt[16].X:=X+5*WX-1;
                   Pt[16].Y:=Y+3*WY-1;
                   Pt[17]:=Pt[16];
                   Pt[18].X:=Pt[17].X;
                   Pt[18].Y:=Y+KH+3*WY-1;
                   Pt[19].X:=Pt[18].X;
                   Pt[19].Y:=Pt[4].Y;
                   Pt[20].X:=Pt[19].X;
                   Pt[20].Y:=Pt[3].Y-WY;
                   Pt[21].X:=X+5*WX-2;
                   Pt[21].Y:=Pt[2].Y;
                   Pt[22].X:=X+3*WX-1;
                   Pt[22].Y:=Pt[1].Y;
                   Pt[23]:=Pt[22];
                   for N:=24 to 46 do
                    begin
                     Pt[N].X:=Pt[47-N].X;
                     Pt[N].Y:=2*Y+H-1-Pt[47-N].Y
                    end;
                   N:=46
                  end;
         ebModule:begin
                   DX:=3*WX;
                   Pt[1].X:=X+WX;
                   Pt[1].Y:=Y+WY;
                   Pt[2]:=Pt[1];
                   Pt[3].X:=X+2*WX-1;
                   Pt[3].Y:=Y+WY;
                   Pt[4]:=Pt[3];
                   Pt[5]:=Pt[4];
                   for N:=6 to 10 do
                    begin
                     Pt[N].X:=Pt[11-N].X;
                     Pt[N].Y:=2*Y+H-1-Pt[11-N].Y
                    end;
                   N:=10
                  end;
        end;
        if Left<>ebNone then
         with Canvas do
          begin
           BeginPath(Handle);
           PolyBezier(Slice(Pt,N));
           CloseFigure(Handle);
           EndPath(Handle);
           SetPenAndBrush;
           StrokeAndFillPath(Handle)
          end;
        Inc(DX,X);
        inherited Paint(DX,Y);
        Inc(DX,W);
        case Right of
         ebRound:begin
                  Inc(DX,2*WX);
                  Pt[1].X:=DX-1;
                  Pt[1].Y:=Y+WY;
                  Pt[2].X:=DX+Round(H*0.156491)-1;
                  Pt[2].Y:=Y+WY+Round(H*0.294316);
                  Pt[3].X:=Pt[2].X;
                  Pt[3].Y:=Y-WY+H-Round(H*0.294316)-1;
                  Pt[4].X:=Pt[1].X;
                  Pt[4].Y:=Y-WY+H-1;
                  Pt[5].X:=DX+Round(H*0.191192)-1;
                  Pt[5].Y:=Y-WY+H-Round(H*0.273051)-1;
                  Pt[6].X:=Pt[5].X;
                  Pt[6].Y:=Y+WY+Round(H*0.273051);
                  Pt[7].X:=DX-1;
                  Pt[7].Y:=Y+WY;
                  N:=7
                 end;
         ebSquare:begin
                   Pt[1].X:=DX+4*WX-1;
                   Pt[1].Y:=Y+WY;
                   Pt[2]:=Pt[1];
                   Pt[3].X:=DX;
                   Pt[3].Y:=Y+WY;
                   Pt[4]:=Pt[3];
                   Pt[5]:=Pt[4];
                   Pt[6].X:=DX;
                   Pt[6].Y:=Y+2*WY-1;
                   Pt[7]:=Pt[6];
                   Pt[8].X:=DX+2*WX-3;
                   Pt[8].Y:=Y+2*WY-1;
                   Pt[9].X:=DX+2*WX;
                   Pt[9].Y:=Y+2*WY-2;
                   Pt[10].X:=DX+2*WX;
                   Pt[10].Y:=Y+3*WY-1;
                   Pt[11]:=Pt[10];
                   for N:=12 to 22 do
                    begin
                     Pt[N].X:=Pt[23-N].X;
                     Pt[N].Y:=2*Y+H-1-Pt[23-N].Y
                    end;
                   N:=22
                  end;
         ebFigure:begin
                   KH:=(H-11*WY) div 2+1;
                   Pt[1].X:=DX+6*WX-1;
                   Pt[1].Y:=Y+KH+5*WY-1;
                   Pt[2].X:=DX+5*WX;
                   Pt[2].Y:=Y+KH+5*WY-1;
                   Pt[3].X:=DX+4*WX-1;
                   Pt[3].Y:=Y+KH+4*WY-2;
                   Pt[4].X:=Pt[3].X;
                   Pt[4].Y:=Y+KH+3*WY-1;
                   Pt[5]:=Pt[4];
                   Pt[6].X:=Pt[5].X;
                   Pt[6].Y:=Y+3*WY-1;
                   Pt[7]:=Pt[6];
                   Pt[8].X:=Pt[7].X;
                   Pt[8].Y:=Y+WY;
                   Pt[9].X:=Pt[7].X-WX;
                   Pt[9].Y:=Y+WY;
                   Pt[10].X:=DX;
                   Pt[10].Y:=Y+WY;
                   Pt[11]:=Pt[10];
                   Pt[12].X:=Pt[10].X;
                   Pt[12].Y:=Y+2*WY-1;
                   Pt[13]:=Pt[12];
                   Pt[14].X:=DX+2*WX;
                   Pt[14].Y:=Y+2*WY-1;
                   Pt[15]:=Pt[14];
                   Pt[16].X:=DX+2*WX;
                   Pt[16].Y:=Y+3*WY-1;
                   Pt[17]:=Pt[16];
                   Pt[18].X:=Pt[17].X;
                   Pt[18].Y:=Y+KH+3*WY-1;
                   Pt[19].X:=Pt[18].X;
                   Pt[19].Y:=Pt[4].Y;
                   Pt[20].X:=Pt[19].X;
                   Pt[20].Y:=Pt[3].Y;
                   Pt[21].X:=DX+2*WX+1;
                   Pt[21].Y:=Pt[2].Y;
                   Pt[22].X:=DX+4*WX;
                   Pt[22].Y:=Pt[1].Y;
                   Pt[23]:=Pt[22];
                   for N:=24 to 46 do
                    begin
                     Pt[N].X:=Pt[47-N].X;
                     Pt[N].Y:=2*Y+H-1-Pt[47-N].Y
                    end;
                   N:=46
                  end;
         ebModule:begin
                   Pt[1].X:=DX+WX;
                   Pt[1].Y:=Y+WY;
                   Pt[2]:=Pt[1];
                   Pt[3].X:=DX+2*WX-1;
                   Pt[3].Y:=Y+WY;
                   Pt[4]:=Pt[3];
                   Pt[5]:=Pt[4];
                   for N:=6 to 10 do
                    begin
                     Pt[N].X:=Pt[11-N].X;
                     Pt[N].Y:=2*Y+H-1-Pt[11-N].Y
                    end;
                   N:=10
                  end
        end;
        if Right<>ebNone then
         with Canvas do
          begin
           BeginPath(Handle);
           PolyBezier(Slice(Pt,N));
           CloseFigure(Handle);
           EndPath(Handle);
           SetPenAndBrush;
           StrokeAndFillPath(Handle)
          end
       end
     end;

   function TExprBracketed.CalcCapDY;
    begin
     if IsBRacketed and ((Left<>ebNone) or (Right<>ebNone)) then
      Result:=0
     else
      Result:=inherited CalcCapDY;
    end;

   procedure TExprBracketed.CalcCapDX;
    begin
     if IsBRacketed and ((Left<>ebNone) or (Right<>ebNone)) then
      begin
       DLeft:=0;
       DRight:=0
      end
     else
      inherited CalcCapDX(DLeft,DRight)
    end;

   procedure TExprBracketed.RemoveBrackets;
    begin
     Left:=ebNone;
     Right:=ebNone;
     ToChange:=ToChange or tcWidth or tcHeight or tcCapDX or tcCapDY;
    end;

   {TExprRound}

   constructor TExprRound.Create;
    begin
     inherited Create(ASon,ebRound,ebRound)
    end;

   function TExprRound.FTType;
    begin
     Result:=efLeft or efRight or efBrackets;
    end;

   {TExprExtSymbol}

   constructor TExprExtSymbol.Create;
    begin
     inherited Create;
     Symbol:=WideChar(SymbolCode)
    end;

   function TExprExtSymbol.CalcWidth;
    var Size:TSize;
        ABC:TABC;
     begin
      SetCanvasFont;
      GetTextExtentPoint32W(Canvas.Handle,@Symbol,1,Size);
      Result:=Size.CX;
      if GetCharABCWidths(Canvas.Handle,Integer(Symbol),Integer(Symbol),ABC) then
       begin
        if ABC.abcA<0 then
         Dec(Result,ABC.abcA);
        if ABC.abcC<0 then
         Dec(Result,ABC.abcC)
       end
     end;

   function TExprExtSymbol.CalcHeight;
    var Size:TSize;
     begin
      SetCanvasFont;
      GetTextExtentPoint32W(Canvas.Handle,@Symbol,1,Size);
      Result:=Size.CY
     end;

   procedure TExprExtSymbol.Paint;
    var ABC:TABC;
     begin
      SetCanvasFont;
      if GetCharABCWidths(Canvas.Handle,Integer(Symbol),Integer(Symbol),ABC) and (ABC.abcA<0) then
       TextOutW(Canvas.Handle,X-ABC.abcA,Y,@Symbol,1)
      else
       TextOutW(Canvas.Handle,X,Y,@Symbol,1)
     end;

   function TExprExtSymbol.CalcCapDY;
    var DY:Extended;
     begin
      case Integer(Symbol) of
       913..929,931..937:DY:=4;
       945,947,949,951,953,954,956,957,959..961,963..969:DY:=8.8;
       946,948,950,952,955,958:DY:=4;
       esEllipsis:DY:=MaxInt/RWY-1;
      else
       DY:=0
      end;
      Result:=Round(DY*RWY);
     end;

   procedure TExprExtSymbol.CalcCapDX;
    var DX:Extended;
     begin
      case Integer(Symbol) of
       913,915..929,931..937,952:DX:=1;
      else
       DX:=0
      end;
      DLeft:=Round(DX*RWX);
      case Integer(Symbol) of
       913..929,931..937:DX:=-1;
       949:DX:=1;
       952:DX:=-0.5
      else
       DX:=0
      end;
      DRight:=Round(DX*RWX)
     end;

   function TExprExtSymbol.CalcPowerXPos;
    var DX:Integer;
     begin
      DX:=0;
      case Integer(Symbol) of
       esPartDiff:DX:=2;
      end;
      Result:=inherited CalcPowerXPos+Round(DX*RWX)
     end;

   {TExprPlank}

   constructor TExprPlank.Create;
    begin
     inherited Create(295)
    end;

   procedure TExprPlank.SetCanvasFont;
    begin
     inherited SetCanvasFont;
     Canvas.Font.Style:=Canvas.Font.Style+[fsItalic]
    end;

   function TExprPlank.CalcCapDY;
    begin
     Result:=Round(4*RWY)
    end;

   procedure TExprPlank.CalcCapDX;
    begin
     DLeft:=Round(RWX);
     DRight:=DLeft
    end;

   {TExprSign}

   function TExprSign.CalcWidth;
    begin
     SetCanvasFont;
     case Integer(Symbol) of
      esMuchLess,esMuchGreater:Result:=Round(1.7*Canvas.TextWidth('<'));
      esApproxLess,esApproxGreater{,esLessOrEqual,esGreaterOrEqual}:Result:=Canvas.TextWidth('<');
      esPlusMinus,esMinusPlus:Result:=Canvas.TextWidth('+');
      esAlmostEqual:Result:=Canvas.TextWidth('~');
      esParallel:Result:=4*WX;
      esPerpendicular,esAngle:begin
                               Result:=Canvas.TextWidth('_');
                               if Odd(Result)<>Odd(WX) then
                                Inc(Result)
                              end;
     else
      Result:=inherited CalcWidth
     end;
     Inc(Result,4*WX)
    end;

   procedure TExprSign.Paint;
    var Y1,XL,XR,XC:Integer;
        TM:TTextMetric;
        Pt:array[1..4] of TPoint;
        GM:TGlyphMetrics;
        M2:TMat2;
        OM:TOutlineTextMetric;
     begin
      SetCanvasFont;
      case Integer(Symbol) of
       esMuchLess:begin
                   Canvas.TextOut(X+2*WX,Y,'<');
                   Canvas.TextOut(X+2*WX+Round(0.7*Canvas.TextWidth('<')),Y,'<')
                  end;
       esMuchGreater:begin
                      Canvas.TextOut(X+2*WX,Y,'>');
                      Canvas.TextOut(X+2*WX+Round(0.7*Canvas.TextWidth('>')),Y,'>')
                     end;
       esApproxLess:begin
                     Canvas.TextOut(X+2*WX,Y,'<');
                     Canvas.TextOut(X+2*WX,Y+Round(7*RWY),'~')
                    end;
       esApproxGreater:begin
                        Canvas.TextOut(X+2*WX,Y,'>');
                        Canvas.TextOut(X+2*WX,Y+Round(7*RWY),'~')
                       end;
       esPlusMinus:begin
                    Canvas.TextOut(X+2*WX,Y-WY,'+');
                    SetPenAndBrush;
                    ZeroMemory(@M2,SizeOf(M2));
                    M2.eM11.value:=1;
                    M2.eM22.value:=1;
                    GetGlyphOutline(Canvas.Handle,Cardinal('+'),GGO_Native,GM,0,nil,M2);
                    GetOutlineTextMetrics(Canvas.Handle,SizeOf(OM),@OM);
                    Y1:=Y+OM.otmTextMetrics.tmHeight-OM.otmTextMetrics.tmDescent-GM.gmptGlyphOrigin.y+GM.gmBlackBoxY;
                    Canvas.Rectangle(X+2*WX+GM.gmptGlyphOrigin.x,Y1,X+2*WX+GM.gmptGlyphOrigin.x+GM.gmBlackBoxX,Y1+WY)
                   end;
       esMinusPlus:begin
                    Canvas.TextOut(X+2*WX,Y+WY,'+');
                    SetPenAndBrush;
                    ZeroMemory(@M2,SizeOf(M2));
                    M2.eM11.value:=1;
                    M2.eM22.value:=1;
                    GetGlyphOutline(Canvas.Handle,Cardinal('+'),GGO_Native,GM,0,nil,M2);
                    GetOutlineTextMetrics(Canvas.Handle,SizeOf(OM),@OM);
                    Y1:=Y+OM.otmTextMetrics.tmHeight-OM.otmTextMetrics.tmDescent-GM.gmptGlyphOrigin.y-WY;
                    Canvas.Rectangle(X+2*WX+GM.gmptGlyphOrigin.x,Y1,X+2*WX+GM.gmptGlyphOrigin.x+GM.gmBlackBoxX,Y1+WY)
                   end;
       esAlmostEqual:begin
                      Canvas.TextOut(X+2*WX,Y-Round(4.5*RWY),'~');
                      SetPenAndBrush;
                      Y1:=Y+Round(15.5*RWY);
                      Canvas.Rectangle(X+2*WX+Round(0.5*RWX),Y1,X+Width-2*WX-Round(0.6*RWX),Y1+WY)
                     end;
       {esLessOrEqual:begin
                      Canvas.TextOut(X+2*WX,Y,'<');
                      SetPenAndBrush;
                      Pt[1].X:=X+2*WX+Round(0.5*RWX);
                      Pt[2].X:=Pt[1].X;
                      Pt[3].X:=X+Width(Canvas)-2*WX-Round(0.6*RWX)-1;
                      Pt[4].X:=Pt[3].X;
                      Pt[3].Y:=Y+Round(22*RWY);
                      Pt[4].Y:=Pt[3].Y+WY-1;
                      Pt[2].Y:=Pt[3].Y-Round(0.43055556*(Pt[3].X-Pt[2].X));
                      Pt[1].Y:=Pt[2].Y+WY-1;
                      Canvas.Polygon(Pt)
                     end;}
       esParallel:begin
                   GetTextMetrics(Canvas.Handle,TM);
                   SetPenAndBrush;
                   Canvas.Rectangle(X+2*WX,Y+TM.tmDescent,X+3*WX,Y+TM.tmAscent+1);
                   Canvas.Rectangle(X+5*WX,Y+TM.tmDescent,X+6*WX,Y+TM.tmAscent+1)
                  end;
       esPerpendicular:begin
                        GetTextMetrics(Canvas.Handle,TM);
                        SetPenAndBrush;
                        XL:=X+2*WX;
                        XR:=X+Width-2*WX;
                        XC:=X+(Width-WX) div 2;
                        Canvas.Rectangle(XL,Y+TM.tmAscent+1-WY,XR,Y+TM.tmAscent+1);
                        Canvas.Rectangle(XC,Y+TM.tmDescent+Round(4*RWY),XC+WX,Y+TM.tmAscent+1)
                       end;
       esAngle:begin
                GetTextMetrics(Canvas.Handle,TM);
                SetPenAndBrush;
                XL:=X+2*WX;
                XR:=X+Width-2*WX;
                XC:=X+(Width) div 2;
                Canvas.Rectangle(XL,Y+TM.tmAscent+1-WY,XR,Y+TM.tmAscent+1);
                Pt[1]:=Point(XL,Y+TM.tmAscent+1-WY);
                Pt[2]:=Point(XC,Y+TM.tmDescent+Round(4*RWY));
                Pt[3]:=Point(Pt[2].X,Pt[2].Y+WY-1);
                Pt[4]:=Point(Pt[1].X,Pt[1].Y+WY-1);
                Canvas.Polygon(Pt)
               end;
      else
       inherited Paint(X+2*WX,Y)
      end
     end;

   function TExprSign.FTType;
    begin
     Result:=efNegative*Integer((Symbol=WideChar(esMinus)) or (Symbol=WideChar(esPlusMinus)) or (Symbol=WideChar(esMinusPlus)))
    end;

   function TExprSign.NeedBrackets;
    begin
     Result:=(Symbol=WideChar(esMinus)) or (Symbol=WideChar(esPlus)) or (Symbol=WideChar(esPlusMinus)) or (Symbol=WideChar(esMinusPlus))
    end;

   function TExprSign.CalcCapDY;
    begin
     Result:=MaxInt
    end;

   {TExprTwinParent}

   constructor TExprTwinParent.Create;
    begin
     inherited Create(ASon);
     Twin1:=FirstTwin;
     Twin2:=SecondTwin
    end;

   destructor TExprTwinParent.Destroy;
    begin
     Twin1.Free;
     Twin2.Free;
     inherited Destroy
    end;

   procedure TExprTwinParent.SetTwins;
    begin
     Twins[Index].Free;
     Twins[Index]:=Value;
     if Assigned(Twins[Index]) then
      with Twins[Index] do
       begin
        Parent:=Self;
        Font:=Self.Font;
        Font.Height:=Round(0.7*Font.Height);
        Canvas:=FCanvas
       end;
     ToChange:=$FFFFFFFF
    end;

   procedure TExprTwinParent.DynaSetFont;
    var TmpFont:TFont;
    begin
     inherited DynaSetFont;
     TmpFont:=TFont.Create;
     TmpFont.Assign(Font);
     TmpFont.Height:=Round(0.7*Font.Height);
     if Assigned(Twin1) then
      Twin1.Font:=TmpFont;
     if Assigned(Twin2) then
      Twin2.Font:=TmpFont;
     TmpFont.Free
    end;

   procedure TExprTwinParent.DynaSetCanvas;
    begin
     inherited DynaSetCanvas;
     if Assigned(Twin1) then
      Twin1.Canvas:=Canvas;
     if Assigned(Twin2) then
      Twin2.Canvas:=Canvas
    end;

   {TExprIndex}

   function TExprIndex.CalcWidth;
    var W1,W2,W3:Integer;
     begin
      W1:=Son.Width;
      if Assigned(Twin1) then
       W2:=Son.IndexXPos+Twin1.Width
      else
       W2:=0;
      if Assigned(Twin2) then
       W3:=Son.PowerXPos+Twin2.Width
      else
       W3:=0;
      Result:=MaxIntValue([W1,W2,W3])
     end;

   function TExprIndex.CalcHeight;
    begin
     Result:=Son.Height;
     if Assigned(Twin1) then
      Inc(Result,MaxIntValue([0,Twin1.Height-Result+Son.IndexYPos]));
     if Assigned(Twin2) then
      Inc(Result,MaxIntValue([0,Twin2.Height-Son.PowerYPos]))
    end;

   function TExprIndex.CalcMidLine;
    begin
     if Origin=eoTop then
      if not Assigned(Twin2) then
       Result:=Son.MidLineUp
      else
       Result:=Son.MidLineUp+MaxIntValue([0,Twin2.Height-Son.PowerYPos])
     else
      if not Assigned(Twin1) then
       Result:=Son.MidLineDn
      else
       Result:=Son.MidLineDn-MaxIntValue([0,Twin1.Height-Son.Height+Son.IndexYPos])
    end;

   function TExprIndex.CalcCapDY;
    begin
     if Assigned(Twin2) then
      Result:=Twin2.CapDY
     else
      Result:=Son.CapDY
    end;

   procedure TExprIndex.Paint;
    var DY:Integer;
     begin
      if Assigned(Twin2) then
       begin
        DY:=MaxIntValue([0,Twin2.Height-Son.PowerYPos]);
        Twin2.Draw(X+Son.PowerXPos,Y+DY+Son.PowerYPos,ehLeft,evBottom)
       end
      else
       DY:=0;
      Son.Draw(X,Y+DY,ehLeft,evTop);
      if Assigned(Twin1) then
       Twin1.Draw(X+Son.IndexXPos,Y+DY+Son.IndexYPos,ehLeft,evTop)
     end;

   function TExprIndex.ArgNeedBrackets;
    begin
     Result:=not (Son is TExprFuncName)
    end;

   function TExprIndex.FTType;
    begin
     FTType:=Son.FTType or efRight
    end;

   {TExprArgument}

   constructor TExprArgument.Create;
    begin
     inherited Create(ASon,ebRound,ebRound);
     ForcedBrackets:=False
    end;

   function TExprArgument.IsBracketed;
    var P:TExprClass;
     begin
      if (ForcedBrackets) or ((Parent is TExprCommonFunc) and (TExprCommonFunc(Parent).ArgumentNeedBrackets)) then
       Result:=True
      else
       begin
        P:=Son;
        while Assigned(P) do
         begin
          if P.NeedBrackets then
           begin
            Result:=True;
            Exit
           end;
          P:=P.Next
         end;
        Result:=False;
       end
     end;

   procedure TExprArgument.SetBrackets;
    begin
     ForcedBrackets:=True;
     ToChange:=$FFFFFFFF
    end;

   {TExprCommonFunc}

   function TExprCommonFunc.CalcWidth;
    begin
     Result:=Son.Width;
     Inc(Result,3*WX+Daughter.Width);
    end;

   function TExprCommonFunc.CalcHeight;
    begin
     Result:=MidLineUp-MidLineDn+1
    end;

   function TExprCommonFunc.CalcMidLine;
    begin
     if Origin=eoTop then
      Result:=MaxIntValue([Son.MidLineUp,Daughter.MidLineUp])
     else
      Result:=MinIntValue([Son.MidLineDn,Daughter.MidLineDn])
    end;

   procedure TExprCommonFunc.Paint;
    var DX,DY:Integer;
     begin
      DY:=Y+MidLineUp-Son.MidLineUp;
      Son.Draw(X,DY,ehLeft,evTop);
      DX:=X+3*WX+Son.Width;
      DY:=Y+MidLineUp-Daughter.MidLineUp;
      Daughter.Draw(DX,DY,ehLeft,evTop)
     end;

   function TExprCommonFunc.FTType;
    begin
     Result:=efLeft+efRight*Integer(Daughter.FTType and efBrackets>0)
    end;

   function TExprCommonFunc.ArgumentNeedBrackets;
    begin
     Result:=Son.ArgNeedBrackets
    end;

   {TExprFuncName}

   function TExprFuncName.ArgNeedBrackets;
    begin
     Result:=False
    end;

   {TExprFunc}

   constructor TExprFunc.Create;
    begin
     inherited Create(nil,ADaughter);
     if Length(FuncName)=1 then
      Son:=TExprVar.Create(FuncName)
     else
      Son:=TExprFuncName.Create(FuncName)
    end;

   {TExprBase}

   constructor TExprBase.Create;
    begin
     inherited Create(ASon,ebRound,ebRound)
    end;

   function TExprBase.IsBracketed;
    begin
     Result:=Assigned(Son.Next)
    end;

   {TExprComma}

   constructor TExprComma.Create;
    begin
     inherited Create(44)
    end;

   function TExprComma.NeedBrackets;
    begin
     Result:=True
    end;

   function TExprComma.CalcCapDY;
    begin
     Result:=MaxInt
    end;

   {TExprLim}

   procedure TExprLim.SetSonFont;
    var TmpFont:TFont;
     begin
      if Assigned(Son) then
       begin
        TmpFont:=TFont.Create;
        TmpFont.Assign(Font);
        TmpFont.Height:=Round(0.7*Font.Height);
        Son.Font:=TmpFont;
        TmpFont.Free
       end
     end;

   procedure TExprLim.SetSonCanvas;
    begin
     if Assigned(Son) then
      Son.Canvas:=Canvas
    end;

   function TExprLim.CalcWidth;
    begin
     SetCanvasFont;
     Result:=Canvas.TextWidth('lim');
     Result:=MaxIntValue([Result,Son.Width])
    end;

   function TExprLim.CalcHeight;
    begin
     SetCanvasFont;
     Result:=Canvas.TextHeight('lim');
     Inc(Result,Son.Height)
    end;

   function TExprLim.CalcMidLine;
    var H:Integer;
     begin
      SetCanvasFont;
      H:=Canvas.TextHeight('lim');
      if Origin=eoTop then
       Result:=H div 2
      else
       Result:=-((H-1) div 2)-Son.Height
     end;

   procedure TExprLim.Paint;
    var W2:Integer;
        LSize:TSize;
     begin
      SetCanvasFont;
      LSize:=Canvas.TextExtent('lim');
      W2:=Son.Width;
      SetCanvasFont;
      Canvas.TextOut(X+MaxIntValue([0,(W2-LSize.CX) div 2]),Y,'lim');
      Son.Draw(X+MaxIntValue([0,(LSize.CX-W2) div 2]),Y+LSize.CY,ehLeft,evTop)
     end;

   function TExprLim.ArgNeedBrackets;
    begin
     Result:=False
    end;

   {TExprSpace}

   constructor TExprSpace.Create;
    begin
     inherited Create;
     N:=Space
    end;

   function TExprSpace.CalcWidth;
    begin
     Result:=N*WX
    end;

   {TExprStrokes}

   constructor TExprStrokes.Create;
    begin
     inherited Create;
     N:=Strokes
    end;

   function TExprStrokes.CalcWidth;
    begin
     Result:=WX*(4*N+2)
    end;

   function TExprStrokes.CalcHeight;
    begin
     SetCanvasFont;
     Result:=Round(0.6*Canvas.TextHeight('A'))
    end;

   procedure TExprStrokes.Paint;
    var I:Integer;
        Pt:array[1..3] of TPoint;
     begin
      SetPenAndBrush;
      Pt[1].X:=X+2*WX;
      Pt[1].Y:=Y+Round(2*RWY);
      Pt[2].X:=X+4*WX-1;
      Pt[2].Y:=Pt[1].Y;
      Pt[3].X:=X+2*WX;
      Pt[3].Y:=Pt[1].Y+6*WY-1;
      for I:=1 to N do
       begin
        Canvas.Polygon(Pt);
        Inc(Pt[1].X,4*WX);
        Inc(Pt[2].X,4*WX);
        Inc(Pt[3].X,4*WX)
       end;
     end;

   {TExprAtValue}

   procedure TExprAtValue.SetDaughterFont;
    var TmpFont:TFont;
     begin
      if Assigned(Daughter) then
       begin
        TmpFont:=TFont.Create;
        TmpFont.Assign(Font);
        TmpFont.Height:=Round(0.7*Font.Height);
        Daughter.Font:=TmpFont;
        TmpFont.Free
       end
     end;

   procedure TExprAtValue.SetDaughterCanvas;
    begin
     if Assigned(Daughter) then
      Daughter.Canvas:=Canvas
    end;

   function TExprAtValue.CalcWidth;
    begin
     Result:=Son.Width+3*WX+Daughter.Width
    end;

   function TExprAtValue.CalcHeight;
    begin
     Result:=MaxIntValue([Son.Height,Daughter.Height])
    end;

   function TExprAtValue.CalcMidLine;
    var DH:Integer;
     begin
      DH:=MaxIntValue([0,Daughter.Height-Son.Height]);
      if Origin=eoTop then
       Result:=Son.MidLineUp+DH
      else
       Result:=Son.MidLineDn
     end;

   procedure TExprAtValue.Paint;
    var H1,H2,DH,W:Integer;
     begin
      H1:=Son.Height;
      H2:=Daughter.Height;
      DH:=MaxIntValue([0,H2-H1]);
      H1:=MaxIntValue([H1,H2]);
      Son.Draw(X,Y+DH,ehLeft,evTop);
      W:=X+Son.Width;
      SetPenAndBrush;
      Canvas.Rectangle(W,Y,W+WX,Y+H1);
      Daughter.Draw(W+3*WX,Y+H1,ehLeft,evBottom)
     end;

   function TExprAtValue.FTType;
    begin
     if Son.FTType and efLeft>0 then
      Result:=efLeft
     else
      Result:=0
    end;

   {TExprCap}

   constructor TExprCap.Create;
    begin
     inherited Create(ASon);
     Style:=CapStyle;
     N:=Count
    end;

   function TExprCap.CalcWidth;
    var DLeft,DRight,W,CX:Integer;
     begin
      Result:=Son.Width;
      DLeft:=Son.CapDXLeft;
      DRight:=Son.CapDXRight;
      if Style in [ecVector,ecLine] then
       begin
        if DLeft<0 then
         Dec(Result,DLeft);
        if DRight>0 then
         Inc(Result,DRight)
       end
      else
       begin
        W:=CapWidth div 2;
        CX:=(DLeft+DRight+Result) div 2;
        Result:=MaxIntValue([CX,W])+MaxIntValue([Result-CX,W])
       end
     end;

   function TExprCap.CalcHeight;
    begin
     Result:=Son.Height+SelfHeight
    end;

   function TExprCap.CalcMidLine;
    begin
     if Origin=eoTop then
      Result:=Son.MidLineUp+SelfHeight
     else
      Result:=Son.MidLineDn
    end;

   function TExprCap.CalcPowerXPos;
    begin
     if Width=Son.Width then
      Result:=Son.PowerXPos
     else
      Result:=inherited CalcPowerXPos
    end;

   function TExprCap.CalcPowerYPos;
    begin
     Result:=Son.PowerYPos+SelfHeight
    end;

   function TExprCap.CalcIndexXPos;
    var DL,DX:Integer;
     begin
      DL:=Son.GetCapDXLeft;
      if Style in [ecPoints,ecCap,ecTilde] then
       DX:=MaxIntValue([CapWidth div 2-(DL+Son.Width+Son.GetCapDXRight) div 2,0])
      else
       DX:=MaxIntValue([0,-DL]);
      Result:=Son.CalcIndexXPos+DX
     end;

   function TExprCap.CapWidth;
    begin
     SetCanvasFont;
     case Style of
      ecPoints:Result:=WX*(4*N-2);
      ecCap:Result:=Canvas.TextWidth('^');
      ecTilde:Result:=Canvas.TextWidth('~')
     end
    end;

   function TExprCap.CapHeight;
    begin
     case Style of
      ecPoints:Result:=5*WY;
      ecVector:Result:=6*WY;
      ecCap:Result:=11*WY;
      ecTilde:Result:=6*WY;
      ecLine:Result:=4*WY
     else
      Result:=0
     end
    end;

   function TExprCap.SelfHeight;
    begin
     Result:=MaxIntValue([0,CapHeight-Son.CapDY])
    end;

   function TExprCap.CalcCapDY;
    begin
     Result:=MaxIntValue([0,Son.CapDY-CapHeight])
    end;

   procedure TExprCap.Paint;
    var DY,DX,W,DLEft,DRight:Integer;
        LX,RX:Integer;
        Pt:array[1..8] of TPoint;
        TW,CX:Integer;
        I:Integer;
     begin
      DY:=Y+SelfHeight;
      DLeft:=Son.CapDXLeft;
      DRight:=Son.CapDXRight;
      W:=Width;
      if Style in [ecPoints,ecCap,ecTilde] then
       begin
        TW:=CapWidth div 2;
        CX:=(DLeft+Son.Width+DRight) div 2;
        DX:=MaxIntValue([TW-CX,0])
       end
      else
       DX:=MaxIntValue([0,-DLeft]);
      Son.Draw(X+DX,DY,ehLeft,evTop);
      Inc(DY,Son.CapDY-WY);
      SetPenAndBrush;
      SetBkMode(Canvas.Handle,Transparent);
      LX:=X+MaxIntValue([0,DLeft]);
      RX:=X+W+MinIntValue([0,DRight]);
      case Style of
       ecPoints:begin
                 for I:=0 to N-1 do
                  begin
                   LX:=X+DX+CX-TW;
                   RX:=LX+2*WX;
                   Canvas.Ellipse(LX+4*WX*I,DY-3*WY,RX+4*WX*I,DY-WY)
                  end
                end;
       ecVector:if Odd(WY) then
                 begin
                  Pt[1].X:=LX;
                  Pt[1].Y:=DY-3*WY;
                  Pt[2].X:=RX-2*WY;
                  Pt[2].Y:=Pt[1].Y;
                  Pt[3].X:=Pt[2].X;
                  Pt[3].Y:=Pt[2].Y-WY;
                  Pt[4].X:=RX-1;
                  Pt[4].Y:=Pt[2].Y+WY div 2;
                  Pt[5].X:=Pt[3].X;
                  Pt[5].Y:=Pt[3].Y+3*WY-1;
                  Pt[6].X:=Pt[5].X;
                  Pt[6].Y:=Pt[5].Y-WY;
                  Pt[7].X:=Pt[1].X;
                  Pt[7].Y:=Pt[6].Y;
                  Canvas.Polygon(Slice(Pt,7))
                 end
                else
                 begin
                  Pt[1].X:=LX;
                  Pt[1].Y:=DY-3*WY;
                  Pt[2].X:=RX-2*WY;
                  Pt[2].Y:=Pt[1].Y;
                  Pt[3].X:=Pt[2].X;
                  Pt[3].Y:=Pt[2].Y-WY;
                  Pt[4].X:=RX-1;
                  Pt[4].Y:=Pt[2].Y+WY div 2-1;
                  Pt[5].X:=Pt[4].X;
                  Pt[5].Y:=Pt[4].Y+1;
                  Pt[6].X:=Pt[3].X;
                  Pt[6].Y:=Pt[3].Y+3*WY-1;
                  Pt[7].X:=Pt[6].X;
                  Pt[7].Y:=Pt[6].Y-WY;
                  Pt[8].X:=Pt[1].X;
                  Pt[8].Y:=Pt[7].Y;
                  Canvas.Polygon(Pt)
                 end;
       ecCap:begin
              SetCanvasFont;
              Canvas.TextOut(X+DX+CX-TW,DY-Round(15*RWY),'^')
             end;
       ecTilde:begin
                SetCanvasFont;
                Canvas.TextOut(X+DX+CX-TW,DY-Round(18.5*RWY),'~')
               end;
       ecLine:begin
               SetCanvasFont;
               Canvas.Rectangle(LX,DY-2*WY,RX,DY-WY)
              end
      end
     end;

   function TExprCap.FTType;
    begin
     Result:=Son.FTType
    end;

   {TExprStand}

   constructor TExprStand.Create;
    begin
     inherited Create(ASon);
     Alg:=Align
    end;

   function TExprStand.CalcWidth;
    var P:TExprClass;
     begin
      Result:=Son.Width;
      P:=Son.Next;
      while Assigned(P) do
       begin
        Result:=MaxIntValue([Result,P.Width]);
        P:=P.Next
       end
     end;

   function TExprStand.CalcHeight;
    var P:TExprClass;
     begin
      Result:=Son.Height;
      P:=Son.Next;
      while Assigned(P) do
       begin
        Inc(Result,P.Height);
        P:=P.Next
       end
     end;

   procedure TExprStand.Paint;
    var P:TExprClass;
        W:Integer;
     begin
      W:=Width;
      P:=Son;
      while Assigned(P) do
       begin
        case Alg of
         ehLeft:P.Draw(X,Y,ehLeft,evTop);
         ehCenter:P.Draw(X+W div 2,Y,ehCenter,evTop);
         ehRight:P.Draw(X+W,Y,ehRight,evTop)
        end;
        Inc(Y,P.Height);
        P:=P.Next
       end
     end;

   {TExprMatrix}

   constructor TExprMatrix.Create;
    begin
     inherited Create(ASon);
     HS:=HorSize;
     VS:=VertSize
    end;

   procedure TExprMatrix.GetCellSize;
    var P:TExprClass;
        Over,Above:Integer;
     begin
      CX:=0;
      Over:=0;
      Above:=0;
      P:=Son;
      while Assigned(P) do
       with P do
        begin
         Over:=MaxIntValue([Over,MidLineUp+1]);
         Above:=MaxIntValue([Above,Height-MidLineUp-1]);
         CX:=MaxIntValue([CX,Width]);
         P:=Next
        end;
      CY:=Over+Above
     end;

   function TExprMatrix.GetCellWidth;
    begin
     if ToChange and tcCellSize>0 then
      begin
       GetCellSize(FCX,FCY);
       ToChange:=ToChange and not tcCellSize
      end;
     Result:=FCX
    end;

   function TExprMatrix.GetCellHeight;
    begin
     if ToChange and tcCellSize>0 then
      begin
       GetCellSize(FCX,FCY);
       ToChange:=ToChange and not tcCellSize
      end;
     Result:=FCY
    end;

   function TExprMatrix.CalcWidth;
    begin
     Result:=GetCellWidth*HS+WX*(4+6*(HS-1))
    end;

   function TExprMatrix.CalcHeight;
    begin
     Result:=GetCellHeight*VS
    end;

   procedure TExprMatrix.Paint;
    var CX,CY:Integer;
        DX:Integer;
        I,J:Integer;
        P:TExprClass;
     begin
      GetCellSize(CX,CY);
      CX:=GetCellWidth;
      CY:=GetCellHeight;
      P:=Son;
      Inc(Y,CY div 2);
      for J:=0 to VS-1 do
       begin
        DX:=X+2*WX+CX div 2;
        for I:=0 to HS-1 do
         if Assigned(P) then
          begin
           P.Draw(DX,Y,ehCenter,evCenter);
           P:=P.Next;
           Inc(DX,CX+6*WX)
          end;
        Inc(Y,CY)
       end
     end;

   {TExprGroupOp}

   constructor TExprGroupOp.Create;
    begin
     inherited Create(ASon,FirstTwin,SecondTwin);
     FSymbolHeight:=0;
     FSymbolWidth:=0
    end;

   function TExprGroupOp.CalcSymbolHeight;
    var H:Integer;
        P:TExprClass;
     begin
      if (Son is TExprChain) and (Son.FTType and efRoundBrackets=0) then
       begin
        P:=TExprChain(Son).Son;
        while Assigned(P) do
         begin
          if P is TExprGroupOp then
           begin
            Result:=TExprGroupOp(P).GetSymbolHeight;
            Exit
           end;
          P:=P.Next
         end
       end;
      if Son is TExprGroupOp then
       Result:=TExprGroupOp(Son).GetSymbolHeight
      else
       begin
        H:=MaxIntValue([Son.MidLineUp,-Son.MidLineDn]);
        SetCanvasFont;
        Result:=Round(2.25*MaxIntValue([H,Canvas.TextHeight('A') div 2]))
       end
     end;

   function TExprGroupOp.GetSymbolWidth;
    begin
     if ToChange and tcSymbolWidth>0 then
      begin
       FSymbolWidth:=CalcSymbolWidth;
       ToChange:=ToChange and not tcSymbolWidth
      end;
     Result:=FSymbolWidth
    end;

   function TExprGroupOp.GetSymbolHeight;
    begin
     if ToChange and tcSymbolHeight>0 then
      begin
       FSymbolHeight:=CalcSymbolHeight;
       ToChange:=ToChange and not tcSymbolHeight
      end;
     Result:=FSymbolHeight
    end;

   function TExprGroupOp.CalcWidth;
    var W1,W2:Integer;
     begin
      if Assigned(Twin1) then
       W1:=Twin1.Width
      else
       W1:=0;
      if Assigned(Twin2) then
       W2:=Twin2.Width
      else
       W2:=0;
      Result:=MaxIntValue([W1,W2,GetSymbolWidth])+Son.Width+5*WX
     end;

   function TExprGroupOp.CalcHeight;
    var H1,H2,SH1,SH2:Integer;
     begin
      if Son is TExprGroupOp then
       with TExprGroupOp(Son) do
        begin
         if Assigned(Twin1) then
          SH1:=Twin1.Height
         else
          SH1:=0;
         if Assigned(Twin2) then
          SH2:=Twin2.Height
         else
          SH2:=0
        end
      else
       begin
        SH1:=0;
        SH2:=0
       end;
      if Assigned(Twin1) then
       H1:=Twin1.Height
      else
       H1:=2*WY;
      if Assigned(Twin2) then
       H2:=Twin2.Height
      else
       H2:=2*WY;
      Result:=GetSymbolHeight+MaxIntValue([H1,SH1])+MaxIntValue([H2,SH2])
     end;

   function TExprGroupOp.CalcMidLine;
    var H,SH:Integer;
     begin
      if Origin=eoTop then
       begin
        if (Son is TExprGroupOp) and Assigned(TExprGroupOp(Son).Twin2) then
         SH:=TExprGroupOp(Son).Twin2.Height
        else
         SH:=0;
        if Assigned(Twin2) then
         H:=Twin2.Height
        else
         H:=2*WY;
        Result:=GetSymbolHeight div 2+MaxIntValue([H,SH])
       end
      else
       begin
        if (Son is TExprGroupOp) and Assigned(TExprGroupOp(Son).Twin1) then
         SH:=TExprGroupOp(Son).Twin1.Height
        else
         SH:=0;
        if Assigned(Twin1) then
         H:=Twin1.Height
        else
         H:=2*WY;
        Result:=-((GetSymbolHeight-1) div 2+MaxIntValue([H,SH]))
       end
     end;

   procedure TExprGroupOp.Paint;
    var W1,W2,H,HS:Integer;
     begin
      if Assigned(Twin1) then
       W1:=Twin1.Width
      else
       W1:=0;
      if Assigned(Twin2) then
       W2:=Twin2.Width
      else
       W2:=0;
      W1:=MaxIntValue([W1,W2,GetSymbolWidth]);
      W2:=X+W1 div 2+2*WX;
      H:=MidLineUp;
      HS:=GetSymbolHeight div 2;
      if Assigned(Twin2) then
       Twin2.Draw(W2,Y+H-HS,ehCenter,evBottom);
      if Assigned(Twin1) then
       Twin1.Draw(W2,Y+H+HS,ehCenter,evTop);
      if HS>27 then
       DrawSymbol(W2,Y+H)
      else
       LRDrawSymbol(W2,Y+H);
      Son.Draw(X+W1+5*WX,Y+H,ehLeft,evCenter)
     end;

   {TExprSumma}

   function TExprSumma.CalcSymbolWidth;
    begin
     Result:=Round(GetSymbolHeight*0.739*GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY))
    end;

   procedure TExprSumma.DrawSymbol;
    var Pt:array[1..49] of TPoint;
        I,H:Integer;
        K:Extended;
     begin
      H:=GetSymbolHeight;
      K:=GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY);
      for I:=1 to 49 do
       begin
        Pt[I].X:=X+Round(ASumma[I].X/10000*H*K);
        Pt[I].Y:=Y-Round(ASumma[I].Y/10000*H)
       end;
      with Canvas do
       begin
        BeginPath(Handle);
        PolyBezier(Pt);
        EndPath(Handle);
        SetPenAndBrush;
        StrokeAndFillPath(Handle)
       end
     end;

   procedure TExprSumma.LRDrawSymbol;
    var Pt:array[1..16] of TPoint;
        H,W:Integer;
        K:Extended;
        WX1,WX2,WY2:Integer;
     begin
      H:=GetSymbolHeight;
      K:=GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY);
      W:=Round(H*0.739*K);
      WY2:=MaxIntValue([1,Round(H*0.1)]);
      WX1:=MaxIntValue([1,Round(H*0.05*K)]);
      WX2:=MaxIntValue([1,Round(H*0.1*K)]);
      Pt[7].X:=X+WX2;
      Pt[7].Y:=Y;
      Dec(X,W div 2);
      Dec(Y,H div 2);
      Pt[1].X:=X;
      Pt[1].Y:=Y;
      Pt[2].X:=X+W-1;
      Pt[2].Y:=Y;
      Pt[3].X:=Pt[2].X;
      Pt[3].Y:=Y+2*WY2;
      Pt[4].X:=Pt[2].X-WX1+1;
      Pt[4].Y:=Pt[3].Y-WY2;
      Pt[5].X:=Pt[4].X;
      Pt[5].Y:=Pt[2].Y+WY2-1;
      Pt[6].X:=Pt[1].X+WX2-1;
      Pt[6].Y:=Pt[5].Y;
      Pt[8].X:=Pt[6].X;
      Pt[8].Y:=Y+H-WY2;
      Pt[9].X:=Pt[5].X;
      Pt[9].Y:=Pt[8].Y;
      Pt[10].X:=Pt[9].X;
      Pt[10].Y:=Pt[9].Y-WY2;
      Pt[11].X:=Pt[2].X;
      Pt[11].Y:=Pt[10].Y;
      Pt[12].X:=Pt[11].X;
      Pt[12].Y:=Y+H-1;
      Pt[13].X:=Pt[1].X;
      Pt[13].Y:=Pt[12].Y;
      Pt[14].X:=Pt[13].X;
      Pt[14].Y:=Pt[8].Y;
      Pt[15].X:=Pt[7].X-WX2+1;
      Pt[15].Y:=Pt[7].Y;
      Pt[16].X:=Pt[1].X;
      Pt[16].Y:=Pt[6].Y;
      SetPenAndBrush;
      Canvas.Polygon(Pt)
     end;

   {TExprProd}

   function TExprProd.CalcSymbolWidth;
    begin
     Result:=Round(GetSymbolHeight*0.8561*GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY))
    end;

   procedure TExprProd.DrawSymbol;
    var Pt:array[1..76] of TPoint;
        I,H:Integer;
        K:Extended;
     begin
      H:=GetSymbolHeight;
      K:=GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY);
      for I:=1 to 76 do
       begin
        Pt[I].X:=X+Round(AProd[I].X/10000*H*K);
        Pt[I].Y:=Y-Round(AProd[I].Y/10000*H)
       end;
      with Canvas do
       begin
        BeginPath(Handle);
        PolyBezier(Pt);
        EndPath(Handle);
        SetPenAndBrush;
        StrokeAndFillPath(Handle)
       end
     end;

   procedure TExprProd.LRDrawSymbol;
    var W,H:Integer;
        WX2,WY1:Integer;
        K:Extended;
        Pt:array[1..20] of TPoint;
     begin
      H:=GetSymbolHeight;
      K:=GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY);
      W:=Round(0.8561*H*K);
      WY1:=MaxIntValue([1,Round(H*0.05)]);
      WX2:=MaxIntValue([1,Round(H*0.1*K)]);
      Dec(X,W div 2);
      Dec(Y,H div 2);
      Pt[1].X:=X;
      Pt[1].Y:=Y;
      Pt[2].X:=X+W-1;
      Pt[2].Y:=Y;
      Pt[3].X:=Pt[2].X;
      Pt[3].Y:=Pt[2].Y+WY1-1;
      Pt[4].X:=Pt[2].X-WX2;
      Pt[4].Y:=Pt[3].Y;
      Pt[5].X:=Pt[4].X;
      Pt[5].Y:=Y+H-WY1;
      Pt[6].X:=Pt[2].X;
      Pt[6].Y:=Pt[5].Y;
      Pt[7].X:=Pt[6].X;
      Pt[7].Y:=Y+H-1;
      Pt[8].X:=X+W-3*WX2;
      Pt[8].Y:=Pt[7].Y;
      Pt[9].X:=Pt[8].X;
      Pt[9].Y:=Pt[6].Y;
      Pt[10].X:=Pt[9].X+WX2;
      Pt[10].Y:=Pt[9].Y;
      Pt[11].X:=Pt[10].X;
      Pt[11].Y:=Pt[4].Y;
      Pt[12].X:=X+2*WX2-1;
      Pt[12].Y:=Pt[11].Y;
      Pt[13].X:=Pt[12].X;
      Pt[13].Y:=Pt[10].Y;
      Pt[14].X:=Pt[13].X+WX2;
      Pt[14].Y:=Pt[13].Y;
      Pt[15].X:=Pt[14].X;
      Pt[15].Y:=Pt[8].Y;
      Pt[16].X:=Pt[1].X;
      Pt[16].Y:=Pt[15].Y;
      Pt[17].X:=Pt[16].X;
      Pt[17].Y:=Pt[13].Y;
      Pt[18].X:=Pt[1].X+WX2;
      Pt[18].Y:=Pt[17].Y;
      Pt[19].X:=Pt[18].X;
      Pt[19].Y:=Pt[12].Y;
      Pt[20].X:=Pt[1].X;
      Pt[20].Y:=Pt[19].Y;
      SetPenAndBrush;
      Canvas.Polygon(Pt)
     end;

   {TExprCirc}

   function TExprCirc.CalcSymbolWidth;
    begin
     Result:=Round(GetSymbolHeight*0.2687*GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY))
    end;

   procedure TExprCirc.DrawSymbol;
    var Pt:array[1..52] of TPoint;
        I,H:Integer;
        K:Extended;
     begin
      H:=GetSymbolHeight;
      K:=GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY);
      for I:=1 to 52 do
       begin
        Pt[I].X:=X+Round((AIntegral[I].X-1343)/10000*H*K);
        Pt[I].Y:=Y-Round(AIntegral[I].Y/10000*H)
       end;
      with Canvas do
       begin
        BeginPath(Handle);
        PolyBezier(Pt);
        EndPath(Handle);
        SetPenAndBrush;
        StrokeAndFillPath(Handle);
        BeginPath(Handle);
        for I:=1 to 13 do
         begin
          Pt[I].X:=X+Round((ABigRing[I].X-1343)/10000*H*K);
          Pt[I].Y:=Y-Round(ABigRing[I].Y/10000*H)
         end;
        PolyBezier(Slice(Pt,13));
        for I:=1 to 13 do
         begin
          Pt[I].X:=X+Round((ASmallRing[I].X-1343)/10000*H*K);
          Pt[I].Y:=Y-Round(ASmallRing[I].Y/10000*H)
         end;
        PolyBezier(Slice(Pt,13));
        EndPath(Handle);
        StrokeAndFillPath(Handle)
       end
     end;

   procedure TExprCirc.LRDrawSymbol;
    var Pt:array[1..6] of TPoint;
        W,H:Integer;
        WX1,WY2,RX,RY:Integer;
        K:Extended;
     begin
      H:=GetSymbolHeight;
      K:=GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY);
      W:=Round(0.2687*H*K);
      WY2:=MaxIntValue([1,Round(H*0.1)]);
      WX1:=MaxIntValue([1,Round(H*0.05*K)]);
      if not Odd(W) then
       Inc(W);
      RX:=W div 2;
      RY:=Round(RX*K);
      Canvas.Pen.Style:=psSolid;
      Canvas.Pen.Width:=1;
      Canvas.Pen.Color:=Color;
      Canvas.Brush.Style:=bsClear;
      Canvas.Ellipse(X-RX,Y-RY,X+RX+1,Y+RY+1);
      Dec(X,W div 2);
      Dec(Y,H div 2);
      Canvas.Brush.Style:=bsSolid;
      Canvas.Brush.Color:=Color;
      Canvas.Ellipse(X+RX+1,Y,X+W,Y+RY);
      Canvas.Ellipse(X,Y+H-RY,X+RX,Y+H);
      Pt[1].X:=X+RX;
      Pt[1].Y:=Y+MaxIntValue([1,RY div 2])+1;
      Pt[2].X:=Pt[1].X-WX1;
      Pt[2].Y:=Pt[1].Y+2*WY2;
      Pt[4].X:=Pt[1].X;
      Pt[4].Y:=Y+H-1-MaxIntValue([1,RY div 2])-1;
      Pt[3].X:=Pt[2].X;
      Pt[3].Y:=Pt[4].Y-4*WY2;
      Pt[5].X:=Pt[4].X+WX1;
      Pt[5].Y:=Pt[4].Y-2*WY2;
      Pt[6].X:=Pt[5].X;
      Pt[6].Y:=Pt[1].Y+4*WY2;
      Canvas.Polygon(Pt)
     end;

   {TExprIntegral}

   constructor TExprIntegral.Create;
    begin
     inherited Create(ASon,FirstTwin,SecondTwin);
     K:=Mult
    end;

   function TExprIntegral.CalcSymbolWidth;
    var Size:TSize;
        Ch:WideChar;
     begin
      Result:=Round(GetSymbolHeight*0.2687*GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY));
      if K<1 then
       begin
        Ch:=WideChar(8230);
        GetTextExtentPoint32W(Canvas.Handle,@Ch,1,Size);
        Result:=3*Result+4*WX+Size.CX
       end
      else
       Result:=Result*K+WX*(K-1)
     end;

   procedure TExprIntegral.DrawHook;
    var Pt:array[1..52] of TPoint;
        I:Integer;
        K:Extended;
     begin
      K:=GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY);
      for I:=1 to 52 do
       begin
        Pt[I].X:=X+Round(AIntegral[I].X/10000*H*K);
        Pt[I].Y:=Y-Round((AIntegral[I].Y-5000)/10000*H)
       end;
      with Canvas do
       begin
        BeginPath(Handle);
        PolyBezier(Pt);
        EndPath(Handle);
        SetPenAndBrush;
        StrokeAndFillPath(Handle)
       end
     end;

   procedure TExprIntegral.LRDrawHook;
    var Pt:array[1..6] of TPoint;
        W:Integer;
        WX1,WY2,RX,RY:Integer;
        K:Extended;
     begin
      K:=GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY);
      W:=Round(0.2687*H*K);
      WY2:=MaxIntValue([1,Round(H*0.1)]);
      WX1:=MaxIntValue([1,Round(H*0.05*K)]);
      if not Odd(W) then
       Inc(W);
      RX:=W div 2;
      RY:=Round(RX*K);
      SetPenAndBrush;
      Canvas.Ellipse(X+RX+1,Y,X+W,Y+RY);
      Canvas.Ellipse(X,Y+H-RY,X+RX,Y+H);
      Pt[1].X:=X+RX;
      Pt[1].Y:=Y+MaxIntValue([1,RY div 2])+1;
      Pt[2].X:=Pt[1].X-WX1;
      Pt[2].Y:=Pt[1].Y+2*WY2;
      Pt[4].X:=Pt[1].X;
      Pt[4].Y:=Y+H-1-MaxIntValue([1,RY div 2])-1;
      Pt[3].X:=Pt[2].X;
      Pt[3].Y:=Pt[4].Y-4*WY2;
      Pt[5].X:=Pt[4].X+WX1;
      Pt[5].Y:=Pt[4].Y-2*WY2;
      Pt[6].X:=Pt[5].X;
      Pt[6].Y:=Pt[1].Y+4*WY2;
      Canvas.Polygon(Pt)
     end;

   procedure TExprIntegral.DrawSymbol;
    var I:Integer;
        H,W,HW:Integer;
        Ch:WideChar;
     begin
      H:=GetSymbolHeight;
      HW:=Round(H*0.2687*GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY));
      W:=GetSymbolWidth;
      Dec(X,W div 2);
      Dec(Y,H div 2);
      if K<1 then
       begin
        DrawHook(H,X,Y);
        DrawHook(H,X+HW+WX,Y);
        Ch:=WideChar(8230);
        SetBkMode(Canvas.Handle,Transparent);
        TextOutW(Canvas.Handle,X+2*HW+3*WX,Y+H-Canvas.TextHeight('A'),@Ch,1);
        DrawHook(H,X+W-HW,Y)
       end
      else
       for I:=0 to K-1 do
        DrawHook(H,X+I*(HW+WX),Y)
     end;

   procedure TExprIntegral.LRDrawSymbol;
    var I:Integer;
        H,W,HW:Integer;
        Ch:WideChar;
     begin
      H:=GetSymbolHeight;
      HW:=Round(H*0.2687*GetDeviceCaps(Canvas.Handle,LogPixelSX)/GetDeviceCaps(Canvas.Handle,LogPixelSY));
      W:=GetSymbolWidth;
      Dec(X,W div 2);
      Dec(Y,H div 2);
      if K<1 then
       begin
        LRDrawHook(H,X,Y);
        LRDrawHook(H,X+HW+WX,Y);
        Ch:=WideChar(8230);
        SetBkMode(Canvas.Handle,Transparent);
        TextOutW(Canvas.Handle,X+2*HW+3*WX,Y+H-Canvas.TextHeight('A'),@Ch,1);
        LRDrawHook(H,X+W-HW,Y)
       end
      else
       for I:=0 to K-1 do
        LRDrawHook(H,X+I*(HW+WX),Y)
     end;

   {TExprLambda}

   constructor TExprLambda.Create;
    begin
     inherited Create(955)
    end;

   procedure TExprLambda.Paint;
    var DY:Integer;
     begin
      inherited Paint(X,Y);
      DY:=Y+Round(9*RWY);
      SetPenAndBrush;
      Canvas.Rectangle(X+Round(1.5*RWX),DY,X+Width-Round(2*RWX),DY+WY)
     end;

   {TExprNabla}

   constructor TExprNabla.Create;
    begin
     inherited Create(916)
    end;

   procedure TExprNabla.Paint;
    var LF:TLogFont;
        NewFont,OldFont:HFont;
        Size:TSize;
     begin
      with LF,Font do
       begin
        lfHeight:=-MulDiv(GetDeviceCaps(Canvas.Handle,LogPixelSY),Font.Size,72);
        lfWidth:=0;
        lfEscapement:=1800;
        lfOrientation:=1800;
        if fsBold in Style then
         lfWeight:=FW_Bold
        else
         lfWeight:=FW_Normal;
        lfItalic:=Byte(fsItalic in Style);
        lfUnderline:=Byte(fsUnderline in Style);
        lfStrikeOut:=Byte(fsStrikeOut in Style);
        lfCharSet:=Byte(CharSet);
        lfOutPrecision:=Out_Default_Precis;
        lfClipPrecision:=Clip_Default_Precis;
        lfQuality:=Default_Quality;
        case Pitch of
         fpVariable:lfPitchAndFamily:=Variable_Pitch;
         fpFixed:lfPitchAndFamily:=Fixed_Pitch
        else
         lfPitchAndFamily:=Default_Pitch
        end;
        StrPCopy(lfFaceName,Name)
       end;
      SetBkMode(Canvas.Handle,Transparent);
      NewFont:=CreateFontIndirect(LF);
      OldFont:=SelectObject(Canvas.Handle,NewFont);
      SetTextColor(Canvas.Handle,Color);
      GetTextExtentPoint32W(Canvas.Handle,#916,1,Size);
      TextOutW(Canvas.Handle,X+Size.CX,Y+Size.CY,#916,1);
      SelectObject(Canvas.Handle,OldFont);
      DeleteObject(NewFont)
     end;

   {TExprAsterix}

   constructor TExprAsterix.Create;
    begin
     inherited Create('*')
    end;

   procedure TExprAsterix.Paint;
    begin
     SetCanvasFont;
     Canvas.TextOut(X,Y+Round(8*RWY),'*')
    end;

   {TExprCase}

   function TExprCase.CalcWidth;
    var W1,W2,I:Integer;
        P:TExprClass;
     begin
      W1:=0;
      W2:=0;
      P:=Son;
      I:=1;
      while Assigned(P) do
       begin
        if Odd(I) then
         W1:=MaxIntValue([W1,P.Width])
        else
         W2:=MaxIntValue([W2,P.Width]);
        Inc(I);
        P:=P.Next
       end;
      Result:=18*WX+W1+W2
     end;

   function TExprCase.CalcHeight;
    var H1,H2,I:Integer;
        P:TExprClass;
     begin
      Result:=0;
      P:=Son;
      I:=1;
      while Assigned(P) do
       begin
        if Odd(I) then
         begin
          H1:=P.MidLineUp;
          H2:=-P.MidLineDn
         end
        else
         begin
          Inc(Result,MaxIntValue([H1,P.MidLineUp]));
          Inc(Result,MaxIntValue([H2,-P.MidLineDn]));
          if Assigned(P.Next) then
           Inc(Result,2*WY)
         end;
        Inc(I);
        P:=P.Next
       end;
      if not Odd(Result) then
       Inc(Result)
     end;

   procedure TExprCase.Paint;
    var KH,I,H,W,H1,H2,DX:Integer;
        Pt:array[1..46] of TPoint;
        P,PP:TExprClass;
     begin
      H:=Height;
      W:=X+Width;
      KH:=(H-11*WY) div 2+1;
      Pt[1].X:=X+WX;
      Pt[1].Y:=Y+KH+5*WY-1;
      Pt[2].X:=X+2*WX-1;
      Pt[2].Y:=Y+KH+5*WY-1;
      Pt[3].X:=X+3*WX;
      Pt[3].Y:=Y+KH+4*WY-2;
      Pt[4].X:=Pt[3].X;
      Pt[4].Y:=Y+KH+3*WY-1;
      Pt[5]:=Pt[4];
      Pt[6].X:=Pt[5].X;
      Pt[6].Y:=Y+3*WY-1;
      Pt[7]:=Pt[6];
      Pt[8].X:=Pt[7].X;
      Pt[8].Y:=Y+WY;
      Pt[9].X:=Pt[7].X+WX;
      Pt[9].Y:=Y+WY;
      Pt[10].X:=X+7*WX-1;
      Pt[10].Y:=Y+WY;
      Pt[11]:=Pt[10];
      Pt[12].X:=Pt[10].X;
      Pt[12].Y:=Y+2*WY-1;
      Pt[13]:=Pt[12];
      Pt[14].X:=X+5*WX-1;
      Pt[14].Y:=Y+2*WY-1;
      Pt[15]:=Pt[14];
      Pt[16].X:=X+5*WX-1;
      Pt[16].Y:=Y+3*WY-1;
      Pt[17]:=Pt[16];
      Pt[18].X:=Pt[17].X;
      Pt[18].Y:=Y+KH+3*WY-1;
      Pt[19].X:=Pt[18].X;
      Pt[19].Y:=Pt[4].Y;
      Pt[20].X:=Pt[19].X;
      Pt[20].Y:=Pt[3].Y-WY;
      Pt[21].X:=X+5*WX-2;
      Pt[21].Y:=Pt[2].Y;
      Pt[22].X:=X+3*WX-1;
      Pt[22].Y:=Pt[1].Y;
      Pt[23]:=Pt[22];
      for I:=24 to 46 do
       begin
        Pt[I].X:=Pt[47-I].X;
        Pt[I].Y:=2*Y+H-1-Pt[47-I].Y
       end;
      BeginPath(Canvas.Handle);
      Canvas.PolyBezier(Pt);
      EndPath(Canvas.Handle);
      SetPenAndBrush;
      StrokeAndFillPath(Canvas.Handle);
      DX:=X+7*WX;
      H:=Y;
      P:=Son;
      I:=1;
      while Assigned(P) do
       begin
        if Odd(I) then
         begin
          H1:=P.MidLineUp;
          H2:=-P.MidLineDn;
          PP:=P;
         end
        else
         begin
          H1:=MaxIntValue([H1,P.MidLineUp]);
          H2:=MaxIntValue([H2,-P.MidLineDn]);
          Inc(H,H1);
          PP.Draw(DX,H,ehLeft,evCenter);
          P.Draw(W,H,ehRight,evCenter);
          Inc(H,H2);
          Inc(H,2*WY)
         end;
        Inc(I);
        P:=P.Next
       end
     end;

   {TExprEmpty}

   function TExprEmpty.CalcHeight;
    begin
     SetCanvasFont;
     Result:=Canvas.TextHeight('A')
    end;

 end.
