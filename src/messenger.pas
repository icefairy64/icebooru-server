unit messenger;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, contnrs;

type
  IMsgNode = interface
    procedure ReceiveMsg(Sender: IMsgNode; Head: Word; Data: Pointer);
  end;

  PMessage = ^TMessage;
  TMessage = record
    Sender: IMsgNode;
    Receiver: IMsgNode;
    Head: Word;
    Data: Pointer;
  end;

  TMessenger = class
    Messages: TQueue;
    constructor Create;
    destructor Destroy; virtual;
    procedure Send(Sender, Receiver: IMsgNode; Head: Word; Data: Pointer);
    procedure Process;
  end;

var
  GlobalMessenger: TMessenger;

procedure InitMessenger;
procedure Send(Sender, Receiver: IMsgNode; Head: Word; Data: Pointer);

implementation

// Helpers

procedure InitMessenger;
begin
  GlobalMessenger := TMessenger.Create;
end;

procedure Send(Sender, Receiver: IMsgNode; Head: Word; Data: Pointer);
begin
  if Assigned(GlobalMessenger) then
    GlobalMessenger.Send(Sender, Receiver, Head, Data);
end;

// TMessenger

constructor TMessenger.Create;
begin
  Messages := TQueue.Create;
end;

destructor TMessenger.Destroy;
begin
  Messages.Free;
  inherited Destroy;
end;

procedure TMessenger.Send(Sender, Receiver: IMsgNode; Head: Word; Data: Pointer);
var
  Msg: PMessage;
begin
  Msg := GetMem(SizeOf(TMessage));
  Msg^.Sender := Sender;
  Msg^.Receiver := Receiver;
  Msg^.Head := Head;
  Msg^.Data := Data;
  Messages.Push(Msg);
end;

procedure TMessenger.Process;
var
  Msg: PMessage;
begin
  Msg := Messages.Pop;
  while Assigned(Msg) do begin
    with Msg^ do
      Receiver.ReceiveMsg(Sender, Head, Data);
    FreeMem(Msg);
    Msg := Messages.Pop;
  end;
end;

end.

