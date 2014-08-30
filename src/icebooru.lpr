
{           -=< icebooru >=-            }
{ Yet another xbooru-like image gallery }
{         Written by icefairy64         }

program icebooru;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Classes, generaltypes, messenger, postmanager, slice, SysUtils, DateUtils;

const
  MULT = 1000;
  DELS_MULT = 10000;

var
  test: TSlice;
  i: LongWord;
  start: TDateTime;
  point: TSliceItem;

function ObjToInt(Obj: TObject): LongWord;
begin
  if Assigned(Obj) then
    Result := LongWord(Pointer(Obj))
  else
    Result := 0;
end;

begin
  Randomize;

  test := TSlice.Create;
  test.PageSize := 5;
  start := Now;
  for i := 1 to MULT * 1000 do begin
    test.Insert(nil);
    //WriteLn(Format('%d: HEAD %.16x NEXTHEAD %.16x TAIL %.16x PREVHEAD %.16x', [i, ObjToInt(test.Head), ObjToInt(test.Head.NextHead), ObjToInt(test.Tail), ObjToInt(test.Tail.PrevHead)]));
  end;
  WriteLn(Format('%dk insertions, ms: %d', [MULT, MilliSecondsBetween(Now, start)]));

  start := Now;
  point := test.Head;
  i := 0;
  while Assigned(point) do begin
    point := point.Next;
    if i mod DELS_MULT = 42 then begin
      //WriteLn(Format('Deletion #%d at %dms', [i div MULT, MilliSecondsBetween(Now, start)]));
      point := point.Next;
      if Assigned(point) then
        test.Remove(point.Prev);
    end;
    i += 1;
  end;
  WriteLn(Format('%d deletions, ms: %d', [MULT * 1000 div DELS_MULT, MilliSecondsBetween(Now, start)]));

  start := Now;
  point := test.Head;
  i := 0;
  while Assigned(point) do begin
    point := point.Next;
    if (i > 0) and (i - 1 < MULT * 1000 div DELS_MULT) then begin
      //WriteLn(Format('Deletion #%d at %dms', [i div MULT, MilliSecondsBetween(Now, start)]));
      point := point.Next;
      if Assigned(point) then
        test.Remove(point.Prev);
    end;
    i += 1;
  end;
  WriteLn(Format('%d deletions from head, ms: %d', [MULT * 1000 div DELS_MULT, MilliSecondsBetween(Now, start)]));

  start := Now;
  point := test.Head;
  i := 0;
  while Assigned(point) do begin
    point := point.Next;
    if DELS_MULT * 1000 - i < MULT * 1000 div DELS_MULT then begin
      //WriteLn(Format('Deletion #%d at %dms', [i div MULT, MilliSecondsBetween(Now, start)]));
      point := point.Next;
      if Assigned(point) then
        test.Remove(point.Prev);
    end;
    i += 1;
  end;
  WriteLn(Format('%d deletions from tail, ms: %d', [MULT * 1000 div DELS_MULT, MilliSecondsBetween(Now, start)]));

  start := Now;
  point := test.Head;
  i := 0;
  while Assigned(point) do begin
    point := point.Next;
    if Abs(MULT * 500 - i) < MULT * 500 div DELS_MULT then begin
      //WriteLn(Format('Deletion #%d at %dms', [i div MULT, MilliSecondsBetween(Now, start)]));
      point := point.Next;
      if Assigned(point) then
        test.Remove(point.Prev);
    end;
    i += 1;
  end;
  WriteLn(Format('%d deletions from mid, ms: %d', [MULT * 1000 div DELS_MULT, MilliSecondsBetween(Now, start)]));
end.

