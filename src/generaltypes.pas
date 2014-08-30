unit generaltypes;

{$mode objfpc}{$H+}

interface

uses
  Classes, Sysutils;

type
  PTag = ^TTag;
  PUser = ^TUser;
  PPost = ^TPost;

  TTag = record
    ID: LongWord;
    Name: String;
  end;

  TUser = record
    ID: LongWord;
    Name: String;
    Score: LongInt;
    Favs: array of PPost;
  end;

  TPost = record
    ID: LongWord;
    Title: String;
    Tags: array of PTag;
    ThumbURL: String;
    ThumbFile: String;
    SrcURL: String;
    SrcFile: String;
    Uploader: PUser;
    Module: String;
    Approved: Boolean;
    Favs: LongWord;
    Score: LongInt;
    Width: LongWord;
    Height: LongWord;
    ThumbScale: Double;
  end;

implementation

end.

