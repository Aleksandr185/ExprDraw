unit ExprMake;

 interface

  uses ExprDraw,SysUtils;

   type TExprBuilder=class
                      protected
                       Build:Boolean;
                       P:Integer;
                       S:string;
                       function Preprocess(S:string):string;
                       procedure AddMult(var Existing:TExprClass;Multiplier:TExprClass);
                       function MakePower(Base,Exponent:TExprClass):TExprClass;
                       function MakeIndex(Base,Index:TExprClass):TExprClass;
                       function MakeCap(Base:TExprClass;Style:TExprCapStyle;N:Integer):TExprClass;
                       procedure Decorate(var Base:TExprClass);
                       function ExprString(Need:Integer;AllowComma:Boolean=False):TExprClass;
                       function BoolExpr(var Flags:Integer):TExprClass;
                       function Expr(var Flags:Integer):TExprClass;
                       function Factor(var Flags:Integer):TExprClass;
                       function Trans(var Flags:Integer):TExprClass;
                       function Func(var Flags:Integer):TExprClass;
                       function FuncName(N:string;var Flags:Integer;Brackets:Boolean):TExprClass;
                       function Token(N:string;var Flags:Integer):TExprClass;
                       function GreekLetter(N:string):Integer;
                       function Comma:Boolean;
                       procedure LookForComma;
                      public
                       FuncAutoIndex,VarAutoIndex,PostSymbols:Boolean;
                       constructor Create;
                       function BuildExpr(Expr:string):TExprClass;
                       function SafeBuildExpr(Expr:string):TExprClass;
                     end;

        EIncorrectExpr=class(Exception);

    function BuildExpr(Expr:string):TExprClass;
    function SafeBuildExpr(Expr:string):TexprClass;

 implementation

  const EChain=0;
        EExpression=1;
        EBracketed=2;
        EArgument=3;
        EPower=4;
        EAbs=5;
        ESquared=6;
        EFigured=7;

        FlagPower=1;
        FlagTrans=3;

   {TExprBuilder}

   constructor TExprBuilder.Create;
    begin
     inherited Create;
     VarAutoIndex:=True;
     FuncAutoIndex:=True;
     PostSymbols:=True
    end;

   function TExprBuilder.Preprocess;
    var I:Integer;
     begin
      I:=1;
      Result:='';
      while I<Length(S) do
       begin
        case S[I] of
         '<':case S[I+1] of
              '<':begin                        // << - много меньше
                   Result:=Result+#5;
                   Inc(I)
                  end;
              '>':begin                        // <> - не равно
                   Result:=Result+#1;
                   Inc(I)
                  end;
              '=':begin                        // <= - меньше или равно
                   Result:=Result+#3;
                   Inc(I)
                  end;
              '~':begin                        // <~ - меньше или порядка
                   Result:=Result+#15;
                   Inc(I)
                  end
              else
               Result:=Result+'<'
             end;
         '>':case S[I+1] of
              '=':begin                        // >= - больше или равно
                   Result:=Result+#2;
                   Inc(I)
                  end;
              '>':begin                        // >> - много больше
                   Result:=Result+#4;
                   Inc(I)
                  end;
              '~':begin                        // >~ - больше или порядка
                   Result:=Result+#14;
                   Inc(I)
                  end
             else
              Result:=Result+'>'
             end;
         '=':case S[I+1] of
              '=':begin                        // == - тождественно
                   Result:=Result+#10;
                   Inc(I)
                  end;
              '~':begin                        // =~ - знак равенства с тильдой сверху
                   Result:=Result+#20;
                   Inc(I)
                  end
             else
              Result:=Result+'='
             end;
         '~':if S[I+1]='~' then                // ~~ - примерно равно
              begin
               Result:=Result+#7;
               Inc(I)
              end
             else
              Result:=Result+'~';              
         '+':if S[I+1]='-' then                // +- - плюс-минус
              begin
               Result:=Result+#8;
               Inc(I)
              end
             else
              Result:=Result+'+';
         '-':case S[I+1] of                    // -+ - минус-плюс
              '+':begin
                   Result:=Result+#9;
                   Inc(I)
                  end;
              '>':begin                        // -> - стрелка (стремится к пределу)
                   Result:=Result+#6;
                   Inc(I)
                  end
             else
              Result:=Result+'-'
             end;                              // // - делить символом "/", без дроби
         '/':case S[I+1] of
              '/':begin
                   Result:=Result+#16;
                   Inc(I)
                  end;
              '+':begin                        // /+ - знак "минус с точкой снизу и точкой сверху"
                   Result:=Result+#11;
                   Inc(I)
                  end
             else
              Result:=Result+'/'
             end;
         '*':case S[I+1] of
              '+':begin                        // *+ - косой крест
                   Result:=Result+#12;
                   Inc(I)
                  end;
              '*':begin                        // ** - умножение без перестановки множителей
                   Result:=Result+#19;
                   Inc(I)
                  end;
              '.':begin                        // *. - умножение точкой
                   Result:=Result+#18;
                   Inc(I)
                  end
             else
              Result:=Result+'*'
             end;
         '!':if S[I+1]='(' then                // !( - обязательная скобка (закрывается обычной)
              begin
               Result:=Result+#17;
               Inc(I)
              end
             else
              Result:=Result+'!';
         ' ':if (I+1<Length(S)) and (S[I+1]='&') and (S[I+2]=' ') then // " & " - то же самое, что и "&"
              begin
               Result:=Result+'&';
               Inc(I,2)
              end
             else
              Result:=Result+' ';
         '.':if (I+1<Length(S)) and (S[I+1]='.') and (S[I+2]='.') then // ... - эллипсис
              begin
               Result:=Result+#13;
               Inc(I,2)
              end
             else
              Result:=Result+'.'
        else
         Result:=Result+S[I]
        end;
        Inc(I)
       end;
      Result:=Result+S[I]
     end;

   procedure TExprBuilder.AddMult;
    var ELast,MLast,Temp:TExprClass;
     begin
      if Build then
       begin
        if not Assigned(Existing) then
         begin
          Existing:=Multiplier;
          Exit
         end;
        ELast:=Existing;
        while Assigned(ELast.Next) do
         ELast:=ELast.Next;
        MLast:=Multiplier;
        while Assigned(MLast.Next) do
         MLast:=MLast.Next;
        if (ELast.FTType and efRight>0) and (Multiplier.FTType and efLeft>0) then
         Existing.AddNext(Multiplier)
        else
         if (MLast.FTType and efRight>0) and (Existing.FTType and efLeft>0) then
          begin
           Multiplier.AddNext(Existing);
           Existing:=Multiplier
          end
         else
          if (Existing is TExprNumber) and (MLast is TExprNumber) then
           begin
            TExprNumber(MLast).Number:=TExprNumber(MLast).Number*TExprNumber(Existing).Number;
            MLast.Next:=Existing.CutOff;
            Existing.Free;
            Existing:=Multiplier
           end
          else
           if (Multiplier.FTType and efLeft>0) and (MLast.FTType and efRight>0) then
            begin
             Temp:=Existing;
             while Assigned(Temp.Next) do
              if (Temp.FTType and efRight>0) and (Temp.Next.FTType and efLeft>0) then
               Break
              else
               Temp:=Temp.Next;
             if Assigned(Temp.Next) then
              begin
               MLast.Next:=Temp.CutOff;
               Temp.Next:=Multiplier
              end
             else
              begin
               Existing.AddNext(TExprSign.Create(esMultiply));
               Existing.AddNext(Multiplier)
              end
            end
           else
            begin
             Existing.AddNext(TExprSign.Create(esMultiply));
             Existing.AddNext(Multiplier)
            end
       end
      else
       Existing:=nil;
     end;

   function TExprBuilder.MakePower;
    var A:TExprClass;
     begin
      if not Build then
       Result:=nil
      else
       begin
        if Base is TExprCommonFunc then
         with TExprCommonFunc(Base) do
          if (Son is TExprIndex) and not Assigned(TExprIndex(Son).Twin2) then
           begin
            TExprIndex(Son).Twin2:=Exponent;
            Result:=Base;
            Exit
           end
          else
           if not (Son is TExprIndex) then
            begin
             A:=TExprIndex.Create(CutOffSon,nil,Exponent);
             Son:=A;
             Result:=Base;
             Exit
            end;
        if (Base is TExprIndex) and not Assigned(TExprIndex(Base).Twin2) then
         begin
          TExprIndex(Base).Twin2:=Exponent;
          Result:=Base
         end
        else
         Result:=TExprIndex.Create(Base,nil,Exponent)
        end
     end;

   function TExprBuilder.MakeIndex;
    var A:TExprClass;
     begin
      if not Build then
       Result:=nil
      else
       begin
        if Base is TExprCommonFunc then
         with TExprCommonFunc(Base) do
          if (Son is TExprIndex) and not Assigned(TExprIndex(Son).Twin1) then
           begin
            TExprIndex(Son).Twin1:=Index;
            Result:=Base;
            Exit
           end
          else
           if not (Son is TExprIndex) then
            begin
             A:=TExprIndex.Create(CutOffSon,Index,nil);
             Son:=A;
             Result:=Base;
             Exit
            end;
        if (Base is TExprIndex) and not Assigned(TExprIndex(Base).Twin1) then
         begin
          TExprIndex(Base).Twin1:=Index;
          Result:=Base
         end
        else
         Result:=TExprIndex.Create(Base,Index,nil)
        end
     end;

   function TExprBuilder.MakeCap;
    var A:TExprClass;
     begin
      if not Assigned(Base) then
       Result:=nil
      else
       if Base is TExprCommonFunc then
        with TExprCommonFunc(Base) do
         begin
          A:=MakeCap(CutOffSon,Style,N);
          Son:=A;
          Result:=Base
         end
       else
        if (Base is TExprIndex) and not Assigned(TExprIndex(Base).Twin2) then
         with TExprIndex(Base) do
          begin
           A:=TExprCap.Create(CutOffSon,Style,N);
           Son:=A;
           Result:=Base
          end
        else
         Result:=TExprCap.Create(Base,Style,N)
     end;

   procedure TExprBuilder.Decorate;
    var A:TExprClass;
     begin
      if (Base is TExprChain) and Assigned(TExprChain(Base).Son.Next) then
       begin
        A:=TExprChain(Base).CutOffSon;
        Base.Free;
        Base:=TExprBracketed.Create(A,ebRound,ebRound)
       end
     end;

   function TExprBuilder.ExprString;
    var Flags:Integer;
        A:TExprClass;
        Sep:Char;
     begin
      Result:=BoolExpr(Flags);
      while (S[P]='&') or ((S[P]=',') and AllowComma) do
       begin
        Sep:=S[P];
        Inc(P);
        if Sep=',' then
         while (S[P]=' ') and (P<Length(S)-1) do
          Inc(P);
        A:=BoolExpr(Flags);
        if Build then
         if Sep='&' then
          Result.AddNext(A)
         else
          begin
           Result.AddNext(TExprComma.Create);
           Result.AddNext(TExprSpace.Create(7));
           Result.AddNext(A)
          end
       end;
      if Build then
       case Need of
        EExpression:if Assigned(Result.Next) then
                     Result:=TExprChain.Create(Result);
        EBracketed:Result:=TExprRound.Create(Result);
        EArgument:if Assigned(Result.Next) then
                   Result:=TExprArgument.Create(Result);
        EPower:if Assigned(Result.Next) then
                Result:=TExprBase.Create(Result)
               else
                if Flags and FlagPower=FlagPower then
                 Result:=TExprBracketed.Create(Result,ebRound,ebRound);
        EAbs:Result:=TExprBracketed.Create(Result,ebModule,ebModule);
        ESquared:Result:=TExprBracketed.Create(Result,ebSquare,ebSquare);
        EFigured:Result:=TExprBracketed.Create(Result,ebFigure,ebFigure)
       end
     end;

   function TExprBuilder.BoolExpr;
    var LFlags,Sign:Integer;
        A:TExprClass;
     begin
      Result:=Expr(LFlags);
      while S[P] in ['<','>','=','~',#1..#7,#10,#14,#15,#20] do
       begin
        case S[P] of
         #1:Sign:=esNotEqual;
         #2:Sign:=esGreaterOrEqual;
         #3:Sign:=esLessOrEqual;
         #4:Sign:=esMuchGreater;
         #5:Sign:=esMuchLess;
         #6:Sign:=esArrow;
         #7:Sign:=esApproxEqual;
         #10:Sign:=esEquivalent;
         #14:Sign:=esApproxGreater;
         #15:Sign:=esApproxLess;
         #20:Sign:=esAlmostEqual;
         '<':Sign:=esLess;
         '=':Sign:=esEqual;
         '>':Sign:=esGreater;
         '~':Sign:=esTilde
        end;
        Inc(P);
        A:=Expr(LFlags);
        if Build then
         begin
          Result.AddNext(TExprSign.Create(Sign));
          Result.AddNext(A)
         end
       end;
      if Build then
       if Assigned(Result.Next) then
        Flags:=FlagPower
       else
        Flags:=LFlags
     end;

   function TExprBuilder.Expr;
    var LFlags,Sign:Integer;
        A:TExprClass;
     begin
      Result:=Trans(LFlags);
      while S[P] in ['-','+',#8,#9] do
       begin
        case S[P] of
         #8:Sign:=esPlusMinus;
         #9:Sign:=esMinusPlus;
         '-':Sign:=esMinus;
         '+':Sign:=esPlus
        end;
        Inc(P);
        A:=Trans(LFlags);
        if Build then
         begin
          if LFlags and FlagTrans=FlagTrans then
           A:=TExprBracketed.Create(A,ebRound,ebRound);
          Result.AddNext(TExprSign.Create(Sign));
          Result.AddNext(A)
         end
       end;
      if Build then
       if Assigned(Result.Next) then
        Flags:=FlagPower
       else
        Flags:=LFlags
     end;

   function TExprBuilder.Trans;
    var LFlags:Integer;
        D1,D2,A:TExprClass;
     begin
      D2:=nil;
      D1:=Factor(LFlags);
      while S[P] in [#11,#12,#16,#18,#19,'*','/'] do
       case S[P] of
        #11:begin
             Inc(P);
             A:=Factor(LFlags);
             if Build then
              begin
               D1.AddNext(TExprSign.Create(esDivide));
               D1.AddNext(A)
              end
            end;
        #12:begin
             Inc(P);
             A:=Factor(LFlags);
             if Build then
              begin
               D1.AddNext(TExprSign.Create(esCrossMultiply));
               D1.AddNext(A)
              end
            end;
        #16:begin
             Inc(P);
             A:=Factor(LFlags);
             if Build then
              begin
               D1.AddNext(TExprSign.Create(esSlash));
               D1.AddNext(A)
              end
            end;
        #18:begin
             Inc(P);
             A:=Factor(LFlags);
             if Build then
              begin
               D1.AddNext(TExprSign.Create(esMultiply));
               D1.AddNext(A)
              end
            end;
        #19:begin
             Inc(P);
             A:=Factor(LFlags);
             if Build then
              D1.AddNext(A)
            end;
        '*':begin
             Inc(P);
             AddMult(D1,Factor(LFlags))
            end;
        '/':begin
             Inc(P);
             AddMult(D2,Factor(LFlags))
            end
       end;
      if Build then
       begin
        Flags:=0;
        if not Assigned(D2) and not Assigned(D1.Next) then
         Flags:=LFlags;
        if Assigned(D2) then
         begin
          if Assigned(D1.Next) then
           D1:=TExprChain.Create(D1);
          if Assigned(D2.Next) then
           D2:=TExprChain.Create(D2);
          Flags:=FlagPower;
          if D1.FTType and efRoundBrackets=efRoundBrackets then
           TExprBracketed(D1).RemoveBrackets;
          if D2.FTType and efRoundBrackets=efRoundBrackets then
           TExprBracketed(D2).RemoveBrackets;
          Result:=TExprRatio.Create(D1,D2)
         end
        else
         Result:=D1
       end
      else
       Result:=nil
     end;

   function TExprBuilder.Factor;
    var B:TExprClass;
        R:Extended;
        J,D:Integer;
     begin
      Flags:=0;
      case S[P] of
       '0'..'9':begin
                 Val(Copy(S,P,255),R,D);
                 J:=D;
                 Val(Copy(S,P,J-1),R,D);
                 if Build then
                  Result:=TExprNumber.Create(R,False)
                 else
                  Result:=nil;
                 Inc(P,J-1)
                end;
       '#':begin
            Inc(P);
            if not (S[P] in ['0'..'9']) then
             raise EIncorrectExpr('Ожидается цифра в позиции '+IntToStr(P));
            Val(Copy(S,P,255),R,D);
            J:=D;
            Val(Copy(S,P,J-1),R,D);
            if Build then
             Result:=TExprNumber.Create(R,True)
            else
             Result:=nil;
            Inc(P,J-1)
           end;
       '+':begin
            Inc(P);
            Flags:=FlagTrans;
            B:=Factor(D);
            if Build then
             begin
              Result:=TExprSign.Create(esPlus);
              Result.AddNext(B)
             end
            else
             Result:=nil
           end;
       '-':begin
            Inc(P);
            B:=Factor(D);
            if Build then
             begin
              Result:=TExprSign.Create(esMinus);
              Result.AddNext(B);
             end
            else
             Result:=nil
           end;
       #8:begin
           Inc(P);
           Flags:=FlagTrans;
           B:=Factor(D);
           if Build then
            begin
             Result:=TExprSign.Create(esPlusMinus);
             Result.AddNext(B)
            end
           else
            Result:=nil
          end;
       #9:begin
           Inc(P);
           Flags:=FlagTrans;
           B:=Factor(D);
           if Build then
            begin
             Result:=TExprSign.Create(esMinusPlus);
             Result.AddNext(B)
            end
           else
            Result:=nil
          end;
       '[':begin
            Inc(P);
            Result:=ExprString(ESquared,True);
            if S[P]=']' then
             Inc(P)
            else
             raise EIncorrectExpr.Create('Ожидается "]" в позиции '+IntToStr(P))
           end;
       '{':begin
            Inc(P);
            Result:=ExprString(EFigured,True);
            if S[P]='}' then
             Inc(P)
            else
             raise EIncorrectExpr.Create('Ожидается "}" в позиции '+IntToStr(P))
           end;
       '(':begin
            Inc(P);
            Result:=ExprString(EArgument);
            if S[P]=')' then
             Inc(P)
            else
             raise EIncorrectExpr.Create('Ожидается ")" в позиции '+IntToStr(P))
           end;
       '|':begin
            Inc(P);
            Result:=ExprString(EAbs,True);
            if S[P]='|' then
             Inc(P)
            else
             raise EIncorrectExpr.Create('Ожидается "|" в позиции '+IntToStr(P))
           end;
       #17:begin
            Inc(P);
            Result:=ExprString(EBracketed,True);
            if S[P]=')' then
             Inc(P)
            else
             raise EIncorrectExpr.Create('Ожидается ")" в позиции '+IntToStr(P))
           end;
       #13:begin
            Inc(P);
            if Build then
             Result:=TExprExtSymbol.Create(esEllipsis)
            else
             Result:=nil
           end;
       '_':begin
            Inc(P);
            B:=Factor(Flags);
            if Build then
             Result:=MakeCap(B,ecVector,0)
            else
             Result:=nil
           end;
       'A'..'Z','a'..'z','А'..'я','Ё','ё':Result:=Func(Flags)
       else
        raise EIncorrectExpr.Create('Недопустимый символ в позиции '+IntToStr(P))
      end;
      if PostSymbols then
       while S[P] in ['^','_','!','`'] do
        case S[P] of
         '^':begin
              Inc(P);
              B:=Factor(D);
              if Build then
               begin
                if B is TExprArgument then
                 TExprArgument(B).RemoveBrackets;
                Decorate(Result);
                Result:=MakePower(Result,B);
               end;
              Flags:=FlagPower
             end;
         '_':begin
              Inc(P);
              PostSymbols:=False;
              B:=Factor(D);
              PostSymbols:=True;
              if Build then
               begin
                if B is TExprArgument then
                 TExprArgument(B).RemoveBrackets;
                Decorate(Result);
                Result:=MakeIndex(Result,B);
               end;
              //Flags:=FlagPower
             end;
         '!':begin
              Inc(P);
              Decorate(Result);
              if Build then
               Result.AddNext(TExprSimple.Create('!'))
             end;
         '`':begin
              Inc(P);
              D:=1;
              while S[P]='`' do
               begin
                Inc(P);
                Inc(D)
               end;
              Decorate(Result);
              Result:=MakePower(Result,TExprStrokes.Create(D))
             end
        end
     end;

   function TExprBuilder.Func;
    var N:string;
        I,J:Integer;
        WasIndex:Boolean;
     begin
      N:=S[P];
      Inc(P);
      while S[P] in ['A'..'Z','a'..'z','0'..'9','А'..'я','Ё','ё'] do
       begin
        N:=N+S[P];
        Inc(P)
       end;
      if (S[P]='(') or (S[P]=#17) then
       begin
        Inc(P);
        Result:=FuncName(N,Flags,S[P-1]=#17);
        if S[P]=')' then
         Inc(P)
        else
         raise EIncorrectExpr.Create('Ожидается ")" в позиции '+IntToStr(P))
       end
      else
       begin
        if VarAutoIndex then
         begin
          I:=Length(N);
          while N[I] in ['0'..'9'] do
           Dec(I);
          if I<Length(N) then
           begin
            WasIndex:=True;
            J:=StrToInt(Copy(N,I+1,MaxInt));
            N:=Copy(N,1,I)
           end
          else
           WasIndex:=False;
         end;
        Result:=Token(N,Flags);
        if Build and VarAutoIndex and WasIndex then
         Result:=TExprIndex.Create(Result,TExprNumber.Create(J,False),nil)
       end
     end;

   function TExprBuilder.FuncName;
    var A,C,D,D2:TExprClass;
        M,T:string;
        I,GI,P0:Integer;
        X:Extended;
        K,K2,J,B:Integer;
        LeftBr,RightBr:TExprBracket;
        Pr,Dig,MD:Integer;
     begin
      Flags:=0;
      M:=UpperCase(N);
      if M='SQRT' then begin
                        A:=ExprString(EExpression);
                        if Build then
                         Result:=TExprRoot.Create(A,nil)
                        else
                         Result:=nil
                       end else
      if M='SQR' then begin
                       Flags:=FlagPower;
                       Result:=MakePower(ExprString(EPower),TExprNumber.Create(2,False))
                      end else
      if M='LOG' then begin
                       A:=ExprString(EExpression);
                       LookForComma;
                       D:=ExprString(EArgument);
                       if Build and Brackets then
                        if D is TExprArgument then
                         TExprArgument(D).SetBrackets
                        else
                         D:=TExprRound.Create(D);
                       if Build then
                        Result:=TExprCommonFunc.Create(TExprIndex.Create(TExprFuncName.Create(N),A,nil),D)
                       else
                        Result:=nil
                      end else
      if M='ABS' then begin
                       Result:=ExprString(EAbs)
                      end else
      if M='POW' then begin
                       Flags:=FlagPower;
                       D:=ExprString(EPower);
                       LookForComma;
                       Result:=MakePower(D,ExprString(EExpression))
                      end else
      if M='ROOT' then begin
                        D:=ExprString(EExpression);
                        LookForComma;
                        A:=ExprString(EExpression);
                        if Build then
                         Result:=TExprRoot.Create(A,D)
                        else
                         Result:=nil
                       end else
      if M='IND' then begin
                       D:=ExprString(EPower);
                       LookForComma;
                       Result:=MakeIndex(D,ExprString(EExpression))
                      end else
      if M='LIM' then begin
                       Flags:=FlagPower;
                       D:=ExprString(EExpression);
                       LookForComma;
                       A:=ExprString(EArgument);
                       if Build and Brackets then
                        if D is TExprArgument then
                         TExprArgument(D).SetBrackets
                        else
                         D:=TExprRound.Create(D);
                       if Build then
                        Result:=TExprCommonFunc.Create(TExprLim.Create(D),A)
                       else
                        Result:=nil
                      end else
      if M='FUNC' then begin
                        A:=ExprString(EExpression);
                        LookForComma;
                        D:=ExprString(EChain);
                        while Comma do
                         begin
                          A:=ExprString(EChain);
                          if Build then
                           begin
                            D.AddNext(TExprComma.Create);
                            D.AddNext(A)
                           end
                         end;
                        if Build then
                         begin
                          D:=TExprArgument.Create(D);
                          if Brackets then
                           TExprArgument(D).SetBrackets;
                          Result:=TExprCommonFunc.Create(A,D)
                         end
                        else
                         Result:=nil
                       end else
      if M='SPACE' then begin
                         Val(Copy(S,P,255),K,B);
                         J:=B;
                         Val(Copy(S,P,J-1),K,B);
                         Inc(P,J-1);
                         if Build then
                          Result:=TExprSpace.Create(K)
                         else
                          Result:=nil
                        end else
      if M='DIFF' then begin  // Diff(x[,n]) - дифференциал от dx^n
                        D:=ExprString(EPower);
                        if Comma then
                         begin
                          A:=ExprString(EExpression);
                          if Build then
                           begin
                            Result:=TExprSpace.Create(4);
                            Result.AddNext(TExprVar.Create('d'));
                            Result.AddNext(TExprIndex.Create(D,nil,A))
                           end
                          else
                           Result:=nil;
                         end
                        else
                         if Build then
                          begin
                           Result:=TExprSpace.Create(4);
                           Result.AddNext(TExprVar.Create('d'));
                           Result.AddNext(D)
                          end
                         else
                          Result:=nil
                       end else
      if M='PDIFF' then begin  // PDiff(x[,n]) - "частный дифференциал" от dx^n
                         D:=ExprString(EPower);
                         if Comma then
                          begin
                           A:=ExprString(EExpression);
                           if Build then
                            begin
                             Result:=TExprSpace.Create(4);
                             Result.AddNext(TExprExtSymbol.Create(esPartDiff));
                             Result.AddNext(TExprIndex.Create(D,nil,A))
                            end
                           else
                            Result:=nil;
                          end
                         else
                          if Build then
                           begin
                            Result:=TExprSpace.Create(4);
                            Result.AddNext(TExprExtSymbol.Create(esPartDiff));
                            Result.AddNext(D)
                           end
                          else
                           Result:=nil
                        end else
      if M='DIFFN' then begin  // DiffN(x[,n]) - d(^n)x
                         D:=ExprString(EPower);
                         if Comma then
                          begin
                           A:=ExprString(EPower);
                           if Build then
                            begin
                             Result:=TExprSpace.Create(4);
                             Result.AddNext(TExprIndex.Create(TExprVar.Create('d'),nil,A));
                             Result.AddNext(D)
                            end
                           else
                            Result:=nil;
                          end
                         else
                          if Build then
                           begin
                            Result:=TExprSpace.Create(4);
                            Result.AddNext(TExprVar.Create('d'));
                            Result.AddNext(D)
                           end
                          else
                           Result:=nil
                        end else
      if M='PDIFFN' then begin // PDiffN(x[,n]) - d(^n)x - "частный дифференциал"
                          D:=ExprString(EPower);
                          if Comma then
                           begin
                            A:=ExprString(EPower);
                            if Build then
                             begin
                              Result:=TExprSpace.Create(4);
                              Result.AddNext(TExprIndex.Create(TExprExtSymbol.Create(esPartDiff),nil,A));
                              Result.AddNext(D)
                             end
                            else
                             Result:=nil;
                           end
                          else
                           if Build then
                            begin
                             Result:=TExprSpace.Create(4);
                             Result.AddNext(TExprExtSymbol.Create(esPartDiff));
                             Result.AddNext(D)
                            end
                           else
                            Result:=nil
                         end else
      if M='DIFFR' then begin // DiffR(x[,n]) - d(^n)/dx^n
                         D:=ExprString(EPower);
                         if Comma then
                          begin
                           P0:=P;
                           A:=ExprString(EExpression);
                           if Build then
                            begin
                             Result:=TExprVar.Create('d');
                             Result.AddNext(TExprIndex.Create(D,nil,A));
                             P:=P0;
                             A:=ExprString(EExpression);
                             Result:=TExprChain.Create(Result);
                             Result:=TExprRatio.Create(TExprIndex.Create(TExprVar.Create('d'),nil,A),Result)
                            end
                           else
                            Result:=nil;
                          end
                         else
                          if Build then
                           begin
                            Result:=TExprVar.Create('d');
                            Result.AddNext(D);
                            Result:=TExprChain.Create(Result);
                            Result:=TExprRatio.Create(TExprVar.Create('d'),Result)
                           end
                          else
                           Result:=nil
                        end else
      if M='PDIFFR' then begin // DiffR(x[,n]) - d(^n)/dx^n - частный дифференциал
                          D:=ExprString(EPower);
                          if Comma then
                           begin
                            P0:=P;
                            A:=ExprString(EExpression);
                            if Build then
                             begin
                              Result:=TExprExtSymbol.Create(esPartDiff);
                              Result.AddNext(TExprIndex.Create(D,nil,A));
                              P:=P0;
                              A:=ExprString(EExpression);
                              Result:=TExprChain.Create(Result);
                              Result:=TExprRatio.Create(TExprIndex.Create(TExprExtSymbol.Create(esPartDiff),nil,A),Result)
                             end
                            else
                             Result:=nil;
                           end
                          else
                           if Build then
                            begin
                             Result:=TExprExtSymbol.Create(esPartDiff);
                             Result.AddNext(D);
                             Result:=TExprChain.Create(Result);
                             Result:=TExprRatio.Create(TExprExtSymbol.Create(esPartDiff),Result)
                            end
                           else
                            Result:=nil
                         end else
      if M='DIFFRF' then begin // DiffRF(y,x[,n]) - d(^n)y/dx^n
                          D2:=ExprString(EPower);
                          LookForComma;
                          D:=ExprString(EPower);
                          if Comma then
                           begin
                            P0:=P;
                            A:=ExprString(EExpression);
                            if Build then
                             begin
                              Result:=TExprVar.Create('d');
                              Result.AddNext(TExprIndex.Create(D,nil,A));
                              P:=P0;
                              A:=ExprString(EExpression);
                              Result:=TExprChain.Create(Result);
                              C:=TExprIndex.Create(TExprVar.Create('d'),nil,A);
                              C.AddNext(D2);
                              C:=TExprChain.Create(C);
                              Result:=TExprRatio.Create(C,Result)
                             end
                            else
                             Result:=nil
                           end
                          else
                           if Build then
                            begin
                             Result:=TExprVar.Create('d');
                             Result.AddNext(D);
                             Result:=TExprChain.Create(Result);
                             C:=TExprVar.Create('d');
                             C.AddNext(D2);
                             C:=TExprChain.Create(C);
                             Result:=TExprRatio.Create(C,Result)
                            end
                           else
                            Result:=nil
                         end else
      if M='PDIFFRF' then begin  // 
                           D2:=ExprString(EPower);
                           LookForComma;
                           D:=ExprString(EPower);
                           if Comma then
                            begin
                             P0:=P;
                             A:=ExprString(EExpression);
                             if Build then
                              begin
                               Result:=TExprExtSymbol.Create(esPartDiff);
                               Result.AddNext(TExprIndex.Create(D,nil,A));
                               P:=P0;
                               A:=ExprString(EExpression);
                               Result:=TExprChain.Create(Result);
                               C:=TExprIndex.Create(TExprExtSymbol.Create(esPartDiff),nil,A);
                               C.AddNext(D2);
                               C:=TExprChain.Create(C);
                               Result:=TExprRatio.Create(C,Result)
                              end
                             else
                              Result:=nil
                            end
                           else
                            if Build then
                             begin
                              Result:=TExprExtSymbol.Create(esPartDiff);
                              Result.AddNext(D);
                              Result:=TExprChain.Create(Result);
                              C:=TExprExtSymbol.Create(esPartDiff);
                              C.AddNext(D2);
                              C:=TExprChain.Create(C);
                              Result:=TExprRatio.Create(C,Result)
                             end
                            else
                             Result:=nil
                          end else
      if M='STRING' then begin
                          if S[P]='"' then
                           begin
                            Inc(P);
                            T:='';
                            repeat
                             if S[P]<>'"' then
                              T:=T+S[P]
                             else
                              if S[P+1]='"' then
                               begin
                                T:=T+'"';
                                Inc(P)
                               end;
                             Inc(P);
                             if P>=Length(S) then
                              raise EIncorrectExpr.Create('Незавершённая строка');
                            until S[P]='"';
                            Inc(P)
                           end
                          else
                           begin
                            T:='';
                            while S[P]<>')' do
                             begin
                              T:=T+S[P];
                              Inc(P);
                              if P>=Length(S) then
                               raise EIncorrectExpr.Create('Незавершённая строка')
                             end
                           end;
                          if Build then
                           Result:=TExprSimple.Create(T)
                          else
                           Result:=nil
                         end else
      if M='STROKES' then begin
                           Flags:=FlagPower;
                           D:=ExprString(EPower);
                           if Comma then
                            begin
                             Val(Copy(S,P,255),K,B);
                             J:=B;
                             Val(Copy(S,P,J-1),K,B);
                             Inc(P,J-1)
                            end
                           else
                            K:=1;
                           if Build then
                            Result:=MakePower(D,TExprStrokes.Create(K))
                           else
                            Result:=nil
                          end else
      if M='FACT' then begin
                        Flags:=FlagPower;
                        D:=ExprString(EPower);
                        if Build then
                         begin
                          Result:=D;
                          Result.AddNext(TExprSimple.Create('!'))
                         end
                        else
                         Result:=nil
                       end else
      if M='AT' then begin
                      A:=ExprString(EArgument);
                      LookForComma;
                      D:=ExprString(EExpression);
                      if Build then
                       Result:=TExprAtValue.Create(A,D)
                      else
                       Result:=nil
                     end else
      if M='LINE' then begin
                        A:=ExprString(EExpression);
                        if Build then
                         Result:=MakeCap(A,ecLine,0)
                        else
                         Result:=nil
                       end else
      if M='VECT' then begin
                        A:=ExprString(EExpression);
                        if Build then
                         Result:=MakeCap(A,ecVector,0)
                        else
                         Result:=nil
                       end else
      if M='CAP' then begin
                       A:=ExprString(EExpression);
                       if Build then
                        Result:=MakeCap(A,ecCap,0)
                       else
                        Result:=nil
                      end else
      if M='TILDE' then begin
                         A:=ExprString(EExpression);
                         if Build then
                          Result:=MakeCap(A,ecTilde,0)
                         else
                          Result:=nil
                        end else
      if M='POINTS' then begin
                          A:=ExprString(EExpression);
                          if Comma then
                           begin
                            Val(Copy(S,P,255),K,B);
                            J:=B;
                            Val(Copy(S,P,J-1),K,B);
                            Inc(P,J-1)
                           end
                          else
                           K:=1;
                          if Build then
                           Result:=MakeCap(A,ecPoints,K)
                          else
                           Result:=nil
                         end else
      if M='STANDL' then begin
                          D:=ExprString(EExpression);
                          while Comma do
                           begin
                            A:=ExprString(EExpression);
                            if Build then
                             D.AddNext(A)
                           end;
                          if Build then
                           Result:=TExprStand.Create(D,ehLeft)
                          else
                           Result:=nil
                         end else
      if M='STANDC' then begin
                          D:=ExprString(EExpression);
                          while Comma do
                           begin
                            A:=ExprString(EExpression);
                            if Build then
                             D.AddNext(A)
                           end;
                          if Build then
                           Result:=TExprStand.Create(D,ehCenter)
                          else
                           Result:=nil
                         end else
      if M='STANDR' then begin
                          D:=ExprString(EExpression);
                          while Comma do
                           begin
                            A:=ExprString(EExpression);
                            if Build then
                             D.AddNext(A)
                           end;
                          if Build then
                           Result:=TExprStand.Create(D,ehRight)
                          else
                           Result:=nil
                         end else
      if M='MATRIX' then begin
                          Val(Copy(S,P,255),K,B);
                          J:=B;
                          Val(Copy(S,P,J-1),K,B);
                          Inc(P,J-1);
                          LookForComma;
                          Val(Copy(S,P,255),K2,B);
                          J:=B;
                          Val(Copy(S,P,J-1),K2,B);
                          Inc(P,J-1);
                          LookForComma;
                          D:=ExprString(EExpression);
                          while Comma do
                           begin
                            A:=ExprString(EExpression);
                            if Build then
                             D.AddNext(A)
                           end;
                          if Build then
                           Result:=TExprMatrix.Create(D,K,K2)
                          else
                           Result:=nil
                         end else
      if M='SUMMA' then begin
                         A:=ExprString(EArgument);
                         if Build and Brackets then
                          if A is TExprArgument then
                           TExprArgument(A).SetBrackets
                          else
                           A:=TExprRound.Create(A);
                         if Comma then
                          D:=ExprString(EExpression)
                         else
                          D:=nil;
                         if Comma then
                          D2:=ExprString(EExpression)
                         else
                          D2:=nil;
                         if Build then
                          Result:=TExprSumma.Create(A,D,D2)
                         else
                          Result:=nil
                        end else
      if M='PROD' then begin
                        A:=ExprString(EArgument);
                        if Build and Brackets then
                         if A is TExprArgument then
                          TExprArgument(A).SetBrackets
                         else
                          A:=TExprRound.Create(A);
                        if Comma then
                          D:=ExprString(EExpression)
                        else
                         D:=nil;
                        if Comma then
                         D2:=ExprString(EExpression)
                        else
                         D2:=nil;
                        if Build then
                         Result:=TExprProd.Create(A,D,D2)
                        else
                         Result:=nil
                       end else
      if M='CIRC' then begin
                        A:=ExprString(EArgument);
                        if Build and Brackets then
                         if A is TExprArgument then
                          TExprArgument(A).SetBrackets
                         else
                          A:=TExprRound.Create(A);
                        if Comma then
                         D:=ExprString(EExpression)
                        else
                         D:=nil;
                        if Comma then
                         D2:=ExprString(EExpression)
                        else
                         D2:=nil;
                        if Build then
                         Result:=TExprCirc.Create(A,D,D2)
                        else
                         Result:=nil
                       end else
      if M='INT' then begin
                       A:=ExprString(EArgument);
                       if Build and Brackets then
                        if A is TExprArgument then
                         TExprArgument(A).SetBrackets
                        else
                         A:=TExprRound.Create(A);
                       if Comma then
                         D:=ExprString(EExpression)
                       else
                        D:=nil;
                       if Comma then
                        D2:=ExprString(EExpression)
                       else
                        D2:=nil;
                       if Build then
                        Result:=TExprIntegral.Create(A,D,D2,1)
                       else
                        Result:=nil
                      end else
      if M='INTM' then begin
                        Val(Copy(S,P,255),K,B);
                        J:=B;
                        Val(Copy(S,P,J-1),K,B);
                        Inc(P,J-1);
                        LookForComma;
                        A:=ExprString(EArgument);
                        if Build and Brackets then
                         if A is TExprArgument then
                          TExprArgument(A).SetBrackets
                         else
                          A:=TExprRound.Create(A);
                        if Comma then
                         D:=ExprString(EExpression)
                        else
                         D:=nil;
                        if Comma then
                         D2:=ExprString(EExpression)
                        else
                         D2:=nil;
                        if Build then
                         Result:=TExprIntegral.Create(A,D,D2,K)
                        else
                         Result:=nil
                       end else
      if M='CASE' then begin
                        A:=ExprString(EExpression);
                        while Comma do
                         begin
                          D:=ExprString(EExpression);
                          if Build then
                           A.AddNext(D)
                         end;
                        if Build then
                         Result:=TExprCase.Create(A)
                        else
                         Result:=nil
                       end else
      if M='COMMA' then begin
                         Val(Copy(S,P,255),K,B);
                         J:=B;
                         Val(Copy(S,P,J-1),K,B);
                         Inc(P,J-1);
                         if Build then
                          begin
                           Result:=TExprComma.Create;
                           Result.AddNext(TExprSpace.Create(K))
                          end
                         else
                          Result:=nil
                        end else
      if M='BRACKETS' then begin
                            case S[P] of
                             '(':LeftBr:=ebRound;
                             '[':LeftBr:=ebSquare;
                             '{':LeftBr:=ebFigure;
                             '|':LeftBr:=ebModule;
                             '0':LeftBr:=ebNone
                            else
                             raise EIncorrectExpr.Create('Ожидается знак открывающей скобки в позиции '+IntToStr(P))
                            end;
                            Inc(P);
                            if P>=Length(S) then
                             raise EIncorrectExpr.Create('Незавершённая строка');
                            case S[P] of
                             ')':RightBr:=ebRound;
                             ']':RightBr:=ebSquare;
                             '}':RightBr:=ebFigure;
                             '|':RightBr:=ebModule;
                             '0':RightBr:=ebNone
                            else
                             raise EIncorrectExpr.Create('Ожидается знак закрывающей скобки в позиции '+IntToStr(P))
                            end;
                            Inc(P);
                            LookForComma;
                            A:=ExprString(EExpression);
                            if Build then
                             Result:=TExprBracketed.Create(A,LeftBr,RightBr)
                            else
                             Result:=nil
                           end else
      if M='SYSTEM' then begin
                          D:=ExprString(EExpression);
                          while Comma do
                           begin
                            A:=ExprString(EExpression);
                            if Build then
                             D.AddNext(A)
                           end;
                          if Build then
                           Result:=TExprBracketed.Create(TExprStand.Create(D,ehLeft),ebFigure,ebNone)
                          else
                           Result:=nil
                         end else
      if M='NUM' then begin
                       Val(Copy(S,P,255),X,B);
                       if B=1 then
                        raise EIncorrectExpr.Create('Ожидается число в позиции '+IntToStr(P));
                       J:=B;
                       Val(Copy(S,P,J-1),X,B);
                       Inc(P,J-1);
                       Dig:=4;
                       MD:=2;
                       if Comma then
                        begin
                         Val(Copy(S,P,255),Pr,B);
                         if B=1 then
                          raise EIncorrectExpr.Create('Ожидается число в позиции '+IntToStr(P));
                         J:=B;
                         Val(Copy(S,P,J-1),Pr,B);
                         Inc(P,J-1);
                         if Comma then
                          begin
                           Val(Copy(S,P,255),Dig,B);
                           if B=1 then
                            raise EIncorrectExpr.Create('Ожидается число в позиции '+IntToStr(P));
                           J:=B;
                           Val(Copy(S,P,J-1),Dig,B);
                           Inc(P,J-1);
                           if Comma then
                            begin
                             Val(Copy(S,P,255),MD,B);
                             if B=1 then
                              raise EIncorrectExpr.Create('Ожидается число в позиции '+IntToStr(P));
                             J:=B;
                             Val(Copy(S,P,J-1),MD,B);
                             Inc(P,J-1)
                            end
                          end
                        end
                       else
                        Pr:=4;
                       if Build then
                        Result:=TExprExpNumber.Create(X,Pr,Dig,MD)
                       else
                        Result:=nil
                      end else
      if M='SYMBOL' then begin
                          Val(Copy(S,P,255),K,B);
                          if B=1 then
                           raise EIncorrectExpr.Create('Ожидается число в позиции '+IntToStr(P));
                          J:=B;
                          Val(Copy(S,P,J-1),K,B);
                          Inc(P,J-1);
                          if Build then
                           Result:=TExprExtSymbol.Create(K)
                          else
                           Result:=nil
                         end else
      if M='ANGLE' then begin
                         if S[P]='"' then
                          begin
                           Inc(P);
                           T:='';
                           repeat
                            if S[P]<>'"' then
                             T:=T+S[P]
                            else
                             if S[P+1]='"' then
                              begin
                               T:=T+'"';
                               Inc(P)
                              end;
                            Inc(P);
                            if P>=Length(S) then
                             raise EIncorrectExpr.Create('Незавершённая строка');
                           until S[P]='"';
                           Inc(P)
                          end
                         else
                          begin
                           T:='';
                           while S[P]<>')' do
                            begin
                             T:=T+S[P];
                             Inc(P);
                             if P>=Length(S) then
                              raise EIncorrectExpr.Create('Незавершённая строка')
                            end
                          end;
                         if Build then
                          begin
                           Result:=TExprSign.Create(esAngle);
                           Result.AddNext(TExprSimple.Create(T))
                          end
                         else
                          Result:=nil
                        end
      else
       begin
        D:=ExprString(EChain,True);
        {while Comma do
         begin
          A:=ExprString(EChain);
          if Build then
           begin
            D.AddNext(TExprComma.Create);
            D.AddNext(A)
           end
         end;}
        if Build then
         begin
          D:=TExprArgument.Create(D);
          if Brackets then
           TExprArgument(D).SetBrackets
         end;
        if FuncAutoIndex then
         begin
          I:=Length(N);
          while N[I] in ['0'..'9'] do
           Dec(I);
          if I<Length(N) then
           if Build then
            begin
             X:=StrToFloat(Copy(N,I+1,MaxInt));
             N:=Copy(N,1,I);
             GI:=GreekLetter(N);
             if GI=0 then
              Result:=MakeIndex(TExprFunc.Create(N,D),TExprNumber.Create(X,False))
             else
              case GI of
               1:Result:=MakeIndex(TExprCommonFunc.Create(TExprLambda.Create,D),TExprNumber.Create(X,False));
               2:Result:=MakeIndex(TExprCommonFunc.Create(TExprNabla.Create,D),TExprNumber.Create(X,False))
              else
               Result:=MakeIndex(TExprCommonFunc.Create(TExprExtSymbol.Create(GI),D),TExprNumber.Create(X,False))
              end
            end
           else
            Result:=nil
          else
           if Build then
            begin
             GI:=GreekLetter(N);
             if GI=0 then
              Result:=TExprFunc.Create(N,D)
             else
              case GI of
               1:Result:=TExprCommonFunc.Create(TExprLambda.Create,D);
               2:Result:=TExprCommonFunc.Create(TExprNabla.Create,D)
              else
               Result:=TExprCommonFunc.Create(TExprExtSymbol.Create(GI),D)
              end 
            end
           else
            Result:=nil
         end
        else
         if Build then
          begin
           GI:=GreekLetter(N);
           if GI=0 then
            Result:=TExprFunc.Create(N,D)
           else
            case GI of
             1:Result:=TExprCommonFunc.Create(TExprLambda.Create,D);
             2:Result:=TExprCommonFunc.Create(TExprNabla.Create,D)
            else
             Result:=TExprCommonFunc.Create(TExprExtSymbol.Create(GI),D)
            end
          end
         else
          Result:=nil
       end
     end;

   function TExprBuilder.Token;
    var M:string;
        GI:Integer;
     begin
      M:=UpperCase(N);
      GI:=GreekLetter(N);
      if GI<>0 then if Build then
                     case GI of
                      1:Result:=TExprLambda.Create;
                      2:Result:=TExprNabla.Create
                     else
                      Result:=TExprExtSymbol.Create(GI)
                     end
                    else
                     Result:=nil else
      if M='INF' then if Build then
                       Result:=TExprExtSymbol.Create(esInfinum)
                      else
                       Result:=nil else
      if M='PLANK' then if Build then
                         Result:=TExprPlank.Create
                        else
                         Result:=nil else
      if M='NIL' then if Build then
                       Result:=TExprClass.Create
                      else
                       Result:=nil else
      if M='COMMA' then if Build then
                         Result:=TExprComma.Create
                        else
                         Result:=nil else
      if M='CONST' then if Build then
                         begin
                          Result:=TExprSimple.Create(N);
                          Result.AddNext(TExprSpace.Create(3))
                         end
                        else
                         Result:=nil else
      if M='ASTERIX' then if Build then
                           Result:=TExprAsterix.Create
                          else
                           Result:=nil else
      if M='MINUS' then if Build then
                         Result:=TExprExtSymbol.Create(esMinus)
                        else
                         Result:=nil else
      if M='PARALLEL' then if Build then
                            Result:=TExprSign.Create(esParallel)
                           else
                            Result:=nil else
      if M='PERPENDICULAR' then if Build then
                                 Result:=TExprSign.Create(esPerpendicular)
                                else
                                 Result:=nil else
      if M='ANGLE' then if Build then
                         Result:=TExprSign.Create(esAngle)
                        else
                         Result:=nil else
      if M='EMPTY' then if Build then
                         Result:=TExprEmpty.Create
                        else
                         Result:=nil
      else
       if Build then
        if N[1] in ['A'..'Z','a'..'z'] then
         Result:=TExprVar.Create(N)
        else
         Result:=TExprSimple.Create(N)
       else
        Result:=nil
     end;

   function TExprBuilder.GreekLetter;
    var M:string;
        DS:Integer;
     begin
      M:=UpperCase(N);
      if N[1] in ['a'..'z'] then
       DS:=32
      else
       DS:=0;
      if M='ALPHA' then
         Result:=913+DS else
      if M='BETA' then
         Result:=914+DS else
      if M='GAMMA' then
         Result:=915+DS else
      if M='DELTA' then
         Result:=916+DS else
      if M='EPSILON' then
         Result:=917+DS else
      if M='ZETA' then
         Result:=918+DS else
      if M='ETA' then
         Result:=919+DS else
      if M='THETA' then
         Result:=920+DS else
      if M='IOTA' then
         Result:=921+DS else
      if M='KAPPA' then
         Result:=922+DS else
      if M='LAMBDA' then
         Result:=923+DS else
      if M='MU' then
         Result:=924+DS else
      if M='NU' then
         Result:=925+DS else
      if M='XI' then
         Result:=926+DS else
      if M='OMICRON' then
         Result:=927+DS else
      if M='PI' then
         Result:=928+DS else
      if M='RHO' then
         Result:=929+DS else
      if M='SIGMA' then
         Result:=931+DS else
      if M='TAU' then
         Result:=932+DS else
      if M='UPSILON' then
         Result:=933+DS else
      if M='PHI' then
         Result:=934+DS else
      if M='CHI' then
         Result:=935+DS else
      if M='PSI' then
         Result:=936+DS else
      if M='OMEGA' then
         Result:=937+DS else
      if M='PLAMBDA' then
         Result:=1 else
      if M='NABLA' then
         Result:=2 else
      Result:=0
     end;

   function TExprBuilder.Comma;
    begin
     Result:=S[P]=',';
     if Result then
      begin
       Inc(P);
       while (P<Length(S)) and (S[P]=' ') do
        Inc(P)
      end
    end;

   procedure TExprBuilder.LookForComma;
    begin
     if not Comma then
      raise EIncorrectExpr.Create('Ожидается "," в позиции '+IntToStr(P))
    end;

   function TExprBuilder.SafeBuildExpr;
    begin
     S:=PreProcess(Expr)+' ';
     Build:=False;
     P:=1;
     ExprString(EExpression,True);
     Build:=True;
     P:=1;
     Result:=ExprString(EExpression,True)
    end;

   function TExprBuilder.BuildExpr;
    begin
     S:=PreProcess(Expr)+' ';
     Build:=True;
     P:=1;
     Result:=ExprString(EExpression,True)
    end;

   function SafeBuildExpr;
    var Builder:TExprBuilder;
     begin
      Builder:=TExprBuilder.Create;
      try
       Result:=Builder.SafeBuildExpr(Expr)
      finally
       Builder.Free
      end
     end;

   function BuildExpr;
    var Builder:TExprBuilder;
     begin
      Builder:=TExprBuilder.Create;
      try
       Result:=Builder.BuildExpr(Expr)
      finally
       Builder.Free
      end
     end;

 end.
