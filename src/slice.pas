unit slice;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  TSliceItem = class
    Next: TSliceItem;
    Prev: TSliceItem;
    Data: Pointer;
    private
      FNextHead: TSliceItem;
      FPrevHead: TSliceItem;
      function FGetNextHead: TSliceItem;
      procedure FSetNextHead(Head: TSliceItem);
      function FGetPrevHead: TSliceItem;
      procedure FSetPrevHead(Head: TSliceItem);
    public
      constructor Create(AData: Pointer; APrev: TSliceItem);
      constructor Create(From: TSliceItem; APrev: TSliceItem);
      destructor Destroy; virtual;
      procedure SetNextHead(Head: TSliceItem);
      procedure SetPrevHead(Head: TSliceItem);
      procedure ShiftNextHead;
      property NextHead: TSliceItem read FGetNextHead write FSetNextHead;
      property PrevHead: TSliceItem read FGetPrevHead write FSetPrevHead;
  end;

  TSlice = class
    Head: TSliceItem;
    Tail: TSliceItem;
    PageSize: Word;
    Size: LongWord;

    constructor Create;
    constructor Create(AHead: TSliceItem; APageSize: Word; ASize: LongWord = 0);
    destructor Destroy; virtual;
    function Insert(Data: Pointer): TSliceItem;
    procedure Remove(Point: TSliceItem; FreeContent: Boolean = False);
    function Slice(Start, Length: LongWord): TSlice;
  end;

implementation

// TSliceItem

constructor TSliceItem.Create(AData: Pointer; APrev: TSliceItem);
begin
  inherited Create;
  Data := AData;
  Prev := APrev;
  if Assigned(APrev) then begin
    APrev.Next := Self;
    if Assigned(APrev.PrevHead) then
      PrevHead := APrev.PrevHead.Next;
  end;
end;

constructor TSliceItem.Create(From: TSliceItem; APrev: TSliceItem);
begin
  Create(From.Data, APrev);
end;

destructor TSliceItem.Destroy;
begin
  inherited Destroy;
end;

function TSliceItem.FGetNextHead: TSliceItem;
begin
  Result := FNextHead;
end;

function TSliceItem.FGetPrevHead: TSliceItem;
begin
  Result := FPrevHead;
end;

procedure TSliceItem.FSetNextHead(Head: TSliceItem);
begin
  FNextHead := Head;
  if Assigned(Head) then
    Head.SetPrevHead(Self);
end;

procedure TSliceItem.FSetPrevHead(Head: TSliceItem);
begin
  FPrevHead := Head;
  if Assigned(Head) then
    Head.SetNextHead(Self);
end;

procedure TSliceItem.SetNextHead(Head: TSliceItem);
begin
  FNextHead := Head;;
end;

procedure TSliceItem.SetPrevHead(Head: TSliceItem);
begin
  FPrevHead := Head;
end;

procedure TSliceItem.ShiftNextHead;
begin
  if Assigned(NextHead) then
    NextHead := NextHead.Next;
end;

// TSlice

constructor TSlice.Create;
begin
  inherited Create;
  Size := 0;
  Head := nil;
  Tail := nil;
end;

constructor TSlice.Create(AHead: TSliceItem; APageSize: Word; ASize: LongWord);
var
  i: LongWord;
  point: TSliceItem;
  prevHead: TSliceItem;
begin
  inherited Create;
  Head := AHead;
  PageSize := APageSize;

  point := TSliceItem.Create(AHead, nil);
  prevHead := AHead;
  i := 0;
  while (Assigned(point) and Assigned(point.Next)) do begin
    point := TSliceItem.Create(point.Next, point);
    i += 1;
    if (i = PageSize + 1) and (PageSize > 0) then
      point.PrevHead := Head;
    if (ASize > 0) and (i = ASize - 1) then begin
      point.Next := nil;
      point.NextHead := nil;
      Break;
    end;
  end;
  if Assigned(point) then
    i += 1;

  Size := i;
  Tail := point;
end;

destructor TSlice.Destroy;
var
  point: TSliceItem;
begin
  point := Head;
  while Assigned(point) and Assigned(point.Next) do begin
    point := point.Next;
    if Assigned(point) then
      Remove(point.Prev);
  end;
  Remove(point);
end;

function TSlice.Insert(Data: Pointer): TSliceItem;
begin
  Result := TSliceItem.Create(Data, Tail);
  if Size = 0 then
    Head := Result;
  Tail := Result;

  if (Size = PageSize) and (PageSize > 0) then
    Result.PrevHead := Head;

  Size += 1;
end;

procedure TSlice.Remove(Point: TSliceItem; FreeContent: Boolean);
var
  p: TSliceItem;
begin
  if not Assigned(Point) then
    Exit;
  if FreeContent and Assigned(Point.Data) then
    FreeMem(Point.Data);

  p := Point.PrevHead;
  while Assigned(p) do begin
    p.ShiftNextHead;
    p := p.Next;
  end;

  if Assigned(Point.Next) then
    Point.Next.Prev := Point.Prev;
  if Assigned(Point.Prev) then
    Point.Prev.Next := Point.Next;
  Point.Free;
end;

function TSlice.Slice(Start, Length: LongWord): TSlice;
var
  i: LongWord;
  point: TSliceItem;
begin
  point := Head;
  if Start > 0 then begin
    i := 0;
    while Assigned(point) do begin
      point := point.Next;
      i += 1;
      if i = Start then
        Break;
    end;
  end;
  Result := TSlice.Create(point, PageSize, Length);
end;

end.

