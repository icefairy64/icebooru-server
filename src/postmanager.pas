unit postmanager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, generaltypes, messenger, contnrs;

type


  TPostManager = class
    PostList: TFPHashList;
    TaggedList: TFPHashObjectList;
  end;

implementation

end.

